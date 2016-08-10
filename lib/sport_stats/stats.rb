class SportStats::Stats

  def self.stats
    stats = []

    stats << self.scrape_nba

    stats
  end

  def self.scrape_nba
    doc = Nokogiri::HTML(open("http://www.espn.com/nba/standings/_/group/league"))
    #binding.pry

    # category_line
    category_line = []
    doc.search("th span.tooltip").each do |category|
      category_line << category.text
    end
    category_line.uniq!

    category_line.each do |category|
      print category + "   "
    end

    # team names, not sure if this is the best way to go about this
    team_names = []
    doc.search(".standings-row td").each do |x|
      team_names << x.css("span.team-names").text
    end

    team_names.reject! {|x| x.empty? }

    # team stat line
    stat_line = []
    #temp_array = []
    doc.search(".standings-row").each do |col|
      temp_array = []
      col.css("td").each do |x|
        temp_array << x.text if x.text.length < 5
      end
      stat_line << temp_array
    end

    stat_hash = Hash[team_names.zip(stat_line)]
  end

end