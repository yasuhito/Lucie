# this plugin will delete builds that are no longer wanted, configure it by setting
#
# BuildReaper.number_of_builds_to_keep = 20
# 
# in site_config.rb
#


class BuildReaper
  cattr_accessor :number_of_builds_to_keep


  def initialize installer
    @installer = installer
  end


  def build_finished build
    delete_all_builds_but BuildReaper.number_of_builds_to_keep
  end
  

  ###############################################################################
  private
  ###############################################################################


  def delete_all_builds_but number
    @installer.builds[ 0..-( number + 1 ) ].each do | each |
      each.destroy
    end
  end
end


unless BuildReaper.number_of_builds_to_keep.nil?
  Installer.plugin :build_reaper
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
