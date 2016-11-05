class AccountsController < ApplicationController
  def show
    account = Account.find_by!(id: params[:id])

    render :show, locals: { account: account }
  end
end