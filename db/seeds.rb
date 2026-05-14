# Idempotent dev seeds — fresh install bootstrap. Safe to run multiple times.

default_password = (Rails.env.development? || Rails.env.test?) ? "password123" : SecureRandom.alphanumeric(20)

# ── 1. Company ─────────────────────────────────────────────────────────
company = Company.find_or_create_by!(code: "default") do |c|
  c.name = "Triage Demo"
  c.default_locale = "ru"
end
puts "[seed] company: #{company.name} (id=#{company.id})"

# ── 1b. Languages ──────────────────────────────────────────────────────
[
  { code: "ru", native_name: "Русский",  english_name: "Russian", flag: "ru", is_default: true,  position: 0 },
  { code: "en", native_name: "English",  english_name: "English", flag: "gb", is_default: false, position: 1 },
  { code: "de", native_name: "Deutsch",  english_name: "German",  flag: "de", is_default: false, position: 2 }
].each do |attrs|
  lang = Language.find_or_initialize_by(company: company, code: attrs[:code])
  lang.assign_attributes(attrs.merge(enabled: true, direction: :ltr))
  lang.save!
  puts "[seed] language: #{lang.native_name} (#{lang.code})"
end

# ── 2. Staff (helpdesk team) ───────────────────────────────────────────
staff_seeds = [
  { email: "admin@triage.local",      name: "Анна Админова",      role: :superadmin, locale: "ru" },
  { email: "supervisor@triage.local", name: "Сергей Старший",     role: :supervisor, locale: "ru" },
  { email: "agent@triage.local",      name: "Алина Агентова",     role: :agent,      locale: "ru" },
  { email: "agent2@triage.local",     name: "Игорь Поддержкин",   role: :agent,      locale: "en" }
]

staff_seeds.each do |attrs|
  user = User.find_or_initialize_by(email: attrs[:email])
  is_new = user.new_record?
  user.password = default_password if is_new
  user.kind     = :staff
  user.role     = attrs[:role]
  user.name     = attrs[:name]
  user.locale   = attrs[:locale]
  user.company  = company
  user.save!
  puts "[seed] staff #{attrs[:role]} #{attrs[:email]} (#{is_new ? 'created' : 'updated'})"
end

# ── 3. Customers (внешние клиенты) ─────────────────────────────────────
customer_seeds = [
  { email: "anna.p@example.com",   name: "Анна Петрова",        locale: "ru", external_id: "ext-1001" },
  { email: "ivan.s@example.com",   name: "Иван Сидоров",        locale: "ru", external_id: "ext-1002" },
  { email: "maria.k@example.com",  name: "Мария Козлова",       locale: "ru", external_id: "ext-1003" },
  { email: "john.smith@example.com", name: "John Smith",         locale: "en", external_id: "ext-1004" },
  { email: "lena@example.com",     name: "Лена Морозова",       locale: "ru", external_id: nil       },
  { email: "max@example.com",      name: "Max Müller",          locale: "de", external_id: "ext-1005" }
]

customer_seeds.each do |attrs|
  user = User.find_or_initialize_by(email: attrs[:email])
  is_new = user.new_record?
  user.password = default_password if is_new
  user.kind     = :customer
  user.role     = nil
  user.name     = attrs[:name]
  user.locale   = attrs[:locale]
  user.external_id = attrs[:external_id]
  user.external_provider = "jwt"
  user.company  = company
  user.save!
  puts "[seed] customer #{attrs[:email]} (#{is_new ? 'created' : 'updated'})"
end

agent  = User.find_by(email: "agent@triage.local")
agent2 = User.find_by(email: "agent2@triage.local")
sup    = User.find_by(email: "supervisor@triage.local")

