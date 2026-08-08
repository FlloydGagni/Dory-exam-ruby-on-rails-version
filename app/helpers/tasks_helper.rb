module TasksHelper
  STATUS_BADGE_CLASSES = {
    "pending" => "bg-slate-100 text-slate-700",
    "in_progress" => "bg-amber-100 text-amber-800",
    "completed" => "bg-green-100 text-green-800"
  }.freeze

  def status_badge_classes(status)
    "badge #{STATUS_BADGE_CLASSES.fetch(status, "bg-slate-100 text-slate-700")}"
  end
end
