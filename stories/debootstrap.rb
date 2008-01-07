require 'stories/helper'


Story 'Determine debootstrap version',
%(As a installer:nfsroot_base task,
  I want to know debootstrap version
  So that I can log debootstrap version when creating base.tgz) do

  Scenario 'get debootstrap version' do
    Then 'I can get debootstrap version with Debootstrap.VERSION' do
      Debootstrap.VERSION.should_not be_empty
    end
  end
end


Story 'Use Debootstrap class',
%(As a nfsroot related task,
  I want to use debootstrap class
  So that I can create a base Linux disk image) do


  Scenario 'debootstrap success if all options are valid' do
    Given 'lucied is started' do
      restart_lucied
    end

    Given 'LC_ALL = $lc_all and http_proxy = $http_proxy', 'C', 'http://proxy.spf.cl.nec.co.jp:3128' do | lc_all, http_proxy |
      @option = Debootstrap::DebootstrapOption.new
      @option.env = { 'LC_ALL' => lc_all, 'http_proxy' => http_proxy }
    end

    Given 'excluded packages are', [ 'ppp' ] do | package_list |
      @option.exclude = package_list
    end

    Given 'included packages are', [ 'lv' ] do | package_list |
      @option.include = package_list
    end

    Given 'package mirror is', 'http://ring.asahi-net.or.jp/archives/linux/debian/debian/' do | mirror |
      @option.mirror = mirror
    end

    Given 'suite is', 'etch' do | suite |
      @option.suite = suite
    end

    Given 'target directory is', '/tmp/debootstrap' do | target |
      @option.target = '/tmp/debootstrap'
    end

    When 'I run debootstrap' do
      DRb.start_service
      @lucie_daemon = DRbObject.new_with_uri( LucieDaemon.uri )
      @result = @lucie_daemon.debootstrap( @option )
    end

    Then 'debootstrap successfully exit' do
      @result.child_status.exitstatus.should == 0
    end
  end
end
