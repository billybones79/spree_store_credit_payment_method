module Spree
  module Order

  end
  def self.included(base)
    # base.state_machine.before_transition to: :confirm, do: :add_store_credit_payments
    base.state_machine.after_transition to: :complete, do: :send_gift_card_emails

    base.has_many :gift_cards, through: :line_items

    base.prepend(InstanceMethods)

    base.include Spree::Order::StoreCredit
  end

  module InstanceMethods

    def finalize!
      gift_cards.each do |gift_card|
        gift_card.make_redeemable!(purchaser: user)
      end

      super
    end

    # def create_gift_cards
    #   line_items.each do |item|
    #     next unless item.gift_card?
    #     next if item.gift_cards.count >= item.quantity
    #     item.quantity.times do
    #       Spree::VirtualGiftCard.create!(amount: item.price, currency: item.currency, purchaser: user, line_item: item)
    #     end
    #   end
    # end

    def send_gift_card_emails
      gift_cards.each do |gift_card|
        Spree::GiftCardMailer.gift_card_email(gift_card).deliver
      end
    end

    private

    def after_cancel
      super

      # Free up authorized store credits
      payments.store_credits.pending.each { |payment| payment.void! }

      # payment_state has to be updated because after_cancel on
      # super does an update_column on the payment_state to set
      # it to 'credit_owed' but that is not correct if the
      # payments are captured store credits that get totally refunded

      reload
      updater.update_payment_state
      updater.persist_totals
    end

    # Override Spree::Core to use the remaining total
    # def update_params_payment_source
    #
    #   if @updating_params[:payment_source].present?
    #     source_params = @updating_params.
    #                     delete(:payment_source)[@updating_params[:order][:payments_attributes].
    #                                             first[:payment_method_id].to_s]
    #
    #     if source_params
    #       @updating_params[:order][:payments_attributes].first[:source_attributes] = source_params
    #     end
    #   end
    #
    #   if @updating_params[:order] && (@updating_params[:order][:payments_attributes] ||
    #                                   @updating_params[:order][:existing_card])
    #     @updating_params[:order][:payments_attributes] ||= [{}]
    #     # @updating_params[:order][:payments_attributes].first[:amount] = total
    #     @updating_params[:order][:payments_attributes].first[:amount] = order_total_after_store_credit
    #   end
    # end

  end
end
