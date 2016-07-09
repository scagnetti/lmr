require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Lmr
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Berlin'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end

module CompanySize
    SMALL = 1
    MID = 2
    LARGE = 3
end

module StockExchange
  TRADEGATE = 'Tradegate'
  NYSE = 'NYSE'
  NASDAQ = 'Nasdaq'
  XETRA = 'Xetra'
  ALL = [TRADEGATE, NYSE, NASDAQ, XETRA]
end

module Currency
  USD = 'USD'
  EUR = 'EUR'
end

module EscapedCharacters
  SPACE = '&nbsp;'
  AMPERSAND = '&amp;'
  LESS_THEN = '&lt;'
  GREATER_THEN = '&gt;'
  QUOTATION = '&quot;'
  HTML = [SPACE, AMPERSAND, LESS_THEN, GREATER_THEN, QUOTATION]
end