ArrivaContent::Application.routes.draw do
  root :to => 'cinema#show_seances'
  
  get 'show_seances' => 'cinema#show_seances'
  post 'show_seances' => 'cinema#show_seances'
  
  get 'cinema/new' => 'cinema#new'
  post 'cinema/create' => 'cinema#create'
  
  get 'cinema/new_hall' => 'cinema#new_hall', as: 'new_hall'
  post 'cinema/create_hall' => 'cinema#create_hall', as: 'create_hall'
  
  get 'parse_seances' => 'cinema#parse_seances'
  
  get 'send_to_arriva' => 'cinema#send_to_arriva'
  get 'film_name' => 'cinema#film_name'
  post 'change_film_name' => 'cinema#change_film_name'
end
