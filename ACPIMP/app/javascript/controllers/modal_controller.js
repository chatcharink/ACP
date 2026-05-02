import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ["overlay"]

  open(){
    this.overlayTarget.classList.remove("hidden")
    this.overlayTarget.classList.add("flex")
  }

  close(){
    this.overlayTarget.classList.add("hidden")
    this.overlayTarget.classList.remove("flex")
  }

}
