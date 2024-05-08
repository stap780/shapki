import { Controller } from "@hotwired/stimulus"
import { Fancybox } from '@fancyapps/ui';

// Connects to data-controller="fancybox"
export default class extends Controller {
  connect() {
  }
}
document.addEventListener('turbo:load', () => {
    Fancybox.bind('[data-fancybox="gallery"]', {
        //
      });
    }
);