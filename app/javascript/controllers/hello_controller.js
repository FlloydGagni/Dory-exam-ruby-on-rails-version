import { Controller } from "@hotwired/stimulus"

// Default Rails-generated example Stimulus controller. Not wired to any element in this
// app's views (no `data-controller="hello"` attribute is used anywhere); kept as scaffolding.
export default class extends Controller {
  // Runs automatically once this controller connects to a DOM element with
  // `data-controller="hello"`.
  connect() {
    this.element.textContent = "Hello World!"
  }
}
