#
define grafana::plugin (
  Enum['present', 'absent', 'latest'] $ensure,
) {

  if ! defined(Class['::grafana']) {
    fail('You must include the grafana base class before using any grafana defined resources')
  }

  package { $name:
    ensure   => $ensure,
    provider => grafana,
    notify   => Class['::grafana::service'],
  }
}
