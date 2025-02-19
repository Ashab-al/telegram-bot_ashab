require 'rails_helper'



RSpec.describe Tg::CreateTarifButtonsInteractor do 

  describe "#execute" do 
    let(:outcome) { described_class.run() }

    it "return correct count buttons" do
      expect(outcome.result[:inline_keyboard].count).to eq(Tg::CreateTarifButtonsInteractor::TARIFS_PRICES.count)
    end
  end
end