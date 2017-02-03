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
          before        => Package['grafana'],
        }
      }
      default: {
        fail("${::osfamily} osfamily not yet supported.")
      }
    }
  }

  package { 'grafana':
    ensure => $::grafana::package_ensure,
    name   => $::grafana::package_name,
  }
}
