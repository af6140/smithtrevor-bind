define bind::zone (
  $domain         = false,
  $type           = false,
  $ensure         = present,
  $create_db      = false,
  $servers        = [],
  $options        = false,
  $enable_notify  = false, 
) {

  validate_re($type, ['^stub$','^master$','^slave$','^forward$'])
  validate_array($servers)
  validate_string($domain)
  validate_re($ensure,['^present$','^absent$'])
  validate_bool($create_db)

  if $options {
    validate_array($options)
  }

  $zone_file = $::bind::enable_views ? {
    true    => "${::bind::config_dir}/zones/${view}_${domain}.conf",
    default => "${::bind::config_dir}/zones/${domain}.conf"
  }

  $db_file = $::bind::enable_views ? {
    true    => "${::bind::var_dir}/${type}/${view}_${domain}.db",
    default => "${::bind::var_dir}/${type}/${domain}.db"
  }

  $zone_template = "bind/${type}_zone.erb"

  concat { $zone_file :
    ensure  => $ensure,
    owner   => root,
    group   => $::bind::bind_group,
    notify  => Exec['bind-reload'],
    require => File["${::bind::config_dir}/zones"],
  }

  concat::fragment { "${type}_${domain}_header":
    ensure  => $ensure,
    target  => $zone_file,
    order   => '1',
    content => "zone \"${domain}\" {",
  }

  concat::fragment { "${type}_${domain}_main":
    ensure  => $ensure,
    target  => $zone_file,
    order   => '2',
    content => template($zone_template),
  }

  if $options {
    concat::fragment { "${type}_${domain}_options":
      ensure  => $ensure,
      target  => $zone_file,
      order   => '98',
      content => template('bind/zone_options.erb'),
    }
  }

  concat::fragment { "${type}_${domain}_footer":
    ensure  => $ensure,
    target  => $zone_file,
    order   => '99',
    content => '};',
  }

  $include_zone_ensure = $::bind::enable_views ? {
    true    => absent,
    default => $ensure,
  }

  concat::fragment { "${type}_${domain}_include":
    ensure  => $include_zone_ensure,
    target  => $::bind::named_conf,
    order   => '98',
    content => "include \"${zone_file}\";",
  }

}
