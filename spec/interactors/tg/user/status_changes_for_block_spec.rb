RSpec.describe Tg::User::StatusChangesForBlock do 

  describe "#execute" do
    let(:user) { create(:user) }

    let(:change_status) { described_class.run(user: user) }

    it "return success edit user status" do 
      except(change_status.result.user.bot_status).to (User::BOT_STATUS_BLOCKED)
    end
  end
end