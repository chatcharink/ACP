import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  // static targets = ["content"]
  static targets = ["item"]

  connect() {
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("show")
          }
        })
      },
      {
        threshold: 0.15
      }
    )

    this.itemTargets.forEach((el, i) => {
      el.style.transitionDelay = `${i * 100}ms` // stagger
      this.observer.observe(el)
    })
  }

  // toggle(){

  //   const el = this.contentTarget

  //   if(el.classList.contains("max-h-0")){
  //     el.classList.remove("max-h-0")
  //     el.classList.add("max-h-[500px]")
  //   }else{
  //     el.classList.add("max-h-0")
  //     el.classList.remove("max-h-[500px]")
  //   }

  // }

}
