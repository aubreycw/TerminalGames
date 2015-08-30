require_relative 'player'
require_relative 'errors'
require_relative 'board'

#alpha beta pruning
#change moves in pieces to also include double jumps

class ComputerPlayer < Player

	def initialize(color, lookahead)
		super(color)
		@n = lookahead
	end

	def get_input
		possible_moves = moves(@board, @color)
		#puts "possible jumps are #{possible_moves.select{|move| (move.first.first.first - 
		#move.first.last.first).abs == 2}}"
		possible_boards = possible_moves.map { |move| make_move(board, move) }
		values = possible_boards.map { |board| minimax(@n-1, board, true)}
		best_index = values.each_with_index.max[1]
		if possible_moves[best_index]
			possible_moves[best_index]
		else
			:lose
		end
	end

	def minimax(n, board, my_turn)
		return value(board) if n == 0
		return value(board) if board.over?
		return -20 if board.stalemate?(@color)
		
		if my_turn
			possible_moves = moves(board, @color)
			#possible_moves += jump_moves(@board, @color)
			possible_boards = possible_moves.map { |move| make_move(board, move) }
			values = possible_boards.map { |board| minimax(n-1, board, false)}
			values.max
		else
			possible_moves = moves(board, other_color)
			#possible_moves += jump_moves(@board, @color)
			possible_boards = possible_moves.map { |move| make_move(board, move) }
			values = possible_boards.map { |board| minimax(n-1, board, true)}
			values.min
		end
	end

	def other_color
		@color == :black ? :white : :black
	end

	def moves(board, color)
		slide_moves = []
		jump_moves = []
		my_pieces = board.grid.flatten.select { |piece| piece.color == @color}
		my_pieces.each do |piece|
			initial_pos = piece.pos
			piece.moves.each do |final_pos|
				if (final_pos[0] - initial_pos[0]).abs == 2
					jump_moves << [[initial_pos, final_pos]]
				else
					slide_moves << [[initial_pos, final_pos]]
				end
			end
		end
		#puts "Starting board"
		#board.render
		#puts "jump_moves are #{jump_moves}"
		slide_moves + expand_jumps(jump_moves, board)
	end

	# finds multi_jump moves
	def expand_jumps(moves, current_board)
		#puts "in expand_jumps jump_moves are #{moves}"
		return [] if moves == []

		new_moves = []
		#puts "moves is #{moves}"
		moves.each do |move_set|
			#puts "move_set is #{move_set}"
			test_board = current_board.deep_dup

			#puts "BOARD HERE"
			#test_board.render
			#puts "move_set is #{move_set}"
			test_board.do_moves!(move_set)

			next_location = move_set.last.last
			#puts "next_location is #{next_location}"
			next_jumps = test_board[next_location].moves.select do |move|
				move.first.abs == 2 ? true : false
			end
			next_jumps.each do |jump|
				new_moves << move_set + [[next_location, jump]]
			end
		end
		moves + expand_jumps(new_moves, current_board)

	end


	def value(board)
		# your pieces - opponents pieces
		result = 0
		board.grid.flatten.each do |elem|
			next if elem.empty?
			if elem.color == @color
				result += 1
			else
				result -= 1
			end
		end
		result
	end

	def make_move(board, moves)
		new_board = board.deep_dup
		new_board.do_moves!(moves)
		new_board
	end
end