require 'rails_helper'

RSpec.describe Tg::OpenVacancyInteractor do
  
  describe "#execute" do 
    let(:category) { create(:category) }
    let(:vacancy) { create(:vacancy, category_title: category.name, category_id: category.id) }
    let(:vacancy_blacklist) { create(:vacancy, category_title: category.name, category_id: category.id) }
    let(:user_zero_balance) { create(:user, point: described_class::ZERO_BALANCE, bonus: described_class::ZERO_BALANCE) }
    let(:user) { create(:user) }

    describe "return status :out_of_points" do 
      let(:outcome) { described_class.run(user: user_zero_balance, id: vacancy.id) }

      it 'correct :out_of_points' do
        expect(outcome.result[:status]).to eq(:out_of_points)
      end
    end

    describe "return status :blacklist" do 
      let!(:blacklist_full) { create(:blacklist_full, contact_information: vacancy_blacklist.platform_id) }
      let(:outcome) { described_class.run(user: user, id: vacancy_blacklist.id) }

      it 'correct :blacklist' do
        expect(outcome.result[:status]).to eq(:blacklist)
      end
    end

    describe "return status :open_vacancy" do 
      let(:outcome) { described_class.run(user: user, id: vacancy.id) }

      it 'correct :open_vacancy' do
        expect(outcome.result[:status]).to eq(:open_vacancy)
      end
    end
  end
end