module ExtractionsHelper
  def format_screenshot(screenshot)
    return "" if screenshot.nil?

    data = screenshot["data"]
    mime_type = screenshot["mime-type"]
    encoding = screenshot["encoding"]
    src = "data:#{mime_type}"
    if encoding
      src << ";#{encoding}"
      src << ","
      src << data
    else
      src << ";base64,"
      src << [data].pack("m*")
    end
    tag.img(src: src)
  end
end
