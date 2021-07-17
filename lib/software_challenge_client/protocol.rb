# encoding: UTF-8
# frozen_string_literal: true
require 'socket'
require_relative 'board'
require_relative 'move'
require_relative 'piece_type'
require_relative 'player'
require_relative 'network'
require_relative 'client_interface'
require 'rexml/document'
require 'rexml/streamlistener'
require 'builder'

# This class handles communication to the server over the XML communication
# protocol. Messages from the server are parsed and moves are serialized and
# send back.
class Protocol
  include Logging
  include REXML::StreamListener

  # @!attribute [r] gamestate
  # @return [Gamestate] current gamestate
  attr_reader :gamestate
  # @!attribute [rw] roomId
  # @return [String] current room id
  attr_accessor :roomId
  # @!attribute [r] client
  # @return [ClientInterface] current client
  attr_reader :client

  def initialize(network, client)
    @gamestate = GameState.new
    @network = network
    @client = client
    @context = {} # for saving context when stream-parsing the XML
    @client.gamestate = @gamestate
  end

  # starts xml-string parsing
  #
  # @param text [String] the xml-string that will be parsed
  def process_string(text)
    #logger.debug "Parse XML:\n#{text}\n----END XML"
    begin
      REXML::Document.parse_stream(text, self)
    rescue REXML::ParseException => e
      # to parse incomplete xml, ignore missing end tag exceptions
      raise e unless e.message =~ /Missing end tag/
    end
  end

  # called when text is encountered
  def text(text)
    @context[:last_text] = text
  end

  # called if an end-tag is read
  #
  # @param name [String] the end-tag name, that was read
  def tag_end(name)
    case name
    when 'board'
      logger.debug @gamestate.board.to_s
    when 'startTeam'
      @gamestate.add_player(Player.new(Color::RED, "ONE", 0))
      @gamestate.add_player(Player.new(Color::BLUE, "TWO", 0))
      if @context[:last_text] == "ONE"
        @gamestate.start_team = @gamestate.player_one
      else
        @gamestate.start_team = @gamestate.player_two
      end
    when 'team'
      @context[:team] = @context[:last_text]
    when 'int'
      if @context[:team] == "ONE"
        logger.info 'Got player one amber'
        @gamestate.player_one.amber = @context[:last_text].to_i
      else
        logger.info 'Got player two amber'
        @gamestate.player_two.amber = @context[:last_text].to_i
      end
    end
  end

  # called if a start tag is read
  # Depending on the tag the gamestate is updated
  # or the client will be asked for a move
  #
  # @param name [String] the start-tag, that was read
  # @param attrs [Dictionary<String, String>] Attributes attached to the tag
  def tag_start(name, attrs)
    case name
    when 'room'
      @roomId = attrs['roomId']
      logger.info 'roomId : ' + @roomId
    when 'data'
      logger.debug "data(class) : #{attrs['class']}"
      @context[:data_class] = attrs['class']
      if attrs['class'] == 'moveRequest'
        @client.gamestate = gamestate
        move = @client.move_requested
        sendString(move_to_xml(move))
      end
      if attrs['class'] == 'error'
        logger.info "Game ended - ERROR: #{attrs['message']}"
        @network.disconnect
      end
      if attrs['class'] == 'result'
        logger.info 'Got game result'
        @network.disconnect
        @gamestate.condition = Condition.new(nil, '')
      end
    when 'state'
      logger.debug 'new gamestate'
      @gamestate = GameState.new
      @gamestate.turn = attrs['turn'].to_i
      @gamestate.round = @gamestate.turn / 2
      logger.debug "Round: #{@gamestate.round}, Turn: #{@gamestate.turn}"
    when 'board'
      logger.debug 'new board'
      @gamestate.board = Board.new()
    when 'pieces'
      @context[:entry] = :pieces
    when 'coordinates'
      @context[:x] = attrs['x'].to_i
      @context[:y] = attrs['y'].to_i
    when 'piece'
      x = @context[:x]
      y = @context[:y]
      team = Team.find_by_key(attrs['team'].to_sym)
      type = PieceType.find_by_key(attrs['type'].to_sym)
      count = attrs['count'].to_i
      field = Field.new(x, y, Piece.new(team.to_c, type, Coordinates.new(x, y), count))
      @gamestate.board.add_field(field)
    when 'from'
      @context[:from] = Coordinates.new(attrs['x'].to_i, attrs['y'].to_i)
    when 'to'
      from = @context[:from]
      @gamestate.last_move = Move.new(Coordinates.new(from.x, from.y), Coordinates.new(attrs['x'].to_i, attrs['y'].to_i))
    when 'ambers'
      @context[:entry] = :ambers
    when 'winner'
      # TODO
      # winning_player = parsePlayer(attrs)
      # @gamestate.condition = Condition.new(winning_player, @gamestate.condition.reason)
    when 'score'
      # TODO
      # there are two score tags in the result, but reason attribute should be equal on both
      # @gamestate.condition = Condition.new(@gamestate.condition.winner, attrs['reason'])
    when 'left'
      logger.debug 'got left event, terminating'
      @network.disconnect
    when 'sc.protocol.responses.CloseConnection'
      logger.debug 'got left close connection event, terminating'
      @network.disconnect
    end
  end

  # send a xml document
  #
  # @param document [REXML::Document] the document, that will be send to the connected server
  def sendXml(document)
    @network.sendXML(document)
  end

  # send a string
  #
  # @param string [String] The string that will be send to the connected server.
  def sendString(string)
    @network.sendString("<room roomId=\"#{@roomId}\">#{string}</room>")
  end

  # converts "this_snake_case" to "thisSnakeCase"
  def snake_case_to_lower_camel_case(string)
    string.split('_').inject([]) do |result, e|
      result + [result.empty? ? e : e.capitalize]
    end.join
  end

  # Converts a move to XML for sending to the server.
  #
  # @param move [Move] The move to convert to XML.
  def move_to_xml(move)
    builder = Builder::XmlMarkup.new(indent: 2)

    # Converting every the move here instead of requiring the Move
    # class interface to supply a method which returns the XML
    # because XML-generation should be decoupled from internal data
    # structures.

    builder.data(class: 'move') do |d|
      d.from(x: move.from.x, y: move.from.y)
      d.to(x: move.to.x, y: move.to.y)
    end
    
    builder.target!
  end
end
