require_relative 'piece'
require_relative 'errors'
require_relative 'empty_piece'
require 'colorize'

class Board
  attr_reader :grid

  def initialize
    @grid = Array.new(10) { Array.new(10) {EmptyPiece.new} }
    populate_board

    @cursor_pos = [6,1]
    @selected_pos = nil
    @possible_moves = []
    @turns_with_no_takes = 0
  end

  def select_pos(color, moves)
    if [color, :none].include?(self[@cursor_pos].color)
      @selected_pos = @cursor_pos
      update_possible_moves(moves)
    end
  end

  def update_possible_moves(moves)
    if moves == []
      @possible_moves = self[@selected_pos].moves
    else
      test_board = self.deep_dup
      test_board.do_moves!(moves)
      @possible_moves = test_board[moves.last.last].moves
    end
  end

  def cursor_pos
    @cursor_pos
  end

  def selected_pos
    @selected_pos
  end

  def move_cursor(diff)
    cr, cc = @cursor_pos
    dr, dc = diff
    new_pos = [cr + dr, cc + dc]
    if on_board?(new_pos)
      @cursor_pos = new_pos
    end
  end

  def do_moves(moves)
    raise InvalidMoveError unless valid_move_set(moves)
    do_moves!(moves)
  end

  def do_moves!(moves)
    @turns_with_no_takes += 1
    if moves.length == 1
      move_piece(moves[0].first, moves[0].last)
    else
      move_piece(moves[0].first, moves[0].last)
      do_moves!(moves.drop(1))
    end
  end

  def can_move_more?(moves)
    from_row, from_col= moves.last.first
    last_row, last_col = moves.last.last

    #checks that last move was a jump
    unless (from_row - last_row).abs + (from_col - last_col).abs == 4
      return false
    end

    #checks if there are any more jumps
    test_board = self.deep_dup
    test_board.do_moves!(moves)
    moves = test_board[moves.last.last].moves
    moves.select do |move| 
      (last_row - move[0]).abs == 2  && (last_col - move[1]).abs == 2 
    end != []
  end

  def valid_move_set?(moves)
    begin 
      test_board = self.deep_dup
      test_board.do_moves!(moves)
    rescue InvalidMoveError
      return false
    end
    return true
  end


  def populate_board
    (0..3).each do |row|
      populate_row(row, :black)
    end
    (6..9).each do |row|
      populate_row(row, :white)
    end
  end

  def populate_row(row, color)
    (0..9).each do |col|
      next if (row + col) % 2 == 0
      @grid[row][col] = Piece.new(color, [row, col], self)
    end
  end

  def move_piece(origin, dest)
    self[origin].perform_move(dest)
  end

  def move_piece!(origin, dest)
    self[dest] = self[origin]
    self[origin] = EmptyPiece.new
  end

  def take_piece!(pos)
    self[pos] = EmptyPiece.new
    @turns_with_no_takes = 0
  end

  def over?
    pieces = Hash.new {0}
    @grid.each do |row|
      row.each do |elem|
        pieces[elem.color] += 1
      end
    end
    pieces[:white] == 0 || pieces[:black] == 0
  end

    def render
      system("clear")
      puts "   0  1  2  3  4  5  6  7  8  9"
      @grid.each_with_index do |row, ridx|
        print "#{ridx} "
        row.each_with_index do |elem, cidx|
          render_elem(elem, ridx, cidx)
        end
        puts
      end
    end

    def render_elem(elem, ridx, cidx)
      if [ridx, cidx] == @cursor_pos
        print elem.to_s.on_magenta
      elsif [ridx, cidx] == @selected_pos
        print elem.to_s.on_blue
      elsif @possible_moves.include?([ridx, cidx])
        print elem.to_s.on_light_blue
      elsif (ridx + cidx) % 2 == 1
        print elem.to_s.on_red
      else
       print elem.to_s.on_light_red
      end
    end

    def on_board?(pos)
    pos.all? { |coord| (0..9).to_a.include?(coord) }
  end

  def turns_with_no_takes
    @turns_with_no_takes
  end

  def stalemate?(color)
    @grid.flatten.all? { |piece| piece.has_no_moves(color) }
  end

  def deep_dup
    test_board = Board.new
    grid.each_with_index do |row, ridx|
        row.each_with_index do |elem, cidx|
          test_board[[ridx,cidx]] = elem.dup(test_board)
        end
    end
    test_board
  end

  def grid
    @grid
  end

  def empty?(pos)
    self[pos].empty?
  end

  def [](pos)
    row, col = pos
    @grid[row][col]
  end

  def []=(pos, input)
    row, col = pos
    @grid[row][col] = input
  end
end