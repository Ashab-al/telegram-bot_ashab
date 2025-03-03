require 'rails_helper'

RSpec.describe Tg::OpenVacancyInteractor do
  describe '#execute' do
    let(:category) { create(:category) }
    let(:vacancy) { create(:vacancy, category_title: category.name, category_id: category.id) }
    let(:user) { create(:user) }

    describe 'return status :warning' do
      let(:user) { create(:user, point: described_class::ZERO_BALANCE, bonus: described_class::ZERO_BALANCE) }
      let(:outcome) { described_class.run(user: user, id: vacancy.id) }

      it 'correct :warning' do
        expect(outcome.result[:status]).to eq(:warning)
      end
    end

    describe 'return status :warning' do
      let(:vacancy) { create(:vacancy, category_title: category.name, category_id: category.id) }
      let!(:blacklist_full) { create(:blacklist_full, contact_information: vacancy.platform_id) }
      let(:outcome) { described_class.run(user: user, id: vacancy.id) }

      it 'correct :warning' do
        expect(outcome.result[:status]).to eq(:warning)
      end
    end

    describe 'return status :open_vacancy' do
      let(:outcome) { described_class.run(user: user, id: vacancy.id) }

      it 'correct :open_vacancy' do
        expect(outcome.result[:status]).to eq(:open_vacancy)
      end
    end
  end
end
