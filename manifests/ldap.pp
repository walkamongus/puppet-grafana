#
class grafana::ldap (
  String            $bind_dn,
  Array[String, 1]  $hosts,
  Array[String, 1]  $search_base_dns,
  String            $search_filter,
  Struct[
    {
      'name'      => String,
      'surname'   => String,
      'username'  => String,
      'member_of' => String,
      'email'     => String,
    } # lint:ignore:trailing_comma
  ]                 $attributes                         = {
    'name'      => 'givenName',
    'surname'   => 'sn',
    'username'  => 'cn',
    'member_of' => 'memberOf',
    'email'     => 'email',
  },
  Optional[String]  $bind_password                      = undef,
  String            $conf_file                          = $::grafana::params::ldap_toml,
  Optional[
    Array[
      Struct[
        {
          'group_dn'         => String,
          'org_role'         => Enum['Admin', 'Editor', 'Viewer'],
          Optional['org_id'] => Integer[1]
        }
      ],
      1
    ]
  ]                 $group_mappings                     = undef,
  Optional[
    Array[String, 1]
  ]                 $group_search_base_dns              = undef,
  Optional[String]  $group_search_filter                = undef,
  Optional[String]  $group_search_filter_user_attribute = undef,
  Integer[0, 65535] $port                               = 389,
  Optional[String]  $root_ca_cert                       = undef,
  Optional[Boolean] $ssl_skip_verify                    = undef,
  Optional[Boolean] $start_tls                          = undef,
  Optional[Boolean] $use_ssl                            = undef,
  Optional[Boolean] $verbose_logging                    = undef,
) inherits ::grafana::params {

  if ! defined(Class['::grafana']) {
    fail('You must include the grafana base class before using the grafana::ldap class')
  }

  validate_ldap_dn($bind_dn)
  validate_absolute_path($conf_file)
  validate_ldap_dn($search_base_dns)
  validate_ldap_filter($search_filter)

  if $group_search_base_dns {
    validate_ldap_dn($group_search_base_dns)
  }
  if $group_search_filter {
    validate_ldap_filter($group_search_filter)
  }
  if $root_ca_cert {
    validate_absolute_path($root_ca_cert)
  }

  include ::grafana::ldap::config

  Class['::grafana::config'] -> Class['::grafana::ldap::config']
    ~> Class['::grafana::service']
}
