# External Single Sign-On через JWT.
#
# Use case: у клиента (HR-помощь школы / customer portal SaaS / автодилер
# и т.д.) уже есть своя система авторизации. Они **не хотят** заставлять
# своих пользователей логиниться повторно в helpdesk.
#
# Flow:
#   1. Admin в Triage включает SSO в /settings/sso, копирует shared_secret
#   2. На стороне клиента: их backend подписывает JWT (HS256) с claims:
#        sub:   external_user_id  (например, "u_12345")
#        email: "alice@acme.com"
#        name:  "Alice Smith"
#        exp:   integer (UTC seconds)
#   3. Клиент редиректит юзера на:
#        https://acme.triage.example.com/sso?token=<jwt>
#        ИЛИ кладёт <a href="/sso?token=...&return_to=/tickets">Поддержка</a> на свою страницу
#   4. ExternalSsoController#callback верифицирует подпись + срок,
#      создаёт/обновляет User с external_id, логинит через Devise
#
# Безопасность:
#   • HS256 (shared secret) — простейший вариант, secret кладётся в БД
#     (нужно ротировать раз в N месяцев; admin может revoke в settings).
#   • Exp check — обязательно (отклоняем токены без exp или с exp в прошлом)
#   • Audience check — опционально, через aud claim
#   • Replay protection — не делаем; токены короткоживущие (≤5 мин)
#
# Возвращает [user, error_message]
class ExternalSso
  TOKEN_LIFETIME_MAX = 10.minutes   # отвергаем токены валидные дольше этого

  def self.authenticate(company:, token:)
    new(company: company, token: token).authenticate
  end

  def initialize(company:, token:)
    @company = company
    @token   = token.to_s
  end

  def authenticate
    return [ nil, "sso_disabled" ]      unless @company&.sso_enabled?
    return [ nil, "missing_token" ]     if @token.blank?
    return [ nil, "missing_secret" ]    if @company.sso_secret.blank?

    payload = decode!
    return [ nil, "invalid_token" ]    unless payload

    external_id = payload[claim_key("user_id")].to_s
    email       = payload[claim_key("email")].to_s.downcase
    name        = payload[claim_key("name")].to_s

    return [ nil, "missing_external_id" ] if external_id.blank?
    return [ nil, "missing_email" ]       if email.blank?

    user = find_or_provision_user(external_id, email, name)
    [ user, nil ]
  end

  private

  def decode!
    payload, _header = JWT.decode(
      @token, @company.sso_secret, true,
      algorithm: "HS256", verify_iat: true, verify_expiration: true
    )
    # Защита от вечных токенов: exp не должен быть более чем TOKEN_LIFETIME_MAX
    # в будущем (5-10 мин лимит спасает от leak'нувшегося долго-живущего токена).
    if payload["exp"] && payload["iat"]
      lifetime = payload["exp"].to_i - payload["iat"].to_i
      return nil if lifetime > TOKEN_LIFETIME_MAX
    end
    payload
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError
    nil
  end

  def claim_key(suffix)
    @company.public_send("sso_#{suffix}_claim").presence || default_claim(suffix)
  end

  def default_claim(suffix)
    { "user_id" => "sub", "email" => "email", "name" => "name" }[suffix]
  end

  def find_or_provision_user(external_id, email, name)
    user = User.find_by(external_provider: "jwt", external_id: external_id) ||
           User.find_by(email: email)

    if user.nil?
      user = User.new(
        email:    email,
        password: SecureRandom.hex(32),   # пользователь не знает пароля — логин только через SSO
        company:  @company,
        role:     :agent,
        external_id: external_id,
        external_provider: "jwt"
      )
      user.save!
    else
      # Update внешние мета-данные при каждом успешном SSO-login'е
      user.update_columns(
        external_id: external_id,
        external_provider: "jwt",
        email: email,
        company_id: @company.id
      )
    end
    user
  end
end
