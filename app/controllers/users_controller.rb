class UsersController < ApplicationController
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(person_params)
    if @user.save
      redirect_to log_in_url, :notice => "Signed up!"
    else
      render "new"
    end
  end

  def person_params
    params.require(:user).permit(:email, :password, :password_confirmation, :fullname)
  end

end
