TravelAPI::Application.routes.draw do
  root :to => 'api#index'
  match '/token' => 'get_token#index', :via => :GET
  match '/callback', :to => 'get_token#callback', :via => :GET
  match '/test', :to => 'temp#test', :via => :GET
  match '/multi', :to => 'temp#multi', :via => :GET
  match '/api', :to => 'api#compute', :via => [:POST,:GET]
end
