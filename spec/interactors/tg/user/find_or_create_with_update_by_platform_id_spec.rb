require 'rails_helper'


RSpec.describe Tg::User::FindOrCreateWithUpdateByPlatformIdInteractor do
  
  describe "#execute" do 
    let(:status_bot_blocked) { User::BOT_STATUS[0] }
    let(:status_works) { User::BOT_STATUS[1] }

    let(:user_number) { rand(10..1000)}

    let(:user) { create(:user) }
    let(:user_second) {{
        name: "Name #{user_number}",
        username: "@username#{user_number}",
        id: user_number,
        point: 0,
        bonus: 5,
        bot_status: status_works
        }}
    let(:user_status_blocked) {create(:user, bot_status: status_bot_blocked)}

    describe "old user" do 
      let(:old_user) { described_class.run(id: user.platform_id) }

      it 'return correct old user' do
        expect(old_user.result[:user]).to eq(user)
      end
    end
    
    describe "new user" do
      let(:new_user) { described_class.run(user_second) }
      
      it 'return correct new user' do
        expect(new_user.result[:user].platform_id).to eq(user_second[:id])
      end
    end

    describe "edit bot status to works" do 
      let(:update_user) { described_class.run(id: user_status_blocked.platform_id) }

      it "return correct bot status" do 
        expect(update_user.result[:user].bot_status).to eq(status_works)
      end
    end
  end
end