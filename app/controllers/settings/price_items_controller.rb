module Settings
  class PriceItemsController < SettingsController
    before_action :load_price_list
    before_action :load_item, only: %i[update destroy]

    def create
      @item = @price_list.price_items.new(item_params)
      if @item.save
        redirect_to edit_settings_price_list_path(@price_list), notice: t("price_items.created", default: "Item added")
      else
        redirect_to edit_settings_price_list_path(@price_list), alert: @item.errors.full_messages.to_sentence
      end
    end

    def update
      if @item.update(item_params)
        redirect_to edit_settings_price_list_path(@price_list), notice: t("price_items.updated", default: "Item updated")
      else
        redirect_to edit_settings_price_list_path(@price_list), alert: @item.errors.full_messages.to_sentence
      end
    end

    def destroy
      @item.destroy
      redirect_to edit_settings_price_list_path(@price_list), notice: t("price_items.deleted", default: "Item removed")
    end

    private

    def load_price_list
      @price_list = PriceList.kept.where(company: current_company).find(params[:price_list_id])
    end

    def load_item
      @item = @price_list.price_items.find(params[:id])
    end

    def item_params
      raw = params.require(:price_item).permit(:name, :description, :amount_rub, :currency, :position, :active)
      if raw[:amount_rub].present?
        raw[:amount_cents] = (raw.delete(:amount_rub).to_d * 100).to_i
      end
      raw
    end
  end
end
