class TransfersController < ApplicationController
  def create
    transfer = current_account.transfers.new(transfer_params)

    if params[:transfer_type] == 'withdrawal'
      transfer.amount = -params[:transfer][:amount].to_i
    elsif params[:transfer_type] == 'deposit'
      transfer.amount = params[:transfer][:amount].to_i
    end

    if transfer.save
      redirect_to account_path(transfer.account)
    else
      redirect_to account_path(transfer.account)
    end
  end

  def update
    transfer.assign_attributes(transfer_params)

    if transfer.save
      redirect_to account_path(transfer.account)
    else
      redirect_to account_path(transfer.account)
    end
  end

  private

  def transfer
    @transfer ||= Transfer.find_by id: params[:id]
  end

  def transfer_params
    params.require(:transfer).permit(:geocash_id, :confirmation_code, :confirmed_at)
  end
end