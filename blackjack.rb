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
  
  def to_s
    c = face_up ? "#{SPACE}#{@face}#{@suit.symbol}#{SPACE * 2}" : "#{SPACE}#{'///'}#{SPACE}"
    if suit.name == "H" || suit.name == "D"
      sprintf("%s %s", Color.red(c), SPACE)
      # sprintf("%s %s", c, SPACE)
    else 
      sprintf("%s %s", Color.black(c), SPACE)
      # sprintf("%s %s", c, SPACE)
    end
    # the original uncolored way
    # str = face_up ? "#{@face}#{@suit.symbol} #{' '*3}" : "#{'##'}#{' '*3}"
  end
end   #Card

# do you want to have a stash that does not get altered and one that does when dealing?
# so we can simply restore the orig deck on reset or shuffle
# or maybe we just move the cards into a dealt array, and return them to cards on reset/shuffle
class Deck  
  def initialize(cards)
    @cards = cards
    @cards.shuffle!
  end
  
  # take the 'top' card off the deck, then add it back to the 'bottom'.
  def get_card(face = nil, suit_name = nil)
    
    # for testing only: if any args passed, return the specified card
    return find_card(face, suit_name) if face && suit_name
    
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
  end
  
  def to_s
    "<Deck> [#{@cards.join(", ")}]"
  end
end   #Deck

# this could be any poker or card game hand...
class Hand
  attr_reader :cards
   def initialize
    @cards = []
    @value = 0
  end
end

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
    # puts "soft_value: #{@soft_value} value: #{@value}"
  end
  
  def final_value
    [@value, @soft_value].max
  end
  
  def clear
    @cards = []
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
end   #Hand

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
end   #Player

class Dealer < Player
  def initialize(name)
    super
  end
end   #Dealer

# ======================================================
#                          GAME
# ======================================================

