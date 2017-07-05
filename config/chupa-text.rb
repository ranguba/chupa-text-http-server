decomposer.names = ["*"]

Mime::EXTENSION_LOOKUP.each do |extension, mime_type|
  mime_types[extension] = mime_type.to_s
end
