class HomeController < ApplicationController
  allow_unauthenticated_access
  def index
    all_blogs = Blog.all
    Rails.logger.debug "Total blogs found: #{all_blogs.size}"
    
    published_blogs = all_blogs.select { |blog| !blog.draft? }
    Rails.logger.debug "Published blogs: #{published_blogs.size}"
    
    @blogs = published_blogs.first(6)
    Rails.logger.debug "Final blogs to display: #{@blogs.size}"
  end

  def about
  end
end 