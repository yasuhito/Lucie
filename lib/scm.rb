require "scm/common"
require "scm/git"
require "scm/mercurial"
require "scm/subversion"


module Scm
  def from scm, options = {}
    raise "scm is not specified" unless scm
    case scm.to_s.downcase
    when "mercurial"
      Mercurial.new options
    when "subversion"
      Subversion.new options
    when "git"
      Git.new options
    else
      raise "#{ scm } is not supported"
    end
  end
  module_function :from
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
