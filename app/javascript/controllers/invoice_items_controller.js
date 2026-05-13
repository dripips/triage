import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template", "row"]

  add() {
    const html = this.templateTarget.innerHTML.replace(/NEW_IDX/g, Date.now())
    this.containerTarget.insertAdjacentHTML("beforeend", html)
  }

  remove(event) {
    const row = event.target.closest("[data-invoice-items-target='row']")
    const destroyFlag = row.querySelector(".destroy-flag")
    if (destroyFlag) {
      destroyFlag.value = "1"
      row.style.display = "none"
    } else {
      row.remove()
    }
  }
}
