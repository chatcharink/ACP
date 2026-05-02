import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "image"]

  open(e) {
    const src = e.currentTarget.src

    this.imageTarget.src = src
    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.modalTarget.classList.remove("flex")
  }
}
