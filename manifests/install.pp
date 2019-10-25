#
class grafana::install {

  if $::grafana::manage_repo {
    case $::osfamily {
      'RedHat': {
        yumrepo { 'grafana':
          descr         => 'Grafana',
          baseurl       => "https://packages.grafana.com/oss/rpm",
          repo_gpgcheck=1
          enabled=1
          gpgcheck=1
          gpgkey=https://packages.grafana.com/gpg.key
          sslverify=1
          proxy         => $::grafana::proxy,
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
