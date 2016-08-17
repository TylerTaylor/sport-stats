class SportStats::CLI

  def call
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
  end

  def menu
    input = nil
    while input != "q"
      puts "\n"
      list_sports
      puts "Enter the number of the league you'd like more info on, or 'q' to exit:"
      input = gets.strip.downcase
      case input
      when "1"
        puts "More info on the NBA..."
        SportStats::Stats.make_teams("nba")
        SportStats::Stats.display_stats
        submenu("nba")
      when "2"
        puts "More info on the NFL..."
        SportStats::Stats.make_teams("nfl")
        SportStats::Stats.display_stats
        submenu("nfl")
      when "3"
        puts "More info on MLB..."
        SportStats::Stats.make_teams("mlb")
        SportStats::Stats.display_stats
        submenu("mlb")
      when "list"
        list_sports
      end
    end
    puts "\nThanks for using Sport-Stats"
  end

  def submenu(league)
    input = nil
    while input != "q"
      puts "\nIf you want the stats for a specific team only, enter the number next to the team name. Type 'q' to return to the main menu."
      input = gets.strip.downcase
      if input.to_i.to_s == input
        SportStats::Stats.find(league, input)
      end
    end
  end

end