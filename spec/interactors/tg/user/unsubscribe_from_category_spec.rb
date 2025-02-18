require 'rails_helper'


RSpec.describe Tg::User::UnsubscribeFromCategoryInteractor do 

  describe "#execute" do
    let(:category) { create(:category) }
    let(:user) { create(:user) }
    let!(:subscriptions) {user.subscriptions.create(category: category)}

    let(:outcome) { described_class.run(user: user, category: category) }

    it "return correct destroy subscription" do 
      expect(outcome.result.category).to be_empty
      expect(outcome.result.subscriptions).to be_empty
    end
  end
end