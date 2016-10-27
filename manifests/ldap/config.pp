#
class grafana::ldap::config {

  $attributes                         = $::grafana::ldap::attributes
  $bind_dn                            = $::grafana::ldap::bind_dn
  $bind_password                      = $::grafana::ldap::bind_password
  $conf_file                          = $::grafana::ldap::conf_file
  $group_mappings                     = $::grafana::ldap::group_mappings
  $group_search_base_dns              = $::grafana::ldap::group_search_base_dns
  $group_search_filter                = $::grafana::ldap::group_search_filter
  $group_search_filter_user_attribute = $::grafana::ldap::group_search_filter_user_attribute
  $hosts                              = $::grafana::ldap::hosts
  $port                               = $::grafana::ldap::port
  $root_ca_cert                       = $::grafana::ldap::root_ca_cert
  $search_base_dns                    = $::grafana::ldap::search_base_dns
  $search_filter                      = $::grafana::ldap::search_filter
  $ssl_skip_verify                    = $::grafana::ldap::ssl_skip_verify
  $start_tls                          = $::grafana::ldap::start_tls
  $use_ssl                            = $::grafana::ldap::use_ssl
  $verbose_logging                    = $::grafana::ldap::verbose_logging

  file { $conf_file:
    ensure  => file,
    owner   => 0,
    group   => $::grafana::group,
    mode    => '0640',
    content => template("${module_name}/ldap.toml.erb"),
  }

  grafana_ini_setting { 'auth.ldap/enabled':
    value => true,
  }

  grafana_ini_setting { 'auth.ldap/config_file':
    value   => $conf_file,
    require => File[$conf_file],
  }
}
