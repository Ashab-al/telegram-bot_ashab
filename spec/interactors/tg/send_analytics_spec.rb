require 'rails_helper'

Rspec.describe Tg::SendAnalyticsInteractor do 

  describe "#execute" do 
    let!(:user) { create(:user) }
    let!(:user) { create(:user) }
    let!(:user) { create(:user, bot_status: User::BOT_STATUS_BLOCKED) }
    let!(:user) { create(:user, bot_status: User::BOT_STATUS_BLOCKED) }
    let(:outcome) { described_class.run() }

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