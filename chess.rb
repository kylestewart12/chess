class Chess
  attr_accessor :board, :white, :black

  def initialize
    @board = Board.new
    @white = Player.new("white")
    @black = Player.new("black")
    @white.set_board(@board)
    @black.set_board(@board)
  end

end

class Board
  attr_accessor :squares
  def initialize
    @squares = Array.new(8){Array.new(8, "-")}
  end

  def position_index(position)
    x = position[0].ord - 96 - 1
    y = 7 - (position[1] - 1)
    [x, y]
  end

  def on_board(position)
    index = position_index(position)
    x = index[0]
    y=index[1]
    if x < 0 or x > 7 or y < 0 or y > 7
      false
    end
    true
  end

  def add_piece(piece)
    index = position_index(piece.position)
    x = index[0]
    y = index[1]
    @squares[y][x] = piece.symbol
  end

  def move_piece(piece, new_position)
    old_index = position_index(piece.position)
    old_x = old_index[0]
    old_y = old_index[1]
    new_index = position_index(new_position)
    new_x = new_index[0]
    new_y = new_index[1]

    @squares[old_y][old_x] = "-"
    @squares[new_y][new_x] = piece.symbol
  end

  def free?(position)
    index = position_index(position)
    x = index[0]
    y = index[1]
    @squares[y][x] == "-"
  end

  def show
    puts "\t   a b c d e f g h"
    puts
    @squares.each_with_index do |row, i|
      print "\t#{8-i}  "
      row.each do |sym|
        print sym, " "
      end
      print "\n"
    end
  end

end

class Player
  attr_reader :color, :pieces
  attr_accessor :in_check

  def initialize(color)
    @color = color
    @pieces = []
    @in_check = false
  end

  def set_board(board)
    if @color == "white"
      row_1 = 1
      row_2 = 2
    else
      row_1 = 8
      row_2 = 7
    end

    for i in 97..104
      @pieces << Pawn.new(self, [i.chr, row_2], board)
    end
    
    @pieces << Rook.new(self, ["a", row_1], board)
    @pieces << Rook.new(self, ["h", row_1], board)
    @pieces << Knight.new(self, ["b", row_1])
    @pieces << Knight.new(self, ["g", row_1])
    @pieces << Bishop.new(self, ["c", row_1], board)
    @pieces << Bishop.new(self, ["f", row_1], board)
    @pieces << Queen.new(self, ["d", row_1], board)
    @pieces << King.new(self, ["e", row_1])
    
    @pieces.each do |piece|
      board.add_piece(piece)
    end
  end

  def occupied_squares
    occupied = []
    @pieces.each do |piece|
      occupied << piece.position
    end
    occupied
  end

  def make_move(board)
    piece_chosen = false
    move_chosen = false
    until piece_chosen and move_chosen
      
      until piece_chosen
        move_chosen = false
        puts "Select a piece"
        @pieces.each_with_index do |p, i|
          puts "#{i+1}. #{p.class.name} at #{p.position[0]}#{p.position[1]}"
        end
        piece_num = gets.chomp.to_i
        if piece_num > 0 and piece_num <= @pieces.length
          piece_chosen = true
          piece = @pieces[piece_num-1]
        end
      end
      
      until move_chosen
        options = piece.allowed_moves
        puts "Where do you want to move the #{piece.class.name} at #{piece.position[0]}#{piece.position[1]}?"
        options.each_with_index do |m, i|
          puts "#{i+1}. #{m[0]}#{m[1]}"
        end
        puts "#{options.length+1}. Choose a different piece"

        move_num = gets.chomp.to_i
        if move_num >0 and move_num <= options.length
          move_chosen = true
          move = options[move_num-1]
        end
        if move_num == options.length+1
          move_chosen = true
          piece_chosen = false
        end
      end
    end
    puts "#{color.capitalize} moves #{piece.class.name} at " +
      "#{piece.position[0]}#{piece.position[1]} to #{move[0]}#{move[1]}"
    board.move_piece(piece, move)
  end

  
end

