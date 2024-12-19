require 'rails_helper'

RSpec.describe "Category", type: :request do
  let(:category) { create(:category) }
  
  describe "Request POST #create" do 
    let(:name) { "Тех-спец" }
    before { post "/api/categories", params: {name: name} }

    it "return correct category" do
      #Смотреть по id есть ли такая категория сравнивая с name
      expect(Category.find_by(id: JSON.parse(response.body)["category"]["id"]).name).to eq(name)
    end 
  end

  describe "Request PATCH #update" do 
    let(:name) { "Дизайн" }
    before { patch "/api/categories/#{category.id}", params: {name: name, id: category.id} }

    it "return correct new name for category" do 
      #Запрос в базу по id и проверка изменилось ли на новое название
      expect(Category.find_by(id: JSON.parse(response.body)["category"]["id"]).name).to eq(name)
    end 
  end

  describe "Request DELETE #destroy" do 
    before { delete "/api/categories/#{category.id}" }

    it "return correct id category after destroy" do 
      # Проверка по id удалилась ли категория
      
      expect(Category.find_by(id: JSON.parse(response.body)["category"]["id"]).nil?).to eq(true)
    end 
  end

  describe "Request GET #index" do 
    let(:categories_size) {rand(1..10)}
    let!(:categories) { create_list(:category, categories_size) }

    before { get "/api/categories" }
    it "return all categories" do 

      # Проверять что в ответе кол-во категорий по categories_size
      expect(JSON.parse(response.body)["categories"].size).to eq(categories_size)
    end 
  end

  describe "Request GET #show" do 
    before { get "/api/categories/#{category.id}" }
    it "return correct category" do 
      # сверять категории
      expect(JSON.parse(response.body)["category"]).to eq(JSON.parse(category.to_json))
    end 
  end
end