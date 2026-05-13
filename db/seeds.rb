# Idempotent dev seeds — fresh install bootstrap. Safe to run multiple times.

default_password = (Rails.env.development? || Rails.env.test?) ? "password123" : SecureRandom.alphanumeric(20)

# ── 1. Company ─────────────────────────────────────────────────────────
company = Company.find_or_create_by!(code: "default") do |c|
  c.name = "Triage Demo"
  c.default_locale = "ru"
end
puts "[seed] company: #{company.name} (id=#{company.id})"

# ── 2. Users ───────────────────────────────────────────────────────────
[
  { email: "admin@triage.local",      role: :superadmin },
  { email: "supervisor@triage.local", role: :supervisor },
  { email: "agent@triage.local",      role: :agent }
].each do |attrs|
  user = User.find_or_initialize_by(email: attrs[:email])
  is_new = user.new_record?
  user.password = default_password if is_new
  user.role     = attrs[:role]
  user.locale   = "ru"
  user.time_zone = "Moscow"
  user.company  = company
  user.save!
  puts "[seed] user #{attrs[:role]} #{attrs[:email]} (#{is_new ? 'created' : 'updated'})"
end

agent = User.find_by(email: "agent@triage.local")

# ── 3. Ticket types с workflow + custom fields ─────────────────────────
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
  { key: "bug",       name: "Bug",          color: "#FF453A", default_priority: 2, workflow: bug_workflow,
    custom_fields_schema: [
      { "key" => "severity", "label" => "Severity", "type" => "select", "options" => %w[minor major critical] },
      { "key" => "browser",  "label" => "Browser",  "type" => "string" }
    ] },
  { key: "complaint", name: "Жалоба клиента", color: "#FF9F0A", default_priority: 2, workflow: complaint_workflow,
    custom_fields_schema: [
      { "key" => "channel",     "label" => "Канал получения", "type" => "select", "options" => %w[email phone reception other] },
      { "key" => "amount_rub",  "label" => "Сумма ущерба ₽",  "type" => "integer" }
    ] },
  { key: "it_request", name: "IT-заявка",   color: "#0A84FF", default_priority: 1, workflow: it_workflow,
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

# ── 4. Sample tickets ──────────────────────────────────────────────────
bug_type = TicketType.find_by(company: company, key: "bug")
it_type   = TicketType.find_by(company: company, key: "it_request")
comp_type = TicketType.find_by(company: company, key: "complaint")

samples = [
  { type: bug_type,  subject: 'Кнопка "Сохранить" не работает в Safari 17',  priority: :high,   description: 'При клике на "Сохранить" в форме создания заявки Safari 17 на macOS — никакой реакции. На Chrome / Firefox работает.' },
  { type: bug_type,  subject: "500 при выгрузке отчёта за период >30 дней",  priority: :urgent, description: "Запрос /reports/export?from=2026-01-01&to=2026-04-01 валится с timeout. Логи: PG statement_timeout (30s)." },
  { type: it_type,   subject: "Не работает Wi-Fi в переговорке 3.14",        priority: :normal, description: "Третий день подряд Wi-Fi пропадает каждые 15 минут. Подходящий канал — 5GHz." },
  { type: it_type,   subject: "Установить Figma на новый MacBook",           priority: :low,    description: "Новому дизайнеру Алине Соколовой нужно установить Figma + Adobe CC + Slack." },
  { type: comp_type, subject: "Мастер опоздал на час, потерял время",        priority: :high,   description: "Клиент Анна П. жалуется что мастер Игорь опоздал на час 12 мая. Просит компенсацию." },
  { type: comp_type, subject: "Услуга не оказана, оплата проведена",         priority: :urgent, description: "Клиент оплатил окрашивание 8 мая, не явился — деньги не возвращены. Запрос refund." }
]

samples.each do |attrs|
  next if Ticket.exists?(company: company, subject: attrs[:subject])
  t = Ticket.create!(
    company:     company,
    ticket_type: attrs[:type],
    reporter:    agent,
    assignee:    nil,
    subject:     attrs[:subject],
    description: attrs[:description],
    priority:    attrs[:priority]
  )
  puts "[seed] ticket: ##{t.id} #{t.subject.truncate(50)} (#{t.status})"
end

puts "[seed] done. users password: #{default_password}"
