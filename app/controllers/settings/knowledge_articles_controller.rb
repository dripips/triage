module Settings
  class KnowledgeArticlesController < SettingsController
    before_action :load_article, only: %i[edit update destroy]

    def index
      @articles = scope.by_position
    end

    def new
      @article = scope.new
    end

    def create
      @article = scope.new(article_params)
      if @article.save
        redirect_to settings_knowledge_articles_path, notice: t("knowledge.created", default: "Статья создана")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @article.update(article_params)
        redirect_to settings_knowledge_articles_path, notice: t("knowledge.updated", default: "Статья обновлена")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @article.discard
      redirect_to settings_knowledge_articles_path, notice: t("knowledge.deleted", default: "Статья удалена")
    end

    private

    def scope
      KnowledgeArticle.kept.where(company: current_company)
    end

    def load_article
      @article = scope.find(params[:id])
    end

    def article_params
      params.require(:knowledge_article).permit(:title, :body, :ticket_type_id, :published, :position)
    end
  end
end
