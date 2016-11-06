class GeocashesController < ApplicationController
  def simulate
    render :simulate, locals: { geocash: geocash }
  end

  def index
    render :index, locals: { geocashes: geocashes }
  end

  private

  def geocash
    @geocash ||= geocashes.find_by!(description: params[:description])
  end

  def geocashes
    @geocashes ||= Geocash.all
  end
end