# == Class bind::install
#
# This class is called from bind for install.
#
class bind::install {

  package { $::bind::package_name:
    ensure => present,
  }

  package { $::bind::bind_utils_package:
    ensure => present,
  }

  exec { 'bind-reload':
    command     => $::bind::service_reload,
    refreshonly => true,
  }

  File {
    owner   => 'root',
    group   => $::bind::bind_group,
  }

  file { $::bind::config_dir:
    ensure  => directory,
    mode    => '0755',
    require => Package[$::bind::package_name],
  }

  file { "${::bind::config_dir}/zones":
    ensure  => directory,
    mode    => '0755',
    purge   => true,
    recurse => true,
    require => File[$::bind::config_dir],
  }

  file { $::bind::var_dir :
    ensure  => directory,
    mode    => '0750',
    require => Package[$::bind::package_name]
  }

  file {  [ "${::bind::var_dir}/stub",
            "${::bind::var_dir}/master",
            "${::bind::var_dir}/slave",
            "${::bind::var_dir}/forward"
          ]:
    ensure  => directory,
    group   => $::bind::bind_group,
    owner   => 'root'
    mode    => '0750',
    require => File[$::bind::var_dir]
  }


  

  

    
}
