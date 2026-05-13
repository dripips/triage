# Rubby Design System

**English** · [Русский](README.ru.md)

> Apple-inspired UI kit for Ruby on Rails apps. Built on Bootstrap 5.3 + custom SCSS, faithful to Apple HIG (iOS 17 / macOS Sequoia): SF Pro typography, system color palette, vibrancy, soft layered shadows, continuous corners, spring transitions.

[![License: MIT](https://img.shields.io/badge/License-MIT-007AFF.svg?style=flat-square)](LICENSE)
[![Bootstrap 5.3](https://img.shields.io/badge/Bootstrap-5.3-7952B3?style=flat-square&logo=bootstrap&logoColor=white)](https://getbootstrap.com)
[![SCSS](https://img.shields.io/badge/SCSS-CC6699?style=flat-square&logo=sass&logoColor=white)](https://sass-lang.com)
[![Rails 8](https://img.shields.io/badge/Rails-8-CC0000?style=flat-square&logo=rubyonrails&logoColor=white)](https://rubyonrails.org)

This is the shared design layer for the [rubby](https://github.com/dripips?tab=repositories&q=rubby) family of projects — five Rails apps (HRMS, real-estate CRM, medical records, ERP-light, EduSaaS) that all share the same look-and-feel. Change a token here, and all five apps update.

---

## Why

Stock Bootstrap looks like Bootstrap. This layer reskins it to feel like a native macOS / iOS app — without throwing away Bootstrap's robust grid, modals, dropdowns, and form controls. You still write `<button class="btn btn-primary">`, but the result has a continuous-corner squircle, an inset-highlight, soft shadow, and a `cubic-bezier(0.32, 0.72, 0, 1)` press animation.

## What's inside

| File | Purpose |
|---|---|
| [`apple-tokens.scss`](apple-tokens.scss) | Light + dark CSS variables — colors, shadows, radii, motion, vibrancy blur |
| [`apple-typography.scss`](apple-typography.scss) | SF Pro type scale — Large Title, Title 1-3, Headline, Body, Callout, Subhead, Footnote, Caption |
| [`apple-bootstrap.scss`](apple-bootstrap.scss) | Bootstrap 5.3 SCSS variable overrides (must be imported **before** Bootstrap) |
| [`apple-components.scss`](apple-components.scss) | Custom blocks: `.app-shell`, `.sidebar-apple`, `.topbar-apple`, `.card-apple`, `.stat-card`, `.auth-shell`, `.hero-apple`, `.table-apple`, `.pill`, `.flash`, `.avatar-apple`, ... |
| [`apple-utilities.scss`](apple-utilities.scss) | Atomic helpers: `.glass`, `.elev-1..4`, `.surface`, `.icon-tile`, `.spinner-apple` |
| [`index.scss`](index.scss) | Single entry point — pulls everything together in correct order |

## Design tokens — quick reference

```scss
// Accent (iOS system colors)
--ds-blue:   #007AFF;   // primary
--ds-green:  #34C759;   // success
--ds-red:    #FF3B30;   // destructive
--ds-orange: #FF9500;   // warning
--ds-purple: #AF52DE;
--ds-indigo: #5856D6;
--ds-pink:   #FF2D55;

// Surfaces (macOS layered)
--ds-bg-base:     #F2F2F7;     // grouped background
--ds-bg-elevated: #FFFFFF;     // cards, sheets
--ds-bg-grouped:  #F9F9F9;     // sidebars
--ds-bg-overlay:  rgba(255,255,255,0.72);  // glass nav

// Continuous corners (squircle approximation)
--ds-radius-sm:  6px;
--ds-radius-md: 10px;   // buttons, inputs
--ds-radius-lg: 14px;   // cards
--ds-radius-xl: 18px;   // modals

// Apple "spring" easing
--ds-ease-spring: cubic-bezier(0.32, 0.72, 0, 1);
```

Dark mode is automatic via `prefers-color-scheme`, or force it with `<html data-theme="dark">`.

## Install in a Rails app (as a git submodule)

```bash
# 1. Add Bootstrap and dart-sass to your Gemfile
bundle add bootstrap dartsass-rails

# 2. Pull this design system into vendor/
git submodule add git@github.com:dripips/rubby-design-system.git vendor/design-system

# 3. Tell Sass where to find it (config/initializers/dartsass.rb)
Rails.application.config.dartsass.builds = {
  "application.scss" => "application.css"
}
Rails.application.config.dartsass.build_options << "--load-path=vendor/design-system"
Rails.application.config.dartsass.build_options << "--load-path=node_modules"  # if using jsbundling

# 4. In app/assets/stylesheets/application.scss
@import "index";   // pulls all of rubby-design-system

# 5. Update submodule when this repo changes
git submodule update --remote vendor/design-system
```

## Cheat sheet — common patterns

### App shell (sidebar + topbar + main)

```erb
<div class="app-shell">
  <aside class="sidebar-apple">
    <div class="sidebar-apple__brand">
      <span class="sidebar-apple__brand-mark">H</span> HRMS
    </div>
    <a class="sidebar-apple__item active" href="#">Dashboard</a>
    <a class="sidebar-apple__item" href="#">Employees <span class="sidebar-apple__badge">128</span></a>
  </aside>

  <header class="topbar-apple">
    <span class="topbar-apple__title">Dashboard</span>
    <span class="topbar-apple__spacer"></span>
    <div class="topbar-apple__search"><input placeholder="Search..."></div>
  </header>

  <main class="main-apple">
    <header class="page-header">
      <div>
        <div class="page-header__eyebrow">Overview</div>
        <h1 class="page-header__title">Good morning, Vadim</h1>
      </div>
      <div class="page-header__actions">
        <button class="btn btn-soft">Export</button>
        <button class="btn btn-primary">New employee</button>
      </div>
    </header>
    <!-- ... -->
  </main>
</div>
```

### Stat card (KPI tile)

```erb
<div class="stat-card">
  <div class="stat-card__icon"><svg>...</svg></div>
  <div class="stat-card__label">Active employees</div>
  <div class="stat-card__value">128</div>
  <span class="stat-card__delta stat-card__delta--up">↑ 4.2%</span>
</div>
```

### Status pill

```erb
<span class="pill pill--success">Active</span>
<span class="pill pill--warning">On leave</span>
<span class="pill pill--danger">Terminated</span>
```

### Auth split-screen (login / register)

```erb
<div class="auth-shell">
  <section class="auth-shell__form-side">
    <form class="auth-shell__form">
      <h1 class="auth-shell__title">Welcome back</h1>
      <p class="auth-shell__subtitle">Sign in to continue.</p>
      <input class="form-control" type="email" placeholder="Email">
      <input class="form-control" type="password" placeholder="Password">
      <button class="btn btn-primary btn-lg">Sign in</button>
    </form>
  </section>
  <aside class="auth-shell__hero-side">
    <h2>Built for teams that ship.</h2>
    <p>One platform. Every employee. Zero friction.</p>
  </aside>
</div>
```

## Versioning

Tagged with semver. Apps pin to a specific commit via the submodule SHA, so an app upgrade is intentional (`git submodule update --remote`).

## License

MIT — see [LICENSE](LICENSE).
