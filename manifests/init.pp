# Class: nginx
#
# This module manages NGINX.
#
# Parameters:
#
# There are no default parameters for this class. All module parameters are managed
# via the nginx::params class
#
# Actions:
#
# Requires:
#  puppetlabs-stdlib - https://github.com/puppetlabs/puppetlabs-stdlib
#
#  stdlib
#    - puppetlabs-stdlib module >= 0.1.6
#    - plugin sync enabled to obtain the anchor type
#
# Sample Usage:
#
# The module works with sensible defaults:
#
# node default {
#   include nginx
# }
class nginx {

  require repo::nginx

  require nginx::params
  
  package{'nginx':
    ensure  => present,
    notify => Class['nginx::service'],
  }  

  class { 'nginx::config':
    require 		=> Package['nginx'],
    notify  		=> Class['nginx::service'],
  }

  include nginx::service
}
