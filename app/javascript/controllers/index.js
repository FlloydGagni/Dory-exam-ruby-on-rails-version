// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
// Scans the importmap for every controllers/**/*_controller.js file (currently just
// hello_controller.js) and registers each one with the shared application instance.
eagerLoadControllersFrom("controllers", application)
