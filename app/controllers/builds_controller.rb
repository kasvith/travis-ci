require 'responders'

class BuildsController < ApplicationController
  responders :rabl
  respond_to :json

  # Github does not currently post the payload with the correct accept or content-type headers.
  # We need to change Github's service-hook code for this to work correctly.
  skip_before_filter :verify_authenticity_token, :only => :create

  def index
    respond_with builds
  end

  def show
    respond_with build
  end

  protected

    def repository
      @repository ||= Repository.find_by(params) || not_found
    end

    def builds
      @builds ||= if build_number = params['build_number']
        repository.builds.older_than(build_number)
      else
        repository.builds.recent
      end
    end

    def build
      @build ||= Build.find(params[:id], :include => [:commit, { :matrix => [:commit, :log] }] )
    end
end
