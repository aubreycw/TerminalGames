require_relative 'player'
require_relative 'errors'
require 'io/console'

class HumanPlayer < Player
	KEYBINDINGS = {
  'w' => [-1, 0], 'a' => [0, -1],
  's' => [1, 0],  'd' => [0, 1]
	}


	def initialize(color)
		super
		@selected_moves = []
	end
	
	def get_input
		@selected_moves = []
		input = nil
		until input
			input = input_from_cursor("it is #{color.to_s}'s turn")
		end
		input
	end

	def get_key
		input = $stdin.getch
		return input if ['w', 'a', 's', 'd', 'p', ' ', 'l', 'q', "\r"].include?(input)
		get_key
	end

	def input_from_cursor(message)
	    board.render
	    puts message
		input = get_key

	    case input
	    when ' '
	    	return space_pressed
	    	
	    when "\r"
	        return enter_pressed

	  	when "p"
	  		return nil if @selected_moves == []
	  		return @selected_moves

	  	when "q"
	  		raise QuitGame, "q"

	  	when "l"
	  		raise SaveGame, "s"

	    else
	      board.move_cursor(KEYBINDINGS[input])
	      return nil
	    end
	end  

	def space_pressed
		begin
  			board.select_pos(@color, @selected_moves)
  			return nil
  		rescue EmptyPieceError
  			return nil
	    end
	end

	def enter_pressed
		result = [board.selected_pos, board.cursor_pos]
      	return nil if result.first.nil?
      	@selected_moves << result
      	begin
	      	if board.can_move_more?(@selected_moves)
	      		board.select_pos(@color, @selected_moves)
	      		return nil
	      	else
	      		return @selected_moves
	      	end
	  	rescue InvalidMoveError
	  		return nil
	  	end  
	end
 end