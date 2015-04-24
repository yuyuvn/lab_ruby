class StaticPagesController < ApplicationController
  def home	
  end
  
  def userhome  
    @micropost = current_user.microposts.build if logged_in?
    @feed_items = current_user.feed.paginate(page: params[:page])
  end

  def help
  end

  def contact
  end

  def about
  end
end
