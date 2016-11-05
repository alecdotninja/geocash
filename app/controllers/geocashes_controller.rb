class GeocashesController < ApplicationController
  def simulate
    render :simulate, locals: { geocache: geocache }
  end

  private

  def geocache
    @geocache ||= Geocash.find_by id: params[:id]
  end
end