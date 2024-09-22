version = ChupaTextHttpServer::Version::STRING

desc "Tag #{version}"
task :tag do
  sh("git", "tag",
     "-a", version,
     "-m", "#{version} has been released!!!")
  sh("git", "push", "--tags")
end

desc "Release #{version}"
task release: :tag
