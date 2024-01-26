# lib/tasks/send_messages.rake
require 'rake'

namespace :messages do
  desc "Send messages to users"
  task send: :environment do
    puts "Message sent to"
  end
end