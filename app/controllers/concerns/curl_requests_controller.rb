class CurlRequestsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :validate_user_agent, only: [:create]
  before_action :validate_params, only: [:create]

  INVALID_PARAMS_MESSAGE = "invalid params"
  INVALID_USER_AGENT = "invalid user agent"

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
    {
      architecture: params[:architecture], 
      operating_system: params[:operating_system]
    }
  end

  def validate_params 
    raise INVALID_PARAMS_MESSAGE if params[:architecture]
    raise INVALID_PARAMS_MESSAGE if params[:operating_system]

    architecture, operating_system = 
      params.
        keys.
        grep(/^curl/).
        pop.
        split(" ").
        at(2).
        slice(1..-2).
        split("-", 2)

    raise INVALID_PARAMS_MESSAGE if architecture.match?("<script>")
    raise INVALID_PARAMS_MESSAGE if operating_system.match?("<script>")

    params[:architecture] = architecture
    params[:operating_system] = operating_system

    params.permit(:architecture, :operating_system)
  rescue
    render plain: INVALID_PARAMS_MESSAGE, status_code: 400
  end

  def validate_user_agent
    unless request.user_agent 
      return plain: INVALID_USER_AGENT, status_code: 400
    end

    unless request.user_agent && request.user_agent.match?(/curl\/(\d+\.)*\d+/)
      return plain: INVALID_USER_AGENT, status_code: 400
    end
  end
end
