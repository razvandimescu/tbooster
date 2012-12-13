Gem::Specification.new do |s|
  s.name        = "tbooster"
  s.version     = "0.2.0"
  s.date        = "2012-12-07"
  s.summary     = "Test booster"
  s.description = "Runs unit tests faster by not reloading the testing environment every time"
  s.authors     = ["Razvan Dimescu"]
  s.email       = 'ssaricu@gmail.com'
  s.homepage    = 'http://rubygems.org/gems/tbooster'


  s.require_paths = ["lib"]
  s.files         = `git ls-files`.split("\n")
  s.executables << 'tbooster'

  s.add_dependency "listen", ">= 0.6.0"
end
