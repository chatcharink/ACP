import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="competition"
export default class extends Controller {

  static targets = ["total", "image", "filename"]

  connect(){
    this.update()
  }

  update(){
    let total = 0

    this.element.querySelectorAll("input[type='number']").forEach(input => {
      let v = parseInt(input.value) || 0
      let max = parseInt(input.dataset.max)

      if(v > max){
        input.value = max
        v = max
      }

      total += v
    })

    this.totalTarget.innerText = total
  }

  show(e){
    const file = e.target.files[0]
    if(!file) return

    // show filename
    if(this.hasFilenameTarget){
      this.filenameTarget.innerText = file.name
      this.filenameTarget.classList.remove("text-gray-400")
      this.filenameTarget.classList.add("text-green-600")
    }

    // preview image
    const reader = new FileReader()

    reader.onload = (event) => {

      // hide placeholder
      // if(this.hasPlaceholderTarget){
      //   this.placeholderTarget.classList.add("hidden")
      // }

      // show image
      this.imageTarget.src = event.target.result
      this.imageTarget.classList.remove("hidden")
    }

    reader.readAsDataURL(file)
  }
}
