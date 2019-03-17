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

    @curl_dash_v = CurlDashV.find_or_initialize_by(curl_dash_v_params)
    @curl_dash_v.increment_count
    @curl_dash_v.save

    render plain: root_url
  end

  def index
    @curl_requests = 
      CurlRequest.
        all.
        order(:architecture, :operating_system)

    @curl_dash_vs = CurlDashV.all.order(:dump)
  end

  private

  def curl_dash_v_params
    {
      dump: params[:dump]
    }
  end

  def curl_request_params
    {
      architecture: params[:architecture], 
      operating_system: params[:operating_system]
    }
  end

  def validate_params 
    raise INVALID_PARAMS_MESSAGE if params[:architecture]
    raise INVALID_PARAMS_MESSAGE if params[:curl_dash_v]
    raise INVALID_PARAMS_MESSAGE if params[:operating_system]

    curl_dash_v = 
      params.
          keys.
          grep(/^curl/).
          pop

    raise INVALID_PARAMS_MESSAGE if curl_dash_v.downcase.match?("<")

    architecture, operating_system = 
      curl_dash_v.
        split(" ").
        at(2).
        slice(1..-2).
        split("-", 2)

    architecture, operating_system = [nil, architecture] unless operating_system

    params[:architecture] = architecture
    params[:dump] = curl_dash_v
    params[:operating_system] = operating_system
    
    params.permit(:architecture, :curl_dash_v, :operating_system)
  rescue
    render plain: INVALID_PARAMS_MESSAGE, status_code: 400
  end

  def validate_user_agent
    unless request.user_agent 
      return render plain: INVALID_USER_AGENT, status_code: 400
    end

    unless request.user_agent && request.user_agent.match?(/curl\/(\d+\.)*\d+/)
      render plain: INVALID_USER_AGENT, status_code: 400
    end
  end
end
