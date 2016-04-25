Deface::Override.new(
  virtual_path: 'spree/checkout/_summary',
  name: 'add_store_credit',
  insert_before: '[data-hook="order_total"]',
  partial: 'spree/checkout/store_credits_sidebar'
)
