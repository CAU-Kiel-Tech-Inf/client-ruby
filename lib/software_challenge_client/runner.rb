# encoding: UTF-8
# frozen_string_literal: true
require_relative 'board'
require_relative 'client_interface'
require_relative 'network'

# Klasse zum Starten einer neue Verbindung zum Spielserver und Verarbeiten der Nachrichten des Servers.
class Runner
  include Logging

  def initialize(host, port, client, reservation = nil)
    logger.info 'Software Challenge 2022'
    logger.info 'Ruby Client'
    logger.info "Host: #{host}"
    logger.info "Port: #{port}"

    board = Board.new
    @network = Network.new(host, port, board, client, reservation)
  end

  def start
    @network.connect
    unless @network.connected
      logger.error 'Not connected'
      return
    end

    while @network.connected
      @network.processMessages
      sleep(0.01)
    end

    logger.info 'Program end...'
    @network.disconnect
  end
end
