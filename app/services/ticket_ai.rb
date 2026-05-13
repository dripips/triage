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

  def estimate_cost(task_key)
    task = TASK_KINDS[task_key.to_s] || { input: 1000, output: 300 }
    info = model_info
    (task[:input].to_f * info[:input_1m] + task[:output].to_f * info[:output_1m]) / 1_000_000
  end

  def monthly_budget
    (setting.get("monthly_budget_usd") || 5).to_f
  end

  private

  def default_model_for_provider
    models = provider_preset[:models]
    balanced = models.find { |_, v| v[:tier] == "balanced" }
    balanced ? balanced.first : models.keys.first
  end
end
