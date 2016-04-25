class QueryGiftCardBalance
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

  def balance
    begin
      response = provider.gc_inquiry(card)

      if response.success?
        response.params['current_balance']
      else
        0
      end

    rescue => e
     puts e
    end
  end


  attr_reader :card, :provider, :user

end
