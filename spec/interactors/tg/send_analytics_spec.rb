require 'rails_helper'

RSpec.describe Tg::SendAnalyticsInteractor do 

  describe "#execute" do 
    before do
      allow(Telegram.bot).to receive(:send_message)
    end

    let(:users_count) { rand(3..10) }

    let!(:user_works) { create_list(:user, users_count) }
    let!(:user_bot_blocked) { create_list(:user, users_count, bot_status: User::BOT_STATUS_BLOCKED)  }

    let(:outcome) { described_class.run(user: user_works.first) }

    it "return correct count all users" do 
      expect(outcome.result[:users_count]).to eq(user_works.count + user_bot_blocked.count)
    end

    it "return correct count users where bot status works" do 
      expect(outcome.result[:works_users]).to eq(user_works.count)
    end

    it "return correct count users where bot status works" do 
      expect(outcome.result[:works_users]).to eq(user_bot_blocked.count)
    end
  end
end