# grafana

Tested with Travis CI

[![Build Status](https://travis-ci.org/bodgit/puppet-grafana.svg?branch=master)](https://travis-ci.org/bodgit/puppet-grafana)
[![Coverage Status](https://coveralls.io/repos/bodgit/puppet-grafana/badge.svg?branch=master&service=github)](https://coveralls.io/github/bodgit/puppet-grafana?branch=master)
[![Puppet Forge](http://img.shields.io/puppetforge/v/bodgit/grafana.svg)](https://forge.puppetlabs.com/bodgit/grafana)
[![Dependency Status](https://gemnasium.com/bodgit/puppet-grafana.svg)](https://gemnasium.com/bodgit/puppet-grafana)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with grafana](#setup)
    * [What grafana affects](#what-grafana-affects)
    * [Beginning with grafana](#beginning-with-grafana)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Classes and Defined Types](#classes-and-defined-types)
        * [Class: grafana](#class-grafana)
        * [Class: grafana::ldap](#class-grafanaldap)
        * [Defined Type: grafana::plugin](#defined-type-grafanaplugin)
    * [Native Types](#native-types)
        * [Native Type: grafana_ini_setting](#native-type-grafana_ini_setting)
        * [Native Type: package](#native-type-package)
    * [Examples](#examples)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module manages the Grafana UI for Graphite.

## Module Description

This module installs the Grafana package, managing the package repository if
required, configures it and optionally enables and configures LDAP
authentication. It can also install publicly available plugins.

## Setup

If running on Puppet 3.x you will need to have the future parser enabled.

### What graphite affects

* The package providing the Grafana software.
* The `/etc/grafana/grafana.ini` configuration file.
* The `/etc/grafana/ldap.toml` LDAP configuration file.
* Plugins installed under `/var/lib/grafana`.
* The service controlling Grafana.

### Beginning with grafana

```puppet
class { '::grafana':
  admin_password => 'admin',
  secret_key     => 'abc123',
}
```

## Usage

### Classes and Defined Types

#### Class: `grafana`

**Parameters within `grafana`:**

##### `admin_password`

Maps to the `security/admin_password` setting.

##### `secret_key`

Maps to the `security/secret_key` setting.

##### `admin_user`

Maps to the `security/admin_user` setting.

##### `allow_sign_up`

Maps to the `users/allow_sign_up` setting.

##### `allow_org_create`

Maps to the `users/allow_org_create` setting.

##### `check_for_updates`

Maps to the `analytics/check_for_updates` setting.

##### `conf_dir`

The root configuration directory, defaults to `/etc/grafana`.

##### `conf_file`

The main configuration file, defaults to `${conf_dir}/grafana.ini`.

##### `data_dir`

The root data directory, defaults to `/var/lib/grafana`.

##### `grafana_home`

The root directory of the web application, defaults to `/usr/share/grafana`.

##### `group`

The group to run as, defaults to `grafana`.

##### `log_dir`

The log directory, defaults to `/var/log/grafana`.

##### `manage_repo`

Whether to manage the external repository for package installation.

##### `max_open_files`

Maximum number of open files, defaults to 10,000.

##### `package_name`

The name of the package to install, defaults to `grafana`.

##### `plugins_dir`

The plugins directory, defaults to `${data_dir}/plugins`.

##### `restart_on_upgrade`

Controls whether package upgrades trigger an automatic restart.

##### `service_name`

The name of the service, defaults to `grafana-server`.

##### `url`

Maps to the `grafana_net/url` setting.

##### `user`

The user to run as, defaults to `grafana`.

#### Class: `grafana::ldap`

**Parameters within `grafana::ldap`:**

##### `bind_dn`

The distinguished name used to bind to LDAP with.

##### `hosts`

An array of hostnames or IP addresses of LDAP servers to use.

##### `search_base_dns`

An array of LDAP search bases to try for locating the user.

##### `search_filter`

An LDAP search filter to apply to user searches.

##### `attributes`

A hash of LDAP attribute mappings. Required keys are `name`, `surname`,
`username`, `member_of`, and `email`. Values for each are the appropriate
LDAP attribute name.

##### `bind_password`

The password to use when binding to LDAP.

##### `conf_file`

The LDAP configuration file, defaults to `${::grafana::conf_dir}/ldap.toml`.

##### `group_mappings`

An array of mappings, each mapping being a hash containing the required keys
`group_dn` and `org_role` which contain the plain or distinguished name of
the group, (or `*` as a catch-all), and one of `Admin`, `Editor` or `Viewer`
respectively. An optional `org_id` key can be passed to map to the desired
Grafana organisation ID.

##### `group_search_base_dns`

An array of LDAP search bases to try for group lookups.

##### `group_search_filter`

An LDAP search filter to apply to group searches.

##### `group_search_filter_user_attribute`

Used with recursive group membership lookups.

##### `port`

Port to use for LDAP connections, defaults to 389.

##### `root_ca_cert`

Path to root CA certificate for verifying SSL/TLS LDAP connections.

##### `ssl_skip_verify`

Boolean for SSL/TLS verification.

##### `start_tls`

Whether to use STARTTLS.

##### `use_ssl`

Whether to use SSL/TLS, usually with port 636.

##### `verbose_logging`

Enable verbose LDAP logging.

#### Defined Type: `grafana::plugin`

**Parameters within `grafana::plugin`:**

##### `name`

The name of the plugin to install.

##### `ensure`

One of `present`, `absent` or `latest`.

### Native Types

#### Native Type: `grafana_ini_setting`

```puppet
grafana_ini_setting { 'auth.ldap/config_file':
  ensure => present,
  value  => '/etc/grafana/ldap.toml',
}

grafana_ini_setting { 'auth.ldap/enabled':
  ensure => absent,
}
```

**Parameters within `grafana_ini_setting`:**

##### `name`

The name of the setting, of the form `<section>/<setting>`.

##### `ensure`

One of `present` or `absent`.

##### `value`

The value of the setting.

#### Native Type: `package`

```puppet
package { 'grafana-piechart-panel':
  ensure   => present,
  provider => grafana,
}
```

**Parameters within `package`:**

See the standard Puppet package type.

### Examples

Install Grafana:

```puppet
class { '::grafana':
  admin_password => 'admin',
  secret_key     => 'abc123',
}
```

Extend the above to also install a piechart plugin:

```puppet
class { '::grafana':
  admin_password => 'admin',
  secret_key     => 'abc123',
}

::grafana::plugin { 'grafana-piechart-panel':
  ensure => present,
}
```

Extend the above to also configure LDAP authentication:

```puppet
include ::openldap
include ::openldap::client
class { '::openldap::server':
  root_dn              => 'cn=Manager,dc=example,dc=com',
  root_password        => 'secret',
  suffix               => 'dc=example,dc=com',
  access               => [
    'to attrs=userPassword by self =xw by anonymous auth',
    'to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by users read',
  ],
  ldap_interfaces      => ['127.0.0.1'],
  local_ssf            => 256,
}
::openldap::server::schema { 'cosine':
  position => 1,
}
::openldap::server::schema { 'inetorgperson':
  position => 2,
}
::openldap::server::schema { 'nis':
  position => 3,
}

class { '::grafana':
  admin_password => 'admin',
  secret_key     => 'abc123',
}

::grafana::plugin { 'grafana-piechart-panel':
  ensure => present,
}

class { '::grafana::ldap':
  bind_dn               => 'cn=Manager,dc=example,dc=com',
  bind_password         => 'secret',
  group_search_base_dns => ['ou=groups,dc=example,dc=com'],
  group_search_filter   => '(&(objectClass=posixGroup)(memberUid=%s))',
  hosts                 => ['127.0.0.1'],
  search_base_dns       => ['ou=people,dc=example,dc=com'],
  search_filter         => '(uid=%s)',
  attributes            => {
    'name'      => 'givenName',
    'surname'   => 'sn',
    'username'  => 'uid',
    'member_of' => 'cn',
    'email'     => 'mail',
  },
  group_mappings        => [
    {
      'group_dn' => 'alice',
      'org_role' => 'Admin',
    },
  ],
  require               => Class['::openldap::server'],
}
```

## Reference

### Classes

#### Public Classes

* [`grafana`](#class-grafana): Main class for managing Grafana.
* [`grafana::ldap`](#class-grafanaldap): Main class for managing LDAP support
  in Grafana.

#### Private Classes

* `grafana::install`: Handles Grafana installation.
* `grafana::config`: Handles Grafana configuration.
* `grafana::params`: Different configuration data for different systems.
* `grafana::service`: Handles running the Grafana service.
* `grafana::ldap::config`: Handles Grafana LDAP configuration.

### Defined Types

#### Public Defined Types

* [`grafana::plugin`](#defined-type-grafanaplugin): Handles plugin
  installation.

### Native Types

* [`grafana_ini_setting`](#native-type-grafana_ini_setting): Manages
  configuration settings in `/etc/grafana/grafana.ini`.
* [`package`](#native-type-package): Package provider for managing Grafana
  plugins.

## Limitations

This module has been built on and tested against Puppet 3.0 and higher.

The module has been tested on:

* RedHat/CentOS Enterprise Linux 6/7

Testing on other platforms has been light and cannot be guaranteed.

## Development

Please log issues or pull requests at
[github](https://github.com/bodgit/puppet-grafana).
