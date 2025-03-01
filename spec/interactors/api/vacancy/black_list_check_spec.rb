require 'rails_helper'


RSpec.describe Api::Vacancy::BlackListCheckInteractor do

  describe "#execute" do 
    let(:category) { create(:category) }
    let(:vacancy) { create(:vacancy, category_title: category.name, category_id: category.id) }
    let!(:blacklist_new) { create(:blacklist_new, contact_information: vacancy.platform_id) }
    let(:checker) { described_class.run(platform_id: vacancy.platform_id, contact_information: vacancy.contact_information) }

    it "return correct error" do 
      expect(checker.errors).not_to be_nil
    end
  end
end
