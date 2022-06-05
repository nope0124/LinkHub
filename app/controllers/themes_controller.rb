class ThemesController < ApplicationController
  before_action :correct_user, only: [:edit, :update, :destroy]
  before_action :is_draft, only: [:show]

  # get '/:user_name/themes/new' => 'themes#new', as: 'new_theme'
  # Themeを新規投稿する
  def new
    @theme_new = Theme.new
  end


  # root to: 'themes#index'
  # ホーム画面を表示、注目度の高い投稿、ユーザーランキングを表示させる、現在はタイムラインとほぼ同じ
  def index
    # @theme_released_all = Theme.includes(:favorited_users).sort {|a, b| b.favorited_users.size <=> a.favorited_users.size}
    # @theme_released_all = @theme_released_all.select { |theme| theme.status == 2 }
    @theme_released_all = Theme.where(status: 2)
    @theme_released_all = @theme_released_all.reverse
    @users = User.all


    #@themes_ranks = @theme_released_all.find(Favorite.group(:theme_id).order('count(theme_id) desc').limit(5).pluck(:theme_id))
    @themes_ranks = Theme.find(Favorite.group(:theme_id).order('count(theme_id) desc').limit(5).pluck(:theme_id))
    #======================================================================
    # ユーザーの全投稿に対するいいね数ランキング
    post_favorite_count = {}
    User.all.each do |user|
      post_favorite_count.store(user, Favorite.where(theme_id: Theme.where(user_id: user.id).pluck(:id)).count)
    end
    @user_post_favorite_ranks = post_favorite_count.sort_by { |_, v| v }.reverse.to_h

    #=======================================================================
  end


  # get '/timeline' => 'themes#timeline'
  # タイムラインを表示、フォロー中と全ユーザーで分けられる
  def timeline
    @theme_released_following = Theme.where(user_id: [*current_user.following_ids], status: 2)
    @theme_released_following = @theme_released_following.reverse
    @theme_released_all = Theme.where(status: 2)
    @theme_released_all = @theme_released_all.reverse

    @users = User.all
  end


  # post '/:user_name' => 'themes#create', as: 'themes'
  # 新しいThemeを保存
  def create
    theme = Theme.new(theme_params)
    theme.status = 0
    theme.user_id = current_user.id
    theme.save
    redirect_to edit_theme_path(user_name: theme.user.name, theme_hashid: theme.hashid)
  end


  # get '/:user_name/themes/:theme_hashid' => 'themes#show', as: 'theme'
  # Themeに結びついたLinkを表示させる
  def show
    unless @theme.user == @user
      render "errors/404.html", status: :not_found#, layout: "error"
    end
  end


  # get '/:user_name/themes/:theme_hashid/edit' => 'themes#edit', as: 'edit_theme'
  # Themeに結びついたLinkを編集する
  def edit
    @theme = Theme.find(params[:theme_hashid])
  end

  def update
    theme = Theme.find(params[:theme_hashid])
    theme.update(theme_params)
    redirect_to theme_path(user_name: theme.user.name, theme_hashid: theme.hashid)
  end

  def destroy
    theme = Theme.find(params[:theme_hashid])
    theme.destroy
    redirect_to user_path(user_name: theme.user.name)
  end

  private

    def theme_params
      params.require(:theme).permit(:title, :status)
    end

    def correct_user
      user = User.find_by(name: params[:user_name])
      unless user.id == current_user.id
        render "errors/404.html", status: :not_found#, layout: "error"
      end
    end

    def is_draft
      @theme = Theme.find(params[:theme_hashid])
      @user = User.find_by(name: params[:user_name])
      # @theme = Theme.find_by_hashid(params[:theme_hashid], user_id: @user.id)
      # binding.pry
      # 自分以外で下書き状態ならroot_pathに飛ばす
      # 本当は404NotFoundにしたい
      if (current_user == nil or @user.id != current_user.id) and @theme.status == 0
        render "errors/404.html", status: :not_found#, layout: "error"
      end
    end

    # def calculate_user_score
    #   @user_all = User.all
    #   @user_all.each{ |user|
    #     user.score  = 0
    #     user.score += user
    #   }
    # end
end
