require 'rails_helper'

RSpec.describe Tg::Vacancy::SendVacancyToUsersInteractor do
  describe '#execute' do
    let(:user_count) { 1 }
    let!(:user) { create(:user) }
    let!(:category) { create(:category) }
    let!(:subscriptions) { user.subscriptions.create(category: category) }
    let(:vacancy) { create(:vacancy, title: category.name, category_title: category.name, category: category) }

    let(:send_vacancy) { described_class.run(vacancy: vacancy) }

    before do
      allow(Telegram.bot).to receive(:send_message).and_return({ 'result' => { 'message_id' => 123 } })
      allow(Telegram.bot).to receive(:edit_message_text)
    end

    it 'return correct count users' do
      expect(send_vacancy.result).to eq(user_count)
    end
  end
end
