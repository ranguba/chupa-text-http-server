require "chupa_text_http_server/version"

desc "Tag #{ChupaTextHttpServer::VERSION}"
task :tag do
  sh("git", "tag",
     "-a", ChupaTextHttpServer::VERSION,
     "-m", "#{ChupaTextHttpServer::VERSION} has been released!!!")
  sh("git", "push", "--tags")
end

desc "Release #{ChupaTextHttpServer::VERSION}"
task release: :tag
