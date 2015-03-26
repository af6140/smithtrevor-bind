# == Class bind::config
#
# This class is called from bind for service config.
#
class bind::config {

  #read top level variables into current scope to make templates easier
  $version = $::bind::version
  $enable_recursion = $::bind::enable_recursion
  $config_dir = $::bind::config_dir
  $enable_root_hints = $::bind::enable_root_hints
  $allow_query = $::bind::allow_query
  $allow_recursion = $::bind::allow_recursion
  $acl = $::bind::acl
  $listen_port = $::bind::listen_port
  $enable_dnssec = $::bind::enable_dnssec

  concat { $::bind::named_conf:
    ensure  => present,
    mode    => '0644',
    warn    => true,
    group   => $::bind::bind_group,
    require => Package[$::bind::package_name],
    notify  => Service[$::bind::service_name],
  }

  file { "${::bind::config_dir}/acl.conf":
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

  concat { "${::bind::config_dir}/views.conf":
    ensure  => $views_ensure,
    owner   => 'root',
    group   => $::bind::bind_group,
    notify  => Service[$::bind::service_name],
    require => File[$::bind::config_dir],
  }

  concat::fragment { 'include_acl':
    ensure  => present,
    order   => '1',
    target  => $::bind::named_conf,
    content => "include ${::bind::config_dir}/acl.conf",
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
