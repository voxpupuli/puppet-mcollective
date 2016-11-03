require 'spec_helper'

describe 'mcollective::setting' do
  context 'some_setting' do
    let(:title) { 'some_setting' }
    let(:params) { { setting: 'like', value: 'pie', target: 'test' } }
    it { is_expected.to contain_datacat_fragment('mcollective::setting some_setting') }
    it { is_expected.to contain_datacat_fragment('mcollective::setting some_setting').with_data('like' => 'pie') }
    it { is_expected.to contain_datacat_fragment('mcollective::setting some_setting').with_target('test') }
  end
end
