require 'rails_helper'

RSpec.describe Tg::Vacancy::VacanciesForTheWeekInteractor do
  describe '#execute' do
    let!(:user) { create(:user) }

    let!(:category) { create(:category) }
    let!(:category_second) { create(:category_2) }
    let!(:category_third) { create(:category_3) }

    let!(:subscriptions) { user.subscriptions.create(category: category) }
    let!(:subscriptions_second) { user.subscriptions.create(category: category_second) }

    let(:vacancies_size) { rand(1..5) }

    let!(:vacancies_first) do
      create_list(:vacancy, vacancies_size, title: category.name, category_title: category.name, category: category)
    end
    let!(:vacancies_second) do
      create_list(:vacancy, vacancies_size, title: category_second.name, category_title: category_second.name,
                                            category: category_second)
    end

    let!(:vacancies_third) do
      create_list(:vacancy, vacancies_size, title: category_third.name, category_title: category_third.name,
                                            category: category_third)
    end

    let(:vacancies_for_pagination) { described_class.run(user: user) }

    it 'return correct vacancies count' do
      expect(vacancies_for_pagination.result[:vacancies].count).to eq(vacancies_first.count + vacancies_second.count)
    end

    it 'return correct vacancies_first' do
      expect(vacancies_for_pagination.result[:vacancies].to_set).to include(vacancies_first.to_set)
    end

    it 'return correct vacancies_second' do
      expect(vacancies_for_pagination.result[:vacancies].to_set).to include(vacancies_second.to_set)
    end

    it 'not return vacancies_third' do
      expect(vacancies_for_pagination.result[:vacancies].to_set).not_to include(vacancies_third.to_set)
    end
  end
end
