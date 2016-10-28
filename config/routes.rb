Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :store_credit_categories
    resources :users, only: [] do
      resources :store_credits

      resources :gift_cards, only: [] do
        collection do
          get :lookup
          post :redeem
        end
      end

      collection do
        resources :gift_cards, only: [:index, :show]
      end
    end
    resources :orders, only: [] do
      resources :gift_cards, only: [:edit, :update] do
        member do
          put :send_email
          put :deactivate
        end
      end
    end
  end

  namespace :api, defaults: { format: 'json' } do
    resources :store_credit_events, only: [] do
      collection do
        get :mine
      end
    end

    resources :gift_cards, only: [] do
      collection do
        post :redeem
      end
    end
  end

  post '/checkout/redeem', to: 'checkout#redeem'
end
