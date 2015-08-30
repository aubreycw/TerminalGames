require_relative 'errors'
require 'colorize'

class Piece
	attr_reader :king, :color, :pos
	attr_accessor :board

	def initialize(color, pos, board, king = false)
		@color, @pos, @board, @king = color, pos, board, king
	end

	def has_no_moves(xcolor)
		return true if @color != xcolor
		moves == []
	end

	def moves
		all_moves = []
		row, col = @pos
		move_diffs.each do |move_diff|
			drow, dcol = move_diff
			new_move = [row + drow, col + dcol]
			if valid_slide?(new_move) || valid_jump?(new_move)
				all_moves << new_move
			end
		end
		all_moves
	end

	def perform_move(new_pos)
		raise InvalidMoveError unless moves.include?(new_pos)

		if valid_slide?(new_pos)
			perform_slide(new_pos)
			return
		elsif valid_jump?(new_pos)
			perform_jump(new_pos)
			return
		end

		raise InvalidMoveError
	end

	def perform_slide(new_pos)
		raise InvalidSlideError unless valid_slide?(new_pos)

		board.move_piece!(@pos, new_pos)
		@pos = new_pos 
		maybe_promote
	end

	def perform_jump(new_pos)
		raise InvalidJumpError unless valid_jump?(new_pos)

		#finds location of jumped piece
		nr, nc = new_pos
		cr, cc = @pos
		jump_piece_pos = [cr + (nr - cr)/2, cc + (nc - cc)/2 ]

		board.move_piece!(@pos, new_pos)
		@pos = new_pos
		maybe_promote
		board.take_piece!(jump_piece_pos)
		
	end

	def valid_slide?(new_pos)
		return false unless on_board?(new_pos) && board.empty?(new_pos)
		new_pos.zip(@pos).all? {|new_p, current_p| (new_p - current_p).abs == 1}
	end

	def valid_jump?(new_pos)
		return false unless on_board?(new_pos) && board.empty?(new_pos)
		return false unless new_pos.zip(@pos).all? do |new_p, current_p|
			 (new_p - current_p).abs == 2
		end

		#finds location of jumped piece
		nr, nc = new_pos
		cr, cc = @pos
		jump_piece_row = cr + (nr - cr)/2
		jump_piece_col = cc + (nc - cc)/2
		jump_piece = board.grid[jump_piece_row][jump_piece_col]

		!jump_piece.empty? && jump_piece.color != self.color
	end

	def move_diffs
		if king?
			return [[1, 1], [1, -1], [-1, 1], [-1, -1],
					[2, 2], [2, -2], [-2, 2], [-2, -2]]
		end
		dir = @color == :black ? 1 : -1
		[[dir, 1], [dir, -1], [dir*2, 2], [dir*2, -2]]
	end

	def maybe_promote
		return false if king?
		if self.color == :black && @pos[0] == 9
			@king = true
			return true
		elsif self.color == :white && @pos[0] == 0
			@king = true
			return true
		end
		false
	end

	def king?
		self.king
	end

	def on_board?(pos)
		pos.all? { |coord| (0..9).to_a.include?(coord) }
	end

	def empty?
		false
	end

	def to_s
		return " ♛ ".colorize(color)if king?
		" ⬤ ".colorize(color)
	end

	def dup(board)
		Piece.new(@color, @pos, board, @king)
	end

end