class AccountsController < ApplicationController
  before_filter :login_required

  def edit
  end

  def update
    if user.update_attributes(account_params)
      flash[:success] = t('flash.updated', name: Account.model_name.human)
      redirect_to page_path('home')
    else
      render :edit
    end
  end

  private

  def account_params
    params.require(:account).permit(
      :email,
      :password,
      :password_confirmation
    )
  end
end
