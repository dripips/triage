import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "modeRadio", "modeChip",
    "providerRadio", "providerChip",
    "advancedBlock", "standardModels", "advancedModels",
    "modelCards", "apiUrlBlock"
  ]

  connect() {
    this.syncMode()
    this.syncProvider()
  }

  switchMode() {
    this.syncMode()
  }

  switchProvider() {
    this.syncProvider()
  }

  // ── Mode: standard / advanced ──
  syncMode() {
    const mode = this._selectedValue(this.modeRadioTargets)
    this.modeChipTargets.forEach(chip => {
      const radio = chip.querySelector("input[type=radio]")
      chip.classList.toggle("active", radio && radio.value === mode)
    })
    this.advancedBlockTargets.forEach(el => {
      el.style.display = mode === "advanced" ? "" : "none"
    })
    // In standard mode show card-style models; in advanced show quick-pick + free-form
    this.standardModelsTargets.forEach(el => el.style.display = mode === "standard" ? "" : "none")
    this.advancedModelsTargets.forEach(el => el.style.display = mode === "advanced" ? "" : "none")
    this.apiUrlBlockTargets.forEach(el => el.style.display = mode === "advanced" ? "" : "none")
  }

  // ── Provider ──
  syncProvider() {
    const provider = this._selectedValue(this.providerRadioTargets)
    this.providerChipTargets.forEach(chip => {
      const radio = chip.querySelector("input[type=radio]")
      chip.classList.toggle("active", radio && radio.value === provider)
    })
    // Show only models for the selected provider
    this.modelCardsTargets.forEach(el => {
      el.style.display = el.dataset.provider === provider ? "" : "none"
    })
  }

  _selectedValue(radios) {
    const checked = radios.find(r => r.checked)
    return checked ? checked.value : radios[0]?.value
  }
}
