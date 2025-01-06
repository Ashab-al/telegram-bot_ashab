require 'rails_helper'

RSpec.describe Tg::SpamVacancyInteractor do
  
  describe "#execute" do 
    let(:first_complaint) { 1 }
    let(:maximum_complaints) { ENV['COMPLAINT_COUNTER'].to_i }
    let(:category) { create(:category) }

    describe "first complaint" do 
      let!(:vacancy) { create(:vacancy, category_title: category.name, category_id: category.id) }
      let!(:blacklist_new) { create(:blacklist_new, contact_information: vacancy.platform_id) }
      let(:outcome) { described_class.run(id: vacancy.id) }

      it 'return correct update first complaint' do
        expect(outcome.result.complaint_counter).to eq(first_complaint)
      end
    end

    describe "full complaint" do 
      let!(:vacancy) { create(:vacancy_2, category_title: category.name, category_id: category.id) }
      let!(:blacklist_full) { create(:blacklist_full, contact_information: vacancy.platform_id, complaint_counter: maximum_complaints) }
      let(:outcome) { described_class.run(id: vacancy.id) }
  
      it 'return correct symbol if max complaint' do 
        expect(outcome.result).to eq(:blacklisted)
      end
    end
  end
end