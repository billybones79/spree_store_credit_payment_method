# NOTE: Remove for 3-1-stable

module Spree
  class Order < Spree::Base
    module StoreCredit
      def add_store_credit_payments

        return if user.nil?
        return if payments.store_credits.checkout.empty? && user.total_available_store_credit.zero?

        payments.store_credits.where(state: 'checkout').map(&:invalidate!)

        authorized_total = payments.pending.sum(:amount)
        remaining_total = outstanding_balance - authorized_total

        if user.store_credits.any?
          payment_method = Spree::PaymentMethod.find_by_type('Spree::PaymentMethod::StoreCredit')
          raise "Store credit payment method could not be found" unless payment_method

          user.store_credits.order_by_priority.each do |credit|
            break if remaining_total.zero?
            next if credit.amount_remaining.zero?

            amount_to_take = store_credit_amount(credit, remaining_total)
            create_store_credit_payment(payment_method, credit, amount_to_take)
            remaining_total -= amount_to_take
          end
        end

        #other_payments = payments.checkout.not_store_credits

        #if remaining_total.zero?
         #other_payments.each(&:invalidate!)
        #end

        #elsif other_payments.size == 1
        #other_payments.first.update_attributes!(amount: remaining_total)
        #end

        #payments.reset

        #if payments.where(state: %w(checkout pending)).sum(:amount) != total
        #return false
        #end
      end

      def covered_by_store_credit?
        return false unless user
        user.total_available_store_credit >= total
      end

      alias_method :covered_by_store_credit, :covered_by_store_credit?

      def total_available_store_credit
        return 0.0 unless user
        user.total_available_store_credit
      end

      def could_use_store_credit?
        total_available_store_credit > 0
      end

      def order_total_after_store_credit
        total - total_applicable_store_credit
      end

      def total_applicable_store_credit
        if payment? || confirm? || complete?
          total_applied_store_credit
        else
          [total, (user.try(:total_available_store_credit) || 0.0)].min
        end
      end

      def total_applied_store_credit
        payments.store_credits.valid.sum(:amount)
      end

      def using_store_credit?
        total_applied_store_credit > 0
      end

      def display_total_applicable_store_credit
        Spree::Money.new(-total_applicable_store_credit, currency: currency)
      end

      def display_total_applied_store_credit
        Spree::Money.new(-total_applied_store_credit, currency: currency)
      end

      def display_order_total_after_store_credit
        Spree::Money.new(order_total_after_store_credit, currency: currency)
      end

      def display_total_available_store_credit
        Spree::Money.new(total_available_store_credit, currency: currency)
      end

      def display_store_credit_remaining_after_capture
        Spree::Money.new(total_available_store_credit - total_applicable_store_credit, currency: currency)
      end

      private

      def create_store_credit_payment(payment_method, credit, amount)
        payments.create!(
            source: credit,
            payment_method: payment_method,
            amount: amount,
            state: 'checkout',
            response_code: credit.generate_authorization_code
        )
      end

      def store_credit_amount(credit, total)
        [credit.amount_remaining, total].min
      end
    end
  end
end
