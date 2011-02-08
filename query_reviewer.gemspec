Gem::Specification.new do |s|
  s.name = 'query_reviewer'
  s.version = '0.1'
  s.author = 'dsboulder'
  s.email = 'tech' + '@' + 'weplay.com'
  s.homepage = 'https://github.com/weplay/query_reviewer'
  s.summary = 'Runs explain before each select query and displays results in an overlayed div'
  s.description = s.summary
  s.files = %w[MIT-LICENSE Rakefile README query_reviewer_defaults.yml] + Dir["lib/**/*"]
end