# == Class bind::config
#
# This class is called from bind for service config.
#
class bind::config {

  concat { $::bind::named_conf:
    ensure  => present,
    mode    => '0644',
    require => Package[$::bind::package_name],
    content => template('bind/named.conf.erb'),
    notify  => Service[$::bind::service_name],
  }

  concat { $::bind::named_local_conf:
    ensure  => present,
    owner   => 'root',
    group   => $::bind::bind_group,
    warn    => true,
    notify  => Service[$::bind::service_name],
    require => File[$::bind::config_dir],
  }

  $views_ensure = $::bind::enable_views ? {
    true    => present,
    default => absent
  }

  concat { "${::bind::config_dir}\views.conf":
    ensure  => $views_ensure,
    owner   => 'root',
    group   => $::bind::bind_group,
    warn    => true,
    notify  => Service[$::bind::service_name],
    require => File[$::bind::config_dir],
  }

  concat::fragment { 'options_open':
    ensure  => present,
    order   => '25',
    target  => $::bind::named_conf,
    content => 'options {',
  }

  concat::fragment { 'options_main':
    ensure  => present,
    order   => '26',
    target  => $::bind::named_conf,
    content => template('bind/options.erb'),
  }
      
  concat::fragment { 'options_close':
    ensure  => present,
    order   => '30',
    target  => $::bind::named_conf,
    content => '};',
  }

  concat::fragment { 'include_views':
    ensure  => $views_ensure,
    order   => '98',
    target  => $::bind::named_conf,
    content => "include \"${::bind::config_dir}/views.conf\";",
  }
}
