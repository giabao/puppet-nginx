# define: nginx::resource::location
#
# This definition creates a new location entry within a virtual host
#
# Parameters:
#   [*ensure*]               - Enables or disables the specified location (present|absent)
#   [*vhost*]                - Defines the default vHost for this location entry to include with
#   [*location*]             - Specifies the URI associated with this location entry
#   [*www_root*]             - Specifies the location on disk for files to be read from. Cannot be set in conjunction with $proxy
#   [*index_files*]          - Default index files for NGINX to read when traversing a directory
#   [*ssl*]                  - Indicates whether to setup SSL bindings for this location.
#   [*ssl_only*]	     - Required if the SSL and normal vHost have the same port.
#   [*location_cfg_prepend*] - It expects a hash with custom directives to put before anything else inside location
#   [*location_cfg_append*]  - It expects a hash with custom directives to put after everything else inside location   
#   [*try_files*]            - An array of file locations to try
#   [*option*]               - Reserved for future use
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  nginx::resource::location { 'test2.local-bob':
#    ensure   => present,
#    www_root => '/var/www/bob',
#    location => '/bob',
#    vhost    => 'test2.local',
#  }
#  
#  Custom config example to limit location on localhost,
#  create a hash with any extra custom config you want.
#  $my_config = {
#    'access_log' => 'off',
#    'allow'      => '127.0.0.1',
#    'deny'       => 'all'
#  }
#  nginx::resource::location { 'test2.local-bob':
#    ensure              => present,
#    www_root            => '/var/www/bob',
#    location            => '/bob',
#    vhost               => 'test2.local',
#    location_cfg_append => $my_config,
#  }

define nginx::resource::location(
  $ensure               = present,
  $vhost,
  $www_root             = undef,
  $index_files          = undef,
  $ssl                  = false,
  $ssl_only	            = false,
  $option               = undef,
  $location_cfg_prepend = undef,
  $location_cfg_append  = undef,
  $try_files            = undef,
  $location             = $name,
) {
  $ensure_real = $ensure ? {
    'absent' => absent,
    default  => file,
  }

  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    ensure  => $ensure_real,
    notify => Class['nginx::service'],
  }

  $content_real = template('nginx/vhost/vhost_location_directory.erb')

  ## Create stubs for vHost File Fragment Pattern
  $n = regsubst($name, '/', '#', 'G')
  if ! $ssl_only {
    file {"$nginx::params::temp_dir/nginx.d/${vhost}-500-$n":
      content => $content_real,
    }
  }

  ## Only create SSL Specific locations if $ssl is true.
  if $ssl {
    file {"$nginx::params::temp_dir/nginx.d/${vhost}-800-${n}-ssl":
      content => $content_real,
    }
  }
}
