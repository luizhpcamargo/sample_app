class UsersController < ApplicationController
  before_filter :signed_in_user,  
                  only: [:index, :edit, :update, :destroy, :following, :followers]
  before_filter :correct_user,    only: [:edit, :update]
  before_filter :admin_user,      only: :destroy
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end
  def new
    if !signed_in?
      @user = User.new
    else
      redirect_to root_path
    end
  end
  def create
    if !signed_in?
      @user = User.new(params[:user])
      if @user.save
        sign_in @user
        flash[:success] = "Welcome to the Sample App!"
        redirect_to @user
      else
        render 'new'
      end
    else
      flash[:notice] = "You don't have access to create a new user while log in!"
      redirect_to root_path
    end
  end
  
  def index
    @users = User.paginate(page: params[:page])
  end
  
  def edit
    # @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    
    user = User.find(params[:id])
     if  current_user.admin && !user.admin
       user.destroy
       flash[:success] = "User destroyed."
       redirect_to users_url
     else
       flash[:error] = "Admin users cannot destroy themselves"
       redirect_to users_url
     end    
  end
  
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end
  
  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  private
  # 
  #   def user_params
  #     params.require(:user).permit(:name, :email, :password,
  #                                  :password_confirmation)
  #   end
    
    # Before filters
    
    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in."
      end
    end
    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
