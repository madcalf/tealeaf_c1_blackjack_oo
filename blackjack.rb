# Blackjack OOP
require_relative 'utils'
SuitCode = Struct.new(:ascii, :unicode)
Suit = Struct.new(:name, :symbol)

class Card
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
    # note need to deal with the unicode issue too if using symbols...
    face_up ? "#{@face}#{@suit.symbol} #{' '*3}" : "#{'##'}#{' '*3}"
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
  
  # returns a specific card in the deck
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

class Hand
  attr_reader :value, :soft_value, :cards
  
  def initialize
    @cards = []
    @value = 0
  end
  
  def add_card(card)
    @cards << card
    calculate_values
  end
  
  def clear
    @cards = []
  end
  
   def value
    [@value, @soft_value].max
  end
  
  def display_value
    (@soft_value == 0 || @soft_value == @value) ? "#{self.value}" : "#{@value}/#{@soft_value}"
    # MAY MOD THIS TO DISPLAY BLACKJACK INSTEAD OF 11/21
  end
  
  def to_s
    # "<hand> cards: [#{@cards.join(', ')}]  value: #{@value}  soft_value: #{@soft_value}"
    "<hand> cards: [#{@cards.join(', ')}]  value: #{self.value}  final: #{display_value}" 
  end
  
  private

  def calculate_values
    @value = 0
    @soft_value = 0
    
    # preliminary total first
    @cards.each do |card|
      face = card.face
      if Utils.numeric?(face)
        @value += face.to_i
      else 
        @value += (face == "A") ? 1 : 10
      end
    end
    
    # calc the 'soft' value if there are aces
    aces = @cards.select { |card| card.face == "A"}
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
    @hand = Hand.new
  end
  
  def add_card(card)
    @hand.add_card(card)
  end
end   #Player

class Dealer < Player
  def initialize(name)
    super
  end
end   #Dealer


class Game
  SUIT_CODES = [SuitCode.new("C", "\u2667"), SuitCode.new("D", "\u2662"), SuitCode.new("H", "\u2661"), SuitCode.new("S", "\u2664") ]
  # SUIT_CODES = {SuitCode.new("C", "\u2667"), SuitCode.new("D", "\u2662"), SuitCode.new("H", "\u2661"), SuitCode.new("S", "\u2664")}
  # SUIT_CODES = [{'C' => "\u2667"}, {'D' => "\u2662"}, {'H' => "\u2661"}, {'S' => "\u2664"}]

  FACES = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  DASH = "-"
  HLINE = DASH * 75
  
  # attr_accessor :player, :dealer, :deck
  
  def initialize
    @deck = make_deck
    @player = Player.new("Player")
    @dealer = Dealer.new("Dealer")
    @messages = []
  end
  
  def run
    # flash_title
    # @player = Player.new(get_player_name)
    system 'clear' # TEMP
    # @player = Player.new("D")
    @player.name = "Player"
    puts "Welcome, #{@player.name}! Ready to play?"
    puts "deck:#{@deck}    card: #{@deck.get_card}"
    deal_to_player
    deal_to_dealer
    
    # --- TEMP 
    # deal_card(@player, "A", "D")
    # 4.times do
    #   deal_card(@player)
    #   puts "player hand: #{@player.hand}"
    # end
  end
  
  # ----------------
  # PRIVATE METHODS
  # ----------------
  private 
  
  def play
    
  end
  
  def wait(delay = 1.0)
    sleep delay
  end
  
  def deal_to_player
    2.times do
      card = @deck.get_card
      card.face_up = true
      @player.add_card(card)
      draw
      wait
    end
  end
  
  def deal_to_dealer
    2.times do |i|
      card = @deck.get_card
      card.face_up = false if i == 0
      @dealer.add_card(card)
      draw
      wait
    end
  end
    
  def get_player_name
    puts "Please tell me your name."
    gets.chomp.capitalize
  end
  
  def draw
    system 'clear'
    draw_title
    puts "#{@player.name}#{@dealer.name.rjust(40)}"
    puts HLINE
    draw_cards
    puts HLINE   
    draw_text
  end
  
  def draw_cards
    player_str = ""
    dealer_str = ""
    @player.hand.cards.each do |card|
      player_str += "#{card}"
    end
    
    @dealer.hand.cards.each do |card|
      dealer_str += "#{card}"
    end
    puts "#{player_str.ljust(40)}#{dealer_str}"
  end
  
  def draw_text
    puts @messages.join("\n")
  end
  
  def draw_title(with_marquee = true)
    with_marquee ? chr = "*" : chr = " "
    puts
    puts "#{chr * 30}".center(75)
    puts "Tealeaf Casino Blackjack".center(75)
    puts "#{chr * 30}".center(75)
    puts
  end
  
  def flash_title  
    system 'clear'
    sleep_time = 0.15
    # flash the marquee to start
    4.times do
      chr = ' '
      system 'clear'
      draw_title(false)
      sleep sleep_time
      system 'clear'
      draw_title(true)
      sleep sleep_time
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

