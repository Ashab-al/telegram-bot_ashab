require 'rails_helper'

RSpec.describe "OpenAPI document", type: :request do
  subject(:schema) { skooma_openapi_schema }

  it { is_expected.to be_valid_document }
end