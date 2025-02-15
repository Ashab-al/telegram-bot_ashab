require 'rails_helper'

RSpec.describe Tg::SendAnalyticsInteractor do 

  describe "#execute" do 
    before do
      allow(Telegram.bot).to receive(:send_message)
    end
    let!(:user_1) { create(:user) }
    let!(:user_2) { create(:user) }
    let!(:user_3) { create(:user, bot_status: User::BOT_STATUS_BLOCKED) }
    let!(:user_4) { create(:user, bot_status: User::BOT_STATUS_BLOCKED) }
    
    let(:outcome) { described_class.run(user: user_1) }

    it "return correct count all users" do 
      expect(outcome.result[:users_count]).to eq(User.count)
    end

    it "return correct count users where bot status works" do 
      expect(outcome.result[:works_users]).to eq(User.where(bot_status: User::BOT_STATUS_WORKS).count)
    end

    it "return correct count users where bot status works" do 
      expect(outcome.result[:works_users]).to eq(User.where(bot_status: User::BOT_STATUS_BLOCKED).count)
    end
  end
end