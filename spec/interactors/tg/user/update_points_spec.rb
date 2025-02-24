require 'rails_helper'


RSpec.describe Tg::User::UpdatePointsInteractor do 
  describe "#execute" do 
    let(:user) { create(:user) }

    let(:points) { rand(1..10) }

    let(:update) { described_class(user: user, points: points) }

    it "return correct update points" do 
      expect(update.result.points).to eq(points)
    end
  end
end