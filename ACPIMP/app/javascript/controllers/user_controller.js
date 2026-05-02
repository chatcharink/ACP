import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="user"
export default class extends Controller {
  static targets = ["input", "error", "panel", "field"]

  connect(){
    this.rules = {
      username: v => v.trim() !== "" || "กรุณากรอก Username",

      password: v => {
        if(!v.length > 6 || !/[A-Z]/.test(v) || !/[a-z]/.test(v) || !/[0-9]/.test(v)) return "กรุณากรอก Password อย่างน้อย 6 ตัวอักษร โดยต้องมีตัวภาษาอังกฤษพิมพ์ใหญ่อย่างน้อย 1 ตัว, ตัวภาษาอังกฤษพิมพ์เล็กอย่างน้อย 1 ตัว และตัวเลขอย่างน้อย 1 ตัว"
        return true
      },

      firstname: v => v.trim() !== "" || "กรุณากรอกชื่อจริง",
      lastname: v => v.trim() !== "" || "กรุณากรอกนามสกุล",

      telephone: v => {
        // if(!v) return "Telephone ห้ามว่าง"
        if(!/^\d{3}-\d{3}-\d{4}$/.test(v)) return "กรุณากรอกเบอร์ฌทรศัพท์ 10 หลัก"
        return true
      },

      email: v => {
        if(!v) return "Email ห้ามว่าง"
        if(!/\S+@\S+\.\S+/.test(v)) return "Email ไม่ถูกต้อง"
        return true
      },

      status: v => v !== "" || "กรุณาเลือก Status",
      role: v => v !== "" || "กรุณาเลือก Role"
    }
  }

  // 🔥 validate ทุกครั้งที่พิมพ์
  validateField(e){
    const input = e.target
    const field = input.dataset.field

    if(field === "password" && input.disabled) return

    const rule = this.rules[field]

    if(!rule) return

    const result = rule(input.value)

    if(result === true){
      this.clearError(input)
    }else{
      this.showError(input, result)
    }
  }

  // 🔥 submit validate
  submit(e){
    let valid = true

    this.inputTargets.forEach(input=>{
      const field = input.dataset.field

      console.log(field)
      console.log(input.disabled)
      console.log(field === "password")
      if(input.disabled) return

      const rule = this.rules[field]

      if(!rule) return

      const result = rule(input.value)

      if(result !== true){
        this.showError(input, result)
        valid = false
      }
    })

    // ❗ block เฉพาะตอน invalid เท่านั้น
    if(!valid){
      e.preventDefault()
    }
  }

  showError(input, message){
    input.classList.add("border-red-500")

    const error = this.errorTargets.find(el => el.dataset.field === input.dataset.field)

    if(error){
      error.innerText = message
      error.classList.remove("hidden")
    }
  }

  clearError(input){
    input.classList.remove("border-red-500")

    const error = this.errorTargets.find(el => el.dataset.field === input.dataset.field)

    if(error){
      error.classList.add("hidden")
    }
  }

  // 🔥 format phone
  formatPhone(e){
    let v = e.target.value.replace(/\D/g, "").slice(0,10)

    if(v.length >= 7){
      v = `${v.slice(0,3)}-${v.slice(3,6)}-${v.slice(6)}`
    }else if(v.length >= 4){
      v = `${v.slice(0,3)}-${v.slice(3)}`
    }

    e.target.value = v
  }

  toggle(){
    const isHidden = this.panelTarget.classList.toggle("hidden")

    this.fieldTargets.forEach(input => {
      input.disabled = isHidden
    })
  }

  cancel(){
    this.fieldTargets.forEach(input => {
      input.value = ""
      input.disabled = true
    })
    this.panelTarget.classList.add("hidden")
  }
}
