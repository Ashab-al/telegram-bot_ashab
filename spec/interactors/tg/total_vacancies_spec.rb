require 'rails_helper'


RSpec.describe Tg::TotalVacanciesInteractor do
  
  describe "#execute" do 
    let(:vacancy_size) {rand(1..4)}
    let!(:category) { create(:category) }
    let!(:vacancies) { create_list(:vacancy, vacancy_size, category_title: category.name, category_id: category.id) }
    let(:outcome) { described_class.run() }

    it 'return correct size' do
      expect(outcome.result[:vacancy_size]).to eq(vacancy_size)
    end

    it 'return correct category count' do 
      expect(outcome.result[:rows]).to eq(1)
    end
  end
end