class InsiderDeal < ActiveRecord::Base
  enum transaction_type: [ :unknown, :buy, :sell ]

  belongs_to :insider_info

  default_scope {order('occurred DESC')}

  def to_s
    return "Datum: #{occurred}  Meldender: #{person}  Anzahl: #{quantity}  Kurs: #{price}  Art: #{transaction_type}"
  end
end
