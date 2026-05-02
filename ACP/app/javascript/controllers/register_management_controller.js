import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="register-management"
export default class extends Controller {
  static targets = ["error", "phone"]

  connect(){
    this.validation = true
    this.formatPhone()
  }

  showPreview(event){
    const file = event.target.files[0]
    if(!file) return

    const reader = new FileReader()
    reader.onload = (e)=>{
      this.element.querySelector("img").src = e.target.result
      this.element.querySelector("img").classList.remove("hidden")
      if (document.getElementById("new_profile")){
        if (!document.getElementById("new_profile").classList.contains("hidden")){
          document.getElementById("new_profile").classList.add("hidden")
        }
      }
    }
    reader.readAsDataURL(file)
  }

  formatPhone(e = null){

    let phone;

    if (e) {
      phone = e.target.value;
    } else {
      phone = this.phoneTarget.value; 
    }

    let val = phone.replace(/\D/g,"")

    if(val.length > 10) val = val.slice(0,10)

    // format 080-123-4567
    if(val.length > 6){
      val = val.replace(/(\d{3})(\d{3})(\d+)/, "$1-$2-$3")
    }else if(val.length > 3){
      val = val.replace(/(\d{3})(\d+)/, "$1-$2")
    }

    e.target.value = val
    this.validatePhone(e)
  }

  formatTime(e){
    let v = e.target.value.replace(/\D/g, "")

    if(v.length >= 3){
      v = v.slice(0,2) + ":" + v.slice(2,4)
    }

    e.target.value = v
  }

  validate(e){
    const input = e.target
    const value = input.value.trim()

    let message = ""
    
    this.validation = true

    if(input.name.includes("name_th") && value.length < 1){
      message = "กรุณากรอกชื่อ-นามสกุลภาษาไทย"
      this.validation = false
    }

    if(input.name.includes("name_en") && value.length < 1 && !((/[A-Za-z]+/i).test(value))){
      message = "กรุณากรอกชื่อ-นามสกุลภาษาอังกฤษ"
      this.validation = false
    }

    if(input.name.includes("phone") && value.replace(/\D/g,"").length !== 10){
      message = "เบอร์โทรไม่ถูกต้อง"
      this.validation = false
    }

    if(input.name.includes("email") && value === ""){
      message = "กรุณากรอก Email"
      this.validation = false
    }

    if(input.name.includes("song") && value === ""){
      message = "กรุณากรอกชื่อเพลงที่จะเล่น"
      this.validation = false
    }

    if(input.name.includes("duration")){
      if(!/^\d{2}:\d{2}$/.test(value)){
        message = "ต้องเป็นรูปแบบ MM:SS"
      }
      this.validation = false
    }
    // show error
    const errorEl = this.errorTargets.find(el => el.dataset.field === input.name.replace("registration[","").replace("]",""))

    if(errorEl){
      if(message){
        errorEl.innerText = message
        errorEl.classList.remove("hidden")
        input.classList.add("border-red-400")
        input.classList.remove("border-green-400")
      }else{
        errorEl.classList.add("hidden")
        input.classList.remove("border-red-400")
        input.classList.add("border-green-400")
      }
    }
  }

  submit(event){
    event.preventDefault()

    const form = event.target
    const formData = new FormData(form)

    const xhr = new XMLHttpRequest()

    if (this.validation) {
      xhr.open(form.method, form.action)
      xhr.setRequestHeader("X-CSRF-Token", this.getCSRFToken())

      // progress upload
      // xhr.upload.onprogress = (e)=>{
      //   if(e.lengthComputable){
      //     const percent = Math.round((e.loaded / e.total) * 100)
      //     this.updateProgress(percent)
      //   }
      // }

      // success
      xhr.onload = ()=>{
        let response = JSON.parse(xhr.response)
        if(response["success"]){
          window.location.replace(response["redirect_path"])
        }else{
          window.location.replace(response["errors"])
        }
      }

      xhr.send(formData)
    }
  }


  getCSRFToken(){
    return document.querySelector("meta[name='csrf-token']").content
  }
}
