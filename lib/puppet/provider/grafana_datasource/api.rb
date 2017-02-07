require_relative '../../../puppet_x/grafana/api.rb'
require 'json'

Puppet::Type.type(:grafana_datasource).provide(:api, :parent => Grafana::Api) do
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
    request(:put, "api/datasources/#{@property_hash[:id]}", payload)
  end

  def self.instances
    response = request(:get, 'api/datasources')
    ids      = JSON.parse(response.body).collect { |item| item['id'] }

    ids.collect do |id|
      response = request(:get, "api/datasources/#{id}")
      data     = JSON.parse(response.body)
      new(
        :ensure              => :present,
        :name                => data['name'],
        :type                => data['type'],
        :is_default          => bool_to_sym(data['isDefault']),
        :access              => data['access'],
        :url                 => data['url'],
        :user                => data['user'],
        :password            => data['password'],
        :database            => data['database'],
        :basic_auth          => bool_to_sym(data['basicAuth']),
        :basic_auth_password => data['basicAuthPassword'],
        :basic_auth_user     => data['basicAuthUser'],
        :with_credentials    => bool_to_sym(data['withCredentials']),
        :json_data           => data['jsonData'],
        :id                  => data['id'],
        :org_id              => data['orgId'],
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
      :name              => resource[:name],
      :type              => resource[:type],
      :isDefault         => resource[:is_default],
      :access            => resource['access'],
      :url               => resource['url'],
      :user              => resource['user'],
      :password          => resource['password'],
      :database          => resource['database'],
      :basicAuth         => resource['basic_auth'],
      :basicAuthPassword => resource['basic_auth_password'],
      :basicAuthUser     => resource['basic_auth_user'],
      :withCredentials   => resource['with_credentials'],
      :jsonData          => resource['json_data'],
    }
    request(:post, 'api/datasources', payload)
    @property_hash[:ensure] = :present
  end

  def destroy
    request(:delete, "api/datasources/#{@property_hash[:id]}")
    @property_hash.clear
  end

  def name=(*)
    update(:name => resource[:name])
  end

  def type=(*)
    update(:type => resource[:type])
  end

  def is_default=(*)
    update(:isDefault => resource[:is_default])
  end

  def access=(*)
    update(:access => resource[:access])
  end

  def url=(*)
    update(:url => resource[:url])
  end

  def user=(*)
    update(:user => resource[:user])
  end

  def password=(*)
    update(:password => resource[:password])
  end

  def database=(*)
    update(:database => resource[:database])
  end

  def basic_auth=(*)
    update(:basicAuth => resource[:basic_auth])
  end

  def basic_auth_password=(*)
    update(:basicAuthPassword => resource[:basic_auth_password])
  end

  def basic_auth_user=(*)
    update(:basicAuthUser => resource[:basic_auth_user])
  end

  def with_credentials=(*)
    update(:withCredentials => resource[:with_credentials])
  end

  def json_data=(*)
    update(:jsonData => resource[:json_data])
  end
end
