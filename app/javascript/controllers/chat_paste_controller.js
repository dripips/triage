import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "preview"]

  onPaste(event) {
    const items = event.clipboardData?.items
    if (!items) return

    const files = []
    for (const item of items) {
      if (item.kind === "file") {
        files.push(item.getAsFile())
      }
    }

    if (files.length === 0) return
    event.preventDefault()

    const dt = new DataTransfer()
    const existing = this.fileInputTarget.files
    for (const f of existing) dt.items.add(f)
    for (const f of files) dt.items.add(f)
    this.fileInputTarget.files = dt.files

    this._updatePreview()
  }

  _updatePreview() {
    const files = this.fileInputTarget.files
    if (!files.length) {
      this.previewTarget.classList.add("d-none")
      return
    }

    this.previewTarget.classList.remove("d-none")
    this.previewTarget.innerHTML = ""
    for (const file of files) {
      const tag = document.createElement("span")
      tag.className = "pill pill--info pill--sm"
      tag.textContent = `📎 ${file.name}`
      this.previewTarget.appendChild(tag)
    }
  }
}