class Game
  SUIT_CODES = [SuitCode.new("C", "\u2667"), SuitCode.new("D", "\u2662"), SuitCode.new("H", "\u2661"), SuitCode.new("S", "\u2664") ]
  FACES = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  DASH = "-"
  HLINE = DASH * 45 #75
    
  def initialize
    @deck = make_deck
    @player = Player.new("Player")
    @dealer = Dealer.new("Dealer")
    @messages = {game_status:"", player_status:"", dealer_status: ""}
  end
  
  def run
    flash_title
    @player.name = get_player_name
    system 'clear'
    draw_title
    puts "Welcome, #{@player.name}! Ready to play?"
    wait(1)
    play
  end
  
  # ----------------
  # PRIVATE METHODS
  # ----------------
  private 
  
  def reset
    @player.reset
    @dealer.reset
    clear_messages
    draw
  end
  
  def play
    reset
    wait
    deal_to_player
    deal_to_dealer
    wait
    # test if the original deal results in a blackjack for player and/or dealer
    if has_blackjack?(@player)
      add_message(:player_status, "#{@player.name} has a blackjack!")
      wait
      show_dealer_cards
      draw
      wait
      if has_blackjack?(@dealer)
        add_message(:dealer_status, "#{@dealer.name} has a blackjaack!")
        wait
      end
      end_game
    else
      player_turn
      if bust?(@player)
        end_game
      else
        wait(2)
        dealer_turn
        wait
        end_game
      end
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
      add_message(:game_status, "PUSH (#{@player.name} and #{@dealer.name} tie)!")
    elsif @player.hand.final_value > 21
      add_message(:game_status, "#{@dealer.name} WINS!")
    elsif @dealer.hand.final_value > 21
      add_message(:game_status, "#{@player.name} WINS!")
    elsif @player.hand.final_value > @dealer.hand.final_value
      add_message(:game_status, "#{@player.name} WINS!")
    else
      add_message(:game_status, "#{@dealer.name} WINS!")
    end
    flash_status
    # draw
  end
  
  def player_turn
    begin
      add_message(:game_status, "Your call, #{@player.name}. [H]it or [S]tay?")
      input = gets.chomp.downcase
      add_message(:game_status, "")
      if input == "h"
        hit(@player)
        if bust?(@player)
          add_message(:player_status, "#{@player.name} busts!")
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
    add_message(:game_status, "Dealer's turn")
    wait
    show_dealer_cards
    wait
    while true
      hit(@dealer) if @dealer.hand.final_value < 17
      if bust?(@dealer)
        add_message(:dealer_status, "#{@dealer.name} busts!")
        break
     elsif @dealer.hand.final_value >= 17
        stay(@dealer)
        break
      end
    end
  end
  
  def show_dealer_cards
    @dealer.hand.cards.each { |card| card.face_up = true }
    @dealer.hand.calculate_values 
    add_message(:dealer_tally, "#{@dealer.hand.display_value}")
    draw
  end
  
  def hit(which_player)
    status_line = (which_player == @player) ? :player_status : :dealer_status
    tally_line = (which_player == @player) ? :player_tally : :dealer_tally
    add_message(status_line, "#{which_player.name} hits.")
    wait(0.5)
    add_message(status_line, "")
    which_player.add_card(@deck.get_card)
    draw
    add_message(tally_line, "#{which_player.hand.display_value}")
    wait
  end
  
  def stay(which_player)
    status_line = (which_player == @player) ? :player_status : :dealer_status
    tally_line = (which_player == @player) ? :player_tally : :dealer_tally
    add_message(status_line, "#{which_player.name} stays at #{which_player.hand.final_value}.")
    add_message(tally_line, which_player.hand.final_value)
  end
  
  def deal_to_player
    # --- TEMP. These are test deals
    # @player.add_card(@deck.get_card("A", "D"))
    # @player.add_card(@deck.get_card("J", "H"))
    # --------------
    
    2.times do
      card = @deck.get_card  # UNCOMMENT THESE LINES WHEN DONE TESTING!!
      card.face_up = true
      @player.add_card(card)
      draw
      wait
    end
    add_message(:player_tally, "#{@player.hand.display_value}")
  end
  
  def deal_to_dealer
    # --- TEMP. These are test deals
    # @dealer.add_card(@deck.get_card("A", "C"))
    # @dealer.add_card(@deck.get_card("K", "D"))
    # --------------

    2.times do |i|
      card = @deck.get_card
      card.face_up = false if i == 0
      @dealer.add_card(card)
      draw
      wait
    end
    add_message(:dealer_tally, "Dealer shows #{@dealer.hand.display_value}")
  end
    
  def get_player_name
    puts "Please tell me your name."
    gets.chomp.capitalize
  end
  
  def add_message(line, str)
    @messages[line] = str 
    draw
  end
  
  def clear_messages
    @messages = {game_status:"", player_status:"", dealer_status: ""}
    draw
  end
  
  def wait(delay = 1)
    sleep delay
  end
  
  def draw
    system 'clear'
    draw_title
    draw_player
    draw_dealer
    puts "\n#{@messages[:game_status]}"
  end
    
  def draw_player
    puts "#{@player.name}"
    puts HLINE
    str = ""
    @player.hand.cards.each { |card| str += "#{card}" }
    puts "#{str}"
    puts HLINE
    puts @messages[:player_tally]
    puts @messages[:player_status]
    puts "\n\n\n"
  end
    
  def draw_dealer
    puts "#{@dealer.name}"
    puts HLINE
    str = ""
    @dealer.hand.cards.each { |card| str += "#{card}" }
    puts "#{str}"
    puts HLINE
    puts @messages[:dealer_tally] 
    puts @messages[:dealer_status]
  end

  def draw_title(with_marquee = true)
    with_marquee ? chr = "*" : chr = " "
    puts "#{chr * 30}".center(75)
    puts "Tealeaf Casino Blackjack".center(75)
    puts "#{chr * 30}".center(75)
    # puts "\n"
  end
  
  def flash_title  
    system 'clear'
    sleep_time = 0.15
    3.times do
      chr = ' '
      system 'clear'
      draw_title(false)
      sleep sleep_time
      system 'clear'
      draw_title(true)
      sleep sleep_time
    end
  end   
   
  def flash_status
    str = @messages[:game_status]
    4.times do 
      add_message(:game_status, "")
      sleep 0.3
      add_message(:game_status, str)
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
    suit.symbol = unicode_supported? ? suit_code.unicode : suit_code.ascii
    Card.new(face, suit)
  end
  
  # test if unicode support is available 
  # found this test here: http://rosettacode.org/wiki/Terminal_control/Unicode_output#Ruby 
  def unicode_supported?
    ENV.values_at("LC_ALL","LC_CTYPE","LANG").compact.first.include?("UTF-8")
  end  
  
end   #Game

Game.new.run

