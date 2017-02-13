require 'puppet/property/boolean'

Puppet::Type.newtype(:grafana_datasource) do
  @doc = 'Create a new Grafana datasource'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The name of the new Grafana datasource'
  end

  newproperty(:type) do
    desc 'The type of datasource to create'
    newvalues(:influxdb, :elasticsearch, :prometheus, :graphite)
    defaultto :graphite
  end

  newproperty(:is_default, :boolean => true, :parent => Puppet::Property::Boolean) do
    desc 'Whether to use the datasource as the default datasource'
    defaultto false
  end

  newproperty(:access) do
    desc 'Whether datasource access is proxied through Grafana'
    newvalues(:proxy, :direct)
    defaultto :proxy
  end

  newproperty(:url) do
    desc 'The access URL for the datasource'
  end

  newproperty(:user) do
    desc 'The username for datasource access'
  end

  newproperty(:password) do
    desc 'The password for datasource access'
  end

  newproperty(:database) do
    desc 'The datasource database name'
  end

  newproperty(:with_credentials, :boolean => true, :parent => Puppet::Property::Boolean) do
    desc 'Whether datasource access requires credentials'
    defaultto false
  end

  newproperty(:basic_auth, :boolean => true, :parent => Puppet::Property::Boolean) do
    desc 'Whether to use basic auth for accessing the datasource'
    defaultto(false)
  end

  newproperty(:basic_auth_user) do
    desc 'The datasource database name'
  end

  newproperty(:basic_auth_password) do
    desc 'The datasource database name'
  end

  newproperty(:json_data) do
    desc 'Datasource JSON data'
  end
end
