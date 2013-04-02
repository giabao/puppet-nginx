# Class: nginx::config
#
# This module manages NGINX bootstrap and configuration
#
# Parameters:
#
# There are no default parameters for this class.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# This class file is not called directly
class nginx::config(
  $worker_processes    = 1,
  $worker_connections  = 1024,
  $use_proxy           = false,
  $proxy_set_header    = $nginx::params::nx_proxy_set_header, #only use if use_proxy
  $confd_purge         = false,
  $daemon_user         = $nginx::params::daemon_user,
  $access_log_off      = false,
  $tcp_nopush          = 'off',
  $client_body_in_single_buffer = 'off',
  $client_body_buffer_size = '128k',
  $client_max_body_size    = '10m',
  $server_tokens       = 'on',
) inherits nginx::params {
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  file { "${nginx::params::nx_conf_dir}":
    ensure => directory,
  }

  file { "${nginx::params::nx_conf_dir}/conf.d":
    ensure => directory,
  }
  if $confd_purge == true {
    File["${nginx::params::nx_conf_dir}/conf.d"] {
      ignore => "vhost_autogen.conf",
      purge => true,
      recurse => true,
    }
  }


  file { "${nginx::config::nx_run_dir}":
    ensure => directory,
  }

  file { "${nginx::config::nx_client_body_temp_path}":
    ensure => directory,
    owner  => $daemon_user,
  }

  file {"${nginx::config::nx_proxy_temp_path}":
    ensure => directory,
    owner  => $daemon_user,
  }

  file { '/etc/nginx/sites-enabled/default':
    ensure => absent,
  }

  file { "${nginx::params::nx_conf_dir}/nginx.conf":
    ensure  => file,
    content => template('nginx/conf.d/nginx.conf.erb'),
  }

  if ($use_proxy == true) {
    file { "${nginx::params::nx_conf_dir}/conf.d/proxy.conf":
      ensure  => file,
      content => template('nginx/conf.d/proxy.conf.erb'),
    }
  }

  file { "${nginx::config::nx_temp_dir}/nginx.d":
    ensure  => directory,
    purge   => true,
    recurse => true,
  }
}
