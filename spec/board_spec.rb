# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers
include Constants

RSpec.describe Board do
  subject(:board) {
    Board.new([Field.new(0,0, Piece.new(Color::RED, PieceType::Herzmuschel, Coordinates.new(0,0))), 
      Field.new(3,1, Piece.new(Color::RED, PieceType::Moewe, Coordinates.new(3,1)))])
  }

  it 'should have fields initialized' do
    expect(board.field_list.size).to eq(BOARD_SIZE**2)
  end

  it 'should be cloneable' do
    expect(board.clone).to eq(board)
  end

  it 'should be comparable' do
    clone = board.clone
    expect(clone).to eq(board)
    clone.add_field(Field.new(1,0,Piece.new(Color::RED, PieceType::Herzmuschel)))
    expect(clone).not_to eq(board)
  end

  it 'should have fields with correct coordinates' do
    c = Coordinates.new(3, 1)
    expect(board.field_at(c).coordinates).to eq(c)
    expect(board.fields[3][1].coordinates).to eq(c)
  end
end
