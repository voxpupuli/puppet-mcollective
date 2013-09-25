require 'spec_helper'

describe 'mcollective::actionpolicy' do
  context 'dummy' do
    let(:title) { 'dummy' }
    it { should contain_datacat('mcollective::actionpolicy dummy') }
  end
end
