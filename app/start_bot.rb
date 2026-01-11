require "discordrb"
require "yaml"

require_relative 'discord_bot.rb'

def load_config
  configuration_file = File.read("./config.yaml")
  return YAML.load(configuration_file)
end

def main
  config = load_config()
  bot = DiscordBot.new(config)
  bot.start()
end


main() if __FILE__ == $PROGRAM_NAME
