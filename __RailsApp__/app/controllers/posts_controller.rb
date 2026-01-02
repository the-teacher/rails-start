class PostsController < ApplicationController
  def index
    @posts = Post.includes(:author, :comments).all
  end

  def show
    @post = Post.includes(:comments, :author).find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    
    if @post.save
      redirect_to @post, notice: 'Post created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    
    if @post.update(post_params)
      redirect_to @post, notice: 'Post updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    
    redirect_to posts_path, notice: 'Post deleted successfully.'
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, :published)
  end
end