class Pawn
  attr_reader :symbol
  attr_accessor :position

  @@name = "pawn"
  def initialize(player, position, board)
    @color = player.color
    @player = player
    @position = position
    @board = board
    if @color == "black"
      @symbol = "\u265F"
    else
      @symbol = "\u2659"
    end
  end

  def allowed_moves
    x = @position[0].ord - 96
    y = @position[1]
    allowed = []

    if @color=="black"
      if y>1 and @board.free?([@position[0], y-1])
        allowed << [@position[0], y-1]
      end
      if y==7 and @board.free?([@position[0], y-2]) and @board.free?([@position[0], y-1])
        allowed << [@position[0], y-2]
      end

      pos = [(x-1+96).chr, y-1]
      if not @board.free?(pos) and @board.on_board(pos) and not @player.occupied_squares.include?(pos)
        allowed << pos
      end

      pos = [(x+1+96).chr, y-1]
      if not @board.free?(pos) and @board.on_board(pos) and not @player.occupied_squares.include?(pos)
        allowed << pos
      end
    else
      if y<8 and @board.free?([@position[0], y+1])
        allowed << [@position[0], y+1]
      end
      if y==2 and @board.free?([@position[0], y+2]) and @board.free?([@position[0], y+1])
        allowed << [@position[0], y+2]
      end

      pos = [(x-1+96).chr, y+1]
      if not @board.free?(pos) and @board.on_board(pos) and not @player.occupied_squares.include?(pos)
        allowed << pos
      end

      pos = [(x+1+96).chr, y+1]
      if not @board.free?(pos) and @board.on_board(pos) and not @player.occupied_squares.include?(pos)
        allowed << pos
      end
    end
    allowed
  end   

end

class Knight
  attr_reader :symbol
  attr_accessor :position

  @@name = "knight"
  def initialize(player, position)
    @color = player.color
    @player = player
    @position = position
  
    if @color == "black"
      @symbol = "\u265E"
    else
      @symbol = "\u2658"
    end
  end

  def allowed_moves
    x = @position[0].ord - 96
    y = @position[1]
    possible_moves = [[x+1,y+2],[x+1,y-2],[x-1,y+2],[x-1,y-2],[x+2,y+1],[x+2,y-1],[x-2,y+1],[x-2,y-1]]
    allowed = []
    possible_moves.each do |move|
      pos = [(move[0]+96).chr, move[1]]
      if move[0]>0 and move[0]<=8 and move[1]>0 and move[1]<=8 and not @player.occupied_squares.include?(pos)
        allowed << pos
      end
    end
    allowed
  end
end

class Bishop
  attr_reader :symbol
  attr_accessor :position

  @@name = "bishop"
  def initialize(player, position, board)
    @color = player.color
    @player = player
    @board = board
    @position = position

    if @color == "white"
      @symbol = "\u2657"
    else
      @symbol = "\u265D"
    end
  end

  def path_free(start, stop)
    x_i = start[0].ord - 96
    y_i = start[1]
    x_f = stop[0].ord - 96
    y_f = stop[1]

    free = true
    if x_f > x_i
      if y_f > y_i
        for i in 1...(x_f-x_i)
          pos = [(x_i+i+96).chr, y_i+i]
          if not @board.free?(pos)
            free = false
          end
        end
      else
        for i in 1...(x_f-x_i)
          pos = [(x_i+i+96).chr, y_i-i]
          if not @board.free?(pos)
            free = false
          end
        end
      end
    else
      if y_f > y_i
        for i in 1...(x_i-x_f)
          pos = [(x_i-i+96).chr, y_i+i]
          if not @board.free?(pos)
            free = false
          end
        end
      else
        for i in 1...(x_i-x_f)
          pos = [(x_i-i+96).chr, y_i-i]
          if not @board.free?(pos)
            free = false
          end
        end
      end
    end
    free
  end

  def allowed_moves
    x = @position[0].ord - 96
    y = @position[1]
    possible_moves = []
    for i in 1..7
      possible_moves << [x+i, y+i]
      possible_moves << [x+i, y-i]
      possible_moves << [x-i, y+i]
      possible_moves << [x-i, y-i]
    end

    allowed = []
    possible_moves.each do |move|
      pos = [(move[0]+96).chr, move[1]]
      if move[0]>0 and move[0]<=8 and move[1]>0 and move[1]<=8 and 
        not @player.occupied_squares.include?(pos) and path_free(@position, pos)
        allowed << pos
      end
    end
    allowed
  end

end

class Rook
  attr_reader :symbol
  attr_accessor :position

  @@name = "rook"
  def initialize(player, position, board)
    @color = player.color
    @player = player
    @board = board
    @position = position

    if @color == "white"
      @symbol = "\u2656"
    else
      @symbol = "\u265C"
    end
  end

  def path_free(start, stop)
    x_i = start[0].ord - 96
    y_i = start[1]
    x_f = stop[0].ord - 96
    y_f = stop[1]

    free = true
    if x_f == x_i
      if y_f > y_i
        for i in 1...(y_f-y_i)
          pos = [(x_i+96).chr, y_i+i]
          if not @board.free?(pos)
            free = false
          end
        end
      else
        for i in 1...(y_i-y_f)
          pos = [(x_i+96).chr, y_i-i]
          if not @board.free?(pos)
            free = false
          end
        end
      end
    else
      if x_f > x_i
        for i in 1...(x_f-x_i)
          pos = [(x_i+i+96).chr, y_i]
          if not @board.free?(pos)
            free = false
          end
        end
      else
        for i in 1...(x_i-x_f)
          pos = [(x_i-i+96).chr, y_i]
          if not @board.free?(pos)
            free = false
          end
        end
      end
    end
    free
  end

  def allowed_moves
    x = @position[0].ord - 96
    y = @position[1]
    possible_moves = []
    for i in 1..7
      possible_moves << [x, y+i]
      possible_moves << [x, y-i]
      possible_moves << [x+i, y]
      possible_moves << [x-i, y]
    end
    allowed = []
    possible_moves.each do |move|
      pos = [(move[0]+96).chr, move[1]]
      if move[0]>0 and move[0]<=8 and move[1]>0 and move[1]<=8 and
         not @player.occupied_squares.include?(pos) and path_free(@position, pos)
        allowed << pos
      end
    end
    allowed
  end

