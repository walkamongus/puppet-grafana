#
class grafana::config {

  $conf_dir           = $::grafana::conf_dir
  $conf_file          = $::grafana::conf_file
  $data_dir           = $::grafana::data_dir
  $grafana_home       = $::grafana::grafana_home
  $group              = $::grafana::group
  $log_dir            = $::grafana::log_dir
  $max_open_files     = $::grafana::max_open_files
  $plugins_dir        = $::grafana::plugins_dir
  $pid_file_dir       = $::grafana::pid_file_dir
  $restart_on_upgrade = $::grafana::restart_on_upgrade
  $user               = $::grafana::user
  $proxy              = $::grafana::proxy
  $no_proxy           = $::grafana::no_proxy

  group { $group:
    ensure => present,
    system => true,
  }

  user { $user:
    ensure => present,
    gid    => $group,
    system => true,
  }

  file { $conf_dir:
    ensure       => directory,
    owner        => 0,
    group        => 0,
    mode         => '0644',
    force        => true,
    purge        => true,
    recurse      => true,
    recurselimit => 1,
  }

  file { $conf_file:
    ensure => file,
    owner  => 0,
    group  => $group,
    mode   => '0640',
  }

  file { $data_dir:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0644',
  }

  file { $log_dir:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0644',
  }

  file { $plugins_dir:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0644',
  }

  case $::osfamily {
    'RedHat': {
      file { '/etc/sysconfig/grafana-server':
        ensure  => file,
        owner   => 0,
        group   => 0,
        mode    => '0644',
        content => template("${module_name}/sysconfig.erb"),
      }
    }
    default: {}
  }

  Grafana_ini_setting {
    require => File[$conf_file],
  }

  resources { 'grafana_ini_setting':
    purge => true,
  }

  $config = delete_undef_values({
    'analytics/check_for_updates' => $::grafana::check_for_updates,
    'paths/data'                  => $data_dir,
    'paths/logs'                  => $log_dir,
    'paths/plugins'               => $plugins_dir,
    'security/admin_password'     => $::grafana::admin_password,
    'security/admin_user'         => $::grafana::admin_user,
    'security/secret_key'         => $::grafana::secret_key,
    'users/allow_sign_up'         => $::grafana::allow_sign_up,
    'users/allow_org_create'      => $::grafana::allow_org_create,
    'grafana_net/url'             => $::grafana::url,
  })

  $config.each |$setting,$value| {
    grafana_ini_setting { $setting:
      value => $value,
    }
  }
}
