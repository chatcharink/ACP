// register_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [
    "formModal", "confirmModal", "successModal",
    "price","vat","total",
    "image","preview", "nameTh", "nameEn", "category", "province", "district", "phone", "email", "song", "duration",
    "nameThError", "nameEnError", "categoryError", "provinceError", "districtError", "phoneError", "emailError", "songError", "durationError",
    "c_preview", "c_name", "c_nameEn", "c_category", "c_provinceDistrict", "c_phone", "c_email", "c_songDuration", "c_total", "c_type",
    "paySlip", "previewSlip", "progressBar"
  ]

  connect(){
    this.initFloating()
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

  open(){
    this.formModalTarget.classList.remove("hidden")
    this.formModalTarget.classList.add("flex")
    this.loadProvinces()
    this.cache = {}
    this.imageTarget.addEventListener("change", (e)=>{
      const file = e.target.files[0]
      if(file){
        this.previewTarget.src = URL.createObjectURL(file)
        // this.previewTarget.classList.remove("hidden")
      }
    })
    this.calculate()
  }

  close(){
    this.formModalTarget.classList.add("hidden")
  }

  loadProvinces(){

    fetch("https://raw.githubusercontent.com/kongvut/thai-province-data/refs/heads/master/api/latest/province.json")
    .then(res=>res.json())
    .then(data=>{
      // this.provinceTarget.innerHTML = `<option value="">เลือกจังหวัด</option>`

      data.forEach( p => {
        const opt = document.createElement("option")
        opt.value = p.id
        opt.textContent = p.name_th
        this.provinceTarget.appendChild(opt)
        this.districtTarget.disabled = true
      })
    })



  }

  loadDistricts(){

    const province = this.provinceTarget.value
    
    if(!province) {
      this.districtTarget.disabled = true
      this.provinceTarget.classList.remove("input-valid")
      this.provinceTarget.classList.add("input-error")
      return
    }

    // cache กันยิงซ้ำ
    if(this.cache[province]){
      this.renderDistricts(this.cache[province])
      return
    }

    fetch("https://raw.githubusercontent.com/kongvut/thai-province-data/refs/heads/master/api/latest/district.json")
    .then(res=>res.json())
    .then(data=>{
      
      const filtered = data.filter(d => parseInt(d.province_id) == parseInt(province))
      
      // this.districtTarget.innerHTML = `<option value="">เลือกอำเภอ</option>`
      this.renderDistricts(filtered)
      this.clearError(this.provinceTarget)
    })

  }

  /* ---------------- render ---------------- */

  renderDistricts(list){

    // this.districtTarget.innerHTML = `<option value="">เลือกอำเภอ</option>`

    list.forEach(d=>{
      const opt = document.createElement("option")
      opt.value = d.name_th
      opt.textContent = d.name_th
      this.districtTarget.appendChild(opt)
      this.districtTarget.disabled = false
    })

  }

  calculate(e = null) {
    let value;

    if (e) {
      value = e.target.value;
    } else {
      value = "500"; 
    }

    let price = parseInt(value) || 0;
    let vat = Math.round(price * 0.07);
    let total = price + vat;

    this.priceTarget.innerText = price;
    this.vatTarget.innerText = vat;
    this.totalTarget.innerText = total;

    this.currentPrice = price;
    this.currentTotal = total;
    this.currentType = value === "500" ? "Online" : "Onsite";
  }

  confirm(e){

    let valid = true

    if(this.nameThTarget.value.trim() === ""){
      this.showError(this.nameThTarget, "กรุณากรอกชื่อ-นามสกุลภาษาไทย")
      valid = false
    }

    if(this.nameEnTarget.value.trim() === "" && !((/[A-Za-z]+/i).test(this.nameEnTarget.value.trim())) ){
      this.showError(this.nameEnTarget, "กรุณากรอกชื่อ-นามสกุลภาษาอังกฤษ")
      valid = false
    }

    if(this.categoryTarget.value === "" ){
      this.showError(this.categoryTarget, "กรุณาเลือกรุ่นที่สมัคร")
      valid = false
    }

    if(this.provinceTarget.value === "" ){
      this.showError(this.provinceTarget, "กรุณาเลือกจังหวัด")
      valid = false
    }

    if(this.districtTarget.value === "" ){
      this.showError(this.districtTarget, "กรุณาเลือกอำเภอ")
      valid = false
    }

    if(this.phoneTarget.value.replace(/\D/g,"").length !== 10){
      this.showError(this.phoneTarget, "เบอร์โทรไม่ถูกต้อง")
      valid = false
    }

    if(this.emailTarget.value === ""){
      this.showError(this.emailTarget, "กรุณากรอก Email")
      valid = false
    }

    if(this.songTarget.value === ""){
      this.showError(this.songTarget, "กรุณากรอกชื่อเพลงที่จะเล่น")
      valid = false
    }
    
    let valid_duration = this.validateDuration()
    if (!valid_duration){
      valid = false
    }

    if (!valid) return

    this.c_previewTarget.src = this.previewTarget.src
    this.c_nameTarget.innerText = this.nameThTarget.value
    this.c_nameEnTarget.innerText = this.nameEnTarget.value
    this.c_typeTarget.innerText = this.currentType
    this.c_categoryTarget.innerText = this.categoryTarget.options[this.categoryTarget.selectedIndex].text
    this.c_provinceDistrictTarget.innerText = this.provinceTarget.options[this.provinceTarget.selectedIndex].text + "/" + this.districtTarget.value
    this.c_phoneTarget.innerText = this.phoneTarget.value
    this.c_emailTarget.innerText = this.emailTarget.value
    this.c_songDurationTarget.innerText = this.songTarget.value + "/" + this.durationTarget.value
    this.c_totalTarget.innerText = this.currentTotal + "บาท"

    this.formModalTarget.classList.add("hidden")
    this.confirmModalTarget.classList.remove("hidden")
    this.confirmModalTarget.classList.add("flex")
    this.paySlipTarget.addEventListener("change", (e)=>{
      const file = e.target.files[0]
      if(file){
        this.previewSlipTarget.src = URL.createObjectURL(file)
        this.previewSlipTarget.classList.remove("hidden")
      }
    })
  }

  back(){
    this.confirmModalTarget.classList.add("hidden")
    this.formModalTarget.classList.remove("hidden")
  }

  formatPhone(e){

    let val = e.target.value.replace(/\D/g,"")

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

  formatDuration(e){

    let val = e.target.value.replace(/\D/g,"") // เอาแต่ตัวเลข

    if(val.length > 4) val = val.slice(0,4)

    // 0330 → 03:30
    if(val.length >= 3){
    val = val.replace(/(\d{2})(\d{1,2})/, "$1:$2")
    }

    e.target.value = val

  }

  validateRequired(e){

    const el = e.target

    if(el.value.trim().length > 2){
      el.classList.add("input-valid")
      el.classList.remove("input-error")
      this.clearError(el)
    }else{
      el.classList.remove("input-valid")
      el.classList.add("input-error")
    }

  }

  validateSelect(e){
    const el = e.target

    if (el.value === ""){
      el.classList.remove("input-valid")
      el.classList.add("input-error")
    } else {
      el.classList.add("input-valid")
      el.classList.remove("input-error")
      this.clearError(el)
    }
  }

  validatePhone(e){

    const val = e.target.value.replace(/\D/g,"")

    if(val.length === 10){
      e.target.classList.add("input-valid")
      e.target.classList.remove("input-error")
      this.clearError(e.target)
    }else{
      e.target.classList.remove("input-valid")
      e.target.classList.add("input-error")
    }

  }

  validateDuration(){

    const val = this.durationTarget.value

    // format ต้องเป็น MM:SS
    const regex = /^([0-5][0-9]):([0-5][0-9])$/

    if(!regex.test(val)){
      this.showError(this.durationTarget, "รูปแบบต้องเป็น MM:SS เช่น 03:30")
      return
    }

    // แปลงเป็นวินาที
    const [min, sec] = val.split(":").map(Number)
    const total = min*60 + sec

    // กำหนดกติกา (เช่น 1–10 นาที)
    if(total < 60){
      this.showError(this.durationTarget, "ต้องมากกว่า 1 นาที")
      return false
    }else if(total > 600){
      this.showError(this.durationTarget, "ต้องไม่เกิน 10 นาที")
      return false
    }else{
      this.clearError(this.durationTarget)
      return true
    }

  }

  submit(event){
    event.preventDefault()

    const form = event.target
    const formData = new FormData(form)

    this.disableButton(true)
    const xhr = new XMLHttpRequest()

    xhr.open("POST", "/registrations")
    xhr.setRequestHeader("X-CSRF-Token", this.getCSRFToken())

    // progress upload
    xhr.upload.onprogress = (e)=>{
      if(e.lengthComputable){
        const percent = Math.round((e.loaded / e.total) * 100)
        this.updateProgress(percent)
      }
    }

    // success
    xhr.onload = ()=>{
      this.disableButton(false)
      let response = JSON.parse(xhr.response)
      if(response["success"]){
        this.showSuccess()
      }else{
        window.location.reload(response["errors"])
        // alert("error")
      }
    }

    xhr.send(formData)
  }

  updateProgress(percent){
    this.progressBarTarget.style.width = percent + "%"
  }

  disableButton(state){
    this.element.querySelectorAll("button").forEach(btn=>{
      btn.disabled = state

      // if(state){
      //   btn.classList.add("opacity-50","cursor-not-allowed")
      // }else{
      //   btn.classList.remove("opacity-50","cursor-not-allowed")
      // }
    })
  }

  showSuccess(){
    this.successModalTarget.classList.remove("hidden")
    this.successModalTarget.classList.add("flex")
    this.confirmModalTarget.classList.add("hidden")
    this.formModalTarget.classList.add("hidden")
    this.formTarget.reset()
  }

  closeAll(){
    this.successModalTarget.classList.add("hidden")
    this.formModalTarget.classList.add("hidden")
    this.confirmModalTarget.classList.add("hidden")
  }

  showError(input, message){

    input.classList.add("input-error")
    input.classList.remove("input-valid")

    const errorTarget = this.getErrorTarget(input)
    if (errorTarget) errorTarget.textContent = message

  }

  clearError(input){

    input.classList.remove("input-error")
    input.classList.add("input-valid")

    const errorTarget = this.getErrorTarget(input)
    if (errorTarget) errorTarget.textContent = ""

  }

  getErrorTarget(input){
    if (input === this.nameThTarget) return this.nameThErrorTarget
    if (input === this.nameEnTarget) return this.nameEnErrorTarget
    if (input === this.categoryTarget) return this.categoryErrorTarget
    if (input === this.provinceTarget) return this.provinceErrorTarget
    if (input === this.districtTarget) return this.districtErrorTarget
    if (input === this.phoneTarget) return this.phoneErrorTarget
    if (input === this.emailTarget) return this.emailErrorTarget
    if (input === this.songTarget) return this.songErrorTarget
    if (input === this.durationTarget) return this.durationErrorTarget

    return null

  }

  getCSRFToken(){
    return document.querySelector("meta[name='csrf-token']").content
  }

}