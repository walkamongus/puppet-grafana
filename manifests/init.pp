#
class grafana (
  String[1]         $admin_password,
  String[1]         $secret_key,
  String            $admin_user         = $::grafana::params::admin_user,
  Optional[Boolean] $allow_sign_up      = undef,
  Optional[Boolean] $allow_org_create   = undef,
  Optional[Boolean] $check_for_updates  = $::grafana::params::check_for_updates,
  String            $conf_dir           = $::grafana::params::conf_dir,
  String            $conf_file          = $::grafana::params::conf_file,
  String            $data_dir           = $::grafana::params::data_dir,
  String            $grafana_home       = $::grafana::params::grafana_home,
  String            $group              = $::grafana::params::group,
  String            $log_dir            = $::grafana::params::log_dir,
  Boolean           $manage_repo        = $::grafana::params::manage_repo,
  Integer[0]        $max_open_files     = $::grafana::params::max_open_files,
  String            $package_name       = $::grafana::params::package_name,
  String            $plugins_dir        = $::grafana::params::plugins_dir,
  Boolean           $restart_on_upgrade = $::grafana::params::restart_on_upgrade,
  String            $service_name       = $::grafana::params::service_name,
  Optional[String]  $url                = $::grafana::params::url,
  String            $user               = $::grafana::params::user,
) inherits ::grafana::params {

  validate_absolute_path($conf_dir)
  validate_absolute_path($conf_file)
  validate_absolute_path($data_dir)
  validate_absolute_path($grafana_home)
  validate_absolute_path($log_dir)
  validate_absolute_path($plugins_dir)

  include ::grafana::install
  include ::grafana::config
  include ::grafana::service

  anchor { 'grafana::begin': }
  anchor { 'grafana::end': }

  Anchor['grafana::begin'] -> Class['::grafana::install']
    ~> Class['::grafana::config'] ~> Class['::grafana::service']
    -> Anchor['grafana::end']
}
