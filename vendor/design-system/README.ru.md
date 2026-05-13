# Rubby Design System

[English](README.md) · **Русский**

> UI-кит в стиле Apple для приложений на Ruby on Rails. Построен на Bootstrap 5.3 + собственный SCSS, следует Apple HIG (iOS 17 / macOS Sequoia): типографика SF Pro, системная палитра, vibrancy, мягкие слоистые тени, continuous corners, spring-анимации.

[![License: MIT](https://img.shields.io/badge/License-MIT-007AFF.svg?style=flat-square)](LICENSE)
[![Bootstrap 5.3](https://img.shields.io/badge/Bootstrap-5.3-7952B3?style=flat-square&logo=bootstrap&logoColor=white)](https://getbootstrap.com)
[![SCSS](https://img.shields.io/badge/SCSS-CC6699?style=flat-square&logo=sass&logoColor=white)](https://sass-lang.com)
[![Rails 8](https://img.shields.io/badge/Rails-8-CC0000?style=flat-square&logo=rubyonrails&logoColor=white)](https://rubyonrails.org)

Это общий слой дизайна для семейства проектов [rubby](https://github.com/dripips?tab=repositories&q=rubby) — пять Rails-приложений (HRMS, CRM для недвижимости, мед-карты, ERP-light, EduSaaS), которые используют единый внешний вид. Меняешь токен здесь — все пять обновляются.

---

## Зачем

Стоковый Bootstrap выглядит как Bootstrap. Этот слой переодевает его так, чтобы интерфейс ощущался как нативное macOS / iOS приложение — и при этом сохраняет надёжную сетку, модалки, дропдауны и формы Bootstrap. Ты по-прежнему пишешь `<button class="btn btn-primary">`, но на выходе получаешь continuous-corner squircle, inset-highlight, мягкую тень и spring-анимацию `cubic-bezier(0.32, 0.72, 0, 1)` при нажатии.

## Что внутри

| Файл | Назначение |
|---|---|
| [`apple-tokens.scss`](apple-tokens.scss) | CSS-переменные для light + dark — цвета, тени, скругления, motion, vibrancy blur |
| [`apple-typography.scss`](apple-typography.scss) | Типографика SF Pro — Large Title, Title 1-3, Headline, Body, Callout, Subhead, Footnote, Caption |
| [`apple-bootstrap.scss`](apple-bootstrap.scss) | Переопределение SCSS-переменных Bootstrap 5.3 (импортируется **до** Bootstrap) |
| [`apple-components.scss`](apple-components.scss) | Компоненты: `.app-shell`, `.sidebar-apple`, `.topbar-apple`, `.card-apple`, `.stat-card`, `.auth-shell`, `.hero-apple`, `.table-apple`, `.pill`, `.flash`, `.avatar-apple`, ... |
| [`apple-utilities.scss`](apple-utilities.scss) | Атомарные хелперы: `.glass`, `.elev-1..4`, `.surface`, `.icon-tile`, `.spinner-apple` |
| [`index.scss`](index.scss) | Единая точка импорта — собирает всё в правильном порядке |

## Дизайн-токены — справочник

```scss
// Акценты (системные цвета iOS)
--ds-blue:   #007AFF;   // основной
--ds-green:  #34C759;   // success
--ds-red:    #FF3B30;   // деструктивные действия
--ds-orange: #FF9500;   // warning
--ds-purple: #AF52DE;
--ds-indigo: #5856D6;
--ds-pink:   #FF2D55;

// Поверхности (слоистые, как в macOS)
--ds-bg-base:     #F2F2F7;     // grouped background
--ds-bg-elevated: #FFFFFF;     // карточки, sheets
--ds-bg-grouped:  #F9F9F9;     // sidebars
--ds-bg-overlay:  rgba(255,255,255,0.72);  // glass nav

// Continuous corners (squircle)
--ds-radius-sm:  6px;
--ds-radius-md: 10px;   // кнопки, поля ввода
--ds-radius-lg: 14px;   // карточки
--ds-radius-xl: 18px;   // модалки

// Apple "spring" easing
--ds-ease-spring: cubic-bezier(0.32, 0.72, 0, 1);
```

Тёмная тема включается автоматически через `prefers-color-scheme`, либо принудительно через `<html data-theme="dark">`.

## Подключение в Rails-приложение (как git submodule)

```bash
# 1. Добавить Bootstrap и dart-sass в Gemfile
bundle add bootstrap dartsass-rails

# 2. Подтянуть дизайн-систему в vendor/
git submodule add https://github.com/dripips/rubby-design-system.git vendor/design-system

# 3. Указать Sass где её искать (config/initializers/dartsass.rb)
Rails.application.config.dartsass.builds = {
  "application.scss" => "application.css"
}
Rails.application.config.dartsass.build_options << "--load-path=vendor/design-system"
Rails.application.config.dartsass.build_options << "--load-path=node_modules"  # если используешь jsbundling

# 4. В app/assets/stylesheets/application.scss
@import "index";   // подтянет всю дизайн-систему

# 5. Обновить submodule когда репозиторий обновится
git submodule update --remote vendor/design-system
```

## Шпаргалка — типовые шаблоны

### Каркас приложения (sidebar + topbar + main)

```erb
<div class="app-shell">
  <aside class="sidebar-apple">
    <div class="sidebar-apple__brand">
      <span class="sidebar-apple__brand-mark">H</span> HRMS
    </div>
    <a class="sidebar-apple__item active" href="#">Дашборд</a>
    <a class="sidebar-apple__item" href="#">Сотрудники <span class="sidebar-apple__badge">128</span></a>
  </aside>

  <header class="topbar-apple">
    <span class="topbar-apple__title">Дашборд</span>
    <span class="topbar-apple__spacer"></span>
    <div class="topbar-apple__search"><input placeholder="Поиск..."></div>
  </header>

  <main class="main-apple">
    <header class="page-header">
      <div>
        <div class="page-header__eyebrow">Обзор</div>
        <h1 class="page-header__title">Доброе утро, Вадим</h1>
      </div>
      <div class="page-header__actions">
        <button class="btn btn-soft">Экспорт</button>
        <button class="btn btn-primary">Новый сотрудник</button>
      </div>
    </header>
    <!-- ... -->
  </main>
</div>
```

### KPI-плитка

```erb
<div class="stat-card">
  <div class="stat-card__icon"><svg>...</svg></div>
  <div class="stat-card__label">Активных сотрудников</div>
  <div class="stat-card__value">128</div>
  <span class="stat-card__delta stat-card__delta--up">↑ 4.2%</span>
</div>
```

### Статусные пилюли

```erb
<span class="pill pill--success">Активен</span>
<span class="pill pill--warning">В отпуске</span>
<span class="pill pill--danger">Уволен</span>
```

### Auth split-screen (вход / регистрация)

```erb
<div class="auth-shell">
  <section class="auth-shell__form-side">
    <form class="auth-shell__form">
      <h1 class="auth-shell__title">С возвращением</h1>
      <p class="auth-shell__subtitle">Войдите, чтобы продолжить.</p>
      <input class="form-control" type="email" placeholder="Email">
      <input class="form-control" type="password" placeholder="Пароль">
      <button class="btn btn-primary btn-lg">Войти</button>
    </form>
  </section>
  <aside class="auth-shell__hero-side">
    <h2>Платформа для команд, которые делают.</h2>
    <p>Один продукт. Каждый сотрудник. Ноль трения.</p>
  </aside>
</div>
```

## Версионирование

Релизы маркируются semver-тегами. Приложения "пинятся" к конкретному коммиту через SHA submodule, поэтому обновление дизайн-системы — намеренное действие (`git submodule update --remote`).

## Лицензия

MIT — см. [LICENSE](LICENSE).
