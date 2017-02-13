require 'spec_helper'

provider_class = Puppet::Type.type(:grafana_datasource).provider(:api)

describe provider_class do
  context 'testing' do
    let(:resource) do
      Puppet::Type.type(:grafana_datasource).new(
        :name                => 'test_datasource',
        :ensure              => :present,
        :access              => 'proxy',
        :basic_auth          => false,
        :basic_auth_password => 'admin',
        :basic_auth_user     => 'admin',
        :database            => 'mydb',
        :is_default          => false,
        :password            => 'dbpass',
        :type                => 'influxdb',
        :url                 => 'http://localhost:8086',
        :user                => 'dbuser',
        :with_credentials    => false
      )
    end

    let(:provider) { resource.provider }
    let(:instance) { provider.class.instances.first }

    it 'should be an instance of the API provider' do
      expect(provider).to be_an_instance_of Puppet::Type::Grafana_datasource::ProviderApi
    end
  end
end
