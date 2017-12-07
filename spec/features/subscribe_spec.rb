require 'rails_helper'
require 'gds_api/test_helpers/email_alert_api'

RSpec.describe "subscribing", type: :feature do
  include GdsApi::TestHelpers::EmailAlertApi

  context "successfully" do
    before do
      email_alert_api_has_subscribable(
        reference: "test135",
        returned_attributes: {
          id: 10,
          title: "Test Subscriber List"
        }
      )

      subscribable_id = "10"
      address = "test@test.com"
      returned_subscription_id = 50

      email_alert_api_creates_a_subscription(
        subscribable_id,
        address,
        returned_subscription_id
      )
    end

    it "subscribes and renders the success page" do
      visit "/email/subscriptions/new?topic_id=test135"
      fill_in :address, with: "test@test.com"
      expect(page).to have_content("Test Subscriber List")
      click_button "Subscribe"
      expect(page).to have_content("Subscription successfully created")
    end
  end
end