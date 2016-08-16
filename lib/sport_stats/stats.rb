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

  def self.make_teams(league)
    SportStats::Team.all.clear
    stats[league.to_sym].each do |team|
      SportStats::Team.new(team)
    end
  end

  def self.make_players(team, doc)
    self.scrape_roster(team, doc) # scrape_roster returns @players with a hash of their info
    @players.each do |player|
      SportStats::Player.new(player)
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
            
            @categories = []
            link.search('tr.colhead').first.children.each do |cat|
              @categories << cat.text
            end

            link.css('tr.evenrow, tr.oddrow').each do |word|
              #categories = ["no.", "name", "pos", "age", "height", "weight", "college", "salary"]
              player_info = []
              word.children.each do |word|
                player_info << word.text
              end

              @player_line = Hash[@categories.zip(player_info)]
              @players << @player_line
            end
          end
        end
      end
    end
  end

  def self.print_roster
    obj = SportStats::Player.all.first # grab a player object to get the titles
    titles = []
    obj.instance_variables.map do |var|
      if obj.instance_variable_get(var) != nil

        var = var.to_s
        var[0] = ''
        titles << var.upcase
      end
    end

    table(:border => true) do
      row do
        titles.each do |title|
          if title == "NAME" || title == "COLLEGE" || title == "BIRTH_PLACE" ||
            title == "SALARY"
            column(title, :width => 20)
          else
            column(title, :width => 6)
          end
        end
      end
      SportStats::Player.all.each do |player|
        row do
          player.instance_variables.map do |var|
            if player.instance_variable_get(var) != nil
              column(player.instance_variable_get(var))
            end
          end
        end
      end
    end
    
    # table(:border => true) do
    #   row do
    #     column('NO.', :width => 3, :align => 'center')
    #     column('NAME', :width => 25, :align => 'center')
    #     column('POS', :width => 4, :align => 'center')
    #     column('AGE', :width => 4, :align => 'center')
    #     column('HEIGHT', :width => 6, :align => 'center')
    #     column('WEIGHT', :width => 6, :align => 'center')
    #     column('COLLEGE', :width => 18, :align => 'center')
    #     column('SALARY', :width => 14, :align => 'center')
    #   end
    #   SportStats::Player.all.each do |player|
    #     row do
    #       column(player.no, :align => 'center')
    #       column(player.name, :align => 'center')
    #       column(player.pos, :align => 'center')
    #       column(player.age, :align => 'center')
    #       column(player.height, :align => 'center')
    #       column(player.weight, :align => 'center')
    #       column(player.college, :align => 'center')
    #       column(player.salary, :align => 'center')
    #     end
    #   end
    # end
  end

  def self.find(league, input)
    self.display_team(input.to_i-1)

    team = stats[league.to_sym].keys[input.to_i-1]
    self.make_players(team, get_page(league))
    self.print_roster
    SportStats::Player.all.clear
  end

  def self.display_stats
    table(:border => true) do
      row do
        column('', :width => 2, :align => 'left')
        column('Team', :width => 25)
        column('W', :width => 5)
        column('L', :width => 5)
        column('PCT', :width => 5)
        column('GB', :width => 5)
        column('HOME', :width => 5)
        column('ROAD', :width => 5)
        column('DIV', :width => 5)
        column('CONF', :width => 5)
        column('PPG', :width => 5)
        column('OPP PPG', :width => 5)
        column('DIFF', :width => 5)
        column('STRK', :width => 5)
        column('LAST 10', :width => 5)
      end
      SportStats::Team.all.each.with_index(1) do |team, index|
        row do
          column("#{index}")
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

  def self.display_team(id)
    table(:border => true) do
      row do
        column('Team', :width => 25)
        column('W', :width => 5)
        column('L', :width => 5)
        column('PCT', :width => 5)
        column('GB', :width => 5)
        column('HOME', :width => 5)
        column('ROAD', :width => 5)
        column('DIV', :width => 5)
        column('CONF', :width => 5)
        column('PPG', :width => 5)
        column('OPP PPG', :width => 5)
        column('DIFF', :width => 5)
        column('STRK', :width => 5)
        column('LAST 10', :width => 5)
      end
      team = SportStats::Team.all[id]
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