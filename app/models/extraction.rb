class Extraction
  include ActiveModel::Model

  attr_accessor :input
  validates :input, presence: true

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

    data = ChupaText::VirtualFileData.new(Pathname(@input.original_filename),
                                          @input.to_io)
    formatter = ChupaText::Formatters::Hash.new
    formatter.format_start(data)
    extractor.extract(data) do |extracted|
      formatter.format_extracted(extracted)
    end
    formatter.format_finish(data)
  end
end
