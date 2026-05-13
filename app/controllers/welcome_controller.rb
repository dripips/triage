# Временный welcome — будет заменён на dashboard в Phase 2.
class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    render plain: "Triage v0.0 — universal helpdesk. Setup in progress."
  end
end
