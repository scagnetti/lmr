# Load the rails application
require File.expand_path('../application', __FILE__)

LOG = Logger.new(STDOUT)
#Rails.logger.level = 0

# Initialize the rails application
Lmr::Application.initialize!
