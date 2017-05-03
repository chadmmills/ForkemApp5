require 'rails_helper'

RSpec.describe "Parsing text for ingredients" do
  it 'should properly resopnsed to text provided by user' do
    post "/parsed-ingredients", params: { text: "1/3 cup milk" }

    expect(response).to be_success
  end

  it 'should properly return errors if any' do
    post "/parsed-ingredients", params: { text: '' }

    expect(JSON.parse(response.body).has_key?("error")).to be_truthy
  end
end
