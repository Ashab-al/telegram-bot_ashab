require 'rails_helper'


RSpec.describe Tg::AdvertisementInteractor do
  
  describe "#execute" do 
    let(:category) { create(:category) }
    let(:user) { create(:user) }
    let!(:subscriptions) {user.subscriptions.create(category: category)}
    let(:outcome) { described_class.run() }

    it 'return correct category' do
      expect(outcome.result[:rows][0][0]).to eq(category.name)
    end
    
    it 'return correct subscriptions size' do
      expect(outcome.result[:rows][0][1]).to eq(1)
    end

    it 'return correct count' do 
      expect(outcome.result[:rows].size).to eq(1)
    end
  end
end