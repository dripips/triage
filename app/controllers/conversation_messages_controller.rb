class ConversationMessagesController < ApplicationController
  before_action :load_ticket

  def create
    @message = @ticket.conversation_messages.new(message_params.merge(
      author: current_user,
      message_type: :text
    ))

    respond_to do |format|
      if @message.save
        format.turbo_stream
        format.html { redirect_to ticket_path(@ticket) }
      else
        format.turbo_stream { head :unprocessable_entity }
        format.html { redirect_to ticket_path(@ticket), alert: @message.errors.full_messages.to_sentence }
      end
    end
  end

  private

  def load_ticket
    @ticket = Ticket.kept.where(company: current_company).find(params[:ticket_id])
  end

  def message_params
    params.require(:conversation_message).permit(:body, :internal)
  end
end
