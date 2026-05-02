import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ["days","hours","minutes","seconds"]

  connect(){

    const targetDate = new Date(this.element.dataset.countdownDate)

    setInterval(()=>{

      const now = new Date()
      const diff = targetDate - now

      const d = Math.floor(diff / (1000*60*60*24))
      const h = Math.floor(diff / (1000*60*60)%24)
      const m = Math.floor(diff / (1000*60)%60)
      const s = Math.floor(diff / 1000%60)

      this.daysTarget.innerText = d
      this.hoursTarget.innerText = h
      this.minutesTarget.innerText = m
      this.secondsTarget.innerText = s

    },1000)

  }

}