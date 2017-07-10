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
    else
      data = ChupaText::InputData.new(@uri)
    end
    formatter = ChupaText::Formatters::Hash.new
    formatter.format_start(data)
    extractor.extract(data) do |extracted|
      formatter.format_extracted(extracted)
    end
    formatter.format_finish(data)
  end
end
