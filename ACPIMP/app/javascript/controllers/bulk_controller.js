import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bulk"
export default class extends Controller {
  static targets = ["form", "result", "item", "menu"]

  fetch() {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      const formData = new FormData(this.formTarget)
      const params = new URLSearchParams(formData)

      params.append("partial", "true")

      fetch(`/backend/competitions?${params}`, {
        headers: { Accept: "text/html" }
      })
        .then(res => res.text())
        .then(html => {
          this.resultTarget.innerHTML = html
        })
    }, 300) // debounce กันยิงรัว
  }

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  connect() {
    document.addEventListener("click", this.closeOutside.bind(this))
  }

  closeOutside(e) {
    if (!this.element.contains(e.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }

  toggle_checkbox(){
    let checkbox_length = this.itemTargets.filter(cb => cb.checked).length
    if (checkbox_length > 0){
      // if (document.getElementById("btn-select-download").classList.contains("hidden")){
        document.getElementById("btn-select-download").classList.remove("hidden")
      // }
    } else {
      document.getElementById("btn-select-download").classList.add("hidden")
      document.getElementById("select-all").checked = false
    }
  }

  toggleAll(e) {
    this.itemTargets.forEach(cb => {
      cb.checked = e.target.checked
      // document.getElementById("btn-select-download").classList.toggle("hidden")
    })

    document.getElementById("btn-select-download").classList.toggle("hidden", !e.target.checked)
  }

  selectedIds() {
    return this.itemTargets
      .filter(cb => cb.checked)
      .map(cb => cb.value)
  }

  downloadAll(e) {
    const url = e.currentTarget.dataset.url
    this.download(url)
  }

  download(url) {
    const ids = this.selectedIds()

    if (ids.length === 0) {
      alert("กรุณาเลือกอย่างน้อย 1 รายการ")
      return
    }

    const params = new URLSearchParams(window.location.search)

    ids.forEach(id => params.append("ids[]", id))

    window.location = `${url}?${params}`

    this.toggle()
  }
}
