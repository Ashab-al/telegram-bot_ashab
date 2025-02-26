module Tg::Common
  def self.erb_render(action, hash)
    ERB.new(File.read(Rails.root.join "app/views/telegram_webhooks/#{action}.html.erb")).result_with_hash(hash)
  end
end