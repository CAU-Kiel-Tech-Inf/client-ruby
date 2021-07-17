# encoding: UTF-8
# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers

RSpec.describe GameState do
  subject(:gamestate) { described_class.new }

  before do
    board =
      <<~BOARD
      RC __ __ __ __ __ __ BS 
      RS __ __ __ __ __ __ BR 
      RR __ __ __ __ __ __ BG 
      RC __ __ __ __ __ __ BC 
      RG __ __ __ __ __ __ BR 
      RG __ __ __ __ __ __ BG 
      RR __ __ __ __ __ __ BC 
      RS __ __ __ __ __ __ BS 
      BOARD
    state_from_string!(board, gamestate)
  end

  it 'holds the board' do
    expect(subject.field(0, 0)).to eq(Field.new(0, 0, Piece.new(Color::RED, PieceType::Herzmuschel, Coordinates.new(0,0))))
  end

  it 'is clonable' do
    clone = gamestate.clone
    clone.turn += 1
    clone.board.add_field(Field.new(0, 0, Piece.new(Color::BLUE, PieceType::Herzmuschel, Coordinates.new(0,0))))
    # if clone is independent, changes will not affect the original gamestate
    expect(gamestate.turn).to_not eq(clone.turn)
    expect(gamestate.board.field(0, 0)).to_not eq(clone.board.field(0, 0))
  end

  it 'returns all own fields' do
    expect(gamestate.own_fields.size).to eq(8)
  end

  it 'performs moves' do
    # expect do
    #   move = SkipMove.new
    #   gamestate.perform!(move)
    # end.not_to raise_error
    expect do
      move = Move.new(
        Coordinates.new(0, 4),
        Coordinates.new(1, 4),
        Piece.new(
          Color::RED,
          PieceType::Moewe,
          Coordinates.new(0, 4)
        )
      )
      gamestate.perform!(move)
    end.not_to raise_error
  end

  #   it 'calculates all possible moves' do
  #     expect(gamestate.possible_moves.size).to eq(16 * 3)
  #   end
end
