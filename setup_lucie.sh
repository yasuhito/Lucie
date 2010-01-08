#!/bin/sh
#
# This script installs prerequisite packages for Lucie.
# Run with
#  % sudo ./setup_lucie.sh
#

aptitude install subversion ruby rubygems facter rake syslinux debootstrap tftpd-hpa nfs-kernel-server dhcp3-server approx mercurial ssh libhighline-ruby telnet
