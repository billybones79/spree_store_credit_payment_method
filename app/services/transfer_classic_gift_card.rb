# @credit_card =
#     ActiveMerchant::Billing::CreditCard.new(
#         :number             => '0211020000001001857',
#         :month              => '00',
#         :year               => '00',
#         :verification_value => '123')

class TransferClassicGiftCard
  def initialize(params, user)
    @provider = Spree::PaymentMethod.where(type: 'Spree::Gateway::MonerisGiftCard').first
    @card = build_moneris_gift_card(params)
    @user = user
  end

  def build_moneris_gift_card(params)
    @credit_card =
        ActiveMerchant::Billing::CreditCard.new(
            :number             => params[:gift_card_number],
            :month              => '00',
            :year               => '00',
            :verification_value => params[:gift_card_cvd])
  end

  # def buy(price)
  #
  #   return false unless user
  #
  #   store_credit_category = Spree::StoreCreditCategory.find_by(name: "Carte-cadeau traditionnelle")
  #
  #   amount = self.balance
  #
  #   begin
  #
  #     if amount.to_f > 0
  #
  #       options = {}
  #       options[:order_id] = "mchoc_#{Time.now}"
  #
  #       amount = Spree::Money.new(price, { currency: :cad }).money.cents
  #
  #       response = provider.gc_purchase(amount, @credit_card, options)
  #
  #       if response.success?
  #         balance = Spree::Money.new(response.params['benefit'], { currency: :cad }).money
  #
  #         if balance > 0
  #           Spree::StoreCredit.create!({
  #                                          amount: balance,
  #                                          currency: 'CAD',
  #                                          memo: response.params['trans_id'],
  #                                          user: user,
  #                                          created_by: user,
  #                                          category: store_credit_category,
  #                                      })
  #
  #         else
  #           return response.params['display_text']
  #         end
  #       else
  #         return false
  #       end
  #     end
  #   rescue => e
  #     return e
  #   end
  # end

  def balance
    begin
      response = provider.gc_inquiry(card)

      if response.success?
        response.params['current_balance']
      else
        0
      end

    rescue => e
      raise Exception
    end
  end

  def transfer

    store_credit_category = Spree::StoreCreditCategory.find_or_create_by(name: "Carte-cadeau traditionnelle")

    return false unless user && store_credit_category

    amount = self.balance

    begin

      # For testing only, need to be wrapped in a transaction and to use proper safeguards
      return false unless amount.to_f > 0

      options = {}
      options[:order_id] = "mchoc_#{Time.now}"

      amount_final = Spree::Money.new(amount, { currency: :cad }).money.cents

      response = provider.gc_purchase(amount_final, @credit_card, options)

      return false unless response.success?

      balance = Spree::Money.new(response.params['benefit'], { currency: :cad }).money

      return false unless balance > 0

      Spree::StoreCredit.create!({
                                     amount: balance,
                                     currency: 'CAD',
                                     memo: response.params['trans_id'],
                                     user: user,
                                     created_by: user,
                                     category: store_credit_category,
                                 })

      balance
    rescue => e
      return e
    end
  end

  attr_reader :card, :provider, :user

end
