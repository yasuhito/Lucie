require File.dirname( __FILE__ ) + '/../spec_helper'


describe ChangesetEntry do
  before(:each) do
    @changeset_entry = ChangesetEntry.new( 'OPERATION', 'FILE' )
  end


  it 'should be converted to text' do
    @changeset_entry.to_s.should == "  OPERATION FILE"
  end
end
