class nginx::service(
  # Service restart after Nginx 0.7.53 could also be just "/path/to/nginx/bin -s HUP"
  # Some init scripts do a configtest, some don't. If configtest_enable it's true
  # then service restart will take $nx_service_restart value, forcing configtest.
  $configtest_enable   = false,
  $service_restart     = '/etc/init.d/nginx configtest && /etc/init.d/nginx restart'
) {
  exec { 'rebuild-nginx-vhosts':
    command     => "/bin/cat $nginx::params::temp_dir/nginx.d/* > $nginx::params::conf_dir/conf.d/vhost_autogen.conf",
    refreshonly => true,
    unless	=> "/usr/bin/test ! -f $nginx::params::temp_dir/nginx.d/*",
    subscribe   => File["$nginx::params::temp_dir/nginx.d"],
  }
  service { "nginx":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => Exec['rebuild-nginx-vhosts'],
  }
  if $configtest_enable == true {
    Service["nginx"] {
      restart => $service_restart,
    }
  }
}
