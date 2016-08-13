class SportStats::Stats

  @all = []

  def self.get_page(input)
    if input == "nba"
      @doc = Nokogiri::HTML(open("http://www.espn.com/nba/standings/_/group/league"))
    elsif input == "nfl"
      @doc = Nokogiri::HTML(open("http://www.espn.com/nfl/standings"))
    elsif input == "mlb"
      @doc = Nokogiri::HTML(open("http://www.espn.com/mlb/standings/_/group/overall"))
    end
  end

  def self.stats
    stats = {}
    stats[:nba] = self.scrape(get_page("nba"))
    stats[:nfl] = self.scrape(get_page("nfl"))
    stats[:mlb] = self.scrape(get_page("mlb"))
    stats

    # formatted_stats = {}
    # stats.dup.each do |key, value|
    #   # for each League, find the longest team name
    #   longest = stats[key].keys.max_by(&:length).length
    #   stats[key].keys.each do |team_name|
    #     # key = key.dup
    #     space = longest - team_name.length
    #     team_name += " " * space + " "
    #     # key << " " * space + " "
    #     binding.pry
    #   end
    #   stats
    # end

    
    # longest = stats[:nba].keys.max_by(&:length).length
    #longest = @all[0].max_by(&:length).length

    # stats[input.to_sym].keys.each do |key|
    #   space = longest - key.length
    #   key << " " * space + " "
    #   binding.pry
    # end
    #binding.pry
    stats
  end

  def self.format_list(input)

    puts "DID WE MAKE IT HERE?"
  end

  def self.scrape(doc)
    # category_line
    @category_line = []
    doc.search("th span.tooltip").each do |category|
      @category_line << category.text
    end
    @category_line.uniq!

    # team names, not sure if this is the best way to go about this
    team_names = []
    doc.search(".standings-row td").each do |x|
      team_names << x.css("span.team-names").text
    end

    team_names.reject! {|x| x.empty? }

    longest = team_names.max_by(&:length).length
    team_names.each.with_index(1) do |team_name, index|
      space = longest - team_name.length
      if index < 10
        team_name << " " * space + "  "
      else
        team_name << " " * space + " "
      end
    end

    @all << team_names



    # team stat lines
    stat_line = []

    doc.search(".standings-row").each do |col|
      temp_array = []
      col.css("td").each do |x|
        temp_array << x.text if x.text.length < 5
      end
      stat_line << temp_array
    end

    # team_stats {"Team" => ["stats"]}
    team_stats = Hash[team_names.zip(stat_line)]
  end

  def self.find(league, input)
    t = stats[league.to_sym].keys[input.to_i-1]
    s = stats[league.to_sym].values[input.to_i-1]

    print_all_categories
    puts "#{t}\t" + s.join("     ")
  end

  def self.print_three_categories
    print "Team:\t\t\t\t "
    @category_line[0..2].each {|cat| print cat + "     "}
    puts "\n"
  end

  def self.print_all_categories
    print "Team:\t\t\t\t "
    @category_line.each {|cat| print cat + "     "}
    puts "\n"
  end

  def self.display_stats(input)
    case input
    when "nba"
      # print categories here
      print_three_categories

      self.stats[:nba].each.with_index(1) do |(k, v), index|
        puts "#{index}. #{k} -   #{v[0..2].join("    ")}"
      end
    when "nfl"
      self.stats[:nfl].each.with_index(1) do |(k, v), index|
        puts "#{index}. #{k} -   #{v[0..2].join("    ")}"
      end
    when "mlb"
      self.stats[:mlb].each.with_index(1) do |(k, v), index|
        puts "#{index}. #{k} -   #{v[0..2].join("    ")}"
      end
    end
  end

end