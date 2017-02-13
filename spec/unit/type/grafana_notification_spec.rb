require 'spec_helper'

notification = Puppet::Type.type(:grafana_notification)

describe notification do
  let(:params) { [:name, :provider] }

  let(:properties) do
    [
      :ensure,
      :type,
      :is_default,
      :settings
    ]
  end

  it 'should have expected properties' do
    properties.each do |property|
      expect(notification.properties.map(&:name)).to be_include(property)
    end
  end

  it 'should have expected parameters' do
    params.each do |param|
      expect(notification.parameters).to be_include(param)
    end
  end
end
