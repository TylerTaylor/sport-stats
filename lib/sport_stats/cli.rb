class SportStats::CLI

  def call
    puts "Sport Stats: \n"
    list_sports
    menu
  end

  def list_sports
    puts "Which league would you like to view?"
    puts """
      1. NBA
      2. NFL
      3. MLB
    """
    #@stats = SportStats::Stats.stats
  end

  def menu
    input = nil
    while input != "exit"
      puts "Enter the number or name of the league you'd like more info on:"
      input = gets.strip.downcase
      case input
      when "1"
        puts "More info on the NBA..."
      when "2"
        puts "More info on the NFL..."
      when "3"
        puts "More info on MLB..."
      when "list"
        list_sports
      else
        puts "I don't recognize that command. Please type list or exit."
      end
    end
  end

end