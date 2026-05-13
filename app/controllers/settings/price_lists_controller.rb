module Settings
  class PriceListsController < SettingsController
    before_action :load_price_list, only: %i[edit update destroy]

    def index
      @price_lists = scope.order(:name)
    end

    def new
      @price_list = scope.new
    end

    def create
      @price_list = scope.new(price_list_params)
      if @price_list.save
        redirect_to settings_price_lists_path, notice: t("price_lists.created", default: "Прайс-лист создан")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @items = @price_list.price_items.by_position
    end

    def update
      if @price_list.update(price_list_params)
        redirect_to edit_settings_price_list_path(@price_list), notice: t("price_lists.updated", default: "Прайс-лист обновлён")
      else
        @items = @price_list.price_items.by_position
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @price_list.discard
      redirect_to settings_price_lists_path, notice: t("price_lists.deleted", default: "Прайс-лист удалён")
    end

    private

    def scope
      PriceList.kept.where(company: current_company)
    end

    def load_price_list
      @price_list = scope.find(params[:id])
    end

    def price_list_params
      params.require(:price_list).permit(:name, :active)
    end
  end
end
