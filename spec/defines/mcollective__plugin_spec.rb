require 'spec_helper'

describe 'mcollective::plugin' do
  let(:title) { 'fishcakes' }
  context '#source' do
    context 'default (unset)' do
      it { should contain_datacat_fragment('mcollective::plugin fishcakes') }
      it { should contain_datacat_fragment('mcollective::plugin fishcakes').with_target('mcollective::site_libdir') }
      it { should contain_datacat_fragment('mcollective::plugin fishcakes').with_data({ 'source_path' => ['puppet:///modules/mcollective/plugins/fishcakes'] }) }
    end

    context 'set' do
      let(:params) { { :source => 'puppet:///modules/my_module/fishcakes' } }
      it { should contain_datacat_fragment('mcollective::plugin fishcakes') }
      it { should contain_datacat_fragment('mcollective::plugin fishcakes').with_target('mcollective::site_libdir') }
      it { should contain_datacat_fragment('mcollective::plugin fishcakes').with_data({ 'source_path' => ['puppet:///modules/my_module/fishcakes'] }) }
    end
  end

  context '#package' do
    context 'default (false)' do
      it { should_not contain_package('mcollective-fishcakes-agent') }
      it { should_not contain_package('mcollective-fishcakes-client') }
    end

    context 'true' do
      let(:params) { { :package => true } }
      it { should contain_package('mcollective-fishcakes-agent') }

      context '#client' do
        context 'default (false)' do
          it { should_not contain_package('mcollective-fishcakes-client') }
        end

        context 'true' do
          let(:params) { { :package => true, :client => true } }
          it { should contain_package('mcollective-fishcakes-client') }
        end
      end
    end
  end
end
