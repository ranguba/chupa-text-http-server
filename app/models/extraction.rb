class Extraction
  include ActiveModel::Model

  attr_accessor :data
  attr_accessor :uri

  validates :data, presence: true, if: ->(record) {record.uri.blank?}

  def persisted?
    false
  end

  def id
    nil
  end

  def extract
    return nil unless valid?

    extractor = ChupaText::Extractor.new
    configuration = ChupaText::Configuration.new
    configuration_loader = ChupaText::ConfigurationLoader.new(configuration)
    configuration_loader.load(Rails.root + "config" + "chupa-text.rb")
    extractor.apply_configuration(configuration)

    if @data
      data_uri = @uri
      data_uri = nil if data_uri.blank?
      if data_uri.nil? and @data.original_filename
        data_uri = Pathname(@data.original_filename)
      end
      data = ChupaText::VirtualFileData.new(data_uri, @data.to_io)
      data.mime_type = @data.content_type if @data.content_type
    else
      begin
        data = ChupaText::InputData.new(@uri)
      rescue ChupaText::DownloadError => error
        errors.add(:uri, :invalid, message: error.message)
        return nil
      rescue => error
        errors.add(:uri, :invalid, message: "#{error.class}: #{error.message}")
        return nil
      end
    end
    formatter = ChupaText::Formatters::Hash.new
    formatter.format_start(data)
    begin
      extractor.extract(data) do |extracted|
        formatter.format_extracted(extracted)
      end
    rescue ChupaText::Error => error
      errors.add(:data, :invalid, message: error.message)
      return nil
    end
    formatter.format_finish(data)
  end
end
