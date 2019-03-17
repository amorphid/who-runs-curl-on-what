class CurlRequestsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :validate_user_agent

  def create
    @curl_request = CurlRequest.find_or_initialize_by(curl_request_params)
    @curl_request.increment_count
    @curl_request.save
    render plain: root_url
  end

  def index
    @curl_requests = 
      CurlRequest.
        all.
        order(:architecture, :operating_system)
  end

  private

  def curl_request_params
    architecture, operating_system = 
      params.
        keys.
        grep(/^curl/).
        pop.
        split(" ").
        at(2).
        slice(1..-2).
        split("-", 2)
    {architecture: architecture, operating_system: operating_system}
  end

  def validate_user_agent
    unless request.user_agent.match?(/curl\/(\d+\.)*\d+/)
      head 400
    end
  end
end
