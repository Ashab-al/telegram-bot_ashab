require 'rails_helper'


RSpec.describe Tg::User::UnsubscribeFromCategoryInteractor do 

  describe "#execute" do
    let(:zero) { 0 }
    let(:category) { create(:category) }
    let(:user) { create(:user) }
    let!(:subscriptions) {user.subscriptions.create(category: category)}

    let(:outcome) { described_class.run(user: user, category: category) }

    it "return correct destroy subscription" do 
      expect(outcome.result.category).to be_empty
    end

    it "return correct count subscriptions" do 
      expect(outcome.result.subscriptions.count).to eq(zero)
    end
  end
end