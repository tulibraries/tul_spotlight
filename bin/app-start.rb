# frozen_string_literal: true

require "fileutils"
require "rsolr"

# Map example config files to use in development.
Dir.glob("config/*")
  .select { |p| p.match(/example$/) }
  .each do |p|
  src = p
  dest = p.gsub(".example", "")
  FileUtils.copy_file(src, dest) unless File.exist? dest
end

# Rails is temperamental if pid is left around.
server_pid = "tmp/pids/server.pid"
File.delete server_pid if File.exist? server_pid

# Run bundle install
`bundle install`

# Start rails app but do not block the rest of the script.
#if ENV["RAILS_ENV"] != "production"
#  system("rails db:setup") || raise("Failed rails db:setup commad")
#end
system("RAILS_ENV=production rails db:setup") || raise("Failed rails db:setup commad")
system("yarn") || raise("Failed yarn command")
system("RAILS_ENV=production rails webpacker:compile") || raise("Failed rails webpacker:compile command")
exec("RAILS_ENV=production rails s -p 3000 -b '0.0.0.0'") if fork == nil

# Wait for rails server to shutdown before stopping the process.
Process.wait
