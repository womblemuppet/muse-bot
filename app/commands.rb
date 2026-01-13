require "csv"
require "fileutils"
require "active_support/all"

USER_DATA_CSV = { headers: [:username, :total_posts] }
MILESTONES = {
  5 => { emoji: ⭐️ },
  20 => { emoji: ⭐️⭐️ },
  50 => { emoji: ⭐️⭐️⭐️ },
  100 => { emoji: 💎 },
  150 => { emoji: 💎💎 },
  250 => { emoji: 💎💎💎 },
  500 => { emoji: 🐀 },
  550 => { emoji: 🐂 },
  600 => { emoji: 🐅 },
  650 => { emoji: 🐇 },
  700 => { emoji: 🐉 },
  750 => { emoji: 🐍 },
  800 => { emoji: 🐴 },
  850 => { emoji: 🐐 },
  900 => { emoji: 🐒 },
  950 => { emoji: 🐓 },
  1000 => { emoji: 🐕 },
  1050 => { emoji: 🐖 },
  1250 => { emoji: 👑 },
  1300 => { emoji: 👑👑 },
  1350 => { emoji: 👑👑👑 },
  1400 => { emoji: 👑👑👑👑 },
  1450 => { emoji: 👑👑👑👑👑 },
  1500 => { emoji: 🍺 }
}

module Commands
  def set_commands()
    @bot.message() do |event|
      username = event.author.username

      new_number_of_posts = nil # idk why we're emulating JS in ruby, seems backward.
      increment_user_post_count = -> (row) do
        new_number_of_posts = row[:total_posts] + 1
        row[:total_posts] += 1
      end

      update_users_csv_for_user(username, increment_user_post_count)

      if new_number_of_posts.in?(MILESTONES.keys)
        msg = <<~MSG
        #{MILESTONES[new_number_of_posts][:emoji]}
        Congratulations to #{username} for hitting a milestone!
        #{new_number_of_posts} posts!
        MSG

        event.respond(msg)
      end
    end
  end

  def update_users_csv_for_user(username, update_func)
    csv_options = {
      headers: true,
      header_converters: :symbol,
      converters: :numeric,
      write_headers: true,
      return_headers: true
    }

    original_filepath = "./user_data.csv"
    updated_csv_filepath = "./user_data_updated.csv"

    # Finicky until I move away from CSV, but just for testing.
    CSV.open(updated_csv_filepath, "w", **csv_options) do |updated_csv|
      user_found = false

      CSV.foreach(original_filepath, **csv_options) do |row|
        if row[:username] == username
          update_func.call(row)
          user_found = true
        end
        
        updated_csv << row
      end

      if !user_found
        row = CSV::Row.new(USER_DATA_CSV[:headers], [username, 0])
        update_func.call(row)
        updated_csv << row
      end
    end

    FileUtils.cp(updated_csv_filepath, original_filepath)

  ensure
    File.delete(updated_csv_filepath)
  end

end
