# == Class: bind
#
# Full description of class bind here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class bind (
  $package_name                 = $::bind::params::package_name,
  $service_name                 = $::bind::params::service_name,
  $bind_utils_package           = $::bind::params::bind_utils_package,
  $bind_group                   = $::bind::params::bind_group,
  $config_dir                   = $::bind::params::config_dir,
  $named_conf                   = $::bind::params::named_conf,
  $named_local_conf             = $::bind::parmas::named_local_conf,
  $enable_root_hints            = true,
  $enable_views                 = false,
  $enable_recursion             = false,
  $enable_root_hints            = true,
  $enable_default_debug_channel = true,
  $v4_listen_addresses          = ['127.0.0.1'],
  $default_logdir               = '/var/log/named',
  $allow_query                  = ['127.0.0.1'],
  $allow_recursion              = ['127.0.0.1'],
  $acl                          = {},
) inherits ::bind::params {

  validate_array($v4_listen_addresses)

  class { '::bind::install': } ->
  class { '::bind::config': } ~>
  class { '::bind::service': } ->
  Class['::bind']
}
