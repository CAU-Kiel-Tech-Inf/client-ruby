# encoding: UTF-8
# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Player do
  subject(:player) { Player.new(Color::RED, 'uwu') }

  context 'when newly created' do
    it 'should have a color and a name' do
      expect(player.color).to eq(Color::RED)
      expect(player.name).to eq('uwu')
    end
  end
end
