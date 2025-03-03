require 'rails_helper'

RSpec.describe Buttons::WithAllCategoriesRenderer do
  describe '#execute' do
    let(:categories_count) { rand(2..6) }
    let(:one) { 1 }
    let(:two) { 2.0 }
    let(:user) { create(:user) }
    let(:categories) { create_list(:category_for_list, categories_count) }
    let!(:subscriptions) { user.subscriptions.create(category: categories.first) }

    let(:buttons) { described_class.new(user.subscriptions.map(&:category)).call }

    it 'return correct count buttons' do
      expect(buttons[:inline_keyboard].count).to eq((categories_count / two).ceil + one)
    end
  end
end