# ── 4. Ticket types с workflow + custom fields ─────────────────────────
bug_workflow = {
  "initial_state" => "new",
  "states" => %w[new triage in_progress in_review released closed],
  "transitions" => {
    "triage"  => { "from" => [ "new" ],         "to" => "triage" },
    "start"   => { "from" => [ "triage" ],      "to" => "in_progress" },
    "review"  => { "from" => [ "in_progress" ], "to" => "in_review" },
    "release" => { "from" => [ "in_review" ],   "to" => "released" },
    "close"   => { "from" => [ "released" ],    "to" => "closed" }
  }
}

complaint_workflow = {
  "initial_state" => "received",
  "states" => %w[received investigating resolved],
  "transitions" => {
    "investigate" => { "from" => [ "received" ],      "to" => "investigating" },
    "resolve"     => { "from" => [ "investigating" ], "to" => "resolved" }
  }
}

it_workflow = {
  "initial_state" => "reported",
  "states" => %w[reported assigned fixing resolved closed],
  "transitions" => {
    "assign"  => { "from" => [ "reported" ],  "to" => "assigned" },
    "start"   => { "from" => [ "assigned" ],  "to" => "fixing" },
    "resolve" => { "from" => [ "fixing" ],    "to" => "resolved" },
    "close"   => { "from" => [ "resolved" ],  "to" => "closed" }
  }
}

types = [
  { key: "bug",       name: "Bug",            color: "#FF453A", default_priority: 2, workflow: bug_workflow,
    custom_fields_schema: [
      { "key" => "severity", "label" => "Severity", "type" => "select", "options" => %w[minor major critical] },
      { "key" => "browser",  "label" => "Browser",  "type" => "string" }
    ] },
  { key: "complaint", name: "Жалоба клиента", color: "#FF9F0A", default_priority: 2, workflow: complaint_workflow,
    custom_fields_schema: [
      { "key" => "channel",     "label" => "Канал получения", "type" => "select", "options" => %w[email phone reception other] },
      { "key" => "amount_rub",  "label" => "Сумма ущерба ₽",  "type" => "integer" }
    ] },
  { key: "it_request", name: "IT-заявка",     color: "#0A84FF", default_priority: 1, workflow: it_workflow,
    custom_fields_schema: [
      { "key" => "os",     "label" => "OS",     "type" => "string" },
      { "key" => "device", "label" => "Device", "type" => "string" }
    ] }
]

types.each do |attrs|
  type = TicketType.find_or_initialize_by(company: company, key: attrs[:key])
  type.assign_attributes(
    name:                 attrs[:name],
    color:                attrs[:color],
    default_priority:     attrs[:default_priority],
    workflow:             attrs[:workflow],
    custom_fields_schema: attrs[:custom_fields_schema],
    active:               true
  )
  type.save!
  puts "[seed] ticket_type: #{type.name}"
end

# ── 5. Sample tickets + некоторые с комментариями + transitions ────────
bug_type  = TicketType.find_by(company: company, key: "bug")
it_type   = TicketType.find_by(company: company, key: "it_request")
comp_type = TicketType.find_by(company: company, key: "complaint")

customers = User.customer_users.where(company: company).to_a

