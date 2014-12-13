class UsersController < ApplicationController
	def show
		@user = User.find(params[:id])
	end
	
	def new
		redirect_to root_url if logged_in?
		@user = User.new
	end
	
	def create
		redirect_to root_url if logged_in?
		@user = User.new(user_params)
		if @user.save
			log_in @user
			remember user
			flash[:success] = "Sign up successful!"
			redirect_to @user
		else
			render 'new'
		end
	end
	
	def user_params
		params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
end
