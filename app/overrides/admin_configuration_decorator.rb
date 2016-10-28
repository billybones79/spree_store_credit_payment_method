Deface::Override.new(:virtual_path => "spree/admin/shared/sub_menu/_configuration",
                     :name => "add_store_credit_category_to_admin_configurations_sidebar_menu",
                     :insert_bottom => "[data-hook='admin_configurations_sidebar_menu']",
                     :partial => "spree/admin/shared/configurations_menu_store_credit_categories",
                     :disabled => false)
