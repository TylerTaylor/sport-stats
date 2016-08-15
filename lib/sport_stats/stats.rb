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

  def self.roster
    roster = {}
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

  def self.format_player_names

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
        team_stat_line << x.text if x.text.length <= 5 # Don't grab the team names
      end
      stat_line << team_stat_line
    end

    # team_stats {"Team" => ["stats"]}
    team_stats = Hash[@team_names.zip(stat_line)]
  end

  def self.scrape_roster(input, doc)
    doc.search(".standings-row td").each do |x|
      if input == x.css("span.team-names").text
        team_page_link = "http://espn.com#{x.search('a').attr('href').value}"
        
        team_page = Nokogiri::HTML(open(team_page_link)) 
        
        @players = []
        team_page.css("span.link-text").each do |text|
          if text.text == "Roster"
            link = Nokogiri::HTML(open(text.parent.attr('href')))
            link.css('tr.evenrow, tr.oddrow').each do |word|
              categories = ["no.", "name", "pos", "age", "height", "weight", "college", "salary"]
              player_info = []
              word.children.each do |word|
                player_info << word.text
              end

              @player_line = Hash[categories.zip(player_info)]
              @players << @player_line
            end
          end
        end
      end
    end
  end

  def self.print_roster(input, doc)
    self.scrape_roster(input, doc) # scrape_roster returns @players with a hash of their info
    
    puts "---------------"
    print @players[0].keys[0..1].join("\t") + "\n"
    puts "---------------"

    @players.each do |player|
      puts player.values[0] + "\t#{player["name"]}"
    end
  end

  def self.find(league, input)
    t = stats[league.to_sym].keys[input.to_i-1]
    s = stats[league.to_sym].values[input.to_i-1]

    print_six_categories(t)
    puts "#{t} " + s[0..5].join("    ")

    self.print_roster(t.strip, get_page(league))
  end

  def self.print_three_categories
    print "Team:\t\t\t\t "
    @category_line[0..2].each {|cat| print cat + "     "}
    puts "\n"
  end

  def self.print_six_categories(input)
    print "Team:" + " " * (input.length-3)

    @category_line[0..5].each do |cat| #{|cat| print cat + "     "}
      if cat.length < 3
        print cat + "    "
      else
        print cat + "    "
      end
    end
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