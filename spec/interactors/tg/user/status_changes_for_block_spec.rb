RSpec.describe Tg::User::StatusChangesForBlockInteractor do
  describe '#execute' do
    let(:user) { create(:user) }

    let(:change_status) { described_class.run(user: user) }

    it 'return success edit user status' do
      expect(change_status.result.bot_status).to eq(User::BOT_STATUS_BLOCKED)
    end
  end
end
