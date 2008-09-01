# This plugin will delete builds that are no longer wanted, configure
# it by setting
#
# BuildReaper.number_of_builds_to_keep = 5
# 
# in config/site_config.rb
#


class BuildReaper
  cattr_accessor :number_of_builds_to_keep


  def initialize installer
    @installer = installer
  end


  def build_finished build
    if BuildReaper.number_of_builds_to_keep
      delete_all_builds_but BuildReaper.number_of_builds_to_keep
    end
  end
  

  ###############################################################################
  private
  ###############################################################################


  def delete_all_builds_but number
    @installer.builds[ 0..-( number + 1 ) ].each do | each |
      Lucie::Log.event "Deleting old build #{ each.label }"
      each.destroy
    end
  end
end


# Set default value
BuildReaper.number_of_builds_to_keep = 10

Installer.plugin :build_reaper


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
