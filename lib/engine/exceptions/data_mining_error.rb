# Signals that a certain figure could not be extracted
# during the data mining phase
class DataMiningError < RuntimeError
  
  attr_reader :figure, :reason
  
  # The figure which could not be extracted and
  # the reason must be given!
  def initialize(figure, reason)
    super(figure << ". " << reason)
    @figure = figure
    @reason = reason
  end
  
end