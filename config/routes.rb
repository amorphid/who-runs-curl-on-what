Rails.application.routes.draw do
  post "/", to: "curl_requests#create"
  root to: "curl_requests#index"
end
