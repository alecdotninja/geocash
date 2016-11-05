class TransfersController < ApplicationController

  def show
    render :show, locals: { transfer: transfer }
  end

  def new
    render :new, locals: { transfer: transfer }
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

  end
end
