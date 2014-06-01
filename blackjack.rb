# encoding: UTF-8

Score = Struct.new(:wins, :losses, :ties)
MIN_DECK_SIZE = 10

# Main method
def play_game
  player_score = Score.new(0, 0, 0)
  puts '---- Welcome to BlackJack ----'
  puts ''
  player_name = prompt 'Enter your name: '
  num_of_decks = prompt 'Number of decks: '

  # Always use at least one deck
  num_of_decks = '1' if num_of_decks.to_i < 1
  deck = shuffle_deck(num_of_decks)

  keep_playing = true
  while keep_playing
    if deck.size < MIN_DECK_SIZE
      system('clear')
      puts "Deck only has #{deck.size} cards..."
      sleep 1
      deck = shuffle_deck(num_of_decks)
    end
    case play_hand(deck, player_name)
    when 1  then player_score.wins   += 1
    when -1 then player_score.losses += 1
    when 0  then player_score.ties   += 1
    end
    puts ''
    say "Wins: #{player_score.wins}    " \
        "Losses: #{player_score.losses}    " \
        "Ties: #{player_score.ties}"
    choice = prompt 'Press enter to play another hand (q to quit): '
    keep_playing = choice.downcase != 'q'
  end
end

def play_hand(deck, player_name)
  player_cards = []
  dealer_cards = []

  # Deal initial cards
  player_cards << deck.pop
  dealer_cards << deck.pop
  player_cards << deck.pop
  dealer_cards << deck.pop

  deal(deck: deck, dealer_cards: dealer_cards, player_cards: player_cards,
       player_name: player_name)

  # Check if player won or lost
  score = winner_check(dealer_cards: dealer_cards, player_cards: player_cards)
  return score unless score.nil?

  # Dealer's turn
  deal(deck: deck, dealer_cards: dealer_cards, player_cards: player_cards,
       player_name: player_name, dealer_turn: true, limit: 17)

  # Display winner
  winner_check(dealer_cards: dealer_cards, player_cards: player_cards,
               dealer_turn_finished: true)
end

def deal(args = {})
  default_args = { dealer_turn: false,
                   limit: 21 }
  args = default_args.merge(args)

  cards = args[:dealer_turn] ? args[:dealer_cards] : args[:player_cards]

  while calc_total(cards) < args[:limit]
    show_summary(dealer_cards: args[:dealer_cards],
                 player_cards: args[:player_cards],
                 player_name: args[:player_name],
                 show_dealer_hand: args[:dealer_turn])

    break if player_stands? unless args[:dealer_turn]
    cards << args[:deck].pop
  end
  # Always refresh display and show dealers hidden card after turn is finished.
  show_summary(dealer_cards: args[:dealer_cards],
               player_cards: args[:player_cards],
               player_name: args[:player_name],
               show_dealer_hand: true)
end

def show_summary(args = {})
  default_args = { show_dealer_hand: false }
  args = default_args.merge(args)

  system('clear')
  puts 'Dealer: '
  if args[:show_dealer_hand]
    puts "#{show_cards(args[:dealer_cards])}"
    puts "Total: #{calc_total(args[:dealer_cards])}"
  else
    puts "#{show_card(args[:dealer_cards].first)}  ??"
    puts "Total: #{calc_total([args[:dealer_cards].first])}"
  end
  puts ''
  puts "#{args[:player_name]}:"
  puts "#{show_cards(args[:player_cards])}"
  puts "Total: #{calc_total(args[:player_cards])}"
end

def winner_check(args = {})
  # Outputs message and returns 1, -1, 0 depending on a win, loose, or draw
  # or nil if there is no winner
  default_args = { dealer_turn_finished: false }
  args = default_args.merge(args)

  dealer_total = calc_total(args[:dealer_cards])
  player_total = calc_total(args[:player_cards])

  # Push if both dealer and player have blackjack
  if player_total == 21 && dealer_total == 21
    say 'Push...'
    0
  elsif player_total == 21
    say '21! You win with a BlackJack!'
    1
  elsif player_total > 21
    say 'Busted! Better luck next time...'
    -1
  elsif dealer_total > 21
    say 'Dealer busted.. You win!'
    1
  elsif args[:dealer_turn_finished] && dealer_total == player_total
    say 'Push...'
    0
  elsif args[:dealer_turn_finished] && dealer_total > player_total
    say 'Dealer wins. Beter luck next time...'
    -1
  elsif args[:dealer_turn_finished] && dealer_total < player_total
    say 'You win!'
    1
  else
    nil
  end
end

# Helper methods

def calc_total(cards)
  total = 0
  num_aces = 0
  cards.each do |_suite, value|
    if value == 'A'
      total += 11
      num_aces += 1
    elsif value.to_i == 0
      total += 10
    else
      total += value.to_i
    end
  end

  # Eval aces as 1 if hand would bust otherwise
  num_aces.times do
    total -= 10 if total > 21
  end

  total
end

def show_cards(cards)
  card_str = ''
  cards.each { |c| card_str << show_card(c) + '  ' }
  card_str
end

def show_card(card)
  icons = { clubs: '♧', diamonds: '♢', hearts: '♡', spades: '♤' }
  "#{card[1]}#{icons[card[0]]}"
end

def player_stands?
  begin
    puts ''
    choice = prompt '(h)it or (s)tand: '
  end until (choice.downcase == 'h') || (choice.downcase == 's')
  # return true if player picked stand
  choice.downcase == 's'
end

def prompt(msg)
  print "=> #{msg}"
  gets.chomp
end

def say(msg)
  puts "=> #{msg}"
end

def shuffle_deck(num_of_decks)
  suites = [:clubs, :diamonds, :hearts, :spades]
  cards = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  say "Shuffling #{num_of_decks} deck(s) of cards..."
  deck = suites.product(cards) * num_of_decks.to_i
  deck.shuffle!
  sleep 1
  deck
end

# Start game
play_game
