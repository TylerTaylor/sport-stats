class SportStats::Team

  attr_accessor :name, :wins, :losses, :pct, :gb, :home, :road, :div, :conf, :ppg, :opp_ppg, :diff, :strk, :l10, :players

  @@all = []

  def initialize(params)
    @name ||= params[0]
    @wins ||= params[1][0]
    @losses ||= params[1][1]
    @pct ||= params[1][2]
    @gb ||= params[1][3]
    @home ||= params[1][4]
    @road ||= params[1][5]
    @div ||= params[1][6]
    @conf ||= params[1][7]
    @ppg ||= params[1][8]
    @opp_ppg ||= params[1][9]
    @diff ||= params[1][10]
    @strk ||= params[1][11]
    @l10 ||= params[1][12]
    @@all << self
  end

  def self.all
    @@all
  end

end