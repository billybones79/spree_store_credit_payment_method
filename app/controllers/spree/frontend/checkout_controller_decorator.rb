# NOTE: Remove for 3-1-stable

module SpreeStoreCredits::CheckoutControllerDecorator
  def self.prepended(base)
    base.before_action :add_store_credit_payments, only: :update
    base.prepend(InstanceMethods)
  end

  module InstanceMethods

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

    def add_store_credit_payments
    if params['apply_store_credit'].to_i == 1
        @order.add_store_credit_payments


          puts "#####################################"
          puts params.inspect
          puts "#####################################"
          # Remove other payment method parameters.
          params[:order].delete(:payments_attributes)
          params.delete(:payment_source)

        puts "#####################################"
        puts params.inspect
        puts "#####################################"
        # Return to the Payments page if additional payment is needed.
        if @order.payments.valid.sum(:amount) < @order.total
          redirect_to checkout_state_path(@order.state) and return
        end
      end
    end

    def redeem_fail_response
      {
          error_message: "#{Spree.t('gift_cards.errors.not_found')}. #{Spree.t('gift_cards.errors.please_try_again')}"
      }
    end

  end
end

Spree::CheckoutController.prepend SpreeStoreCredits::CheckoutControllerDecorator
