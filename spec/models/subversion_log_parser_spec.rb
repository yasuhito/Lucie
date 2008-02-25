require File.dirname( __FILE__ ) + '/../spec_helper'


describe SubversionLogParser do
  it 'should parse log with no optional values' do
    expected = [ Revision.new( 359, nil, nil, nil, [] ) ]

    parse_log( "<log><logentry revision='359'/></log>" ).should == expected
  end


  it 'should parse simple log entry' do
    expected = [ Revision.new( 359, 'aslak', DateTime.parse( '2006-05-22T13:23:29.000005Z' ), 'versioning', [ ChangesetEntry.new( 'A', '/trunk/foo.txt' ) ] ) ]
    actual = parse_log( simple_log_entry )

    actual.should == expected
    actual.to_s.should == "Revision 359 committed by aslak on 2006-05-22 13:23:29\nversioning\n  A /trunk/foo.txt\n" # this is fixing a bug
  end


  it 'should parse log with no message' do
    expected = [ Revision.new( 1, nil, nil, nil, [] ) ]
    actual = parse_log( log_with_no_message )

    actual.should == expected
    actual.to_s.should == "Revision 1 committed by  on \n\n\n" # this is fixing a bug
  end


  it 'should parse log entry with anonymous author' do
    expected = [ Revision.new( 127, '(no author)', DateTime.parse( '2006-05-22T13:23:29.000005Z' ), 'categories added', [ ChangesetEntry.new( 'A', '/trunk/foo.txt' ) ] ) ]

    assert_equal expected, parse_log( log_entry_with_anonymous_author )
  end


  it 'should parse log entry with multiple entries' do
    expected = [
      Revision.new( 359, 'aslak', DateTime.parse( '2006-05-22T13:23:29.000005Z' ), 'versioning', [ ChangesetEntry.new( 'A', '/trunk/foo.txt' ), ChangesetEntry.new( 'D', '/trunk/bar.exe' ) ] ),
      Revision.new( 358, 'joe', DateTime.parse( '2006-05-22T13:20:05.471105Z' ), "Added Rakefile for packaging of svn ruby bindings (swig) in prebuilt gems for different platforms", [ ChangesetEntry.new( 'A', '/trunk/bar.exe' ) ] )
    ]

    parse_log( log_entry_with_multiple_entries ).should == expected
  end


  it 'should parse update output' do
    expected = [
      ChangesetEntry.new( 'A  ', 'failing_project' ),
      ChangesetEntry.new( 'D  ', 'failing_project\Rakefile' ),
      ChangesetEntry.new( 'U* ', 'failing_project\\failing_test.rb' ),
      ChangesetEntry.new( 'G  ', 'failing_project\\revision_label.txt' ),
      ChangesetEntry.new( 'C B', 'passing_project\\revision_label.txt' ),
      ChangesetEntry.new( '?  ', 'foo.txt' )
    ]

    parse_update( update_output ).should == expected
  end


  it 'should parse empty line' do
    SubversionLogParser.new.parse_log( [] ).should == []
  end


  def parse_log log_entry
    SubversionLogParser.new.parse_log( log_entry.split( "\n" ) )
  end


  def parse_update log_entry
    SubversionLogParser.new.parse_update( log_entry.split( "\n" ) )
  end


  def simple_log_entry
    <<-EOF
<?xml version="1.0"?>
<log>
<logentry revision="359">
  <author>aslak</author>
  <date>2006-05-22T13:23:29.000005Z</date>
  <paths>
    <path action="A">/trunk/foo.txt</path>
  </paths>
  <msg>versioning</msg>
</logentry>
</log>
EOF
  end


  def log_with_no_message
    <<-EOF
<log>
<logentry revision="1">
  <msg></msg>
</logentry>
</log>
EOF
  end


  def log_entry_with_anonymous_author
    <<-EOF
<log>
<logentry revision="127">
  <author>(no author)</author>
  <date>2006-05-22T13:23:29.000005Z</date>
  <paths>
    <path action="A">/trunk/foo.txt</path>
  </paths>
  <msg>categories added</msg>
</logentry>
</log>
EOF
  end


  def log_entry_with_multiple_entries
    <<-EOF
<log>
<logentry revision="359">
  <author>aslak</author>
  <date>2006-05-22T13:23:29.000005Z</date>
  <paths>
    <path action="A">/trunk/foo.txt</path>
    <path action="D">/trunk/bar.exe</path>
  </paths>
  <msg>versioning</msg>
</logentry>
<logentry revision="358">
  <author>joe</author>
  <date>2006-05-22T13:20:05.471105Z</date>
  <paths>
    <path action="A">/trunk/bar.exe</path>
  </paths>
  <msg>Added Rakefile for packaging of svn ruby bindings (swig) in prebuilt gems for different platforms</msg>
</logentry>
</log>
EOF
  end


  def update_output
    <<-EOF
A    failing_project
D    failing_project\\Rakefile
U*   failing_project\\failing_test.rb
G    failing_project\\revision_label.txt
C B  passing_project\\revision_label.txt
?    foo.txt

Fetching external item into 'vendor\rails'
Updated external to revision 5875.

Updated to revision 46.
EOF
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
