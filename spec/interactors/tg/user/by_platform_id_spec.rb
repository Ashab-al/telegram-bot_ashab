require 'rails_helper'


RSpec.describe Tg::User::ByPlatformIdInteractor do
  
  describe "#execute" do 
    let(:user_number) { rand(10..1000)}
    let(:user) { create(:user) }
    let(:user_second) {{
        name: "Name #{user_number}",
        username: "@username#{user_number}",
        id: user_number,
        point: 0,
        bonus: 5,
        bot_status: "works"
        }}

    describe "old user" do 
      let(:old_user) { described_class.run(id: user.platform_id) }

      it 'return correct old user' do
        expect(old_user.result[:user]).to eq(user)
      end
    end
    
    describe "new user" do
      let(:new_user) { described_class.run(user_second) }
      
      it 'return correct new user' do
        # binding.pry
        expect(new_user.result[:user].platform_id).to eq(user_second[:id])
      end
    end

  end
end