require "json"

record Message,
  id : String,
  from : String,
  to : String,
  body : String do
  JSON.mapping(
    id: String,
    from: String,
    to: String,
    body: String,
  )
end
