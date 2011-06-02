class PasswordsController < ApplicationController
  before_filter :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_with_password(params[:user].dup)
      sign_in(@user, :bypass => true)
      redirect_to @user, :notice => "Password updated."
    else
      render :edit, :status => :unprocessable_entity
    end
  end
end
