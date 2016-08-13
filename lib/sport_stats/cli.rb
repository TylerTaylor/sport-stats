class SportStats::CLI

  def call
    list_sports
    menu
  end

  def list_sports
    puts "Sport Stats: \n"
    puts "Which league would you like to view?"
    puts """
      1. NBA
      2. NFL
      3. MLB
    """
    @stats = SportStats::Stats.stats
  end

  def menu
    input = nil
    while input != "exit"
      puts "\n"
      puts "Enter the number or name of the league you'd like more info on:"
      input = gets.strip.downcase
      case input
      when "1"
        puts "More info on the NBA..."
        SportStats::Stats.display_stats("nba")
        submenu("nba")
      when "2"
        puts "More info on the NFL..."
        SportStats::Stats.display_stats("nfl")
        submenu("nfl")
      when "3"
        puts "More info on MLB..."
        SportStats::Stats.display_stats("mlb")
        submenu("nfl")
      when "list"
        list_sports
      else
        puts "I don't recognize that command. Please type list or exit."
      end
    end
  end

  def submenu(league)
    input = ""
    while input != "q"
      puts "\nIf you want the stats for a specific team only, enter the number next to the team name. Type 'q' to return to the main menu."
      input = gets.strip.downcase
      if input.to_i.to_s == input
        binding.pry
        SportStats::Stats.find(league, input)
      end
    end
  end

end