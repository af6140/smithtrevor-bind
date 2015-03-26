# == Class bind::config
#
# This class is called from bind for service config.
#
class bind::config {

  concat { $::bind::named_conf:
    ensure  => present,
    mode    => '0644',
    warn    => true,
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

  file { "${::bind::config_dir}\acl.conf":
    ensure  => present,
    owner   => 'root',
    group   => $::bind::bind_group,
    mode    => '0644',
    content => template('bind/acl.erb'),
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

  concat::fragment { 'logging_open':
    ensure  => present,
    order   => '31',
    target  => $::bind::named_conf,
    content => 'logging {',
  }

  concat::fragment { 'default_debug_channel':
    ensure  => present,
    order   => '32',
    target  => $::bind::named_conf,
    content => template('bind/default_debug_channel.erb'),
  }

  concat::fragment { 'logging_categories':
    ensure  => present,
    order   => '33',
    target  => $::bind::named_conf,
    content => template('bind/logging_categories.erb'),
  }

  concat::fragment { 'logging_close':
    ensure  => present,
    order   => '36',
    target  => $::bind::named_conf,
    content => '};',
  }
  
  concat::fragment { 'root_hints':
    ensure  => present,
    order   => '37',
    target  => $::bind::named_conf,
    content => template('bind/root_hints.erb'),
  }

  concat::fragment { 'include_views':
    ensure  => $views_ensure,
    order   => '98',
    target  => $::bind::named_conf,
    content => "include \"${::bind::config_dir}/views.conf\";",
  }

  concat::fragment { 'default_includes':
    ensure  => present,
    order   => '99',
    target  => $::bind::named_conf,
    content => template('bind/default_includes.erb'),
  }
}