end

class Queen
  attr_reader :symbol
  attr_accessor :position

  @@name = "queen"
  def initialize(player, position, board)
    @color = player.color
    @player = player
    @board = board
    @position = position

    if @color == "white"
      @symbol = "\u2655"
    else
      @symbol = "\u265B"
    end
  end

  def path_free(start, stop)
    x_i = start[0].ord - 96
    y_i = start[1]
    x_f = stop[0].ord - 96
    y_f = stop[1]

    free = true
    if x_f > x_i and y_f != y_i
      if y_f > y_i
        for i in 1...(x_f-x_i)
          pos = [(x_i+i+96).chr, y_i+i]
          if not @board.free?(pos)
            free = false
          end
        end
      else
        for i in 1...(x_f-x_i)
          pos = [(x_i+i+96).chr, y_i-i]
          if not @board.free?(pos)
            free = false
          end
        end
      end
    elsif x_f < x_i and y_f != y_i
      if y_f > y_i
        for i in 1...(x_i-x_f)
          pos = [(x_i-i+96).chr, y_i+i]
          if not @board.free?(pos)
            free = false
          end
        end
      else
        for i in 1...(x_i-x_f)
          pos = [(x_i-i+96).chr, y_i-i]
          if not @board.free?(pos)
            free = false
          end
        end
      end
    elsif x_f == x_i
      if y_f > y_i
        for i in 1...(y_f-y_i)
          pos = [(x_i+96).chr, y_i+i]
          if not @board.free?(pos)
            free = false
          end
        end
      else
        for i in 1...(y_i-y_f)
          pos = [(x_i+96).chr, y_i-i]
          if not @board.free?(pos)
            free = false
          end
        end
      end
    elsif y_f == y_i
      if x_f > x_i
        for i in 1...(x_f-x_i)
          pos = [(x_i+i+96).chr, y_i]
          if not @board.free?(pos)
            free = false
          end
        end
      else
        for i in 1...(x_i-x_f)
          pos = [(x_i-i+96).chr, y_i]
          if not @board.free?(pos)
            free = false
          end
        end
      end
    end
    free
  end

  def allowed_moves
    x = @position[0].ord - 96
    y = @position[1]
    possible_moves = []
    for i in 1..7
      possible_moves << [x+i, y+i]
      possible_moves << [x+i, y-i]
      possible_moves << [x-i, y+i]
      possible_moves << [x-i, y-i]
      possible_moves << [x, y+i]
      possible_moves << [x, y-i]
      possible_moves << [x+i, y]
      possible_moves << [x-i, y]
    end

    allowed = []
    possible_moves.each do |move|
      pos = [(move[0]+96).chr, move[1]]
      if move[0]>0 and move[0]<=8 and move[1]>0 and move[1]<=8 and not allowed.include?(pos) and 
        not @player.occupied_squares.include?(pos) and path_free(@position, pos)
        allowed << pos
      end
    end
    allowed
  end
end

class King
  attr_reader :symbol
  attr_accessor :position

  @@name = "king"
  def initialize(player, position)
    @color = player.color
    @player = player
    @position = position

    if @color == "white"
      @symbol = "\u2654"
    else
      @symbol = "\u265A"
    end
  end

  def allowed_moves
    x = @position[0].ord - 96
    y = @position[1]
    possible_moves = [[x+1,y],[x+1,y+1],[x+1,y-1],[x,y+1],[x,y-1],[x-1,y],[x-1,y+1],[x-1,y-1]]

    allowed = []
    possible_moves.each do |move|
      pos = [(move[0]+96).chr, move[1]]
      if move[0]>0 and move[0]<=8 and move[1]>0 and move[1]<=8 and not @player.occupied_squares.include?(pos)
        allowed << pos
      end
    end
    allowed
  end
end

game = Chess.new
game.board.show
game.black.make_move(game.board)
game.board.show
