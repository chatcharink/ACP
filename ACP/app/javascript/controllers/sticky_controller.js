import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["btn"]

  connect() {
    window.addEventListener("scroll", () => this.check())
  }

  check() {
    if (window.scrollY > 400) {
      this.btnTarget.classList.remove("hidden")
    } else {
      this.btnTarget.classList.add("hidden")
    }
  }
}
