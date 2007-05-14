#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


class PollingScheduler
  def initialize installer
    @installer = installer
    @custom_polling_interval = nil
    @last_build_loop_error_source = nil
    @last_build_loop_error_time = nil
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
