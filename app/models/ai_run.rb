class AiRun < ApplicationRecord
  belongs_to :company
  belongs_to :ticket, optional: true
  belongs_to :user, optional: true

  KINDS = %w[
    categorize suggest_reply summarize sentiment
    suggest_kb_article draft_response
  ].freeze

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :model, presence: true

  scope :recent,     -> { order(created_at: :desc) }
  scope :this_month, -> { where(created_at: Time.current.beginning_of_month..) }
  scope :successful, -> { where(success: true) }

  def self.monthly_cost(company)
    where(company: company).this_month.sum(:cost_usd)
  end

  def self.by_kind_stats(company)
    where(company: company).this_month
         .group(:kind)
         .select("kind, COUNT(*) as runs_count, SUM(total_tokens) as tokens, SUM(cost_usd) as total_cost")
  end

  def self.by_model_stats(company)
    where(company: company).this_month
         .group(:model)
         .select("model, COUNT(*) as runs_count, SUM(total_tokens) as tokens, SUM(cost_usd) as total_cost")
  end
end
