require 'rails_helper'
require 'skooma'

RSpec.describe Api::VacancyController, type: :controller do
  subject(:schema) { skooma_openapi_schema }

  let!(:category) { create(:category) }
  let!(:vacancies) { create_list(:vacancy, 3, category_title: category.name) }

  describe "GET #index" do
    before { get :index }

    it "returns status ok" do 
      expect(response).to have_http_status(:ok)
    end

    it "returns correct vacancies data" do 
      expect(JSON.parse(response.body)).to eq(vacancies.as_json)
    end

    it "conforms to schema 200" do
      expect(response).to conform_schema(200)
    end
  end
end
