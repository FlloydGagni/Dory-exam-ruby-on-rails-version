// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// Entry point loaded on every page (see javascript_importmap_tags in the layout).
// Turbo intercepts link clicks/form submissions for the SPA-like page acceleration and
// turbo_method/turbo_confirm data attributes used throughout the views.
import "@hotwired/turbo-rails"
// Boots and auto-registers every Stimulus controller under app/javascript/controllers.
import "controllers"
