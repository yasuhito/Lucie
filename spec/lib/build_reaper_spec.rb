require File.dirname( __FILE__ ) + '/../spec_helper'


describe BuildReaper do
  after( :each ) do | each |
    BuildReaper.number_of_builds_to_keep = 0
  end


  it "should have an attribute 'number_of_builds_to_keep'" do
    BuildReaper.number_of_builds_to_keep = 100
    BuildReaper.number_of_builds_to_keep.should == 100
  end


  describe 'when number_of_builds_to_keep = 5' do
    before( :each ) do
      @installer = Object.new
      @br = BuildReaper.new( @installer )
      BuildReaper.number_of_builds_to_keep = 5
    end


    it 'should not destroy any builds if number of latest builds is 3' do
      @installer.stubs( :builds ).returns dummy_builds( :size => 3, :ndestroy => 0 )

      lambda do
        @br.build_finished 'DUMMY_BUILD'
      end.should_not raise_error
    end


    it 'should not destroy any builds if number of latest builds is 5' do
      @installer.stubs( :builds ).returns dummy_builds( :size => 5, :ndestroy => 0 )

      lambda do
        @br.build_finished 'DUMMY_BUILD'
      end.should_not raise_error
    end


    it 'should destroy 5 builds if number of latest builds is 10' do
      @installer.stubs( :builds ).returns dummy_builds( :size => 10, :ndestroy => 5 )
      
      lambda do
        @br.build_finished 'DUMMY_BUILD'
      end.should_not raise_error
    end
  end


  def dummy_builds opt
    Array.new( opt[ :size ] ) do | i |
      if i < opt[ :ndestroy ]
        "BUILD_#{ i }_DESTROY"
      else
        "BUILD_#{ i }_KEEP"
      end
    end.collect do | each |
      case each
      when /DESTROY\Z/
        each.expects( :destroy )
      when /KEEP\Z/
        each.expects( :destroy ).never
      else
        raise "This shouldn't happen!"
      end
      each
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
