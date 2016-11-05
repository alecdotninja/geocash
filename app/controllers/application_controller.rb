class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_account
    Account.find_by(id: params[:account_id]) if params[:account_id].present?
  end
end
