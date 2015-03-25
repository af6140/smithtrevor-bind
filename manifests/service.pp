# == Class bind::service
#
# This class is meant to be called from bind.
# It ensure the service is running.
#
class bind::service {

  service { $::bind::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package[$::bind::package_name],
  }
}
