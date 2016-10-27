#
class grafana::install {

  if $::grafana::manage_repo {
    case $::osfamily {
      'RedHat': {
        yumrepo { 'grafana':
          baseurl       => "https://packagecloud.io/grafana/stable/el/${::operatingsystemmajrelease}/\$basearch",
          repo_gpgcheck => true,
          enabled       => true,
          gpgcheck      => true,
          gpgkey        => 'https://packagecloud.io/gpg.key https://grafanarel.s3.amazonaws.com/RPM-GPG-KEY-grafana',
          sslverify     => true,
          before        => Package[$::grafana::package_name],
        }
      }
      default: {
        fail('')
      }
    }
  }

  package { $::grafana::package_name:
    ensure => present,
  }
}
