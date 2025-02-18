require 'rails_helper'


RSpec.describe Tg::User::SubscribeToCategoryInteractor do 

  describe "#execute" do
    let(:one_subscription) { 1 }
    let(:category_size) { rand(2..10) }
    let(:user) { create(:user) }
    let(:categories) { create_list(:category_for_list, category_size) }

    let(:subscription) { described_class.run(user: user, category: categories.first) }

    it "return correct create subscription" do 
      expect(subscription.result.category.first).to eq(categories.first) 
    end

    it "return correct count subscription" do
      expect(subscription.result.subscriptions.count).to eq(one_subscription)
    end
  end
end