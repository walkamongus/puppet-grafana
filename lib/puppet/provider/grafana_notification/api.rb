require_relative '../../../puppet_x/grafana/api.rb'
require 'net/http'
require 'uri'
require 'json'
require 'openssl'

Puppet::Type.type(:grafana_notification).provide(:api, :parent => Grafana::Api) do
  mk_resource_methods

  def request(*args)
    self.class.request(*args)
  end

  def camelize(*args)
    self.class.camelize(*args)
  end

  def bool_to_sym(*args)
    self.class.bool_to_sym(*args)
  end

  def update(new_value)
    payload = Hash[@property_hash.map {|k, v| [camelize(k).to_sym, v] }]
    payload.delete(:ensure)
    payload.merge!(new_value)
    request(:put, "api/alert-notifications/#{@property_hash[:id]}", payload)
  end

  def self.instances
    response = request(:get, 'api/alert-notifications')
    ids      = JSON.parse(response.body).collect { |item| item['id'] }

    ids.collect do |id|
      response = request(:get, "api/alert-notifications/#{id}")
      data     = JSON.parse(response.body)
      new(
        :name       => data['name'],
        :ensure     => :present,
        :id         => data['id'],
        :type       => data['type'],
        :is_default => bool_to_sym(data['isDefault']),
        :settings   => data['settings']
      )
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if (resource = resources[prov.name])
        resource.provider = prov
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    payload = {
      :name      => resource[:name],
      :type      => resource[:type],
      :isDefault => resource[:is_default],
      :settings  => resource[:settings]
    }
    request(:post, 'api/alert-notifications', payload)
    @property_hash[:ensure] = :present
  end

  def destroy
    request(:delete, "api/alert-notifications/#{@property_hash[:id]}")
    @property_hash.clear
  end

  def is_default=(*)
    update(:isDefault => resource[:is_default])
  end

  def settings=(*)
    update(:settings => resource[:settings])
  end

  def type=(*)
    update(:type => resource[:type])
  end

  def name=(*)
    update(:name => resource[:name])
  end
end
