# Changelog

## v1.0.0 — 2026-05-14

**First production-ready release.** Universal helpdesk — AI-native, multi-tenant, multi-language, open source.

### Core
- **Tickets** with custom workflows per ticket type (AASM-like via jsonb)
- **Custom fields** per ticket type (Dictionary pattern)
- **Staff / Customer** role separation with access control
- **Multi-tenant** via subdomain → `Current.company`
- **External SSO** — JWT-based login for customer auth systems

### Communication
- **TG-style chat** — real-time via Turbo Streams + Action Cable
- **Read receipts** (✓ delivered / ✓✓ read)
- **Date separators** between messages
- **File attachments** (Active Storage + clipboard paste)
- **System events** in chat (transitions, assignments)
- **Comments** (legacy thread with internal/public distinction)

### AI Assistant
- **Real API integration** — OpenAI, Anthropic, YandexGPT, Ollama, Custom
- **4 actions**: Categorize, Suggest Reply, Summarize, Sentiment Analysis
- **Autonomous mode** — AI monitors chat, suggests corrections, auto-assigns
- **Standard / Advanced** settings modes
- **Cost calculator** + usage tracking (AiRun model)

### Invoicing
- **Invoice CRUD** with per-item discount + hidden surcharge
- **Price Lists** with inline item management
- **PDF export** via browser print
- **Payment settings** — Stripe, YooKassa, Tinkoff integration config

### Notifications
- **In-app bell** with dropdown + badge
- **Email** delivery (SMTP via ActionMailer)
- **Telegram** bot integration
- **Slack** webhook integration
- **Turbo Stream** broadcast for real-time updates

### Settings (11 sections)
- General, AI Assistant, Notifications, SSO, API Tokens
- Knowledge Base, Price Lists, Payments, Chat, Languages, Translations

### i18n
- **Russian + English** — full coverage (~300 keys each)
- **DB-backed translations** — per-key override via Settings → Translations
- **Language management** — add/edit/delete/set-default via Settings → Languages
- **Zero hardcoded text** in views

### Design
- **Apple-HIG design system** (shared with HRMS via vendor/design-system)
- **Dark theme** support (auto/light/dark toggle)
- **Apple-style** select dropdowns + date picker (Stimulus controllers)
- **Responsive** sidebar + offcanvas mobile

### Infrastructure
- Rails 8.1.3 + Hotwire (Turbo + Stimulus) + PostgreSQL 18
- Bootstrap 5.3 (CSS via gem, JS via CDN)
- Devise + Pundit + Discard + PaperTrail
- Solid Queue / Cache / Cable
- DartSass for SCSS compilation
- CI: Rubocop + Brakeman + Bundler-audit + Importmap audit + Zeitwerk + RSpec
