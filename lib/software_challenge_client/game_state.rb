# frozen_string_literal: true

require_relative './util/constants'
require_relative 'player'
require_relative 'board'
require_relative 'condition'

# Ein Spielzustand. Wird vom Server an die Computerspieler übermittelt und
# enthält alles, was der Computerspieler wissen muss, um einen Zug zu machen.
#
# Um eine Liste der gerade möglichen Züge zu bekommen, gibt es die Methode
# {GameState#possible_moves}.
class GameState
  # @!attribute [rw] turn
  # @return [Integer] Aktuelle Zugnummer (von 0 beginnend)
  attr_accessor :turn

  # @!attribute [rw] round
  # @return [Integer] Aktuelle Rundennummer (von 1 beginnend)
  attr_accessor :round

  # @!attribute [r] player_one
  # @return [Player] Der erste Spieler
  attr_reader :player_one

  # @!attribute [r] player_two
  # @return [Player] Der zweite Spieler
  attr_reader :player_two

  # @!attribute [rw] start_team
  # @return [Team] Der Spieler der zuerst zieht
  attr_accessor :start_team

  # @!attribute [rw] board
  # @return [Board] Das aktuelle Spielbrett
  attr_accessor :board

  # @!attribute [rw] last_move
  # @return [Move] Der zuletzt gemachte Zug (ist nil vor dem ersten Zug, also
  #                bei turn == 0)
  attr_accessor :last_move

  # @!attribute [rw] condition
  # @return [Condition] Gewinner und Gewinngrund, falls das Spiel bereits
  #                     entschieden ist, sonst nil.
  attr_accessor :condition

  # Zugriff auf ein Feld des Spielbrettes. Siehe {Board#field}.
  def field(x, y)
    board.field(x, y)
  end

  # Erstellt einen neuen leeren Spielstand.
  def initialize
    @board = Board.new
    @turn = 0
  end

  # Fügt einen Spieler zum Spielzustand hinzu.
  #
  # @param player [Player] Der hinzuzufügende Spieler.
  def add_player(player)
    case player.color
    when Color::RED
      @player_one = player
    when Color::BLUE
      @player_two = player
    end
  end

  # @return [Array<Piece>] Die aktiven roten Spielsteine
  def red_pieces
    board.red_pieces
  end

  # @return [Array<Piece>] Die aktiven blauen Spielsteine
  def blue_pieces
    board.blue_pieces
  end

  # @return [Player] Spieler, der gerade an der Reihe ist.
  def current_player
    turn.even? ? player_one : player_two
  end

  # @return [Player] Spieler, der gerade nicht an der Reihe ist.
  def other_player
    turn.even? ? player_two : player_one
  end

  # @return [Team] Typ des Spielers, der gerade nicht an der Reihe ist.
  def other_team
    other_player.type
  end

  # @return [Bool] Ob diese gamestate in der ersten Runde ist
  def is_first_move?
    round == 1
  end

  # Führt einen Zug auf dem Spielzustand aus. Das Spielbrett wird entsprechend
  # modifiziert.
  #
  # @param move [Move] Der auszuführende Zug.
  def perform!(move)
    GameRuleLogic.perform_move(self, move)
  end

  # @return [Boolean] true, falls das Spiel bereits geendet hat, false bei noch
  #                   laufenden Spielen.
  def game_ended?
    !condition.nil?
  end

  # @return [Player] Der Spieler, der das Spiel gewonnen hat, falls dies schon
  #                  entschieden ist. Sonst false.
  def winner
    condition.nil? ? nil : condition.winner
  end

  # @return [String] Der Grund, warum das Spiel beendet wurde, nil falls das
  #                  Spiel noch läuft.
  def winning_reason
    condition.nil? ? nil : condition.reason
  end

  # Ermittelt die Punkte eines Spielers. Wenn das Spiel durch Erreichen des
  # Rundenlimits beendet wird, hat der Spieler mit den meisten Punkten gewonnen.
  #
  # @param player [Player] Der Spieler, dessen Punkte berechnet werden sollen.
  # @return [Integer] Die Punkte des Spielers
  def points_for_player(_player)
    # TODO
    -1
  end

  def ==(other)
    turn == other.turn &&
      start_color == other.start_color &&
      current_color == other.current_color &&
      blue == other.blue &&
      yellow == other.yellow &&
      red == other.red &&
      green == other.green &&
      board == other.board &&
      lastMove == other.lastMove &&
      condition == other.condition
  end

  # Erzeugt eine Kopie des Spielzustandes. Änderungen an dieser Kopie
  # beeinflussen den originalen Spielzustand nicht. Die Kopie kann also zum
  # testen von Spielzügen genutzt werden.
  def clone
    Marshal.load(Marshal.dump(self))
  end

  # Wechselt den Spieler, der aktuell an der Reihe ist.
  def switch_current_player
    @current_player_color = other_player_color
  end

  # @return [Array<Field>] Alle Felder mit Blöcken des Spielers, der gerade an der Reihe ist.
  def own_fields
    board.fields_of_color(current_player.color)
  end
end
