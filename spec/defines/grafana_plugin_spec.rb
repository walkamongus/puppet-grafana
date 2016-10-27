require 'spec_helper'

describe 'grafana::plugin' do

  let(:title) do
    'test'
  end

  let(:params) do
    {
      :ensure => 'present',
    }
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'without grafana class included' do
        it { expect { should compile }.to raise_error(/must include the grafana base class/) }
      end

      context 'with grafana class included', :compile do
        let(:pre_condition) do
          'class { "::grafana": admin_password => "admin", secret_key => "abc123", }'
        end

        it { should contain_grafana__plugin('test') }
        it { should contain_package('test').with_provider('grafana').that_notifies('Class[grafana::service]') }
      end
    end
  end
end
