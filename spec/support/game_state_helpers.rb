# frozen_string_literal: true

require_relative '../../lib/software_challenge_client/util/constants'
require_relative '../../lib/software_challenge_client/color'

module GameStateHelpers
  include Constants

  class BoardFormatError < StandardError
  end

  def field_from_descriptor(coordinates, descriptor)
    piece = nil

    if descriptor != '__' and descriptor != '_'
      unless Color.to_a.map(&:value).include? descriptor[0]
        raise BoardFormatError.new("unknown color descriptor #{descriptor[0]}")
      end
      color = Color.find_by_value(descriptor[0])

      unless PieceType.to_a.map(&:value).include? descriptor[1]
        raise BoardFormatError.new("unknown piecetype descriptor #{descriptor[1]}")
      end
      type = PieceType.find_by_value(descriptor[1])

      piece = Piece.new(color, type, coordinates)
    end
    
    Field.new(coordinates.x, coordinates.y, piece)
  end

  # NOTE that this currently does not update undeployed pieces!
  def state_from_string!(string, gamestate)
    fields = Board.new.field_list
    field_descriptors = string.split(' ')
    board_fields = []
    fields.each do |field|
      board_fields << field_from_descriptor(field.coordinates, field_descriptors[field.y * BOARD_SIZE + field.x])
    end
    gamestate.turn = 4
    gamestate.round = 2
    gamestate.add_player(Player.new(Color::RED, "ONE", 0))
    gamestate.add_player(Player.new(Color::BLUE, "TWO", 0))
    gamestate.board = Board.new(board_fields)
  end
end
