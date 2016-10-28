class AddPositionToSpreeStoreCreditCategory < ActiveRecord::Migration
  def change
    add_column :spree_store_credit_categories, :position, :integer
  end
end
