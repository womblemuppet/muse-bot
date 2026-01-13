require "csv"
require "fileutils"

USER_DATA_CSV = { headers: [:username, :total_posts] }

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
