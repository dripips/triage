class TicketsController < ApplicationController
  before_action :load_ticket, only: %i[show transition]

  def index
    @tickets = scope.recent.includes(:ticket_type, :assignee, :reporter).limit(100)
    @open_count   = scope.where(closed_at: nil).count
    @closed_count = scope.where.not(closed_at: nil).count
  end

  def show
    @comments     = @ticket.comments.kept.chronological.includes(:author)
    @new_comment  = @ticket.comments.new
    @transitions  = @ticket.ticket_type.transitions.select do |_event, cfg|
      Array(cfg["from"]).include?(@ticket.status)
    end
  end

  def new
    @ticket = scope.new(ticket_type_id: params[:ticket_type_id] || default_ticket_type&.id)
  end

  def create
    @ticket = scope.new(ticket_params.merge(reporter: current_user))
    if @ticket.save
      redirect_to ticket_path(@ticket), notice: t("tickets.created", default: "Тикет создан")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def transition
    event = params[:event].to_s
    unless @ticket.can_transition?(event)
      redirect_to ticket_path(@ticket), alert: "Invalid transition: #{event}"
      return
    end
    @ticket.transition!(event, actor: current_user, comment: params[:comment])
    redirect_to ticket_path(@ticket)
  end

  private

  def scope
    Ticket.kept.where(company: current_company)
  end

  def load_ticket
    @ticket = scope.find(params[:id])
  end

  def ticket_params
    params.require(:ticket).permit(:subject, :description, :ticket_type_id, :priority, :assignee_id)
  end

  def default_ticket_type
    @default_ticket_type ||= TicketType.where(company: current_company).active_types.first
  end
end
