class SportStats::Stats
  extend CommandLineReporter

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

  def self.make_teams(league)
    stats[league.to_sym].each do |team|
      SportStats::Team.new(team)
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
    #@all << @team_names

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
    @team_stats = Hash[@team_names.zip(stat_line)]
    #SportStats::Team.new(@team_stats)
    #make_teams
    #binding.pry
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

  def self.display_stats
    table(:border => true) do
      row do
        column('Team', :width => 25)
        column('W', :width => 4)
        column('L', :width => 4)
        column('PCT', :width => 4)
        column('GB', :width => 4)
        column('HOME', :width => 4)
        column('ROAD', :width => 4)
        column('DIV', :width => 4)
        column('CONF', :width => 4)
        column('PPG', :width => 4)
        column('OPP PPG', :width => 4)
        column('DIFF', :width => 4)
        column('STRK', :width => 4)
        column('LAST 10', :width => 4)
      end
      SportStats::Team.all.each do |team|
        row do
          column(team.name)
          column(team.wins)
          column(team.losses)
          column(team.pct)
          column(team.gb)
          column(team.home)
          column(team.road)
          column(team.div)
          column(team.conf)
          column(team.ppg)
          column(team.opp_ppg)
          column(team.diff)
          column(team.strk)
          column(team.l10)
        end
      end
    end
  end

end