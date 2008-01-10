require 'stories/helper'


Story 'install packages',
%(As a Lucie installer,
  I want to execute install_packages
  So that I can install packages) do


  Scenario 'read help message' do
    When 'I run', 'ruby -Ilib ./script/install_packages --help' do | command |
      @stdout, @stderr = output_with( command )
    end

    expected_help_message = <<-EOF
install_packages 0.1.0

Options:
  -c, --config-file=[FILE]     specify a configuration file to use.
  -D, --debug                  displays lots on internal stuff.
  -d, --dry-run                no action.
  -h, --help                   you're looking at it.
  -v, --version                display install_packages's version and exit.
  -p, --http-proxy=[URL]       specify a http proxy url.
EOF

    Then 'the output to stderr should be empty' do
      STDERR.puts @stderr unless @stderr.empty?
      @stderr.should be_empty
    end

    Then 'the output should look like', expected_help_message do | message |
      @stdout.split.should == message.strip.split( /\s+/ )
    end
  end


  Scenario 'show version number' do
    When 'I run', 'ruby -Ilib ./script/install_packages --version'
    Then 'the output should look like', 'install_packages 0.1.0'
  end


  Scenario 'run install_packages' do
    Given 'config file path is', '/tmp/packages.rb' do | config |
      @config_path = config
    end

    Given 'its content is', packages_config do | config |
      File.open( @config_path, 'w' ) do | file |
        file.puts config
      end
    end

    When 'I run', "ruby -Ilib ./script/install_packages --config-file=#{ @config_path } --dry-run"

    expected_output = <<-EOF
ENV{ 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'chroot /tmp/target aptitude -R -y -o Dpkg::Options="--force-confdef" -o Dpkg::Options="--force-confold" install emacs vi'
ENV{ 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'chroot /tmp/target apt-get clean'
ENV{ 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'chroot /tmp/target aptitude -r -y -o Dpkg::Options="--force-confdef" -o Dpkg::Options="--force-confold" install emacs vi'
ENV{ 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'chroot /tmp/target apt-get clean'
ENV{ 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'chroot /tmp/target apt-get -y -o Dpkg::Options="--force-confdef" -o Dpkg::Options="--force-confold" --fix-missing install linux-image-2.6-686 lv'
ENV{ 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'chroot /tmp/target apt-get clean'
ENV{ 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'chroot /tmp/target apt-get -y -o Dpkg::Options="--force-confdef" -o Dpkg::Options="--force-confold" --purge remove ppp man'
ENV{ 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'chroot /tmp/target apt-get clean'
EOF

    Then 'the output to stderr should be empty'
    Then 'the output should look like', expected_output
  end


  Scenario 'run install_packages with --http-proxy option' do
    Given 'config file path is', '/tmp/packages.rb' do | config |
      @config_path = config
    end

    Given 'its content is', packages_config do | config |
      File.open( @config_path, 'w' ) do | file |
        file.puts config
      end
    end

    When 'I run', "ruby -Ilib ./script/install_packages --config-file=#{ @config_path } --dry-run --http-proxy=http://PROXY:3128/"

    expected_output = <<-EOF
ENV{ 'http_proxy' => 'http://PROXY:3128/', 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'chroot /tmp/target aptitude -R -y -o Dpkg::Options="--force-confdef" -o Dpkg::Options="--force-confold" install emacs vi'
ENV{ 'http_proxy' => 'http://PROXY:3128/', 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'chroot /tmp/target apt-get clean'
ENV{ 'http_proxy' => 'http://PROXY:3128/', 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'chroot /tmp/target aptitude -r -y -o Dpkg::Options="--force-confdef" -o Dpkg::Options="--force-confold" install emacs vi'
ENV{ 'http_proxy' => 'http://PROXY:3128/', 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'chroot /tmp/target apt-get clean'
ENV{ 'http_proxy' => 'http://PROXY:3128/', 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'chroot /tmp/target apt-get -y -o Dpkg::Options="--force-confdef" -o Dpkg::Options="--force-confold" --fix-missing install linux-image-2.6-686 lv'
ENV{ 'http_proxy' => 'http://PROXY:3128/', 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'chroot /tmp/target apt-get clean'
ENV{ 'http_proxy' => 'http://PROXY:3128/', 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'chroot /tmp/target apt-get -y -o Dpkg::Options="--force-confdef" -o Dpkg::Options="--force-confold" --purge remove ppp man'
ENV{ 'http_proxy' => 'http://PROXY:3128/', 'DEBIAN_FRONTEND' => 'noninteractive', 'LC_ALL' => 'C' }, 'chroot /tmp/target apt-get clean'
EOF

    Then 'the output to stderr should be empty'
    Then 'the output should look like', expected_output
  end


  def packages_config
    %(
aptitude 'emacs', 'vi'
aptitude_r 'emacs', 'vi'
aptget_install 'linux-image-2.6-686', 'lv'
aptget_remove 'ppp', 'man'
aptget_clean
)
  end
end
