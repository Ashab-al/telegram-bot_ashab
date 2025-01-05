require 'rails_helper'

RSpec.describe "Vacancy", type: :request do
  let(:category) { create(:category) }
  
    
  describe "Request GET #index" do 
    let(:vacancies_size) {rand(1..10)}
    let!(:vacancies) { create_list(:vacancy, vacancies_size, category_title: category.name, category_id: category.id) }

    before { get "/api/vacancies" }

    it { is_expected.to conform_schema(200) }

    it "returns correct size vacancies" do 
      expect(JSON.parse(response.body).size).to eq(vacancies_size)
    end

    it "returns correct vacancies data" do 
      expect(JSON.parse(response.body)).to eq(JSON.parse(vacancies.to_json))
    end
  end
                              
  describe "Request POST #create" do
    let(:vacancy) { 
      {
        title: "Тех-спец",
        description: "Описание",
        contact_information: "@username",
        platform_id: "123123",
        source: "TG",
        category_title: category.name,
        category_id: category.id
      }
    }
    before do
      allow_any_instance_of(TelegramMessageService).to receive(:sending_vacancy_to_users)
    end

    it "after create new vacancy, return correct data" do 

      post "/api/vacancies", params: vacancy.to_json, headers: { 'Content-Type' => 'application/json' }
      
      is_expected.to conform_schema(200)

      expect(JSON.parse(response.body)["title"]).to eq(vacancy[:title])
    end
  end
end