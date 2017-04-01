require 'rails_helper'

feature "A User" do
  scenario "can signup through the signup form" do
    visit "/create-account"
    fill_in "Email", with: "email@123.com"
    fill_in "Password", with: "password123"
    click_button "Create Account"

    expect(page).to have_css "h1", text: "Mealbooks"

    fill_in "Mealbook Name", with: "Some Family"
    click_button "Create Mealbook"

    expect(page).to have_css "nav", text: "Some Family"
  end
end
