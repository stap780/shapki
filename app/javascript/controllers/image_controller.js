import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage";
import { post } from "@rails/request.js"

// Connects to data-controller="image-upload"
export default class extends Controller {

  static targets = ["filesInput","fileItem"];

  // Bind to normal file selection
  uploadFile(event) {
    const filesInput = this.filesInputTarget;
    const url = filesInput.dataset.directUploadUrl;
    const uploadPath = filesInput.dataset.uploadUrl;
    Array.from(filesInput.files).forEach(file => {
      //console.log('file',file)
      this.createUploadController(file, url, uploadPath).start();
    })
    filesInput.value = "";
  }
  removeFile(event) {
    // not use
  }


  createUploadController(file, url,uploadPath) {
    return new DirectUploadController(file, url, uploadPath);
  }
}

class DirectUploadController {
  constructor(file, url, uploadPath) {
    // console.log('DirectUploadController');
    this.directUpload = this.createDirectUpload(file, url, this);
    this.file = file;
    this.uploadPath = uploadPath;
  }

  start() {
    // console.log('start');
    this.directUpload.create((error, blob) => {
      if (error) {
        // Handle the error
        alert(error);
      } else {
        // console.log('blob',blob);
        this.uploadToActiveStorage(blob, this.uploadPath);
        // Add an appropriately-named hidden input to the form
        // with a value of blob.signed_id
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // Use event.loaded and event.total to update the progress bar
    // console.log(event.loaded, event.total);
    // const percentage = (event.loaded / event.total) * 100;
    // const progress = document.querySelector(`#upload_${this.directUpload.id} .progress`);
    // progress.style.transform = `translateX(-${100 - percentage}%)`;
  }

  createDirectUpload(file, url, controller) {
    return new DirectUpload(file, url, controller);
  }

  async uploadToActiveStorage(blob, uploadPath) {
    const response = await post(uploadPath, {
      body: JSON.stringify({ blob_signed_id: blob.signed_id}),
      responseKind: "turbo-stream",
    })
    
    return response.status === 204
  }

}