require 'rails_helper'


RSpec.describe Tg::User::UpdateSubscriptionWithCategoryInteractor do 

  describe "#execute" do
    let(:user) { create(:user) }

    let(:category_first) { create(:category) }
    let(:category_second) { create(:category_2) }

    let!(:subscriptions) {user.subscriptions.create(category: category_first)}

    describe "create subscription" do 
      let(:subscribe_to_category) { described_class.run(id: user.platform_id, category_name: category_second.name) }

      it "return correct subscription" do 
       
        expect(subscribe_to_category.result[:result].subscriptions.map(&:category)).to include(category_second)
      end
    end

    describe "unsubscribe from category" do 
      let(:unsubscribe_from_category) { described_class.run(id: user.platform_id, category_name: category_first.name) }

      it "return correct destroy subscribe" do 
        expect(unsubscribe_from_category.result[:result].subscriptions.map(&:category)).not_to include(category_first)
      end
    end
  end
end