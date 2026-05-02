import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ["input","row", "modal", "keyword", "category", "type", "results"]

  search(){

    const term = this.inputTarget.value.toLowerCase()

    this.rowTargets.forEach(row=>{

      const text = row.innerText.toLowerCase()

      row.style.display = text.includes(term) ? "" : "none"

    })

  }

  open(){
    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")
    this.initFloating()
  }

  close(){
    this.modalTarget.classList.add("hidden")
  }

  initFloating(){

    this.element.querySelectorAll(".form-group").forEach(group=>{

      const input = group.querySelector(".input-lux")

      if(!input) return

      // ตอนโหลด (edit / autofill)
      if(input.value.trim() !== ""){
        group.classList.add("has-value")
      }

      // focus
      input.addEventListener("focus", ()=>{
        group.classList.add("focused")
      })

      // blur
      input.addEventListener("blur", ()=>{
        group.classList.remove("focused")

        if(input.value.trim() !== ""){
          group.classList.add("has-value")
        }else{
          group.classList.remove("has-value")
        }
      })

      // ตอนพิม
      input.addEventListener("input", ()=>{
        if(input.value.trim() !== ""){
          group.classList.add("has-value")
        }else{
          group.classList.remove("has-value")
        }
      })

    })
  }

  submit(){

    const keyword = this.keywordTarget.value
    // const category = this.categoryTarget.value
    // const type = this.typeTarget.value

    const params = new URLSearchParams({keyword})

    fetch(`/registrations/search?${params}`)
      .then(res=>res.json())
      .then(data=>{
        this.render(data)
      })

  }

  render(data){

    const locale = this.getLocale()

    if(data.length === 0){
      this.resultsTarget.innerHTML = `
      <div class="text-center text-gray-400">
        ${locale === "th" ? "ไม่พบข้อมูล" : "No result"}
      </div>`
      return
    }

    this.resultsTarget.innerHTML = data.map(r=>{

      const name = locale === "th" ? r.name_th : (r.name_en || r.name_th)
      const category = r.category
      const type = r.type == "500" ? "Online" : "Onsite"

      return `
      <div class="border border-gray-800 rounded-lg p-4 space-y-3">

        <div class="flex justify-between">

          <div>
            <div class="text-gold text-lg">${name}</div>
            <div class="text-sm text-gray-400">${category} | ${type}</div>
          </div>

          <div>
            ${this.statusBadge(r.status, locale)}
          </div>

        </div>

        <div class="text-sm">
          ${locale === "th" ? "รางวัล" : "Award"}: ${r.award}
        </div>

        <div class="flex flex-wrap gap-2 mt-3">
          ${this.rejectButton(r, locale)}
          ${this.downloadButtons(r, locale)}
        </div>

      </div>
      `
    }).join("")
  }

  getLocale(){
    return document.documentElement.lang || "en"
  }

  statusBadge(status, locale){

    if(status == 1){
      return `<span class="px-2 py-1 bg-green-600 text-white rounded text-xs">
        ${locale === "th" ? "ยืนยันแล้ว" : "Confirmed"}
      </span>`
    }else if(status == 2){
      return `<span class="px-2 py-1 bg-red-600 text-white rounded text-xs">
        ${locale === "th" ? "ไม่ผ่าน" : "Rejected"}
      </span>`
    }else{
      return `<span class="px-2 py-1 bg-yellow-500 text-black rounded text-xs">
        ${locale === "th" ? "รอการยืนยัน" : "Pending"}
      </span>`
    }

  }

  rejectButton(r, locale){

    if(!r.is_reject) return ""

    return `
      <form name="upload_slip" action="/registrations/${r.id}/upload_slip" method="post" enctype="multipart/form-data">
        <div class="form-group">
          <div>
            <label for="registration_pay_slip" class="block text-sm text-gray-400 mb-2">${locale === "th" ? "อัปโหลดสลิปใหม่" : "Upload Slip"}</label>
            <input type="file" name="upload_slip[pay_slip]" accept="image/*" class="input-lux file:bg-[#B91C1C] file:text-white file:border-0 file:rounded-lg file:px-3 file:py-1">
          </div>
        </div>

        <div class="flex gap-4 mt-6">
          <button type="submit" class="btn-primary px-8 py-3 text-lg w-full cursor-pointer">${locale === "th" ? "อัปโหลด" : "Upload"}</button>
        </div>
      </form>
    `
  }

  downloadButtons(r, locale){

    if(!r.has_competition) return ""

    return `
      <a href="/registrations/${r.id}/certificate"
        class="px-4 py-2 btn-primary rounded text-sm">
        ${locale === "th" ? "เกียรติบัตร" : "Certificate"}
      </a>

      <a href="/registrations/${r.id}/comment"
        class="px-4 py-2 gold-btn rounded text-sm">
        ${locale === "th" ? "ใบคอมเมนต์" : "Comment"}
      </a>
    `
  }

}