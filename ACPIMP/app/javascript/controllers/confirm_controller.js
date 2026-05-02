import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  confirm(event){

    event.preventDefault()

    const url = event.currentTarget.href
    const menu = event.currentTarget.dataset.menu

    const popup = document.createElement("div")

    popup.innerHTML = `
                      <div class="fixed inset-0 bg-black/60 flex items-center justify-center z-50">

                        <div class="bg-prussian rounded-xl p-6 w-100 text-center">

                          <h2 class="text-gold text-xl mb-3">Delete `+menu+`</h2>

                          <p class="text-silverslate mb-6">
                            Are you sure you want to delete this `+menu+`?
                          </p>

                          <div class="flex justify-center gap-4">

                            <button id="confirmBtn" class="gold-btn cursor-pointer">
                              Delete
                            </button>

                            <button id="cancelBtn" class="px-4 py-2 border border-silverslate rounded cursor-pointer">
                              Cancel
                            </button>

                          </div>

                        </div>

                      </div>
                      `

    document.body.appendChild(popup)

    popup.querySelector("#cancelBtn").onclick = () => popup.remove()

    popup.querySelector("#confirmBtn").onclick = () => {

      fetch(url,{
        method:"DELETE",
        headers:{ "X-CSRF-Token": document.querySelector("[name='csrf-token']").content}
      }).then(()=>location.reload())

    }

  }

}