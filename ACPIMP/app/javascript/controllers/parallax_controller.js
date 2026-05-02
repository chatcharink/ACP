import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="parallax"
export default class extends Controller {
  connect() {
    window.addEventListener("scroll", () => {
      const offset = window.scrollY
      this.element.style.transform = `translateY(${offset * 0.3}px)`
    })
  }
}
