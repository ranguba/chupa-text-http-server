class Extraction
  include ActiveModel::Model

  attr_accessor :data
  attr_accessor :uri
  attr_accessor :timeout
  attr_accessor :limit_cpu
  attr_accessor :limit_as
  attr_writer :max_body_size
  attr_writer :need_screenshot

  validates :data, presence: true, if: ->(record) {record.uri.blank?}
  validates :max_body_size,
            numericality: {only_integer: true},
            allow_nil: true

  class << self
    def extractor
      @extractor ||= build_extractor
    end

    private
    def build_extractor
      extractor = ChupaText::Extractor.new
      configuration = ChupaText::Configuration.new
      configuration_loader = ChupaText::ConfigurationLoader.new(configuration)
      configuration_loader.load(Rails.root + "config" + "chupa-text.rb")
      extractor.apply_configuration(configuration)
      extractor
    end
  end

  def initialize(attributes={})
    @data = nil
    @uri = nil
    @timeout = nil
    @limit_cpu = nil
    @limit_as = nil
    @max_body_size = nil
    @need_screenshot = nil
    super
  end

  def persisted?
    false
  end

  def id
    nil
  end

  def max_body_size
    if @max_body_size.is_a?(Numeric)
      @max_body_size
    elsif @max_body_size.blank?
      nil
    else
      Integer(@max_body_size, 10)
    end
  end

  def need_screenshot?
    case @need_screenshot
    when "false", false
      false
    else
      true
    end
  end

  def extract
    return nil unless valid?

    extractor = self.class.extractor
    create_data do |data|
      formatter = ChupaText::Formatters::Hash.new
      formatter.format_start(data)
      max = data.max_body_size
      size = 0
      begin
        extractor.extract(data) do |extracted|
          formatter.format_extracted(extracted)
          body = extracted.body
          extracted.release
          if max and body
            size += body.bytesize
            break if size >= max
          end
        end
      rescue ChupaText::Error => error
        errors.add(:data, :invalid, message: error.message)
        return nil
      end
      formatter.format_finish(data)
    end
  end

  private
  def create_data
    data = nil
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
    begin
      setup_data(data)
      yield(data)
    ensure
      data.release
    end
  end

  def setup_data(data)
    data.max_body_size = max_body_size
    data.timeout = @timeout
    data.limit_cpu = @limit_cpu
    data.limit_as = @limit_as
    data.need_screenshot = need_screenshot?
  end
end
