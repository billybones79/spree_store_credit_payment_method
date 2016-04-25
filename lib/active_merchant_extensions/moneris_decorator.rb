ActiveMerchant::Billing::MonerisGateway.class_eval do

  def gc_inquiry(credit_card)
    card_number = credit_card.number
    post = {}
    post[:language_code]   = '3'
    post[:pan]   = card_number
    post[:cvc_prompt]  = 0
    post[:expdate] = expdate(credit_card)
    post[:cvd_value] = credit_card.verification_value
    action = 'ernex_gift_card_inquiry'
    commit(action, post)
  end

  def gc_activate(money, credit_card, options = {})
    requires!(options, :order_id)
    post = {}
    post[:initial_amount]  = amount(money)
    post[:order_id]   = options[:order_id]
    post[:language_code]  = '3'
    post[:pan]   = credit_card.number
    post[:expdate] = expdate(credit_card)
    post[:cvd_value] = credit_card.verification_value
    action = 'ernex_gift_activation'
    commit(action, post)
  end

  def gc_purchase(money, credit_card, options)
    requires!(options, :order_id)
    post = {}
    post[:total_amount]  = amount(money)
    post[:order_id]   = options[:order_id]
    post[:language_code]   = '3'
    post[:pan]   = credit_card.number
    post[:expdate] = expdate(credit_card)
    post[:cvd_value] = credit_card.verification_value
    action = 'ernex_gift_purchase'
    commit(action, post)
  end

  def gc_void(authorization, options = {})
    requires!(options, :order_id)
    post = {}
    post[:order_id]   = options[:order_id]
    post[:cvd_value] = '123'
    post[:txn_number] = authorization
    action = 'ernex_gift_void'
    commit(action, post)
  end

  def gc_refund(authorization, options = {})
    requires!(options, :order_id)
    post = {}
    post[:order_id]   = options[:order_id]
    post[:cvd_value] = '123'
    post[:txn_number] = authorization
    action = 'ernex_gift_refund'
    commit(action, post)
  end

  def actions
    {
        "purchase"                        => [:order_id, :cust_id, :amount, :pan, :expdate, :crypt_type, :avs_info, :cvd_info, :track2, :pos_code],
        "preauth"                         => [:order_id, :cust_id, :amount, :pan, :expdate, :crypt_type, :avs_info, :cvd_info, :track2, :pos_code],
        "ernex_gift_purchase"             => [:order_id, :cust_id, :total_amount, :pan, :expdate, :language_code, :cvd_value, :track2],
        "ernex_gift_activation"           => [:order_id, :initial_amount, :pan, :language_code, :cvd_value, :track2],
        "ernex_gift_card_inquiry"         => [:language_code, :cvc_prompt, :pan, :expdate, :cvd_value],
        "ernex_gift_void"                 => [:order_id, :cvd_value, :txn_number],
        "ernex_gift_refund"               => [:order_id, :cvd_value, :txn_number],
        "command"                         => [:order_id],
        "refund"                          => [:order_id, :amount, :txn_number, :crypt_type],
        "indrefund"                       => [:order_id, :cust_id, :amount, :pan, :expdate, :crypt_type],
        "completion"                      => [:order_id, :comp_amount, :txn_number, :crypt_type],
        "purchasecorrection"              => [:order_id, :txn_number, :crypt_type],
        "cavvpurcha"                      => [:order_id, :cust_id, :amount, :pan, :expdate, :cav],
        "cavvpreaut"                      => [:order_id, :cust_id, :amount, :pan, :expdate, :cavv],
        "transact"           => [:order_id, :cust_id, :amount, :pan, :expdate, :crypt_type],
        "Batchcloseall"      => [],
        "opentotals"         => [:ecr_number],
        "batchclose"         => [:ecr_number],
        "res_add_cc"         => [:pan, :expdate, :crypt_type],
        "res_delete"         => [:data_key],
        "res_update_cc"      => [:data_key, :pan, :expdate, :crypt_type],
        "res_purchase_cc"    => [:data_key, :order_id, :cust_id, :amount, :crypt_type],
        "res_preauth_cc"     => [:data_key, :order_id, :cust_id, :amount, :crypt_type]
    }
  end

end
