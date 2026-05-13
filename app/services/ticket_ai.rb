class TicketAi
  PROVIDER_PRESETS = {
    "openai" => {
      label: "OpenAI",
      url: "https://api.openai.com/v1/chat/completions",
      models: {
        "gpt-5-nano"  => { label: "GPT-5 Nano",  tier: "fast",      input_1m: 0.05,  output_1m: 0.40,  ctx: 1_048_576, hint: "Самый дешёвый. $0.05/1M in. Для авто-категоризации и sentiment." },
        "gpt-5-mini"  => { label: "GPT-5 Mini",  tier: "balanced",  input_1m: 0.25,  output_1m: 2.00,  ctx: 1_048_576, hint: "Баланс цена/качество. Для suggest_reply и summarize." },
        "gpt-5"       => { label: "GPT-5",       tier: "smart",     input_1m: 1.25,  output_1m: 10.00, ctx: 1_048_576, hint: "Полноценная модель. Для сложных задач и длинных тредов." },
        "gpt-5.2"     => { label: "GPT-5.2",     tier: "smart",     input_1m: 1.75,  output_1m: 14.00, ctx: 1_048_576, hint: "Улучшенная GPT-5. 90% скидка на cached inputs." },
        "o3-pro"      => { label: "o3 Pro",      tier: "reasoning", input_1m: 20.00, output_1m: 80.00, ctx: 200_000,   hint: "Reasoning-модель с CoT. Для анализа сложных кейсов." }
      }
    },
    "anthropic" => {
      label: "Anthropic",
      url: "https://api.anthropic.com/v1/messages",
      models: {
        "claude-haiku-4-5-20251001"  => { label: "Haiku 4.5",    tier: "fast",      input_1m: 1.00,  output_1m: 5.00,  ctx: 200_000,   hint: "Самый быстрый. $1/1M in. Для авто-категоризации." },
        "claude-sonnet-4-6"         => { label: "Sonnet 4.6",   tier: "balanced",  input_1m: 3.00,  output_1m: 15.00, ctx: 200_000,   hint: "Лучший баланс. Рекомендуем как default." },
        "claude-opus-4-5-20250414"  => { label: "Opus 4.5",     tier: "smart",     input_1m: 5.00,  output_1m: 25.00, ctx: 200_000,   hint: "Мощная. Hybrid extended thinking." },
        "claude-opus-4-7"           => { label: "Opus 4.7",     tier: "reasoning", input_1m: 5.00,  output_1m: 25.00, ctx: 200_000,   hint: "Новейшая. Extended thinking, агентская работа." }
      }
    },
    "yandexgpt" => {
      label: "YandexGPT",
      url: "https://llm.api.cloud.yandex.net/foundationModels/v1/completion",
      models: {
        "yandexgpt-lite" => { label: "YandexGPT Lite", tier: "fast",     input_1m: 2.50,  output_1m: 2.50,  ctx: 8_192,   hint: "Лёгкая. ~$2.50/1M. 10 бесплатных запросов/час." },
        "yandexgpt"      => { label: "YandexGPT Pro",  tier: "balanced", input_1m: 5.00,  output_1m: 5.00,  ctx: 32_768,  hint: "Продвинутая. Хороший русский. 10 бесплатных запросов/час." }
      }
    },
    "ollama" => {
      label: "Ollama (локальная)",
      url: "http://localhost:11434/v1/chat/completions",
      models: {
        "llama3.2"    => { label: "Llama 3.2 (8B)",   tier: "fast",     input_1m: 0, output_1m: 0, ctx: 128_000, hint: "Локальная. Бесплатно, нужен GPU." },
        "mistral"     => { label: "Mistral 7B",       tier: "fast",     input_1m: 0, output_1m: 0, ctx: 32_768,  hint: "Локальная. Хорошая для простых задач." },
        "custom"      => { label: "Своя модель",      tier: "custom",   input_1m: 0, output_1m: 0, ctx: 0,       hint: "Впишите название модели вручную." }
      }
    },
    "custom" => {
      label: "Свой endpoint",
      url: "",
      models: {}
    }
  }.freeze

  TASK_KINDS = {
    "categorize"         => { label: "Авто-категоризация",  input: 500,   output: 100  },
    "suggest_reply"      => { label: "Подсказка ответа",    input: 2000,  output: 500  },
    "summarize"          => { label: "Резюме треда",        input: 3000,  output: 300  },
    "sentiment"          => { label: "Анализ настроения",   input: 500,   output: 50   },
    "suggest_kb_article" => { label: "Подбор статей KB",    input: 1000,  output: 200  },
    "draft_response"     => { label: "Черновик ответа",     input: 2000,  output: 800  }
  }.freeze

  attr_reader :setting

  def initialize(company:)
    @setting = AppSetting.fetch(company: company, category: "ai")
    @company = company
  end

  def enabled?
    setting.get("enabled").to_s == "1" || setting.get("enabled") == true
  end

  def autonomous?
    enabled? && setting.get("autonomous_mode").to_s == "1"
  end

  def auto_assign_enabled?
    enabled? && setting.get("auto_assign").to_s == "1"
  end

  def chat_monitoring_enabled?
    enabled? && setting.get("chat_monitoring").to_s == "1"
  end

  def provider_key
    setting.get("provider") || "anthropic"
  end

  def provider_preset
    PROVIDER_PRESETS[provider_key] || PROVIDER_PRESETS["custom"]
  end

  def model_key
    setting.get("model") || default_model_for_provider
  end

  def model_info
    provider_preset[:models][model_key] || { label: model_key, tier: "custom", input_1m: 0, output_1m: 0, ctx: 0, hint: "" }
  end

  def api_url
    custom = setting.get("api_base_url").presence
    custom || provider_preset[:url]
  end

  def monitor_chat(ticket, new_message)
    return unless chat_monitoring_enabled?
    return if new_message.system? || new_message.ai_suggestion?

    prompt = build_monitor_prompt(ticket, new_message)
    result = call(:suggest_reply, prompt)
    return unless result[:ok] && result[:content].present?

    ticket.conversation_messages.create!(
      author: nil,
      body: "💡 #{result[:content]}",
      message_type: :ai_suggestion,
      internal: true
    )
  end

  def auto_assign_ticket(ticket)
    return unless auto_assign_enabled?
    return if ticket.assignee.present?

    staff = User.kept.staff_users.where(company: @company)
    return if staff.empty?

    prompt = "Given these available agents: #{staff.map(&:display_name).join(', ')}.\n" \
             "Ticket: #{ticket.subject}\nDescription: #{ticket.description}\n" \
             "Who should handle this? Reply with ONLY the agent name, nothing else."
    result = call(:categorize, prompt)
    return unless result[:ok]

    match = staff.find { |u| result[:content].to_s.include?(u.display_name) }
    ticket.assign_to!(match, actor: nil) if match
  end

  def estimate_cost(task_key)
    task = TASK_KINDS[task_key.to_s] || { input: 1000, output: 300 }
    info = model_info
    (task[:input].to_f * info[:input_1m] + task[:output].to_f * info[:output_1m]) / 1_000_000
  end

  def monthly_budget
    (setting.get("monthly_budget_usd") || 5).to_f
  end

  def categorize(ticket)
    call(:categorize, build_categorize_prompt(ticket))
  end

  def suggest_reply(ticket)
    call(:suggest_reply, build_suggest_reply_prompt(ticket))
  end

  def summarize(ticket)
    call(:summarize, build_summarize_prompt(ticket))
  end

  def analyze_sentiment(ticket)
    call(:sentiment, build_sentiment_prompt(ticket))
  end

  private

  def default_model_for_provider
    models = provider_preset[:models]
    balanced = models.find { |_, v| v[:tier] == "balanced" }
    balanced ? balanced.first : models.keys.first
  end

  def api_key
    setting.get("api_key")
  end

  def system_prompt
    setting.get("system_prompt").presence ||
      "You are an AI assistant for a helpdesk system called Triage. Help agents respond to customers professionally and accurately."
  end

  def temperature
    (setting.get("temperature") || 0.3).to_f
  end

  def max_tokens
    (setting.get("max_tokens") || 1024).to_i
  end

  def call(task_key, user_message)
    return { ok: false, error: "AI disabled" } unless enabled?
    return { ok: false, error: "No API key" } if api_key.blank?

    started_at = Time.current
    response = if provider_key == "anthropic"
      call_anthropic(user_message)
    else
      call_openai_compatible(user_message)
    end

    input_tokens  = response.dig(:usage, :input_tokens) || response.dig(:usage, :prompt_tokens) || 0
    output_tokens = response.dig(:usage, :output_tokens) || response.dig(:usage, :completion_tokens) || 0
    total_tokens  = input_tokens + output_tokens
    info = model_info
    cost = (input_tokens.to_f * info[:input_1m] + output_tokens.to_f * info[:output_1m]) / 1_000_000

    AiRun.create!(
      company: @company,
      kind: task_key.to_s,
      model: model_key,
      input_tokens: input_tokens,
      output_tokens: output_tokens,
      total_tokens: total_tokens,
      cost_usd: cost,
      success: response[:ok],
      payload: response[:ok] ? { content: response[:content] } : nil,
      error: response[:error]
    )

    response
  rescue Faraday::Error, JSON::ParserError => e
    AiRun.create!(company: @company, kind: task_key.to_s, model: model_key, success: false, error: e.message)
    { ok: false, error: e.message }
  end

  def call_openai_compatible(user_message)
    conn = Faraday.new(url: api_url) do |f|
      f.request :json
      f.response :json
      f.adapter Faraday.default_adapter
    end

    resp = conn.post do |req|
      req.headers["Authorization"] = "Bearer #{api_key}"
      req.headers["Content-Type"]  = "application/json"
      req.body = {
        model: model_key,
        messages: [
          { role: "system", content: system_prompt },
          { role: "user",   content: user_message }
        ],
        temperature: temperature,
        max_tokens: max_tokens
      }.to_json
    end

    body = resp.body.is_a?(String) ? JSON.parse(resp.body) : resp.body
    if body["error"]
      { ok: false, error: body.dig("error", "message") || body["error"].to_s }
    else
      {
        ok: true,
        content: body.dig("choices", 0, "message", "content"),
        usage: {
          prompt_tokens: body.dig("usage", "prompt_tokens") || 0,
          completion_tokens: body.dig("usage", "completion_tokens") || 0
        }
      }
    end
  end

  def call_anthropic(user_message)
    conn = Faraday.new(url: "https://api.anthropic.com") do |f|
      f.request :json
      f.response :json
      f.adapter Faraday.default_adapter
    end

    resp = conn.post("/v1/messages") do |req|
      req.headers["x-api-key"]         = api_key
      req.headers["anthropic-version"] = "2023-06-01"
      req.headers["Content-Type"]      = "application/json"
      req.body = {
        model: model_key,
        max_tokens: max_tokens,
        system: system_prompt,
        messages: [{ role: "user", content: user_message }]
      }.to_json
    end

    body = resp.body.is_a?(String) ? JSON.parse(resp.body) : resp.body
    if body["error"]
      { ok: false, error: body.dig("error", "message") || body["error"].to_s }
    else
      {
        ok: true,
        content: body.dig("content", 0, "text"),
        usage: {
          input_tokens: body.dig("usage", "input_tokens") || 0,
          output_tokens: body.dig("usage", "output_tokens") || 0
        }
      }
    end
  end

  def build_categorize_prompt(ticket)
    "Categorize this support ticket. Return a JSON with: category (string), priority (low/normal/high/urgent), confidence (0-1).\n\nSubject: #{ticket.subject}\nDescription: #{ticket.description}"
  end

  def build_suggest_reply_prompt(ticket)
    comments = ticket.comments.kept.chronological.last(5).map { |c| "#{c.author&.display_name}: #{c.body}" }.join("\n")
    "Suggest a professional reply for this ticket.\n\nSubject: #{ticket.subject}\nDescription: #{ticket.description}\n\nRecent comments:\n#{comments}\n\nWrite a helpful reply in the same language as the ticket."
  end

  def build_summarize_prompt(ticket)
    comments = ticket.comments.kept.chronological.map { |c| "#{c.author&.display_name}: #{c.body}" }.join("\n")
    "Summarize this support ticket thread in 2-3 sentences.\n\nSubject: #{ticket.subject}\nDescription: #{ticket.description}\n\nComments:\n#{comments}"
  end

  def build_sentiment_prompt(ticket)
    "Analyze the customer sentiment for this ticket. Return JSON: { sentiment: positive/neutral/negative, score: -1 to 1, explanation: string }.\n\nSubject: #{ticket.subject}\nDescription: #{ticket.description}"
  end

  def build_monitor_prompt(ticket, new_message)
    recent = ticket.conversation_messages.chronological.last(10).map { |m|
      "#{m.author&.respond_to?(:display_name) ? m.author.display_name : 'system'}: #{m.body.to_s.truncate(200)}"
    }.join("\n")

    "You are monitoring a helpdesk chat. A new message just arrived.\n" \
    "If the agent is going off-track, suggest a correction.\n" \
    "If a service/product should be recommended, suggest it.\n" \
    "If everything is fine, reply with just 'OK' (do not send a suggestion).\n\n" \
    "Ticket: #{ticket.subject}\n\nRecent messages:\n#{recent}\n\n" \
    "New message from #{new_message.author&.respond_to?(:display_name) ? new_message.author.display_name : 'unknown'}: #{new_message.body}\n\n" \
    "Reply with a short internal suggestion for the team, or 'OK' if no action needed."
  end
end
