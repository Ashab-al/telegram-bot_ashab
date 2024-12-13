require 'rails_helper'

RSpec.describe "Vacancy", type: :request do
  let!(:category) { create(:category) }
  let!(:vacancies) { create_list(:vacancy, 3, category_title: category.name) }
    
  describe "Request GET #index" do 
    before { get "/api/get_all_vacancies" }

    it "returns correct size vacancies" do 
      expect(JSON.parse(response.body).length).to eq(vacancies.size)
    end

    it "returns correct vacancies data" do 
      expect(JSON.parse(response.body)).to eq(vacancies.as_json)
    end
  end
                              
  describe "Request POST #create" do
    let!(:vacancy) { create(:vacancy, category_title: category.name) }
    
    before do
      allow_any_instance_of(TelegramMessageService).to receive(:sending_vacancy_to_users)
    end

    it "after create new vacancy, return correct data" do 
      allow(Vacancy).to receive(:new).and_return(vacancy)
      
      post "/api/vacancies_create", params: vacancy.as_json
      
      expect(JSON.parse(response.body)).to eq(vacancy.as_json)
    end

    it "returns status unprocessable_entity" do 
      post "/api/vacancies_create", params: {}

      expect(JSON.parse(response.body)["err"]).to eq(I18n.t("error.messages.error_validate_vacancy"))
    end
  end
end