import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets=["row"]

  sort(event){

    const column = event.currentTarget.dataset.column

    const rows = Array.from(this.rowTargets)

    rows.sort((a,b)=>{

      const aText = a.dataset[column]
      const bText = b.dataset[column]

      return aText.localeCompare(bText)

    })

    rows.forEach(row => this.element.appendChild(row))

  }

}