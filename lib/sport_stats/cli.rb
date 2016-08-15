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
      puts "Enter the number or name of the league you'd like more info on, or type 'exit' to exit:"
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
        submenu("mlb")
      when "list"
        list_sports
      end
    end
    puts "\nThanks for using Sport-Stats"
  end

  def submenu(league)
    input = ""
    while input != "q"
      puts "\nIf you want the stats for a specific team only, enter the number next to the team name. Type 'q' to return to the main menu."
      input = gets.strip.downcase
      if input.to_i.to_s == input
        SportStats::Stats.find(league, input)
        #SportStats::Stats.scrape_roster(input)
      end
    end
  end

end