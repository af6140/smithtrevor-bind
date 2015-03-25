require 'spec_helper'

describe 'bind' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "bind class without any parameters" do
          let(:params) {{ }}

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('bind::params') }
          it { is_expected.to contain_class('bind::install').that_comes_before('bind::config') }
          it { is_expected.to contain_class('bind::config') }
          it { is_expected.to contain_class('bind::service').that_subscribes_to('bind::config') }

          it { is_expected.to contain_service('bind') }
          it { is_expected.to contain_package('bind').with_ensure('present') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'bind class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('bind') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
