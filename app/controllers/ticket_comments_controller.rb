class TicketCommentsController < ApplicationController
  before_action :load_ticket

  def create
    @comment = @ticket.comments.new(comment_params.merge(author: current_user))

    respond_to do |format|
      if @comment.save
        format.turbo_stream  # → app/views/ticket_comments/create.turbo_stream.erb
        format.html { redirect_to @ticket, notice: t("ticket_comments.posted", default: "Комментарий опубликован") }
      else
        format.turbo_stream { render :create_error, status: :unprocessable_entity }
        format.html { redirect_to @ticket, alert: @comment.errors.full_messages.to_sentence }
      end
    end
  end

  private

  def load_ticket
    @ticket = Ticket.kept.where(company: current_company).find(params[:ticket_id])
  end

  def comment_params
    params.require(:ticket_comment).permit(:body, :internal)
  end
end
