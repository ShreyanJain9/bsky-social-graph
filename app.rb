require "sinatra"
require_relative "src/methods"

get "/" do
  erb :home
end

get "/are_they_moots" do
  { :moots => are_they_moots?(params["handle1"], params["handle2"]) }.to_json
end

get "/follows" do
  @handles = get_follows(params["handle"])
  @title = "Follows"
  erb :list
end

get "/followers" do
  @handles = get_followers(params["handle"])
  @title = "Followers"
  erb :list
end

get "/does_follow" do
  { :follows? => do_they_follow?(params["handle1"], params["handle2"]) }.to_json
end

get "/mutuals" do
  @handles = mutuals(params["handle"])
  @title = "Mutuals"
  erb :list
end
