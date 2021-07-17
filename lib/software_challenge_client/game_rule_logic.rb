# frozen_string_literal: true

require_relative './util/constants'
require_relative 'invalid_move_exception'
require_relative 'move'

require 'set'

# Methoden, welche die Spielregeln von Ostseeschach abbilden.
#
# Es gibt hier viele Helfermethoden, die von den beiden Hauptmethoden {GameRuleLogic#valid_move?}
# und {GameRuleLogic.possible_moves} benutzt werden.
class GameRuleLogic
  include Constants

  SUM_MAX_SQUARES = 89

  # --- Possible Moves ------------------------------------------------------------

  # Gibt alle möglichen Züge für den Spieler zurück, der in der gamestate dran ist.
  # Diese ist die wichtigste Methode dieser Klasse für Schüler.
  #
  # @param gamestate [GameState] Der zu untersuchende Spielstand.
  def self.possible_moves(gamestate)
    moves = []
    pieces = []
    if gamestate.current_player.color == Color::RED
      pieces = gamestate.red_pieces
    else
      pieces = gamestate.blue_pieces
    end

    pieces.each do |p|
      moves.push(*moves_for_piece(gamestate, p))
    end

    moves
  end

  # Gibt einen zufälligen möglichen Zug zurück
  # @param gamestate [GameState] Der zu untersuchende Spielstand.
  def self.possible_move(gamestate)
    possible_moves(gamestate).sample
  end

  # Hilfsmethode um Legezüge für einen [Piece] zu berechnen.
  # @param gamestate [GameState] Der zu untersuchende Spielstand.
  # @param piece [Piece] Der Typ des Spielsteines
  def self.moves_for_piece(gamestate, piece)
    moves = Set[]
    piece.target_coords.each do |c| 
      moves << Move.new(piece.position, c, piece)
    end
    moves.select { |m| valid_move?(gamestate, m) }.to_a
  end

  # --- Move Validation ------------------------------------------------------------

  # Prüft, ob der gegebene [Move] zulässig ist.
  # @param gamestate [GameState] Der zu untersuchende Spielstand.
  # @param move [Move] Der zu überprüfende Zug
  #
  # @return ob der Zug zulässig ist
  def self.valid_move?(gamestate, move)
    return false unless gamestate.current_player.color == move.piece.color

    return false unless gamestate.board.in_bounds?(move.to)

    return false if gamestate.board.field_at(move.to).color == move.piece.color

    return false unless move.piece.target_coords.include? move.to

    # TODO 2022: Forgot checks?

    true
  end

  # Überprüft, ob die gegebene [position] schon mit einer Farbe belegt wurde.
  # @param board [Board] Das aktuelle Spielbrett
  # @param position [Coordinates] Die zu überprüfenden Koordinaten
  def self.obstructed?(board, position)
    !board.field_at(position).empty?
  end

  # --- Perform Move ------------------------------------------------------------

  # Führe den gegebenen [Move] im gebenenen [GameState] aus.
  # @param gamestate [GameState] der aktuelle Spielstand
  # @param move der auszuführende Zug
  def self.perform_move(gamestate, move)
    raise 'Invalid move!' unless valid_move?(gamestate, move)

    if move.instance_of? Move
      target_field = gamestate.board[move.to]

      # Update board pieces if one is stepped on
      if not target_field.empty?
        if target_field.piece.color == COLOR::BLUE
          gamestate.board.red_pieces.remove(target_field.piece)
        else
          gamestate.board.blue_pieces.remove(target_field.piece)
        end

        move.piece.tower_height++

        # Check for high tower
        if move.piece.tower_height >= 3
          gamestate.current_player.amber++
          gamestate.board.field_at(move.to).piece = nil
          move.piece = nil
        end
      end
      
      # Update board fields
      gamestate.board.field_at(move.from).piece = nil
      if move.piece != nil
        gamestate.board.field_at(move.to).piece = move.piece
        move.piece.position = move.to
      end

      # TODO 2022: Missed some perform logic?
    end

    gamestate.turn += 1
    gamestate.last_move = move
  end

  # --- Other ------------------------------------------------------------

  # Prueft, ob ein Spieler im gegebenen GameState gewonnen hat.
  # @param gamestate [GameState] Der zu untersuchende GameState.
  # @return [Condition] nil, if the game is not won or a Condition indicating the winning player
  def self.winning_condition(gamestate)
    if gamestate.player_one.amber >= 2
      Condition.new(gamestate.player_one, "Spieler 1 hat 2 Bernsteine erreicht")
    end

    if gamestate.player_two.amber >= 2
      Condition.new(gamestate.player_two, "Spieler 2 hat 2 Bernsteine erreicht")
    end

    nil
  end
end
