require 'rails_helper'
require 'gds_api/test_helpers/email_alert_api'

RSpec.describe SubscriptionsController do
  include GdsApi::TestHelpers::EmailAlertApi

  let(:topic_id) { "GOVUK123" }
  let(:subscribable_title) { "My exciting list" }
  let(:subscribable_id) { 10 }
  let(:subscribable_attributes) do
    {
      id: subscribable_id,
      title: subscribable_title,
    }
  end

  render_views

  before do
    email_alert_api_has_subscribable(
      reference: topic_id,
      returned_attributes: subscribable_attributes
    )
  end

  describe "GET /email/subscriptions/new" do
    context "when no topic is provided" do
      it "raises an error" do
        expect { get :new, params: {} }
          .to raise_error(ActionController::ParameterMissing)
      end
    end

    context "when a topic that doesn't exist in Email Alert API is provided" do
      before do
        email_alert_api_does_not_have_subscribable(reference: topic_id)
      end

      it "returns 404" do
        get :new, params: { topic_id: topic_id }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when a topic is provided" do
      it "returns 200" do
        get :new, params: { topic_id: topic_id }
        expect(response).to have_http_status(:ok)
      end
    end

    context "when a topic and frequency are provided" do
      let(:frequency) { "immediately" }
      it "returns 200" do
        get :new, params: { topic_id: topic_id, frequency: frequency }
        expect(response).to have_http_status(:ok)
      end
    end

    context "when a topic and an invalid frequency are provided" do
      let(:frequency) { "foobar" }
      it "redirects to new without the frequency" do
        get :new, params: { topic_id: topic_id, frequency: frequency }
        expect(response).to redirect_to(new_subscription_url(topic_id: topic_id))
      end
    end
  end

  describe "POST /email/subscriptions/frequency" do
    context "when no frequency is provided" do
      it "redirects to new without the frequency" do
        post :frequency, params: { topic_id: topic_id }
        expect(response).to redirect_to(new_subscription_url(topic_id: topic_id))
      end
    end

    context "when an invalid frequency is provided" do
      let(:frequency) { "foobar" }
      it "redirects to new without the frequency" do
        post :frequency, params: { topic_id: topic_id, frequency: frequency }
        expect(response).to redirect_to(new_subscription_url(topic_id: topic_id))
      end
    end

    context "when a valid frequency is provided" do
      let(:frequency) { "daily" }
      it "redirects to new with frequency" do
        post :frequency, params: { topic_id: topic_id, frequency: frequency }
        destination = new_subscription_url(
          topic_id: topic_id, frequency: frequency
        )
        expect(response).to redirect_to(destination)
      end
    end
  end

  describe "POST /email/subscriptions/create" do
    let(:valid_email) { "joe@example.com" }

    context "when no frequency is provided" do
      it "redirects to new without the frequency" do
        post :create, params: { topic_id: topic_id, address: valid_email }
        expect(response).to redirect_to(new_subscription_url(topic_id: topic_id))
      end
    end

    context "when no address is provided" do
      let(:params) { { topic_id: topic_id, frequency: "daily" } }

      it "renders an error" do
        post :create, params: params
        missing_email_error = Regexp.new(described_class::MISSING_EMAIL_ERROR)
        expect(response.body).to match missing_email_error
        expect(response).to have_http_status(:ok)
      end
    end

    context "when an invalid email address is provided" do
      let(:address) { "bad-email" }
      let(:frequency) { "immediately" }
      let(:params) do
        { topic_id: topic_id, frequency: frequency, address: address }
      end

      before do
        email_alert_api_refuses_to_create_subscription(subscribable_id, address, frequency)
      end

      it "renders an error" do
        post :create, params: params
        invalid_email_error = Regexp.new(described_class::INVALID_EMAIL_ERROR)
        expect(response.body).to match invalid_email_error
        expect(response).to have_http_status(:ok)
      end
    end

    context "when a valid email address is provided" do
      let(:address) { valid_email }
      let(:frequency) { "immediately" }
      let(:params) do
        { topic_id: topic_id, frequency: frequency, address: address }
      end

      before do
        email_alert_api_creates_a_subscription(subscribable_id, address, frequency, 1)
      end

      it "returns a redirect to subscription page" do
        post :create, params: params
        redirect = subscription_url(topic_id: topic_id, frequency: frequency)
        expect(response).to redirect_to(redirect)
      end

      it "sends a request to email-alert-api" do
        post :create, params: params
        assert_subscribed(subscribable_id, address, frequency)
      end
    end
  end
end
