require File.dirname(__FILE__) + '/../spec_helper'


describe Revision, ' (empty)' do
  before( :each ) do
    @revision = Revision.new
  end


  it 'should not be converted to String' do
    lambda {
      @revision.to_s
    }.should raise_error( NoMethodError )
  end


  it 'should have empty revision number' do
    @revision.number.should be_nil
  end


  it 'should have empty committer name' do
    @revision.committed_by.should be_nil
  end


  it 'should have empty commit timestamp' do
    @revision.time.should be_nil
  end


  it 'should have empty commit message' do
    @revision.message.should be_nil
  end


  it 'should have empty changeset' do
    @revision.changeset.should be_nil
  end
end


describe Revision, 'when initialized with properties' do
  before( :each ) do
    @revision = Revision.new( 1, 'COMMITTER', Time.now, 'MESSAGE', [ 'CHANGESET' ] )
  end


  it 'should be converted to human readable String' do
    @revision.to_s.should match( /\ARevision 1 committed by COMMITTER on.+/ )
  end


  it 'should have revision number' do
    @revision.number.should equal( 1 )
  end


  it 'should have committer name' do
    @revision.committed_by.should eql( 'COMMITTER' )
  end


  it 'should have commit timestamp' do
    @revision.time.should be_an_instance_of( Time )
  end


  it 'should have commit message' do
    @revision.message.should eql( 'MESSAGE' )
  end


  it 'should have changeset' do
    @revision.changeset.should eql( [ 'CHANGESET' ] )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
