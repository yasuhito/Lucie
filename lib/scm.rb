require "scm/common"
require "scm/git"
require "scm/mercurial"
require "scm/subversion"


class Scm
  # [FIXME] obsolete
  def self.from scm, debug_options = {}
    raise "scm is not specified" unless scm
    return debug_options[ :dummy_scm ] if debug_options[ :dummy_scm ]
    case scm.to_s.downcase
    when "mercurial"
      Mercurial.new debug_options
    when "subversion"
      Subversion.new debug_options
    when "git"
      Git.new debug_options
    when "dummy_scm"
      # [FIXME]
      Mercurial.new debug_options
    else
      raise "#{ scm } is not supported"
    end
  end


  def initialize debug_options = {}
    @debug_options = debug_options
  end


  def named name
    raise "scm is not specified" unless name
    return @debug_options[ :dummy_scm ] if @debug_options[ :dummy_scm ]
    case name.to_s.downcase
    when "mercurial"
      Mercurial.new @debug_options
    when "subversion"
      Subversion.new @debug_options
    when "git"
      Git.new @debug_options
    else
      raise "#{ name } is not supported"
    end
  end


  def from directory
    return named( @debug_options[ :scm ] ) if @debug_options[ :scm ]
    Dir.glob( File.join( directory, ".*" ) ).each do | each |
      name = scm_name[ File.basename( each ) ]
      return named( name ) if name
    end
    nil
  end


  ##############################################################################
  private
  ##############################################################################


  def scm_name
    { ".hg" => "Mercurial",
      ".svn" => "Subversion",
      ".git" => "Git" }
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
