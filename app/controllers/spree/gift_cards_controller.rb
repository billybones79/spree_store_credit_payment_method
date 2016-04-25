module Spree
  class GiftCardsController < Spree::StoreController

    before_action :logged_in_user, only: [:new, :create]

    def preview
      render :preview, :layout => 'spree/layouts/gift_card_preview_layout'
    end

    def query

    end

    def show

    end

    def balance
      service = QueryGiftCardBalance.new(params, try_spree_current_user)

      response = service.balance

      @balance = nil

      if response
        flash[:success] = "Votre solde est de : #{response}"
      else
        flash[:error] = "Carte invalide ou opération impossible"
      end

      redirect_to query_traditional_gift_cards_path
    end

    def redeem
      redemption_code = Spree::RedemptionCodeGenerator.format_redemption_code_for_lookup(params[:redemption_code] || "")
      @gift_card = Spree::VirtualGiftCard.active_by_redemption_code(redemption_code)

      if !@gift_card
        render status: :not_found, json: redeem_fail_response
      elsif @gift_card.redeem(try_spree_current_user)
        render status: :created, json: {status: 'success'}
      else
        render status: 422, json: redeem_fail_response
      end
    end

    private

    def logged_in_user
      unless spree_current_user
        redirect_to new_spree_user_session_path
      end
    end

    def model_class
      Spree::VirtualGiftCard
    end
  end
end
