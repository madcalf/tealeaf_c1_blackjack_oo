# encoding: UTF-8
# Blackjack OOP
require 'pry'
require_relative 'util'
require_relative 'color'

SuitCode = Struct.new(:ascii, :unicode)
Suit = Struct.new(:name, :symbol)

class Card
  SPACE = " "
  attr_accessor :suit, :face, :face_up
  def initialize(face, suit)
    @suit = suit
    @face = face
    @face_up = true
  end
  
  def face_up
    @face_up
  end
  
  def get_colored_str(str)
    if !face_up
      "#{Color.blue_white(str)}#{SPACE}"
    elsif suit.name == "D" || suit.name == "H"
      "#{Color.red_white(str)}#{SPACE}"
    elsif suit.name == "C" || suit.name == "S"
      "#{Color.black_white(str)}#{SPACE}"
    end    
  end
  
  # returns the suit in the upper left corner
  def top
    s = face_up ? ("#{suit.symbol}").ljust(5) : ("#{'///'}").center(5)
    get_colored_str(s)
  end
  
  # returns the suit for lower right corner
  def bottom
    spacer = (suit.symbol.codepoints[0] < 100) ? "" : SPACE
    s = face_up ? ("#{suit.symbol}#{spacer}").rjust(5) : ("#{'///'}").center(5)
    get_colored_str(s)
  end

  # returns the face value of the card in the center
  def to_s
    c = face_up ? ("#{@face}").center(5) : ("#{'///'}").center(5)
    get_colored_str(c)
  end
end   #Card

class Deck  
  def initialize(cards)
    @cards = cards
    @cards.shuffle!
  end
  
  def get_card(face = nil, suit_name = nil)
    # --------------------------------
    # for testing only: if any args passed, return the specified card
    return find_card(face, suit_name) if face && suit_name
    # --------------------------------
    
    # return the 'top' card off the deck, add it back to the 'bottom'.
    card = @cards.shift
    @cards.push(card)
    card
  end
  
  # returns a specific card in the deck. To allow testing specific card combos
  def find_card(face, suit_name)
    card = @cards.select { |card| card.face == face && card.suit.name == suit_name}[0]
  end
    
  def shuffle
    @cards.shuffle!
    # make sure all the cards are face up, since that's our default
    @cards.each { |card| card.face_up = true}
  end
  
  def to_s
    "<Deck> [#{@cards.join(", ")}]"
  end
end #Deck

# this could be any poker or card game hand...
class Hand
  attr_reader :cards
   def initialize
    @cards = []
    @value = 0
  end
end #Hand

# blackjack specific hand
class BlackjackHand < Hand
  def initialize
    super
    @soft_value = nil
  end
  
  def add_card(card)
    @cards << card
    calculate_values
  end
  
  def display_value
    if @soft_value != 0 && @soft_value != @value
      "#{@value}/#{@soft_value}"
    else
      self.final_value
    end
  end
  
  def final_value
    [@value, @soft_value].max
  end
  
  def to_s
    "<hand> cards: [#{@cards.join(', ')}]  value: #{self.final_value}  display: #{display_value}" 
  end

  def calculate_values
    @value = 0
    @soft_value = 0
    
    # preliminary total first. Only count face up cards
    upcards = cards.select { |card| card.face_up }
    upcards.each do |card|
      face = card.face
      if Util.numeric?(face)
        @value += face.to_i
      else 
        @value += (face == "A") ? 1 : 10
      end
    end
    
    # calc the 'soft' value if there are aces
    aces = upcards.select { |card| card.face == "A"}
    if aces.size > 0 
      @soft_value = @value
      aces.each do
        @soft_value += 10 if @soft_value + 10 <= 21
      end
    end
  end
end #BlackjackHand

class Player
  attr_accessor :name, :hand
  
  def initialize(name)
    @name = name
    @hand = BlackjackHand.new
  end
  
  def add_card(card)
    @hand.add_card(card)
  end
  
  def reset
    @hand = BlackjackHand.new
  end
end #Player

# ======================================================
#                          GAME
# ======================================================

