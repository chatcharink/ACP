import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

static targets = ["form", "result", "userInput", "userForm", "userResult", "item", "input"]

  connect(){
    this.debounceTimer = null
  }

  live(){
    clearTimeout(this.debounceTimer)

    this.debounceTimer = setTimeout(()=>{
      this.fetch()
    }, 300)
  }

  fetch(extra = {}){
    const formData = new FormData(this.formTarget)

    Object.keys(extra).forEach(k=>formData.append(k, extra[k]))

    const params = new URLSearchParams(formData)
    params.append("partial", "true")

    fetch(`/backend/registrations?${params}`)
    .then(res => res.text())
    .then(html => {
      this.resultTarget.innerHTML = html
    })
  }

  sort(e){
    const sort = e.currentTarget.dataset.sort

    const current = this.formTarget.dataset.direction || "desc"
    const direction = current === "desc" ? "asc" : "desc"

    this.formTarget.dataset.direction = direction

    this.fetch({ sort: sort, direction: direction })
  }

  userLive(){
    clearTimeout(this.debounceTimer)

    this.tidebounceTimermer = setTimeout(()=>{
      this.userFetch()
    }, 300)
  }

  userFetch(){
    const formData = new FormData(this.userFormTarget)
    const params = new URLSearchParams(formData)
    params.append("partial", "true")

    fetch(`/backend/users?${params}`)
    .then(res => res.text())
    .then(html => {
      this.userResultTarget.innerHTML = html
      // window.history.replaceState({}, "", `?${params}`)
    })
  }

}