require 'spec_helper'

describe 'grafana::ldap' do

  let(:params) do
    {
      :bind_dn         => 'cn=Manager,dc=example,dc=com',
      :hosts           => ['127.0.0.1'],
      :search_base_dns => ['dc=example,dc=com'],
      :search_filter   => '(uid=%s)',
    }
  end

  context 'on unsupported distributions' do
    let(:facts) do
      {
        :osfamily => 'Unsupported'
      }
    end

    it { expect { should compile }.to raise_error(/not supported on an Unsupported/) }
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

        it { should contain_class('grafana::ldap') }
        it { should contain_class('grafana::ldap::config') }
        it { should contain_file('/etc/grafana/ldap.toml') }
        it { should contain_grafana_ini_setting('auth.ldap/enabled') }
        it { should contain_grafana_ini_setting('auth.ldap/config_file') }
      end
    end
  end
end
