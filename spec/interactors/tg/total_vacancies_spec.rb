require 'rails_helper'


RSpec.describe Tg::TotalVacanciesInteractor do
  
  describe "#execute" do 
    let(:vacancies_size) {rand(1..4)}
    let!(:category) { create(:category) }
    let!(:vacancies) { create_list(:vacancy, vacancies_size, category_title: category.name, category_id: category.id) }
    let(:outcome) { described_class.run() }

    it 'return correct size' do
      expect(outcome.result[:vacancies_size]).to eq(vacancies_size)
    end

    it 'return correct category count' do 
      expect(outcome.result[:rows].size).to eq(1)
    end
  end
end