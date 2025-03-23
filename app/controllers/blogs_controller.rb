class BlogsController < ApplicationController
  def index
    @blogs = Blog.all
  end

  def show
    @blog = Blog.find(params[:id])

    if @blog.nil?
      redirect_to blogs_path, alert: "Blog no encontrado"
    end
  end
end