define bind::logchannel (
  $ensure             = 'present',
  $channel            = false,
  $output_method      = false,
  $output_target      = false,
  $file_versions      = '1',
  $file_size          = '5m',
  $severity           = 'dynamic',
  $enable_print_time  = true,
  $log_dir            = $::bind::default_logdir,
){

  validate_string($channel)
  validate_bool($enable_print_time)
  validate_re($severity, ['^dynamic$',
                          '^critical$',
                          '^error$',
                          '^warning$',
                          '^notice$',
                          '^info$',
                          '^debug \d$']
              )
  validate_re($output_method, ['^file$','^syslog$','^stderr$','^null$'])
  
  case $output_method {
    'file': {
      $target = "${log_dir}/${output_target}"
      validate_absolute_path($target)
      validate_re($file_versions, '\d+')
      validate_re($file_size, '\d+(kKmMgG)')
    }
    'syslog': {
      $target = $output_target
      validate_string($target)
    }
    default: {
      $target = ''
    }
  }

  $print_time = $enable_print_time ? {
    true    => 'yes',
    default => 'no'
  }

  concat::fragment { "${name}::${channel}":
    ensure  => $ensure,
    order   => '33',
    target  => $::bind::named_conf,
    content => template('bind/logchannel.erb'),
  }
}
