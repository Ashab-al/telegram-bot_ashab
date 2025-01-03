require 'rails_helper'


RSpec.describe Tg::TotalVacanciesInteractor do
  
  describe "#execute" do 
    let!(:category) { create(:category) }
    let!(:vacancies) { create_list(:vacancy, 3, category_title: category.name, category_id: category.id) }
    let(:outcome) { described_class.run() }

    it 'return string' do 

      expect(outcome.result).to be_an_instance_of(String)
    end
  end
end