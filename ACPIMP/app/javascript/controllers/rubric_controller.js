// controllers/rubric_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ["judgeTotal", "total", "label", "icon", "image", "filename"]

  connect(){
    this.recalculate()
  }

  recalculate(e){
    const judgeId = e.target.dataset.judgeId

    // ✅ หา input ของ judge นี้ทั้งหมด
    const inputs = this.element.querySelectorAll(
      `input[data-judge-id='${judgeId}']`
    )

    let sum = 0

    inputs.forEach(input => {
      const val = parseFloat(input.value)
      if(!isNaN(val)) sum += val
    })

    // ✅ update total ของ judge
    const totalEl = this.judgeTotalTargets.find(
      el => el.dataset.judgeId === judgeId
    )

    if(totalEl){
      totalEl.textContent = sum
    }

    this.updateOverall()
  }

  updateOverall(){
    const allInputs = this.element.querySelectorAll(".score-input")

    let total = 0

    allInputs.forEach(input => {
      const val = parseFloat(input.value)
      if(!isNaN(val)) total += val
    })

    this.totalTarget.textContent = total

    // 🎯 award logic
    let label = "Participant"
    let icon = ""

    if(total >= 80){
      label = "Gold"
      icon = "🥇"
    }else if(total >= 70){
      label = "Silver"
      icon = "🥈"
    }else if(total >= 60){
      label = "Bronze"
      icon = "🥉"
    }

    this.labelTarget.textContent = label
    this.iconTarget.textContent = icon
  }

  show(e){
    const input = e.target
    const file = input.files[0]
    if(!file) return

    const id = input.dataset.id

    // หา image ที่ id ตรงกัน
    const img = this.imageTargets.find(el => el.dataset.id === id)
    const filename = this.filenameTargets.find(el => el.dataset.id === id)

    if(filename){
      filename.innerText = file.name
      filename.classList.remove("text-gray-400")
      filename.classList.add("text-green-600")
    }

    const reader = new FileReader()

    reader.onload = (ev) => {
      if(img){
        img.src = ev.target.result
        document.getElementById("no-picture-"+id).style.display = "none"
      }
    }

    reader.readAsDataURL(file)
  }

}