#!/usr/bin/env ruby
#
# $Id: tc_options.rb 1111 2007-03-02 08:12:44Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1111 $
# License::  GPL2


$LOAD_PATH.unshift( '../../lib' ) if __FILE__ =~ /\.rb$/


require 'rubygems'
require 'flexmock'
require 'install-packages/options'
require 'test/unit'


class TC_Options < Test::Unit::TestCase
  include FlexMock::TestCase


  def setup
    @options = InstallPackages::Options.new
  end


  def test_default_options
    assert_nil @options.debug
    assert_nil @options.help
    assert_nil @options.version
    assert_nil @options.dry_run
    assert_nil @options.config_file
  end


  def test_parse_debug
    @options.parse [ '--debug' ]

    assert @options.debug
  end


  def test_parse_help
    flexstub( STDOUT, 'STDOUT_MOCK' ).should_receive( :print )
    flexstub( STDOUT, 'STDOUT_MOCK' ).should_receive( :puts )

    @options.parse [ '--help' ]

    assert @options.help
  end


  def test_parse_version
    flexstub( STDOUT, 'STDOUT_MOCK' ).should_receive( :puts )

    @options.parse [ '--version' ]

    assert @options.version
  end


  def test_parse_dry_run
    @options.parse [ '--dry-run' ]

    assert @options.dry_run
  end


  def test_parse_config_file
    @options.parse [ '--config-file', 'CONFIG_FILE' ]

    assert_equal 'CONFIG_FILE', @options.config_file
  end


  def test_parse_invalid_option
    flexstub( STDERR, 'STDERR_MOCK' ).should_receive( :puts )

    assert_raises( GetoptLong::InvalidOption ) do
      @options.parse [ '--invalid-option' ]
    end
  end


  def test_parse_missing_argument
    flexstub( STDERR, 'STDERR_MOCK' ).should_receive( :puts )

    assert_raises( GetoptLong::MissingArgument ) do
      @options.parse [ '--config-file' ]
    end
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
