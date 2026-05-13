class AiActionsController < ApplicationController
  before_action :load_ticket

  def suggest_reply
    result = ai.suggest_reply(@ticket)
    if result[:ok]
      @ticket.conversation_messages.create!(
        author: current_user,
        body: result[:content],
        message_type: :ai_suggestion,
        internal: true
      )
      redirect_to ticket_path(@ticket), notice: t("ai_actions.suggestion_ready")
    else
      redirect_to ticket_path(@ticket), alert: "AI: #{result[:error]}"
    end
  end

  def categorize
    result = ai.categorize(@ticket)
    if result[:ok]
      @ticket.comments.create!(
        author: current_user,
        body: "🤖 AI categorization:\n#{result[:content]}",
        internal: true
      )
      redirect_to ticket_path(@ticket), notice: t("ai_actions.categorized")
    else
      redirect_to ticket_path(@ticket), alert: "AI: #{result[:error]}"
    end
  end

  def summarize
    result = ai.summarize(@ticket)
    if result[:ok]
      @ticket.comments.create!(
        author: current_user,
        body: "🤖 AI summary:\n#{result[:content]}",
        internal: true
      )
      redirect_to ticket_path(@ticket), notice: t("ai_actions.summarized")
    else
      redirect_to ticket_path(@ticket), alert: "AI: #{result[:error]}"
    end
  end

  def sentiment
    result = ai.analyze_sentiment(@ticket)
    if result[:ok]
      @ticket.comments.create!(
        author: current_user,
        body: "🤖 Sentiment analysis:\n#{result[:content]}",
        internal: true
      )
      redirect_to ticket_path(@ticket), notice: t("ai_actions.sentiment_done")
    else
      redirect_to ticket_path(@ticket), alert: "AI: #{result[:error]}"
    end
  end

  private

  def load_ticket
    @ticket = Ticket.kept.where(company: current_company).find(params[:ticket_id])
  end

  def ai
    @ai ||= TicketAi.new(company: current_company)
  end
end
