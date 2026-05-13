module Settings
  class ApiTokensController < SettingsController
    def show
      @tokens = ApiToken.where(user: User.kept.where(company: current_company)).order(created_at: :desc)
    end
  end
end
