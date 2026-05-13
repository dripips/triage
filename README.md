# Triage

**Universal helpdesk — for any team, from devs to vet clinics.** AI-native, self-hostable, open source.

Rails 8 · Hotwire · Multi-tenant · Apple-HIG · MIT.

![Status](https://img.shields.io/badge/status-v0.1%20foundation-orange) ![License](https://img.shields.io/badge/license-MIT-green) ![Rails](https://img.shields.io/badge/rails-8.1-cc0000)

---

## Why Triage

Most OSS helpdesks (Zammad, osTicket, FreeScout) were built before the LLM era and assume "customer support" context. They don't bend easily to:
- Internal IT helpdesk for a school
- Bug tracker for a 3-dev team
- Complaint system for a vet clinic
- Patient inquiries for a private practice

Triage bends — **every ticket type has its own custom fields, workflow (AASM states), and AI auto-categorization**.

## Features (planned per [PRODUCT.md](PRODUCT.md))

- 🤖 **AI-native** — auto-categorize, suggested replies (RAG), sentiment, duplicate detection
- 🎨 **Custom fields per ticket type** — bend any entity to any industry (shared pattern with HRMS)
- 🔁 **Configurable workflows** — AASM states defined per ticket type
- 📨 **Multi-channel inbound** — web form, email webhook, Telegram bot, Slack, REST API
- 🌐 **Multi-tenant from day 1** — subdomain-resolved tenants
- 🏗️ **Apple-HIG design** — modern UI, light + dark, mobile responsive
- 🐳 **One-command Docker install** + zero-downtime upgrade script
- 🔐 **Bearer-token REST API** + Swagger UI

## Status

**v0.1** — Foundation (Rails 8 + Devise + Multi-tenant + Apple-HIG shell)

See [PRODUCT.md](PRODUCT.md) for the full vision and roadmap.

## Quick install (in progress)

```bash
git clone https://github.com/dripips/triage.git
cd triage
./scripts/install.sh
```

## Built with HRMS DNA

Triage shares ~65% of its infrastructure with [HRMS](https://github.com/dripips/rubby-hrms) — sibling OSS Rails product — multi-tenant resolver, Apple design-system, AI provider abstraction, Docker scripts, CI workflow, Slack/Telegram delivery methods.

## License

MIT.
