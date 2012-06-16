require 'active_record'
require 'yaml'
require 'logger'
require 'erb'
require 'omniauth'
require 'rack/utils'

#Load database.yml
config_file = File.expand_path("../database.yml", __FILE__)

def env
  @env ||= {}
end

def logger
  if env[:mode] == 'test'
    Logger.new(File.open(File.expand_path('../../log/test.log', __FILE__), 'a'))
  else
    Logger.new(STDOUT)
  end
end

db_yaml = ERB.new(File.read(config_file)).result(binding)
env[:dbconfigs] = YAML.load db_yaml
env[:mode] = ENV["RACK_ENV"] || 'development'
env[:db] = env[:dbconfigs][env[:mode]]

#Establish Connection
ActiveRecord::Base.logger = logger
OmniAuth.config.logger = logger
ActiveRecord::Base.establish_connection(env[:db])

models = File.expand_path('../../models/*.rb', __FILE__)
Dir[models].each {|f| require f }
