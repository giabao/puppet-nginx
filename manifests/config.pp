class nginx::config($cfg){
  create_resources(nginx::dconfig, {'config' => $cfg})
}

define nginx::dconfig(
  $daemon_user          = 'nginx',
  $worker_processes     = 1,
  $worker_connections   = 1024,
  $nx_pid               = '/var/run/nginx.pid',
  $multi_accept         = off,
  $confd_purge          = false,
  $access_log_off       = false,
  $nx_sendfile          = on,
  $server_tokens        = on,
  $tcp_nopush           = false,
  $keepalive_timeout    = 65,
  $tcp_nodelay          = on,
  $gzip_on              = false,
  $run_dir              = '/var/nginx',
  $client_body_in_single_buffer = false,
  $client_body_buffer_size      = '128k',
  $client_max_body_size         = '10m',
){
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  file { ["$nginx::params::conf_dir", "$nginx::params::conf_dir/conf.d", "$run_dir"]:
    ensure => directory,
  }
  
  if $confd_purge {
    File["$nginx::params::conf_dir/conf.d"] {
      ignore => "vhost_autogen.conf",
      purge => true,
      recurse => true,
    }
  }
  
  file { ["$run_dir/client_body_temp", "$run_dir/proxy_temp"]:
    ensure => directory,
    owner  => $daemon_user,
  }

  file { "$nginx::params::conf_dir/nginx.conf":
    ensure  => file,
    content => template('nginx/conf.d/nginx.conf.erb'),
  }

  file { "$nginx::params::temp_dir/nginx.d":
    ensure  => directory,
    purge   => true,
    recurse => true,
  }
}
