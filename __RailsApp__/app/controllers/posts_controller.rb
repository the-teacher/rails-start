class PostsController < ApplicationController
  POST_CACHE_EXPIRATION = 10.minutes

  def index
    @posts = Post.includes(:author, :comments).all
  end

  def show
    @post = fetch_post_with_time_cache(post_id_param)
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

  def post_id_param
    params[:id].to_i
  end

  def fetch_post_with_time_cache(post_id)
    post = Post.select(:id, :updated_at).find(post_id)

    Rails.cache.fetch(post.cache_key_with_version, expires_in: POST_CACHE_EXPIRATION) do
      Post.includes(:comments, :author).find(post_id)
    end
  end
end
