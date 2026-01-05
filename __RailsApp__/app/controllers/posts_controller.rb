class PostsController < ApplicationController
  def index
    @posts = Post.includes(:author, :comments).all
  end

  def show
    post_id = params[:id].to_i

    puts "Post Cache Key: #{post.cache_key_with_version}"
    puts "Cache Exists? #{Rails.cache.exist?(post.cache_key_with_version)}"
    puts "Cache Read: #{Rails.cache.read(post.cache_key_with_version).inspect}"

    @post = Rails.cache.fetch(post.cache_key_with_version, expires_in: 10.minutes) do
      puts "Fetching post #{post_id} from database"
      Post.includes(:comments, :author).find(post_id)
    end
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