samples = [
  { type: bug_type,  subject: 'Кнопка "Сохранить" не работает в Safari 17',
    priority: :high, reporter: customers[0],
    description: 'При клике на "Сохранить" в форме создания заявки Safari 17 на macOS — никакой реакции. На Chrome / Firefox работает.',
    assignee: agent, transition: "triage" },
  { type: bug_type,  subject: "500 при выгрузке отчёта за период >30 дней",
    priority: :urgent, reporter: customers[1],
    description: "Запрос /reports/export?from=2026-01-01&to=2026-04-01 валится с timeout. Логи: PG statement_timeout (30s).",
    assignee: agent2, transition: "start" },
  { type: bug_type,  subject: "Layout сломан на iPhone SE",
    priority: :normal, reporter: customers[3],
    description: "On iPhone SE (375px width) the sidebar overlaps the content. Safari only.",
    assignee: agent },
  { type: it_type,   subject: "Не работает Wi-Fi в переговорке 3.14",
    priority: :normal, reporter: customers[2],
    description: "Третий день подряд Wi-Fi пропадает каждые 15 минут. Подходящий канал — 5GHz.",
    assignee: agent2, transition: "assign" },
  { type: it_type,   subject: "Установить Figma на новый MacBook",
    priority: :low, reporter: customers[4],
    description: "Новому дизайнеру Алине Соколовой нужно установить Figma + Adobe CC + Slack." },
  { type: it_type,   subject: "Доступ к VPN не работает после смены пароля",
    priority: :high, reporter: customers[1],
    description: "После сброса пароля по корп.правилам VPN-клиент Cisco AnyConnect не принимает новый пароль.",
    assignee: agent },
  { type: comp_type, subject: "Мастер опоздал на час, потерял время",
    priority: :high, reporter: customers[0],
    description: "Клиент Анна П. жалуется что мастер Игорь опоздал на час 12 мая. Просит компенсацию.",
    assignee: sup },
  { type: comp_type, subject: "Услуга не оказана, оплата проведена",
    priority: :urgent, reporter: customers[4],
    description: "Клиент оплатил окрашивание 8 мая, не явился — деньги не возвращены. Запрос refund." },
  { type: comp_type, subject: "Кофе пролили на коврик в салоне",
    priority: :low, reporter: customers[2],
    description: "Лёгкая ситуация — кофе пролили, попросили компенсацию химчистки." },
  { type: bug_type,  subject: "Авторизация ломается после 30 минут idle",
    priority: :normal, reporter: customers[3],
    description: "Session expires silently — пользователю не показывается banner, просто 401 на следующий запрос." },
  { type: it_type,   subject: "Принтер на 3-м этаже не печатает",
    priority: :normal, reporter: customers[5],
    description: "Brother HL-L2350DW. Светит оранжевым. Подозреваем замятие бумаги — менеджер занят, нужен IT." },
  { type: comp_type, subject: "Грубое отношение администратора на ресепшене",
    priority: :high, reporter: customers[5],
    description: "Beschwerde: der Empfang war sehr unhöflich am 10. Mai um 14:00. Bitte überprüfen." }
]

samples.each do |attrs|
  ticket = Ticket.find_or_initialize_by(company: company, subject: attrs[:subject])
  is_new = ticket.new_record?
  if is_new
    ticket.assign_attributes(
      ticket_type: attrs[:type],
      reporter:    attrs[:reporter],
      assignee:    attrs[:assignee],
      description: attrs[:description],
      priority:    attrs[:priority]
    )
    ticket.save!
    if attrs[:transition].present? && ticket.can_transition?(attrs[:transition])
      ticket.transition!(attrs[:transition], actor: attrs[:assignee] || agent)
    end
  end
  puts "[seed] ticket: ##{ticket.id} #{ticket.subject.truncate(50)} (#{ticket.status})"
end

# ── 6. Несколько комментариев для демонстрации ────────────────────────
first_bug = Ticket.find_by(company: company, subject: 'Кнопка "Сохранить" не работает в Safari 17')
if first_bug && first_bug.comments.count < 3
  first_bug.comments.create!(author: agent, body: "Воспроизвёл локально на Safari 17.4 / macOS Sonoma. Проблема в onClick — preventDefault кладёт всё.", internal: false)
  first_bug.comments.create!(author: sup,   body: "Эскалирую к фронтенд-команде — это блокер для всех маков.",   internal: true)
  first_bug.comments.create!(author: customers[0], body: "Спасибо, жду исправления — пока работаю через Chrome.", internal: false)
end

