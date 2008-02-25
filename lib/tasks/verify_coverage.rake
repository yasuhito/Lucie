require 'rake'
require "#{ RAILS_ROOT }/vendor/plugins/rspec/lib/spec/rake/verify_rcov"


# Coverage threshold
RCov::VerifyTask.new( :verify_rcov => :spec ) do | t |
  t.threshold = 100.0
  t.index_html = "#{ RAILS_ROOT }/coverage/index.html"
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
