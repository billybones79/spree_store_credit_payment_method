module Spree
  module GiftCards::OrderConcerns
    extend ActiveSupport::Concern

    included do
      # base.state_machine.before_transition to: :confirm, do: :add_store_credit_payments
      Spree::Order.state_machine.after_transition to: :complete, do: :send_gift_card_emails

      has_many :gift_cards, through: :line_items

      prepend(InstanceMethods)

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
          if gift_card.send_email_at.nil? || gift_card.send_email_at <= DateTime.now
            gift_card.send_email
          end
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

    end
  end
end