import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dashboard"
export default class extends Controller {
  static targets = ["online","onsite"]

  switch(e){
    const type = e.target.dataset.type

    this.onlineTarget.classList.add("hidden")
    this.onsiteTarget.classList.add("hidden")

    if(type === "online"){
      this.onlineTarget.classList.remove("hidden")
    }else{
      this.onsiteTarget.classList.remove("hidden")
    }

    this.element.querySelectorAll(".tab-btn").forEach(btn=>{
      btn.classList.remove("tab-active")
    })
    e.target.classList.add("tab-active")
  }

  draw(){

  }
}
