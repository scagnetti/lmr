Lmr::Application.routes.draw do
  
  get "log_in" => "sessions#new", :as => "log_in"
  
  get "log_out" => "sessions#destroy", :as => "log_out"

  get "sign_up" => "users#new", :as => "sign_up"
  
  resources :sessions
  
  resources :users

  resources :score_cards

  resources :stock_indices
  
  resources :insider_deals
  
  resources :rising_scores

  resources :person_of_interests

  resources :shares do
    member do
      get 'lookup_insider_trades'
    end
  end

  get '/score_cards/assess_share/:isin' => 'score_cards#assess_share'

  root :to => 'score_cards#index'

end