class Spree::Gateway::MonerisGiftCard < Spree::Gateway

  def provider_class
    ActiveMerchant::Billing::MonerisGateway
  end

  preference :login, :string
  preference :password, :password

  def payment_profiles_supported?
    false
  end

  def payment_source_class
    Spree::CreditCard
  end

  def balance(source)
    provider.gc_inquiry(source)
  end

  def transfer(money, source, options = {})
    balance = provider.gc_inquiry(source)
    provider.gc_purchase(balance, source, options )
  end
end