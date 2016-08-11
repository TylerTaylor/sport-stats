class SportStats::Stats

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

  def self.scrape(doc)
    #doc = Nokogiri::HTML(open("http://www.espn.com/nba/standings/_/group/league"))
    #binding.pry

    # category_line
    category_line = []
    doc.search("th span.tooltip").each do |category|
      category_line << category.text
    end
    category_line.uniq!

    # category_line.each do |category|
    #   print category + "   "
    # end

    # team names, not sure if this is the best way to go about this
    team_names = []
    doc.search(".standings-row td").each do |x|
      team_names << x.css("span.team-names").text
    end

    team_names.reject! {|x| x.empty? }

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

  def self.display_stats(input)
    case input
    when "nba"
      # print categories here
      self.stats[:nba].each do |k, v|
        puts "#{k} - #{v}"
      end
    when "nfl"
      self.stats[:nfl].each do |k, v|
        puts "#{k} - #{v}"
      end
    when "mlb"
      self.stats[:mlb].each do |k, v|
        puts "#{k} - #{v}"
      end
    end
  end

end