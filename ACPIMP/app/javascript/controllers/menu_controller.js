import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

    static targets = ["sidebar","dropdown", "menu"]

    toggleSidebar() {
        this.sidebarTarget.classList.toggle("-translate-x-full")
    }

    toggleDropdown() {
        this.dropdownTarget.classList.toggle("hidden")
    }

    toggle() {
        this.menuTarget.classList.toggle("hidden")
    }

}