class GeocashesController < ApplicationController
  def simulate
    render :simulate, locals: { geocash: geocash }
  end

  private

  def geocash
    @geocash ||= Geocash.find_by id: params[:id]
  end
end