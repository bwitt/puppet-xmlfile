# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'xmlfile' do
  it_behaves_like 'an idempotent resource' do
    let(:manifest) do
      <<~PUPPET
        xmlfile { '/tmp/test.xml':
          ensure  => present,
          mode    => '0644',
          content => '<beans><broker><transportConnectors><transportConnector name="openwire" uri="tcp://0.0.0.0:61616"/></transportConnectors></broker></beans>',
        }

        xmlfile_modification { 'change openwire uri':
          file    => '/tmp/test.xml',
          changes => 'set /beans/broker/transportConnectors/transportConnector[#attribute/name == "openwire"]/#attribute/uri "tcp://0.0.0.0:61617"',
          onlyif  => 'match /beans/broker/transportConnectors/transportConnector[#attribute/name == "openwire"] size == 1',
        }

        xmlfile_modification { 'set broker name':
          file    => '/tmp/test.xml',
          changes => 'set /beans/broker/#attribute/brokerName "localhost"',
        }
      PUPPET
    end
  end

  describe file('/tmp/test.xml') do
    it { is_expected.to be_file }
    it { is_expected.to be_mode 644 }
    its(:content) { is_expected.to match %r{<broker brokerName=['"]localhost['"]>} }
    its(:content) { is_expected.to match %r{<transportConnector name=['"]openwire['"] uri=['"]tcp://0\.0\.0\.0:61617['"]/>} }
  end
end
