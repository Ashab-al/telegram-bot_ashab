require 'rails_helper'


RSpec.describe Tg::Vacancy::VacanciesForTheWeekInteractor do 

  describe "#execute" do 
    let(:user) { create(:user) }

    let(:category) { create(:category) }
    let(:category_second) { create(:category_2) }
    let(:category_third) { create(:category_3) }

    let!(:subscriptions) {user.subscriptions.create(category: category)}
    let!(:subscriptions_second) {user.subscriptions.create(category: category_second)}

    let(:vacancies_size) { rand(5..20) }

    let!(:vacancies_first) { create_list(:vacancy, vacancies_size, title: category.name) }
    let!(:vacancies_second) { create_list(:vacancy, vacancies_size, title: category_second.name) }

    let!(:vacancies_third) { create_list(:vacancy, vacancies_size, title: category_third.name) }

    let(:vacancies_for_pagination) { described_class.run(user: user) }

    it "return correct vacancies count" do 
      expect(vacancies_for_pagination.result.count).to eq(vacancies_first.count + vacancies_second.count)
    end

    it "return correct vacancies_first" do 
      expect(vacancies_for_pagination.result).to include(vacancies_first)
    end

    it "return correct vacancies_second" do 
      expect(vacancies_for_pagination.result).to include(vacancies_second)
    end

    it "not return vacancies_third" do 
      expect(vacancies_for_pagination.result).not_to include(vacancies_third)
    end
  end
end