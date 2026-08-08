import { Application } from "@hotwired/stimulus"

// Single shared Stimulus application instance for the whole page.
const application = Application.start()

// Configure Stimulus development experience
application.debug = false
// Exposed on window so it's reachable from the browser console for debugging.
window.Stimulus   = application

// Imported by controllers/index.js to register individual controllers against this instance.
export { application }
