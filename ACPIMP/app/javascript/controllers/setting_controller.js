import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="setting"
export default class extends Controller {
  static targets = ["panel", "preview", "list", "groups", "removepic", "scores", "removedScores"]

  connect() {
    this.files = []
    this.removedIds = []
  }

  switch(e) {
    const tab = e.currentTarget.dataset.tab

    this.panelTargets.forEach(p => {
      p.classList.toggle("hidden", p.dataset.name !== tab)
    })

    // active tab style
    this.element.querySelectorAll(".tab-btn").forEach(btn => {
      btn.classList.remove("tab-active")
    })

    e.currentTarget.classList.add("tab-active")
  }

  preview(e) {
    this.previewTarget.innerHTML = ""

    Array.from(e.target.files).forEach(file => {
      const reader = new FileReader()

      reader.onload = (ev) => {
        const img = document.createElement("img")
        img.src = ev.target.result
        img.className = "rounded-lg shadow"
        this.previewTarget.appendChild(img)
      }

      reader.readAsDataURL(file)
    })
  }

  addFiles(e) {
    const newFiles = Array.from(e.target.files)

    // 🔥 append ไม่ replace
    this.files = [...this.files, ...newFiles]

    this.render()
    e.target.value = "" // reset input (สำคัญมาก ไม่งั้นเลือกไฟล์เดิมไม่ได้)
  }

  remove(e) {
    const index = e.currentTarget.dataset.index
    this.files.splice(index, 1)
    this.render()
  }

  render() {
    this.previewTarget.innerHTML = ""

    this.files.forEach((file, i) => {
      const reader = new FileReader()

      reader.onload = (e) => {
        const div = document.createElement("div")
        div.className = "relative group"

        div.innerHTML = `
          <img src="${e.target.result}"
               class="w-full h-32 object-cover rounded-lg">

          <button type="button"
            data-action="click->setting#remove"
            data-index="${i}"
            class="absolute top-1 right-1 bg-red-500 text-white rounded-full w-6 h-6 text-xs hidden group-hover:block">
            ✕
          </button>
        `

        this.previewTarget.appendChild(div)
      }

      reader.readAsDataURL(file)
    })
  }

  removeExisting(e) {
    const id = e.currentTarget.dataset.id

    // mark delete
    let remove_id = []
    if (this.removepicTarget.value != ""){
      remove_id = this.removepicTarget.value.split(",")
    }
    remove_id.push(id)
    this.removepicTarget.value = remove_id
    // this.previewTarget.appendChild(input)

    e.currentTarget.closest("div").remove()
  }

  // 🔥 เอาไฟล์ไป submit
  getFiles() {
    return this.files
  }

  addGroup() {
    const div = document.createElement("div")
    div.className = "border rounded-xl p-4 mt-3"

    div.innerHTML = `
      <input name="groups[][name_th]" placeholder="หัวข้อ" class="input-clean mb-2">

      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <input name="groups[][categories][][name_th]" placeholder="ชื่อรุ่นภาษาไทย" class="input-clean">
        <input name="groups[][categories][][name_en]" placeholder="ชื่อรุ่นภาษาอังกฤษ" class="input-clean">
        <input name="groups[][categories][][code]" placeholder="PIANO01" class="input-clean">
      </div>

      <button type="button" data-action="click->setting#addItem">
        + เพิ่ม category
      </button>
    `

    this.groupsTarget.appendChild(div)
  }

  addItem(e) {
    const container = e.currentTarget.previousElementSibling

    const input_th = document.createElement("input")
      input_th.name = "groups[][categories][][name_th]"
      input_th.className = "input-clean"
      input_th.placeholder = "ชื่อรุ่นภาษาไทย"

    const input_en = document.createElement("input")
      input_en.name = "groups[][categories][][name_en]"
      input_en.className = "input-clean"
      input_en.placeholder = "ชื่อรุ่นภาษาอังกฤษ"

    const input_code = document.createElement("input")
      input_code.name = "groups[][categories][][code]"
      input_code.className = "input-clean"
      input_code.placeholder = "PIANO01"

    container.appendChild(input_th)
    container.appendChild(input_en)
    container.appendChild(input_code)
  }

  addScore() {
    const html = `
      <div class="grid grid-cols-[1fr_120px_40px] gap-3 items-center">

        <input
          type="text"
          name="scores[][name]"
          class="input-clean"
          placeholder="ชื่อหัวข้อ"
        >

        <input
          type="number"
          name="scores[][max_score]"
          class="input-clean text-center"
          placeholder="100"
        >

        <button type="button"
          data-action="click->setting#removeScore"
          class="text-red-500 hover:text-red-700">
          ✕
        </button>

      </div>
    `

    this.scoresTarget.insertAdjacentHTML("beforeend", html)
  }

  removeScore(e) {
    const row = e.target.closest("[data-score-row]")

    const idInput = row.querySelector("input[name='scores[][id]']")

    if (idInput && idInput.value) {
      const id = idInput.value

      if (!this.removedIds.includes(id)) {
        this.removedIds.push(id)
      }
      this.removedScoresTarget.value = this.removedIds.join(",")
    }

    row.remove()
  }

  submit(e) {
    e.preventDefault()

    const form = e.target
    const formData = new FormData(form)

    this.getFiles().forEach(file => {
      formData.append("gallery[]", file)
    })

    fetch(form.action, {
      method: "PATCH",
      body: formData
    }).then(() => window.location.href = "/backend/settings")
  }
}
