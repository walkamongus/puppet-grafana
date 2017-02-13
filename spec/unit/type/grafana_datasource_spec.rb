require 'spec_helper'

datasource = Puppet::Type.type(:grafana_datasource)

describe datasource do
  let(:params) { [:name, :provider] }

  let(:properties) do
    [
      :ensure,
      :type,
      :is_default,
      :access,
      :url,
      :user,
      :password,
      :database,
      :with_credentials,
      :basic_auth,
      :basic_auth_user,
      :basic_auth_password,
      :json_data
    ]
  end

  it 'should have expected properties' do
    properties.each do |property|
      expect(datasource.properties.map(&:name)).to be_include(property)
    end
  end

  it 'should have expected parameters' do
    params.each do |param|
      expect(datasource.parameters).to be_include(param)
    end
  end
end
