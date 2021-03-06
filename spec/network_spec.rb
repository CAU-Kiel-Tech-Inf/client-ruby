# encoding: UTF-8
# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Network do
  let(:board) { instance_double('Board') }
  let(:client) { instance_double('Client') }

  subject { Network.new('localhost', 99_999, board, client) }

  before { allow(client).to receive(:gamestate=) }

  it 'should send XML' do
    subject.sendXML(REXML::Document.new)
  end
end
