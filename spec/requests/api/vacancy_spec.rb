require 'rails_helper'

RSpec.describe "Vacancy", type: :request do
  let(:category) { create(:category) }
  
    
  describe "Request GET #index" do 
    let(:vacancies_size) {rand(1..10)}
    let!(:vacancies) { create_list(:vacancy, vacancies_size, category_title: category.name) }

    before { get "/api/vacancies" }

    it "returns correct size vacancies" do 
      expect(JSON.parse(response.body)["vacancies"].size).to eq(vacancies_size)
    end

    it "returns correct vacancies data" do 
      expect(JSON.parse(response.body)["vacancies"]).to eq(JSON.parse(vacancies.to_json))
    end
  end
                              
  describe "Request POST #create" do
    let(:vacancy) { create(:vacancy, category_title: category.name) }
    
    before do
      allow_any_instance_of(TelegramMessageService).to receive(:sending_vacancy_to_users)
    end

    it "after create new vacancy, return correct data" do 
      allow(Vacancy).to receive(:new).and_return(vacancy)
      
      post "/api/vacancies", params: vacancy.as_json
      
      expect(JSON.parse(response.body)).to eq(vacancy.as_json)
    end

    it "returns status unprocessable_entity" do 
      post "/api/vacancies", params: {}

      expect(JSON.parse(response.body)["err"]).to eq(I18n.t("error.messages.error_validate_vacancy"))
    end
  end
end