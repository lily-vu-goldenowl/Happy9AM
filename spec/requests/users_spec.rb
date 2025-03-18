require 'rails_helper'

RSpec.describe "Users", type: :request do
  let!(:user) { create(:user) }

  describe "POST /users" do
    subject { post(users_path, params:) }

    context 'with valid params' do
      let(:params) { { user: attributes_for(:user) } }
      it "creates a new user" do
        expect {
          subject
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      let(:params) { { user: { first_name: "", last_name: "", birthday: "", timezone: "" } } }

      it "returns errors when parameters are missing" do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end

  describe "PUT /users/:id" do
    subject { put(user_path(user.id), params:) }

    context 'with valid params' do
      let(:params) { { user: { first_name: "Johnny" } } }

      it "updates an existing user" do
        subject
        expect(response).to have_http_status(:ok)
        expect(user.reload.first_name).to eq("Johnny")
      end
    end

    context 'with invalid params' do
      let(:params) { { user: { first_name: "" } } }

      it "returns errors when parameters are missing" do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end

  describe "DELETE /users/:id" do
    it "deletes the user" do
      expect {
        delete user_path(user.id)
      }.to change(User, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
