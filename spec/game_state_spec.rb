# encoding: UTF-8
# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers

RSpec.describe GameState do
  subject(:gamestate) { described_class.new }

  before do
    board =
      <<~BOARD
        R _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ B B
        R _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ B
        R R _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ B
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        G _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ Y
        G G G _ _ _ _ _ _ _ _ _ _ _ _ _ _ Y Y Y
      BOARD
    state_from_string!(board, gamestate)
  end

  it 'holds the board' do
    expect(subject.field(0, 0)).to eq(Field.new(0, 0, Color::RED))
  end

  it 'is clonable' do
    clone = gamestate.clone
    clone.turn += 1
    clone.board.add_field(Field.new(0, 0, Color::BLUE))
    clone.current_color = Color::BLUE
    # if clone is independent, changes will not affect the original gamestate
    expect(gamestate.turn).to_not eq(clone.turn)
    expect(gamestate.board.field(0, 0)).to_not eq(clone.board.field(0, 0))
    expect(gamestate.current_color).to_not eq(clone.current_color)
  end

  it 'returns all own fields' do
    expect(gamestate.own_fields.size).to eq(4)
  end

  it 'performs moves' do
    expect do
      move = SkipMove.new
      gamestate.perform!(move)
    end.not_to raise_error(NoMethodError)
    expect do
      move = SetMove.new(
        Piece.new(
          Color::RED,
          gamestate.undeployed_pieces(Color::RED).first,
          Rotation::NONE,
          false,
          Coordinates.new(1, 0)
        )
      )
      gamestate.perform!(move)
    end.not_to raise_error
  end

  #   it 'calculates all possible moves' do
  #     expect(gamestate.possible_moves.size).to eq(16 * 3)
  #   end
end
