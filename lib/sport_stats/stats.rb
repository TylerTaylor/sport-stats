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
  end

  def self.format_team_names
    longest = @team_names.max_by(&:length).length
    @team_names.each.with_index(1) do |team_name, index|
      space = longest - team_name.length
      if index < 10
        team_name << " " * space + "  "
      else
        team_name << " " * space + " "
      end
    end
  end

  def self.scrape(doc)
    # category_line
    @category_line = []
    doc.search("th span.tooltip").each do |category|
      @category_line << category.text
    end
    @category_line.uniq!

    # team names, not sure if this is the best way to go about this
    @team_names = []
    doc.search(".standings-row td").each do |x|
      @team_names << x.css("span.team-names").text
    end
    @team_names.reject! {|x| x.empty? }
    self.format_team_names
    @all << @team_names

    # team stat lines
    stat_line = []
    doc.search(".standings-row").each do |col|
      team_stat_line = []
      col.css("td").each do |x|
        team_stat_line << x.text if x.text.length < 5 # Don't grab the team names
      end
      stat_line << team_stat_line
    end

    # team_stats {"Team" => ["stats"]}
    team_stats = Hash[@team_names.zip(stat_line)]
  end

  def self.scrape_roster

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
      print_three_categories
      self.stats[:nba].each.with_index(1) do |(k, v), index|
        puts "#{index}. #{k} -   #{v[0..2].join("    ")}"
      end
    when "nfl"
      print_three_categories
      self.stats[:nfl].each.with_index(1) do |(k, v), index|
        puts "#{index}. #{k} -   #{v[0..2].join("    ")}"
      end
    when "mlb"
      print_three_categories
      self.stats[:mlb].each.with_index(1) do |(k, v), index|
        puts "#{index}. #{k} -   #{v[0..2].join("    ")}"
      end
    end
  end

end