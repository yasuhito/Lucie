require 'lib/lucie/version'
require 'rake/gempackagetask'


gem_spec = Gem::Specification.new do | spec |
  spec.name = 'lucie'
  spec.version = Lucie::VERSION::STRING
  spec.summary = 'Lucie automatic cluster installer'
  spec.author = 'Yasuhito TAKAMIYA'
  spec.email = 'yasuhito@gmail.com'
  spec.homepage = 'http://lucie.is.titech.ac.jp/'
  spec.files = FileList[ 'installer', 'lucie', 'node', 'COPYING', 'Changes.rdoc', 'README', 'Rakefile', 'installers', 'nodes', 'log', 'app/**/*', 'builder_plugins/**/*', 'config/**/*', 'kernels/**/*', 'lib/**/*', 'public/**/*', 'script/**/*', 'tasks/**/*', 'test/**/*', 'vendor/**/*' ]
  spec.has_rdoc = true
end


Rake::GemPackageTask.new( gem_spec ) do | package |
  package.need_zip = true
  package.need_tar = true
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
