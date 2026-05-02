import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="nav"
export default class extends Controller {
  connect() {
    this.sections = document.querySelectorAll("section[id]")

    window.addEventListener("scroll", () => {
      let current = ""

      this.sections.forEach((section) => {
        const top = section.offsetTop - 150
        if (scrollY >= top) {
          current = section.getAttribute("id")
        }
      })

      document.querySelectorAll("nav a").forEach((a) => {
        a.classList.remove("text-gold")
        if (a.getAttribute("href") === `#${current}`) {
          a.classList.add("text-gold")
        }
      })
    })
  }
}
