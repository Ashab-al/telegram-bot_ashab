require 'rails_helper'

RSpec.describe "Vacancy", type: :request do
  let!(:category) { create(:category) }
  let!(:category_2) { create(:category_2) }

  describe "Request POST #create" do 
    before { post "/api/categories", params: {name: category.name} }

    it "return correct category" do 
      expect(JSON.parse(response.body)).to eq(category.as_json)
    end
  end

  describe "Request PATCH #update" do 
    before { patch "/api/categories", params: {new_name: category_2.name, id: category.id} }

    it "return correct new name for category" do 
      expect(JSON.parse(response.body).category.name).to eq(category_2.name)
    end
  end

  describe "Request DELETE #destroy" do 
    before { delete "/api/categories", params: {category_id: category.id} }

    it "return correct id category after destroy" do 
      expect(JSON.parse(response.body).category.id).to eq(category.id)
    end
  end
end