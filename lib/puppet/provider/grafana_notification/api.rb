require_relative '../../../puppet_x/grafana/api.rb'
require 'net/http'
require 'uri'
require 'json'
require 'openssl'

Puppet::Type.type(:grafana_notification).provide(:api, :parent => Grafana::Api) do
  mk_resource_methods

  def initialize(value = {})
    super(value)
    @needs_update = false
  end

  def self.api_root
    'api/alert-notifications'
  end

  def self.instances
    response = request(:get, api_root)
    ids      = JSON.parse(response.body).collect { |item| item['id'] }
    ids.collect do |id|
      new get_properties(api_root, id)
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if (resource = resources[prov.name])
        resource.provider = prov
      end
    end
  end

  def api_root
    self.class.api_root
  end

  def update
    updated_values = @property_hash.merge(@resource.to_hash)
    payload = create_payload(updated_values)
    request(:put, "#{api_root}/#{@property_hash[:id]}", payload)
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    payload = create_payload(@resource.to_hash)
    request(:post, api_root, payload)
    @property_hash[:ensure] = :present
  end

  def destroy
    request(:delete, "#{api_root}/#{@property_hash[:id]}")
    @property_hash.clear
  end

  [
    :name,
    :type,
    :is_default,
    :settings
  ].each do |prop|
    define_method(prop.to_s + '=') do |*|
      @needs_update = true
    end
  end

  def flush
    update if @needs_update
  end
end
