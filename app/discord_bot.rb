require_relative "commands"

class DiscordBot
  include Commands

   def initialize(config)
    options = { 
      token: config['TOKEN'],
      client_id: config['CLIENT_ID'],
      prefix: '!',
      intents: :all
    }

    @bot = Discordrb::Commands::CommandBot.new(**options)
    @state = {}
    @logger = nil
    puts "Starting discord bot at #{Time.now.strftime('%d %b - %H:%M:%S')}"
  end

  def start
    set_commands()
    @bot.run()
  end

end
