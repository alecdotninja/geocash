class TransfersController < ApplicationController

  def show
    render :show, locals: { transfer: transfer }
  end

  def new
    transfer = Transfer.new(account: Account.first_or_create)

    render :new, locals: { transfer: transfer, geocashes: Geocash.all, account: transfer.account }
  end

  def create
    transfer = Transfer.new(transfer_params)

    if transfer.save
      redirect_to :show, locals: { transfer: transfer }
    else
      render :new, locals: { transfer: transfer }
    end
  end

  def edit
    render :edit, locals: { transfer: transfer }
  end

  def update
    transfer = transfer.assign_attributes(transfer_params)

    if transfer.save
      redirect_to :show, locals: { transfer: transfer }
    else
      render :edit, locals: { transfer: transfer }
    end

  end

  private

  def transfer
    @transfer ||= Transfer.find_by id: params[:id]
  end

  def transfer_params
    params.require(:transfer).permit(:account_uuid, :amount, :confirmation_code, :confirmed_at)
  end
end