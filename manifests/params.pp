#
class grafana::params {

  $admin_user     = 'admin'
  $package_ensure = 'present'

  case $::osfamily {
    'RedHat': {
      $check_for_updates  = true
      $conf_dir           = '/etc/grafana'
      $conf_file          = "${conf_dir}/grafana.ini"
      $data_dir           = '/var/lib/grafana'
      $grafana_home       = '/usr/share/grafana'
      $group              = 'grafana'
      $ldap_toml          = "${conf_dir}/ldap.toml"
      $log_dir            = '/var/log/grafana'
      $manage_repo        = true
      $max_open_files     = 10000
      $package_name       = 'grafana'
      $plugins_dir        = "${data_dir}/plugins"
      $restart_on_upgrade = false
      $service_name       = 'grafana-server'
      $url                = 'https://grafana.net'
      $user               = 'grafana'
    }
    default: {
      fail("The ${module_name} module is not supported on an ${::osfamily} based system.")
    }
  }
}
