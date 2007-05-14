require 'ftools'
require 'fileutils'
require 'test/unit/assertions'

module FileSandbox
  VERSION = "0.2"
  def in_sandbox(&block)
    raise "I expected to create a sandbox as you passed in a block to me" if !block_given?

    setup_sandbox
    original_error = nil

    begin
      Dir.chdir(@sandbox.root) do
        yield @sandbox
      end
    rescue => e
      original_error = e
      raise
    ensure
      begin
        teardown_sandbox
      rescue
        if original_error
          STDERR.puts "ALERT: a test raised an error and failed to release some lock(s) in the sandbox directory"
          raise(original_error)
        else
          raise
        end
      end
    end
  end

  def setup_sandbox(path = '__sandbox')
    @sandbox = Sandbox.new(path)
  end

  def teardown_sandbox
    if @sandbox
      @sandbox.clean_up
      @sandbox = nil
    end
  end

  def file(name)
    SandboxFile.new(File.join(@sandbox.root, name))
  end

  class Sandbox
    include Test::Unit::Assertions
    attr_reader :root

    def initialize(path = '__sandbox')
      @root = File.expand_path(path)
      clean_up
      FileUtils.mkdir_p @root
    end

    # usage new :file=>'my file.rb', :with_contents=>'some stuff'
    def new(options)
      name = File.join(@root, options.delete(:file))
      dir = File.dirname(name)
      FileUtils.mkdir_p dir

      if (binary_content = options.delete(:with_binary_content) || options.delete(:with_binary_contents))
        File.open(name, "wb") {|f| f << binary_content }
      else
        File.open(name, "w") {|f| f << (options.delete(:with_content) || options.delete(:with_contents) || '')}
      end
      
      raise "unexpected keys '#{options.keys.join(', ')}'" unless options.empty?
    end
    
    def remove(options)
      name = File.join(@root, options[:file])
      FileUtils.remove_file name
    end
    
    # usage assert :file=>'my file.rb', :has_contents=>'some stuff'
    def assert(options)
      name = File.join(@root, options[:file])
      if (expected_content = options[:has_content] || options[:has_contents])
        assert_equal(expected_content, File.read(name))
      else
        fail('expected something to assert')
      end
    end

    def clean_up
      FileUtils.rm_rf @root
      if File.exists? @root
        raise "Could not remove directory #{@root.inspect}, something is probably still holding a lock on it"
      end
    end
  end

  class SandboxFile
    attr_reader :name
    
    def initialize(name)
      @name = name
    end

    def exist?
      File.exist? name
    end

    alias exists? exist?

    def content
      File.read name
    end

    alias contents content
  end
end