require "csv"
require "fileutils"

module Commands
  def set_commands()
    @bot.message() do |event|
      username = event.author.username

      increment_user_post_count = -> (row) { row[:total_posts] += 1 }

      update_users_csv_for_user(username, increment_user_post_count)
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

      updated_csv << [username, 1] if !user_found
    end

    FileUtils.cp(updated_csv_filepath, original_filepath)

  ensure
    File.delete(updated_csv_filepath)
  end

end
