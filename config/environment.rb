# Load the rails application
require File.expand_path('../application', __FILE__)

LOG = Logger.new(STDOUT)

# Initialize the rails application
Lmr::Application.initialize!
