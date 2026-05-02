import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]

  toggle() {
    const isOpen = !this.contentTarget.classList.contains("hidden")

    this.contentTarget.classList.toggle("hidden")
    this.iconTarget.textContent = isOpen ? "+" : "−"
  }
}