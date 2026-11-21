module DifficultModes
  # Variable number that control the difficult.
  # To use a different variable, change this. 0 deactivates this script
  VARIABLE=200 
  # Easy and Normal use the same party overrides. #pk code
  NORMAL_PARTY_OFFSET=50
  
  def self.currentMode
    difficultHash={}

    hardMode = Difficult.new
    hardMode.idJump = 200
    hardMode.levelProcedure = proc{|level|
      next level*1.0
    }
    hardMode.moneyProcedure = proc{|money|
      next money*1.0
    }
    difficultHash[2] = hardMode
    
    return DifficultModes::VARIABLE>0 ? 
      difficultHash[pbGet(DifficultModes::VARIABLE)] : nil
  end 
  
  def self.applyLevelProcedure(level,procedure)
    return procedure ? 
      [[procedure.call(level).floor,MAXIMUMLEVEL].min,1].max : level
  end
  
  def self.applyMoneyProcedure(money)
    difficultSelected = self.currentMode
    return difficultSelected && difficultSelected.moneyProcedure ? 
      [difficultSelected.moneyProcedure.call(money).floor,0].max : money
  end
  
  def self.loadTrainer(trainerid,trainername,partyid=0)
    trainer = nil
    procedure = nil
    difficultSelected = self.currentMode
    if difficultSelected
      trainer=pbLoadTrainerDifficult(trainerid,trainername,
        partyid + difficultSelected.idJump) if difficultSelected.idJump>0
      procedure = difficultSelected.levelProcedure
    elsif DifficultModes::VARIABLE>0 && [0,1].include?(pbGet(DifficultModes::VARIABLE)) #pk code
      trainer=pbLoadTrainerDifficult(trainerid,trainername,
        partyid + NORMAL_PARTY_OFFSET)
    end
    return trainer ? trainer : pbLoadTrainerDifficult(
      trainerid,trainername,partyid,procedure)
  end
    
  private
  class Difficult
    attr_accessor :idJump
    attr_accessor :levelProcedure
    attr_accessor :moneyProcedure
    
    def initialize
      @idJump = 0
      @levelProcedure = nil
      @moneyProcedure = nil
    end  
  end  
end

def pbLoadTrainer(trainerid,trainername,partyid=0)
  return DifficultModes.loadTrainer(trainerid,trainername,partyid)
end
