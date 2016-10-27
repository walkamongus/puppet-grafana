require 'spec_helper_acceptance'

describe 'grafana::ldap' do

  it 'should work with no errors' do

    pp = <<-EOS
      include ::openldap
      include ::openldap::client
      class { '::openldap::server':
        root_dn              => 'cn=Manager,dc=example,dc=com',
        root_password        => 'secret',
        suffix               => 'dc=example,dc=com',
        access               => [
          'to attrs=userPassword by self =xw by anonymous auth',
          'to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by users read',
        ],
        ldap_interfaces      => ['#{default.ip}'],
        local_ssf            => 256,
      }
      ::openldap::server::schema { 'cosine':
        position => 1,
      }
      ::openldap::server::schema { 'inetorgperson':
        position => 2,
      }
      ::openldap::server::schema { 'nis':
        position => 3,
      }

      class { '::grafana':
        admin_password => 'admin',
        secret_key     => 'abc123',
      }

      class { '::grafana::ldap':
        bind_dn               => 'cn=Manager,dc=example,dc=com',
        bind_password         => 'secret',
        group_search_base_dns => ['ou=groups,dc=example,dc=com'],
        group_search_filter   => '(&(objectClass=posixGroup)(memberUid=%s))',
        hosts                 => ['#{default.ip}'],
        search_base_dns       => ['ou=people,dc=example,dc=com'],
        search_filter         => '(uid=%s)',
        attributes            => {
          'name'      => 'givenName',
          'surname'   => 'sn',
          'username'  => 'uid',
          'member_of' => 'cn',
          'email'     => 'mail',
        },
        group_mappings        => [
          {
            'group_dn' => 'alice',
            'org_role' => 'Admin',
          },
        ],
        require               => Class['::openldap::server'],
      }
    EOS

    apply_manifest(pp, :catch_failures => true, :future_parser => true)
    apply_manifest(pp, :catch_changes  => true, :future_parser => true)
  end

  describe command('ldapadd -Y EXTERNAL -H ldapi:/// -f /root/example.ldif') do
    its(:exit_status) { should eq 0 }
  end

  describe file('/etc/grafana/ldap.toml') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'grafana' }
    it { should be_mode 640 }
  end

  # Get session cookie
  describe command('curl -s -b cookies.txt -c cookies.txt http://localhost:3000/') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should eq %Q{<a href="/login">Found</a>.\n\n} }
  end

  # Log in
  describe command(%q{curl -s -b cookies.txt -c cookies.txt -X POST -H 'Content-Type: application/json' -d '{ "user": "alice", "email": "", "password": "password" }' http://localhost:3000/login}) do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should eq '{"message":"Logged in","redirectUrl":"/"}' }
  end

  # Now should be logged in
  describe command('curl -s -b cookies.txt -c cookies.txt http://localhost:3000/') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /^\s+user:{"isSignedIn":true,"id":\d+,"login":"alice","email":"alice@example.com","name":"Alice Example",[^,]+,"orgId":\d+,"orgName":"Main Org.","orgRole":"Admin",/ }
  end
end