# ── 7. Knowledge base articles ─────────────────────────────────────────
[
  { title: "Как сбросить пароль", body: "Перейдите на страницу входа, нажмите «Забыли пароль?», введите email.", ticket_type: bug_type, published: true },
  { title: "Правила приёма жалоб", body: "Жалоба регистрируется в течение 24 часов. Ответ клиенту — в течение 48 часов.", ticket_type: comp_type, published: true },
  { title: "Как подключить VPN", body: "Скачайте Cisco AnyConnect, введите адрес сервера vpn.company.com, войдите с корпоративным логином.", ticket_type: it_type, published: true }
].each do |attrs|
  article = KnowledgeArticle.find_or_initialize_by(company: company, title: attrs[:title])
  article.assign_attributes(attrs.merge(company: company, position: 0))
  article.save!
  puts "[seed] KB article: #{article.title}"
end

# ── 8. Price list + items ──────────────────────────────────────────────
pl = PriceList.find_or_create_by!(company: company, name: "Основной прайс") do |p|
  p.active = true
end
[
  { name: "Консультация (30 мин)",  amount_cents: 150000, description: "Базовая консультация" },
  { name: "Диагностика оборудования", amount_cents: 250000, description: "Полная проверка" },
  { name: "Настройка ПО",           amount_cents: 300000, description: "Установка и настройка" },
  { name: "Выезд специалиста",      amount_cents: 500000, description: "Выезд в пределах города" }
].each do |attrs|
  item = pl.price_items.find_or_initialize_by(name: attrs[:name])
  item.assign_attributes(attrs.merge(active: true, position: 0))
  item.save!
end
puts "[seed] price list: #{pl.name} (#{pl.price_items.count} items)"

# ── 9. Chat messages for first ticket ─────────────────────────────────
if first_bug && first_bug.conversation_messages.count < 3
  first_bug.conversation_messages.create!(author: customers[0], body: "Добрый день! Кнопка сохранить не работает уже второй день.", message_type: :text)
  first_bug.conversation_messages.create!(author: agent, body: "Здравствуйте! Спасибо за обращение. Уточните, пожалуйста — какая версия macOS?", message_type: :text)
  first_bug.conversation_messages.create!(author: customers[0], body: "macOS Sonoma 14.5, Safari 17.4.1", message_type: :text)
  first_bug.conversation_messages.create!(author: agent, body: "Спасибо, воспроизвёл. Передал фронтенд-команде, исправим в ближайшем релизе.", message_type: :text)
  puts "[seed] chat messages for ticket ##{first_bug.id}"
end

# ── 10. Sample invoice ─────────────────────────────────────────────────
if first_bug && Invoice.where(company: company, ticket: first_bug).none?
  inv = Invoice.create!(
    company: company, ticket: first_bug, user: admin,
    currency: "RUB", status: :sent, tax_percent: 20, due_at: 7.days.from_now
  )
  inv.invoice_items.create!(name: "Диагностика Safari-бага", quantity: 1, unit_price_cents: 250000)
  inv.invoice_items.create!(name: "Исправление фронтенда",   quantity: 2, unit_price_cents: 300000)
  inv.recalculate_totals
  inv.save!
  puts "[seed] invoice: #{inv.number} (#{inv.formatted_total})"
end

# ── 11. Notifications ─────────────────────────────────────────────────
admin = User.find_by(email: "admin@triage.local")
if admin.in_app_notifications.count < 3
  InAppNotification.create!(recipient: admin, actor: agent, action: "ticket_created", message: "Новый тикет: Layout сломан на iPhone SE", url: "/tickets/7")
  InAppNotification.create!(recipient: admin, actor: sup, action: "ticket_assigned", message: "Вам назначен тикет #5", url: "/tickets/5")
  InAppNotification.create!(recipient: admin, actor: customers[0], action: "message_received", message: "Новое сообщение в тикете #1", url: "/tickets/1")
  puts "[seed] notifications for admin"
end

puts "[seed] done. password for all accounts: #{default_password}"
puts ""
puts "Test accounts:"
puts "  admin@triage.local       — superadmin"
puts "  supervisor@triage.local  — supervisor"
puts "  agent@triage.local       — agent"
puts "  agent2@triage.local      — agent (locale: en)"
puts "  anna.p@example.com       — customer"
puts "  ... + 5 more customers (see db/seeds.rb)"
