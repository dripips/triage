class TicketTypesController < ApplicationController
  before_action :require_admin!
  before_action :load_ticket_type, only: %i[show edit update destroy]

  def index
    @ticket_types = scope.order(:name)
  end

  def show; end

  def new
    @ticket_type = scope.new(workflow: default_workflow)
  end

  def create
    @ticket_type = scope.new(ticket_type_params)
    if @ticket_type.save
      redirect_to ticket_types_path, notice: t("ticket_types.created", default: "Тип тикета создан")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @ticket_type.update(ticket_type_params)
      redirect_to ticket_types_path, notice: t("ticket_types.updated", default: "Тип тикета обновлён")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ticket_type.discard
    redirect_to ticket_types_path, notice: t("ticket_types.disabled", default: "Тип тикета отключён")
  end

  private

  def scope
    TicketType.kept.where(company: current_company)
  end

  def load_ticket_type
    @ticket_type = scope.find(params[:id])
  end

  def ticket_type_params
    params.require(:ticket_type).permit(:key, :name, :active, :workflow_json).tap do |p|
      if p[:workflow_json].present?
        p[:workflow] = JSON.parse(p.delete(:workflow_json)) rescue {}
      end
    end
  end

  def default_workflow
    {
      "initial_state" => "new",
      "states" => %w[new triage in_progress resolved closed],
      "transitions" => {
        "triage"      => { "from" => [ "new" ],         "to" => "triage" },
        "start"       => { "from" => [ "triage" ],      "to" => "in_progress" },
        "resolve"     => { "from" => [ "in_progress" ], "to" => "resolved" },
        "close"       => { "from" => [ "resolved" ],    "to" => "closed" }
      }
    }
  end

  def require_admin!
    return if current_user&.admin? || current_user&.superadmin?
    redirect_to root_path, alert: t("pundit.not_authorized")
  end
end
