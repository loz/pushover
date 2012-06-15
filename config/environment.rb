require 'active_record'
require 'yaml'
require 'logger'
require 'erb'

#Load database.yml
config_file = File.expand_path("../database.yml", __FILE__)

def env
  @env ||= {}
end
db_yaml = ERB.new(File.read(config_file)).result(binding)
env[:dbconfigs] = YAML.load db_yaml
env[:mode] = ENV["RACK_ENV"] || 'development'
env[:db] = env[:dbconfigs][env[:mode]]

#Establish Connection
ActiveRecord::Base.establish_connection(env[:db])

