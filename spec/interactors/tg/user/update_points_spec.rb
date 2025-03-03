require 'rails_helper'

RSpec.describe Tg::User::UpdatePointsInteractor do
  describe '#execute' do
    let(:user) { create(:user) }
    let(:points) { rand(1..10) }
    let(:stars) { points * 2 }
    let(:one) { 1 }

    let(:update) { described_class.run(user: user, points: points, stars: stars) }

    before do
      allow(Tg::SendInfoAboutNewPaymentInteractor).to receive(:run)
    end

    it 'return correct update points' do
      expect(update.result.point).to eq(one + points)
    end
  end
end
