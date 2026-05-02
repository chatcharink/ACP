import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    this.activeTab = "online"
  }

  switch(e) {
    const tab = e.currentTarget.dataset.tab
    this.activeTab = tab

    // toggle panel
    this.panelTargets.forEach(panel => {
      panel.classList.toggle("hidden", panel.dataset.tab !== tab)
    })

    // toggle active button
    this.element.querySelectorAll("[data-tab]").forEach(btn => {
      btn.classList.toggle("active", btn.dataset.tab === tab)
    })
  }
}
