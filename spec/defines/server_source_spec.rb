require 'spec_helper'

describe 'rsync::server::source', :type => :define do
  let :title do
    'foobar'
  end

  let :fragment_file do
    "/etc/rsync.d/frag-foobar"
  end

  let :mandatory_params do
    { :path => '/some/path' }
  end

  let :params do
    mandatory_params
  end

  describe "when using default class paramaters" do
    it do
      should contain_file(fragment_file).with_content(/^\[ foobar \]$/)
      should contain_file(fragment_file).with_content(/^path\s*=\s*\/some\/path$/)
      should contain_file(fragment_file).with_content(/^read only\s*=\s*yes$/)
      should contain_file(fragment_file).with_content(/^write only\s*=\s*no$/)
      should contain_file(fragment_file).with_content(/^list\s*=\s*yes$/)
      should contain_file(fragment_file).with_content(/^uid\s*=\s*0$/)
      should contain_file(fragment_file).with_content(/^gid\s*=\s*0$/)
      should contain_file(fragment_file).with_content(/^incoming chmod\s*=\s*0644$/)
      should contain_file(fragment_file).with_content(/^outgoing chmod\s*=\s*0644$/)
      should contain_file(fragment_file).with_content(/^max connections\s*=\s*0$/)
      should_not contain_file(fragment_file).with_content(/^lock file\s*=.*$/)
      should_not contain_file(fragment_file).with_content(/^secrets file\s*=.*$/)
      should_not contain_file(fragment_file).with_content(/^auth users\s*=.*$/)
      should_not contain_file(fragment_file).with_content(/^hosts allow\s*=.*$/)
      should_not contain_file(fragment_file).with_content(/^hosts deny\s*=.*$/)
    end

  end

  describe "when overriding max connections" do
    let :params do
      mandatory_params.merge({ :max_connections => 1 })
    end

    it do
      should contain_file(fragment_file).with_content(/^max connections\s*=\s*1$/)
      should contain_file(fragment_file).with_content(/^lock file\s*=\s*\/var\/run\/rsyncd\.lock$/)
    end
  end

  {
    :comment        => 'super module !',
    :read_only      => 'no',
    :write_only     => 'yes',
    :list           => 'no',
    :uid            => '4682',
    :gid            => '4682',
    :incoming_chmod => '0777',
    :outgoing_chmod => '0777',
    :secrets_file   => '/path/to/secrets',
    :hosts_allow    => ['localhost', '169.254.42.51'],
    :hosts_deny     => ['some-host.example.com', '10.0.0.128']
  }.each do |k,v|
    describe "when overriding #{k}" do
      let :params do
        mandatory_params.merge({ k => v })
      end
      it { should contain_file(fragment_file).with_content(/^#{k.to_s.gsub('_', ' ')}\s*=\s*#{Array(v).join(' ')}$/)}
    end
  end

  describe "when overriding auth_users" do
    let :params do
      mandatory_params.merge({ :auth_users     => ['me', 'you', 'them'] })
    end
    it { should contain_file(fragment_file).with_content(/^auth users\s*=\s*me, you, them$/)}
  end

end
