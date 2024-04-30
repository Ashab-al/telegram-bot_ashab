require 'rails_helper'

RSpec.describe Api::VacancyController, :type => :controller do
                 
  describe "GET #index" do 
    it "returns all vacancies" do 
      vacancies = FactoryBot.create_list(:vacancy, 3)

      get :index

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).length).to eq(vacancies.size)
    end
  end
                              
  describe "POST #create" do
    context "with valid params" do 
      it "create new vacancy" do 
        vacancy = instance_double(Vacancy, save: true)
        
        allow(Vacancy).to receive(:new).and_return(vacancy)

        allow_any_instance_of(Api::VacancyController).to receive(:send_vacancy).with(vacancy).and_return(true)
        allow_any_instance_of(Api::VacancyController).to receive(:blacklist_check).with(vacancy).and_return(true)

        post :create, params: { vacancy: {:category_title => "Тех-спец", :title => "Тех-спец", 
        :description => "Описание", :contact_information => "@username",
        :source => "tg_chat", :platform_id => "123123"} }
        expect(response).to have_http_status(:created)
      end
    end
  end
end