class Game
  SUIT_CODES = [SuitCode.new("C", "\u2667"), SuitCode.new("D", "\u2662"), SuitCode.new("H", "\u2661"), SuitCode.new("S", "\u2664") ]
  FACES = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  DASH = Util.unicode_supported? ? "—" : "-"
  HLINE = DASH * 40
    
  def initialize
    @deck = make_deck
    @player = Player.new("Player")
    @dealer = Player.new("Dealer")
    @messages = {game_status: "", player_status: "", player_tally: "", dealer_status: "", dealer_tally: ""}
  end
  
  def run
    flash_title
    @player.name = get_player_name
    Util.clear_screen
    draw_title
    puts "Welcome, #{@player.name}! Ready to play?"
    wait
    play
  end
  
  # ----------------
  # PRIVATE METHODS
  # ----------------
  private 
  
  def reset
    @player.reset
    @dealer.reset
    @deck.shuffle
    clear_messages
    draw
  end
  
  def play
    reset
    wait
    deal
    wait
    player_turn
    if has_blackjack?(@player)
      reveal_dealer_cards
      end_game
    elsif bust?(@player)
      end_game
    else
      dealer_turn
      wait
      end_game
    end
    wait
    puts "Play again?  [Y]es  [N]o"
    play if gets.chomp.downcase == "y"    
  end
  
  def has_blackjack?(which_player)
    which_player.hand.cards.count == 2 && which_player.hand.final_value == 21
  end
  
  def bust?(which_player)
    which_player.hand.final_value > 21
  end
    
  def end_game   
    if @player.hand.final_value == @dealer.hand.final_value
      if has_blackjack?(@player) && !has_blackjack?(@dealer)
        set_message(:game_status, Color.green("#{@player.name} WINS!", nil, false) )
      elsif has_blackjack?(@dealer) && !has_blackjack?(@player)
        set_message(:game_status, Color.red("#{@dealer.name} WINS!", nil, false))
      else
        set_message(:game_status, Color.yellow("PUSH!  #{@player.name} and #{@dealer.name} tie."))
      end
    elsif @player.hand.final_value > 21
      set_message(:game_status, Color.red("#{@dealer.name} WINS!", nil, false))
    elsif @dealer.hand.final_value > 21
      set_message(:game_status, Color.green("#{@player.name} WINS!", nil, false) )
    elsif @player.hand.final_value > @dealer.hand.final_value
      set_message(:game_status, Color.green("#{@player.name} WINS!", nil, false) )
    else
      set_message(:game_status, Color.red("#{@dealer.name} WINS!", nil, false))
    end
    flash_status
  end
  
  def player_turn
    if has_blackjack?(@player)
      set_message(:player_tally, @player.hand.final_value)
      set_message(:player_status, "#{@player.name} has a Blackjack!")
      return
    end
    
    begin
      set_message(:game_status, "Your call, #{@player.name}. [H]it or [S]tay?")
      input = gets.chomp.downcase
      set_message(:game_status, "")
      if input == "h"
        hit(@player)
        if bust?(@player)
          set_message(:player_status, "#{@player.name} busts!")
          break
        end
      elsif input == "s"
        stay(@player)
        break
      end
    end while true
  end
  
  # note: dealer stands on soft 17
  def dealer_turn
    reveal_dealer_cards
    return if has_blackjack?(@dealer)

    wait
    while true
      hit(@dealer) if @dealer.hand.final_value < 17
      if bust?(@dealer)
        set_message(:dealer_status, "#{@dealer.name} busts!")
        break
      elsif @dealer.hand.final_value >= 17
        stay(@dealer)
        break
      end
    end
  end
  
  def reveal_dealer_cards
    wait 1.6
    @dealer.hand.cards.each { |card| card.face_up = true }
    @dealer.hand.calculate_values 
    draw
    set_message(:dealer_tally, "#{@dealer.hand.display_value}")
    wait
    if has_blackjack?(@dealer)
      set_message(:dealer_status, "#{@dealer.name} has a blackjack!")
      set_message(:dealer_tally, "#{@dealer.hand.final_value}")
    end
    draw
  end

  def hit(which_player)
    status_line = (which_player == @player) ? :player_status : :dealer_status
    tally_line = (which_player == @player) ? :player_tally : :dealer_tally
    set_message(status_line, "#{which_player.name} hits.")
    wait(0.5)
    set_message(status_line, "")
    which_player.add_card(@deck.get_card)
    draw
    set_message(tally_line, "#{which_player.hand.display_value}")
    wait
  end
  
  def stay(which_player)
    status_line = (which_player == @player) ? :player_status : :dealer_status
    tally_line = (which_player == @player) ? :player_tally : :dealer_tally
    set_message(status_line, "#{which_player.name} stays at #{which_player.hand.final_value}.")
    set_message(tally_line, which_player.hand.final_value)
  end
  
  # for testing only
  def deal_test_cards(which_player, cards, first_card_down = false)
    cards.each_with_index do | card, i |
      if first_card_down && i == 0
        card.face_up = false
      end
      which_player.add_card(card)
      draw
      wait
    end
  end
  
  def deal
    2.times do |i|
      card = @deck.get_card
      @player.add_card(card)
      draw
      wait
      
      card = @deck.get_card
      card.face_up = false if i == 0
      @dealer.add_card(card)
      draw
      wait     
    end  
    set_message(:player_tally, "#{@player.hand.display_value}")
    set_message(:dealer_tally, "Dealer shows #{@dealer.hand.display_value}")
  end
    
  def get_player_name
    puts "Please tell me your name."
    gets.chomp.capitalize
  end
  
  def set_message(line, str)
    @messages[line] = str 
    draw
  end
  
  def clear_messages
    @messages = {game_status: "", player_status: "", player_tally: "", dealer_status: "", dealer_tally: ""}
    draw
  end
  
  def wait(delay = 0.8)
    sleep delay
  end
  
  def draw
    Util.clear_screen
    draw_title
    draw_player
    draw_dealer
    puts "#{@messages[:game_status]}"
  end
    
  def draw_player
    top = @player.hand.cards.map { |card| card.top }.join()
    mid = @player.hand.cards.map { |card| card }.join()
    bottom = @player.hand.cards.map { |card| card.bottom }.join()
    
    puts "#{@player.name}"
    puts HLINE
    puts "#{top}"
    puts "#{mid}"
    puts "#{bottom}"
    puts HLINE
    puts @messages[:player_tally]
    puts @messages[:player_status]
    puts "\n"
  end
    
  def draw_dealer
    top = @dealer.hand.cards.map { |card| card.top }.join()
    mid = @dealer.hand.cards.map { |card| card }.join()
    bottom = @dealer.hand.cards.map { |card| card.bottom }.join()

    puts "#{@dealer.name}"
    puts HLINE
    puts "#{top}"
    puts "#{mid}"
    puts "#{bottom}"
    puts HLINE
    puts @messages[:dealer_tally] 
    puts @messages[:dealer_status]
  end

  def draw_title(with_marquee = true)
    with_marquee ? chr = "*" : chr = " "
    puts "#{chr * 30}".center(75)
    puts Color.yellow("Tealeaf Casino Blackjack".center(75))
    puts "#{chr * 30}".center(75)
  end
  
  def flash_title  
    Util.clear_screen
    sleep_time = 0.15
    3.times do
      Util.clear_screen
      draw_title(false)
      sleep sleep_time
      Util.clear_screen
      draw_title(true)
      sleep sleep_time
    end
  end   
   
  def flash_status
    str = @messages[:game_status]
    4.times do 
      set_message(:game_status, "")
      sleep 0.3
      set_message(:game_status, str)
      sleep 0.3
    end
  end
  
  def make_deck
    cards = Array.new
    SUIT_CODES.each do |suit_code|
      FACES.each do |face|
        cards << make_card(face, suit_code)
      end
    end
    Deck.new(cards)
  end
  
  def make_card(face, suit_code)
    suit = Suit.new(suit_code.ascii, nil)
    suit.symbol = Util.unicode_supported? ? suit_code.unicode : suit_code.ascii
    Card.new(face, suit)
  end
  
end #Game

Game.new.run
