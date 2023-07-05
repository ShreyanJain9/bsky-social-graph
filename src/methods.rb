require "xrpc"

def xrpc_login(username, pw)
  XRPC::Client.new("https://bsky.social", nil).post.com_atproto_server_createSession(identifier: username, password: pw)["accessJwt"]
end

Bluesky = XRPC::Client.new("https://bsky.social", xrpc_login(ENV["BSKY_USERNAME"], ENV["BSKY_PASSWORD"]))

def resolve_handle(handle)
  Bluesky.get.com_atproto_identity_resolveHandle(handle: handle)["did"]
end

def get_follows(handle, cursor = nil)
  follows = Bluesky.get.app_bsky_graph_getFollows(actor: resolve_handle(handle), limit: 100, cursor: cursor)
  follows_array = follows["follows"].map { |follow| follow["handle"] } unless follows["follows"].nil?
  return ["Error: Nonexistent handle"] if follows_array.nil?
  follows["cursor"].nil? ? follows_array : follows_array + get_follows(handle, follows["cursor"])
end

def get_followers(handle, cursor = nil)
  followers = Bluesky.get.app_bsky_graph_getFollowers(actor: resolve_handle(handle), limit: 100, cursor: cursor)
  followers_array = followers["followers"].map { |follower| follower["handle"] } unless followers["followers"].nil?
  return ["Error: Nonexistent handle"] if followers_array.nil?
  followers["cursor"].nil? ? followers_array : followers_array + get_followers(handle, followers["cursor"])
end

def do_they_follow?(handle1, handle2)
  get_follows(handle1).include?(handle2)
end

def are_they_moots?(handle1, handle2)
  do_they_follow?(handle1, handle2) && do_they_follow?(handle2, handle1)
end

def mutuals(handle)
  get_followers(handle) & get_follows(handle)
end
