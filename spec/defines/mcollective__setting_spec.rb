require 'spec_helper'

describe 'mcollective::setting' do
  context 'some_setting' do
    let(:title) { 'some_setting' }
    let(:params) { { :setting => 'like', :value => 'pie', :target => 'test' } }
    it { should contain_datacat_fragment('mcollective::setting some_setting') }
    it { should contain_datacat_fragment('mcollective::setting some_setting').with_data({ 'like' => 'pie' }) }
    it { should contain_datacat_fragment('mcollective::setting some_setting').with_target('test') }
  end
end
