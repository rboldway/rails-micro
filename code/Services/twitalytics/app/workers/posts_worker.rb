#---
# Excerpted from "Deploying with JRuby 9k",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jkdepj2 for more book information.
#---
class PostsWorker
  include Sidekiq::Worker

  def perform(post_id)
    post = Post.find(post_id)
    url = ENV["STOCK_SERVICE_URL"] || "localhost:8080"
    host = url.split(":")[0]
    port = url.split(":")[1]
    Net::HTTP.start(host, port) do |http|
      http.request_post("/stockify", post.body) do |resp|
        post.update({ html: resp.body })
      end
    end
    channel = $bunny.create_channel
    exchange = channel.fanout("twitalytics.posts")
    exchange.publish(post.html)
  end
end
