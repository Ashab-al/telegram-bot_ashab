require 'rails_helper'

RSpec.describe Api::VacancyController, type: :controller do
  let!(:category) { create(:category) }
  let!(:vacancies) { create_list(:vacancy, 3, category_title: category.name) }
  let!(:vacancy) { create(:vacancy, category_title: category.name) }

  describe "GET #index" do
    it "returns status ok" do
      get :index 
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do 
    before do
      allow_any_instance_of(TelegramMessageService).to receive(:sending_vacancy_to_users)
    end

    it "returns status created" do 
      post :create, params: vacancy.as_json
      
      expect(response).to have_http_status(:created)
    end

    it "returns status unprocessable_entity" do 
      post :create, params: {}

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
