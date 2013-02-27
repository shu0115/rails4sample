json.array!(@tasks) do |task|
  json.extract! task, :title, :content, :deadline, :count
  json.url task_url(task, format: :json)
end