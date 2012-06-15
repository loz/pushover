require 'active_record'
require 'yaml'
require 'logger'

#Load database.yml
config_file = File.expand_path("../database.yml", __FILE__)

def env
  @env ||= {}
end
env[:dbconfigs] = YAML.load File.read(config_file)
env[:mode] = ENV["RACK_ENV"] || 'development'
env[:db] = env[:dbconfigs][env[:mode]]

#Establish Connection
ActiveRecord::Base.establish_connection(env[:db])

