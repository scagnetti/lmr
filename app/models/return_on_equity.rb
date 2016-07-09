# Data object for Return on Equity (RoE) last year
# Eigenkapitalrendite des letzten Jahres- Lohn des Unternehmers - Verzinsung des Beteiligungskapitals
# Jahresueberschuss / im Unterehmen gebundenes Eigenkapital * 100
class ReturnOnEquity < ActiveRecord::Base
  has_many :score_cards
end
