# == Class bind::params
#
# This class is meant to be called from bind.
# It sets variables according to platform.
#
class bind::params {
  $config_dir = '/etc/named'
  $var_dir = '/var/named'
  $enable_rndc = true
  $bind_utils_package = 'bind-utils'

  case $::osfamily {
    'Debian': {
      $package_name = 'bind9'
      $service_name = 'bind9'
      $named_conf = '/etc/named/named.conf'
      $service_reload = '/usr/sbin/service bind9 reload'
    }
    'RedHat', 'Amazon': {
      $bind_user = 'named'
      $bind_group = 'named'
      $package_name = 'bind'
      $service_name = 'named'
      $named_conf = '/etc/named.conf'
      $service_reload = $operatingsystemmajrelease ? {
        '7'     => '/usr/bin/systemctl reload named',
        default => '/sbin/service named reload'
      }
      $named_local = "${named_conf}/named.local.conf"
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
