require 'spec_helper'

provider_class = Puppet::Type.type(:grafana_notification).provider(:api)

describe provider_class do
  context 'testing' do
    let(:resource) do
      Puppet::Type.type(:grafana_notification).new(
        :name       => 'test_notification',
        :ensure     => :present,
        :type       => 'email',
        :settings   => {'addresses' => 'test@example.org'},
        :is_default => false
      )
    end

    let(:provider) { resource.provider }
    let(:instance) { provider.class.instances.first }

    it 'should be an instance of the API provider' do
      expect(provider).to be_an_instance_of Puppet::Type::Grafana_notification::ProviderApi
    end
  end
end
