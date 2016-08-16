class SportStats::Player

  attr_accessor :no, :name, :pos, :age, :height, :weight, :college, :salary,
                :bat, :thw, :birth_place, :exp

  @@all = []

  def initialize(params)
    @no ||= params["NO."] || params["NO"]
    @name ||= params["NAME"]
    @pos ||= params["POS"]
    @bat ||= params["BAT"]
    @thw ||= params["THW"]
    @age ||= params["AGE"]
    @height ||= params["HT"]
    @weight ||= params["WT"]
    @exp ||= params["EXP"]
    @college ||= params["COLLEGE"]
    @birth_place ||= params["BIRTH PLACE"]
    @salary ||= params["2016-2017 SALARY"] || params["SALARY"]
    @@all << self
  end

  def self.all
    @@all
  end

end