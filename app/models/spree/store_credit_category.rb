# NOTE: Remove for 3-1-stable

module Spree
  class StoreCreditCategory < Spree::Base
    acts_as_list

    validates_presence_of :name

    GIFT_CARD_CATEGORY_NAME = 'Gift Card'
    DEFAULT_NON_EXPIRING_TYPES = [GIFT_CARD_CATEGORY_NAME]
    self.whitelisted_ransackable_attributes = ['name']

    validates :name, uniqueness: {case_sensitive: true}

    default_scope { order(position: :asc) }

    def non_expiring?
      non_expiring_category_types.include? name
    end

    def non_expiring_category_types
      DEFAULT_NON_EXPIRING_TYPES | Spree::Config[:non_expiring_credit_types]
    end

    class << self
      def default_reimbursement_category(options = {})
        Spree::StoreCreditCategory.first
      end
    end
  end
end
