require 'rails_helper'


RSpec.describe Tg::Category::FindUserSubscribeInteractor do
  
  describe "#execute" do 
    let(:category) { create(:category) }
    let(:user) { create(:user) }
    let!(:subscriptions) {user.subscriptions.create(category: category)}

    let(:outcome) { described_class.run(user: user) }

    it 'return correct subscribe category' do
      expect(outcome.result.first).to eq(category)
    end

    it 'return correct subscribe size' do
      expect(outcome.result.size).to eq(user.subscriptions.size)
    end
  end
end