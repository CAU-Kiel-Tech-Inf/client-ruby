# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe GameStateHelpers do
  include GameStateHelpers

  let(:gamestate) { GameState.new }

  it 'creates a gamestate from a string board representation' do
    board =
      <<~BOARD
      RC RS RR RC RG RG RR RS 
      __ __ __ __ __ __ __ __ 
      __ __ __ __ __ __ __ __ 
      __ __ __ __ __ __ __ __ 
      __ __ __ __ __ __ __ __ 
      __ __ __ __ __ __ __ __ 
      __ __ __ __ __ __ __ __ 
      BS BR BG BC BR BG BC BS 
      BOARD
    state_from_string!(board, gamestate)
    expect(gamestate.board.field(0, 0)).to be_a(Field)
    expect(gamestate.board.field(0, 0).color).to eq(Color::RED)
    expect(gamestate.board.field(1, 0)).to be_a(Field)
    expect(gamestate.board.field(1, 1).color).to be_nil
    expect(gamestate.board.field(0, 7)).to be_a(Field)
    expect(gamestate.board.field(0, 7).color).to eq(Color::BLUE)
  end

  it 'raises an error on illegal format' do
    board =
      <<~BOARD
      RC RS RR RC RG RG RR RS 
      __ __ __ __ __ __ __ __ 
      __ __ __ __ __ __ __ __ 
      __ __ __ EY __ __ __ __ 
      __ __ __ __ UWU __ __ __ 
      __ __ __ __ __ __ __ __ 
      __ __ __ __ __ __ __ __ 
      BS BR BG BC BR BG BC BS 
      BOARD
    expect do
      state_from_string!(board, gamestate)
    end.to raise_error(GameStateHelpers::BoardFormatError)
  end

  it 'updates undeployed pieces'
end
