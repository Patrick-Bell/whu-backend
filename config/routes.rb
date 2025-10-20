Rails.application.routes.draw do


  scope 'api' do
    resources :carts
    resources :managers
    resources :workers
    resources :games
    resources :fixtures

    post '/completed-game/:id', to: 'games#completed_game', as: 'completed_game'
    post '/mark-as-watch/:id', to: 'workers#mark_as_watch', as: 'mark_as_watch'
    post '/send-workers-email', to: 'workers#send_email', as: 'send_email'
    patch '/add-watching/:id', to: 'workers#add_watching', as: 'add_watching'
    patch '/remove-watching/:id', to: 'workers#remove_watching', as: 'remove_watching'

    patch '/update-password/:id', to: 'managers#update_password', as: 'update_password'
    patch '/update-access/:id', to: 'managers#update_access', as: 'update_access'

    post '/forgot-password', to: 'password#handle_email', as: 'handle_email'
    post '/verify-code', to: 'password#verify_code', as: 'verify_code'
    post '/create-password', to: 'password#create_password', as: 'create_password'

    #patch '/enable-notifications/:id', to: 'managers#enable_notifications', as: 'enable_notifications'
    #patch '/disable-notifications/:id', to: 'managers#disable_notifications', as: 'disable_notifications'
    patch '/toggle-theme/:id', to: 'managers#toggle_theme', as: 'toggle_theme'
    patch '/toggle-notification/:id', to: 'managers#toggle_notification', as: 'toggle_notification'

    post '/login', to: 'sessions#create', as: 'create'
    delete '/logout', to: 'sessions#destroy', as: 'destroy'
    get '/current-user', to: 'sessions#current_user'
    get '/get-current-user', to: 'application#get_current_user', as: 'get_current_user'
    
    get '/next-3-games', to: 'fixtures#get_next_3_games', as: 'get_next_3_games'
    get '/next-month-games', to: 'fixtures#find_fixtures_next_month', as: 'find_fixtures_next_month'
    get '/last-3-home-games', to: 'fixtures#last_3_home_games', as: 'last_3_home_games'
    get '/get-month-fixtures', to: 'fixtures#get_month_fixtures', as: 'get_month_fixtures'

    get '/get-current-month-games', to: 'games#get_current_month_games', as: 'get_current_month_games'
    get '/get-previous-month-games', to: 'games#get_previous_month_games', as: 'get_previous_month_games'

    get '/add-calendar/:id/calendar.ics', to: 'fixtures#add_calendar_event', as: 'add_calendar_event'

  end

end
