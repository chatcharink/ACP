import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  confirm(event){

    const id = event.currentTarget.dataset.deleteId

      if(confirm("Delete this user?")){

        fetch(`/users/${id}`,{
          method:"DELETE",
          headers:{ "X-CSRF-Token":document.querySelector("[name='csrf-token']").content}
          
      }).then(()=>location.reload())

    }

  }

}