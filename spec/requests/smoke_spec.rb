require "rails_helper"

# Smoke spec: ловит boot/template-ошибки в CI. По мере роста проекта
# добавляем сюда новые URL'ы.
RSpec.describe "smoke", type: :request do
  describe "GET /up" do
    it "returns 200" do
      get "/up"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /" do
    it "renders welcome (or redirects to sign-in)" do
      get "/"
      expect([ 200, 302 ]).to include(response.status)
    end
  end

  describe "GET /users/sign_in" do
    it "renders Devise sign-in" do
      get "/users/sign_in"
      expect(response).to have_http_status(:ok)
    end
  end
end
