require File.dirname( __FILE__ ) + '/../spec_helper'


describe ChangesetLogParser do
  it 'should parse log with single revision' do
    expected_result = [ Revision.new( 204.1, 'leonard0', DateTime.parse( '2007-02-12 15:32:55' ), 'Detect when X occurs and trigger Y to happen.', [ ChangesetEntry.new( 'M', '/trunk/app/models/project.rb' ), ChangesetEntry.new( 'M', '/trunk/test/unit/project_test.rb' ) ] ) ]

    ChangesetLogParser.new.parse_log( log_with_single_revision.split( "\n" ) ).should == expected_result
  end


  it 'should parse log with multiple revisions' do
    expected_result = [ Revision.new( 189, 'joepoon', DateTime.parse( '2007-02-11 02:24:27' ), 'Checking in code comment.', [ ChangesetEntry.new( 'A', '/trunk/app/models/build_status.rb' ), ChangesetEntry.new( 'M', '/trunk/test/unit/status_test.rb' ) ] ), Revision.new( 190, 'alexeyv', DateTime.parse( '2007-02-11 15:34:43' ), 'Radical refactoring.', [ ChangesetEntry.new( 'M', '/trunk/app/controllers/projects_controller.rb' ), ChangesetEntry.new( 'M', '/trunk/app/models/projects.rb' ), ChangesetEntry.new( 'M', '/trunk/app/views/projects/index.rhtml' ) ] ) ]

    ChangesetLogParser.new.parse_log( log_with_multiple_revisions.split( "\n" ) ).should == expected_result
  end


  it 'should parse log with no comment' do
    expected_result = [ Revision.new( 204.1, 'leonard0', DateTime.parse( '2007-02-12 15:32:55' ), '', [ ChangesetEntry.new( 'M', '/trunk/app/models/project.rb' ), ChangesetEntry.new( 'M', '/trunk/test/unit/project_test.rb' ) ] ) ]

    ChangesetLogParser.new.parse_log( log_with_no_comment.split( "\n" ) ).should == expected_result
  end


  it 'should parse log with multiple lined comment' do
    expected_result = [ Revision.new( 42, 'ninja', DateTime.parse( '2007-02-12 02:32:55' ), "\nLine one\n\nLine two\n", [ ChangesetEntry.new( 'M', '/trunk/app/foo.rb' ), ChangesetEntry.new( 'M', '/trunk/tests/foo_test.rb' ) ] ) ]

    ChangesetLogParser.new.parse_log( log_with_multiple_lined_comment.split( "\n" ) ).should == expected_result
  end


  it 'should parse malformed changeset' do
    parser = ChangesetLogParser.new
    parser.stubs( :parse_revision ).raises
    parser.stubs( :puts )

    parser.parse_log( [ "malformed changeset" ] ).should be_empty
  end


  def log_with_single_revision
    <<-EOF
Revision 204.1 committed by leonard0 on 2007-02-12 15:32:55
Detect when X occurs and trigger Y to happen.
  M /trunk/app/models/project.rb
  M /trunk/test/unit/project_test.rb
EOF
  end


  def log_with_multiple_revisions
    <<-EOF
Revision 189 committed by joepoon on 2007-02-11 02:24:27
Checking in code comment.
  A /trunk/app/models/build_status.rb
  M /trunk/test/unit/status_test.rb

Revision 190 committed by alexeyv on 2007-02-11 15:34:43
Radical refactoring.
  M /trunk/app/controllers/projects_controller.rb
  M /trunk/app/models/projects.rb
  M /trunk/app/views/projects/index.rhtml
EOF
  end


  def log_with_no_comment
    <<-EOF
Revision 204.1 committed by leonard0 on 2007-02-12 15:32:55

  M /trunk/app/models/project.rb
  M /trunk/test/unit/project_test.rb
EOF
  end


  def log_with_multiple_lined_comment
    <<-EOF
Revision 42 committed by ninja on 2007-02-12 02:32:55

Line one

Line two

  M /trunk/app/foo.rb
  M /trunk/tests/foo_test.rb
EOF
  end
end
