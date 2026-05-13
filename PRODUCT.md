# Triage

> Universal helpdesk — for any team, from devs to vet clinics. AI-native, self-hostable, open source.

---

## Для кого

Любая команда которая ловит **incoming requests** и должна на них реагировать:

- **Dev teams** — issue tracker для багов/feature requests (lite Linear/Jira)
- **Internal helpdesk** — IT / HR / facilities tickets от сотрудников
- **Customer support** — B2B/B2C support inbox с SLA
- **Узкие индустрии** — клиники (жалобы пациентов), автосервисы (рекламации), школы (обращения родителей), коворкинги (заявки участников)

Главный признак — есть **вход** (форма, email, чат), **очередь работы** и **kто-то-должен-ответить**.

---

## Какую боль решаем

1. **Существующие OSS-helpdesk'и устарели** — Zammad, osTicket, FreeScout — старая UX, не AI-native, не bend'ятся под разные индустрии
2. **SaaS дорогие** — Intercom/Zendesk/Freshdesk: $40–80 за seat/мес, для команды 10 человек = $5k+/год
3. **Industry-specific системы — vendor lock** — стоматологический софт умеет только зубные карты; ветеринарный — только животных; для жалоб клиентов и SLA приходится тянуть отдельный helpdesk
4. **Custom workflow ≠ конфиг** — у dev-команды bug имеет states `triage→dev→review→released`, у customer support тот же тикет — `received→investigating→resolved`. Готовые системы либо хардкодят, либо требуют программирования

---

## Что делает Triage универсальным

**Custom fields per ticket type** (как HRMS Dictionaries):
- IT-тикет: OS, версия ПО, серийник железа
- Bug: severity, версия релиза, browser
- Жалоба клиента: продукт, сумма ущерба, канал получения

**Кастомные workflow per type** (AASM с динамической конфигурацией):
- Bug: `triage → in-dev → in-review → released → closed`
- Customer complaint: `received → investigating → resolved → CSAT`
- IT-incident: `reported → assigned → fixing → resolved`

**Multi-channel inbound** — один inbox для всех каналов:
- v1: web-form, email (webhook)
- v1.1: Telegram-бот, Slack
- v1.2: API endpoint, web-widget для встройки на сайт

**AI Bootstrap** (флагман-фича) — описал бизнес обычным текстом → AI предлагает:
- Какие ticket types нужны
- Какие custom fields на каждый тип
- Какой workflow для каждого
- Какие SLA-правила
- Какие auto-routing rules

---

## Killer AI-фичи

| Фича | Когда срабатывает |
|---|---|
| **Auto-categorize** | Новый тикет → AI определяет ticket-type, priority, предлагает assignee |
| **Suggested replies** | RAG по knowledge base + истории закрытых тикетов |
| **Sentiment scoring** | Гневный клиент → red flag для supervisor'а |
| **Duplicate detection** | Кластеризация похожих тикетов (semantic search pgvector) |
| **KB article generator** | Из решённого тикета → черновик статьи для базы знаний |
| **Translation** | Multi-locale support (RU/EN/DE) с переводом тикетов клиента |

---

## Что НЕ делаем (для фокуса)

- Не делаем chat live (это chatwoot-territory) — асинхронные тикеты эффективнее
- Не делаем CRM — мы про reactive, не про outbound sales
- Не делаем телефонию в v1 — telegram/email/web покрывают 90%
- Не делаем ML-models локально — стоим на multi-provider LLM API

---

## Каналы (порядок реализации)

### v1.0 (foundation)
- **Web form** (публичная страница `/new`) — anonymous + auth
- **REST API** — POST `/api/v1/tickets`
- **Email webhook** — Postmark / Mailgun / SendGrid receiving

### v1.1
- **Telegram bot** — inbound сообщений как тикет (используем v1.7 webhook-инфру из HRMS)
- **Slack** — webhook для исходящих, slash-command `/triage` для inbound

### v1.2
- **Web widget** — embed на сайт бизнеса (JS-snippet)
- **Mobile-friendly web app** (PWA install prompt)

---

## Стек (переиспользуем из HRMS на 65-70%)

- **Rails 8.1** + Hotwire (Turbo + Stimulus)
- **PostgreSQL 18** + Solid Queue/Cache/Cable + pgvector (для AI semantic search в v1.2)
- **Devise + Pundit + paper_trail + Discard + AASM**
- **Noticed v3** + custom Slack/Telegram delivery (из HRMS)
- **Multi-provider AI** (OpenAI/Anthropic/Together/Groq/etc — портируем из HRMS)
- **Apple-HIG design-system** (shared submodule с HRMS)
- **Docker** + scripts/install.sh + scripts/update.sh (zero-downtime, из HRMS)
- **CI**: Rubocop + Brakeman + Bundler-audit + RSpec + Zeitwerk check (из HRMS)

---

## Roadmap

### v0.1 — Foundation ✓
- Rails 8 + Devise + Multi-tenant (`Current.company` + `TenantResolver` middleware из HRMS)
- ApiToken (bcrypt + 8-char prefix) — из HRMS
- Apple-HIG layout shell
- CSP + a11y baseline
- Docker + install/update scripts
- 3-locale i18n инфра

### v0.2 — Core entities (next)
- Ticket model + TicketType (с custom fields per type)
- TicketComment + threading
- AASM workflows configurable per ticket-type
- Status / Priority enums
- Apple-HIG views: list / show / new
- Web form для anonymous submission
- Smoke spec для всех страниц

### v0.3 — Inbound channels
- Email webhook (Postmark / Mailgun / SendGrid format)
- Telegram bot inbound (расширяем v1.7 HRMS pattern)
- Slack slash-command

### v0.4 — AI baseline
- Auto-categorize (OpenAI-like API → ticket_type + priority + assignee suggestion)
- Suggested replies (history-based, без RAG)
- Multi-provider AI gem (порт из HRMS)

### v0.5 — Knowledge base
- KnowledgeArticle model
- Simple keyword search
- "Promote ticket to KB-article" workflow

### v1.0 — Production-ready
- Pgvector RAG для suggested replies + duplicate detection
- AI Bootstrap chat (описал бизнес → AI настроил типы/workflows)
- SLA tracking (per ticket type / priority / customer tier)
- Bearer-token REST API + Swagger UI (порт из HRMS v1.11)
- Landing page (3 locales) на GitHub Pages
- Production Docker compose + auto-deploy

### v1.1+
- Web widget embed JS
- PWA mobile manifest
- Sentiment scoring
- Auto-translation (multi-locale тикеты)
- Customer portal (внешние пользователи видят свои тикеты)

---

## Метрики успеха

| Этап | Цель |
|---|---|
| **MVP** (v0.4) | 1 реальная команда использует daily, ≥10 tickets/week |
| **v1.0 публичный лонч** | 50 GitHub stars в первую неделю, 5 self-hosted установок |
| **6 месяцев** | 500 stars, упоминание в awesome-selfhosted, 50+ установок |

---

_Последнее обновление: 2026-05-13_
