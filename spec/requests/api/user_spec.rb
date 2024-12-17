require 'rails_helper'

RSpec.describe "User", type: :request do
  let(:user) { create(:user) }
  
  describe "Request GET #show" do 
    before { post "/api/users/#{user.id}"}

    it "return correct user" do 
      expect(JSON.parse(response.body).user).to eq(user)
    end 
  end

  describe "Request GET #index" do 
    let(:users_size) {rand(1, 10)}
    let!(:users) { create_list(:user, users_size) }

    before { get "/api/users" }
    it "return all users" do 
      expect(JSON.parse(response.body).users.size).to eq(users_size)
    end 
  end

  describe "Request POST #set_status" do 
    let(:status) { "bot_blocked" }
    before { post "/api/users/#{user.id}/set_status", params: {bot_status: status} }

    it "return success" do 
      expect(User.find_by(id: user.id).bot_status).to eq(status)
    end 
  end

  describe "Request POST #set_bonus" do 
    let(:bonus) { 25 }
    before { post "/api/users/#{user.id}/set_bonus", params: {bonus: bonus} }

    it "return success" do 
      expect(User.find_by(id: user.id).bonus).to eq(bonus)
    end 
  end

  describe "Request POST #mail_all" do 
    let(:text) { "Какой-то длинный текст Какой-то длинный текст Какой-то длинный текст" }
    before { post "/api/users/mail_all", params: {text: text} }

    it "return success" do 
      expect(JSON.parse(response.body).status).to eq("success")
    end 
  end
end