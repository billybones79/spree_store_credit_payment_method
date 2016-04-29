# NOTE: Remove for 3-1-stable

Deface::Override.new(
  virtual_path: 'spree/checkout/_payment',
  name: 'insert_store_credit_instructions',
  insert_top: '#store_credit_body',
  partial: 'spree/checkout/payment/storecredit',
  disabled: false
)
