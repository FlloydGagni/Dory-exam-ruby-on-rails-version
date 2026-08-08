# View helpers for rendering task data. Mixed into task-related views automatically by Rails.
module TasksHelper
  # Maps each Task status to the Tailwind classes used to color its badge.
  # Frozen since this is a static lookup table, never mutated at runtime.
  STATUS_BADGE_CLASSES = {
    "pending" => "bg-slate-100 text-slate-700",
    "in_progress" => "bg-amber-100 text-amber-800",
    "completed" => "bg-green-100 text-green-800"
  }.freeze

  # Returns the full CSS class string for a status badge, given a task's status string.
  # Falls back to the "pending" (slate) styling for any status not in the lookup table,
  # so an unexpected value never renders with no styling at all.
  def status_badge_classes(status)
    "badge #{STATUS_BADGE_CLASSES.fetch(status, "bg-slate-100 text-slate-700")}"
  end
end
