module Spree
  class GiftCardsController < Spree::StoreController

    before_action :logged_in_user, only: [:new, :create, :redeem]
    before_filter :load_gift_card_for_redemption, only: [:redeem]

    def preview
      #render :preview, :layout => 'spree/layouts/gift_card_preview_layout'
      respond_to do |format|
        format.js {}
      end
    end

    def query

    end

    def show

    end

    def edit_gift

      @gc = Spree::VirtualGiftCard.find(params[:id])

      unless @gc.line_item.order_id == @current_order.id
        redirect_to root_path
      end

      respond_to do |format|
        format.js {}
      end

    end

    def update_gift
      @user = try_spree_current_user

      @gc = Spree::VirtualGiftCard.find(params[:id])

      unless @gc.line_item.order_id == @current_order.id
        redirect_to root_path
      end

      if @gc.update_attributes(update_gift_params)
        flash[:success] = "La carte-cadeau à été mise à jour"
      else
        render :json => { error: "Champs invalides"}, status: :unprocessable_entity
      end
    end

    def transfer
      service = TransferClassicGiftCard.new(params, try_spree_current_user)

      response = service.transfer

      if response
        flash[:success] = Spree.t("card_balance", amount: Spree::Money.new(response, {currency: 'CAD'}))
      else
        flash[:error] =  Spree.t("card_balance_invalid")
      end

      redirect_to new_gift_card_path
    end

    def balance
      service = QueryGiftCardBalance.new(params, try_spree_current_user)

      response = service.balance

      @balance = nil

      if response
        flash[:success] = Spree.t("card_balance", amount: Spree::Money.new(response, {currency: 'CAD'}))
      else
        flash[:error] = Spree.t("card_balance_invalid")
      end

      redirect_to query_gift_cards_path
    end

    def redeem
      if @gift_card.redeem(try_spree_current_user)
        flash[:success] = Spree.t("admin.gift_cards.redeemed_gift_card")
        redirect_to account_path
      else
        flash[:error] = Spree.t("admin.gift_cards.errors.unable_to_redeem_gift_card")
        redirect_to new_gift_card_path
      end
    end

    private

    def update_gift_params
      params.require(:virtual_gift_card).permit(:purchaser_name, :recipient_name, :gift_message, :recipient_email, :locale)
    end

    def load_gift_card_for_redemption
      redemption_code = Spree::RedemptionCodeGenerator.format_redemption_code_for_lookup(params[:gift_card][:redemption_code])
      @gift_card = Spree::VirtualGiftCard.active_by_redemption_code(redemption_code)

      if @gift_card.blank?
        flash[:error] = Spree.t("admin.gift_cards.errors.not_found")
        redirect_to new_gift_card_path
      end
    end

    def logged_in_user
      return if spree_current_user
      store_location
        redirect_to new_spree_user_session_path
    end

    def model_class
      Spree::VirtualGiftCard
    end

    def redeem_fail_response
      {
          error_message: "#{Spree.t('gift_cards.errors.not_found')}. #{Spree.t('gift_cards.errors.please_try_again')}"
      }
    end

    # Introduces a registration step whenever the +registration_step+ preference is true.
  end
end
