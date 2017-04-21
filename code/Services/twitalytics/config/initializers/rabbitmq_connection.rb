#---
# Excerpted from "Deploying with JRuby 9k",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jkdepj2 for more book information.
#---
Rails.application.config.after_initialize do
  $bunny = MarchHare.connect(
    :heartbeat => 5,
    :uri => ENV["RABBITMQ_URL"] ||
            ENV["CLOUDAMQP_URL"] ||
            "amqp://192.168.99.100:5672")

  channel = $bunny.create_channel
  exchange = channel.fanout("twitalytics.posts")
  queue = channel.queue("").bind(exchange)
  $streams = Concurrent::Array.new
  consumer = queue.subscribe do |metadata, payload|
    $streams.reject! do |stream|
      begin
        stream.write("data: #{payload}\n\n")
        false
      rescue IOError => e
        stream.close
        true
      end
    end
  end

  # task = Concurrent::TimerTask.new do
  #   $streams.reject! do |stream|
  #     begin
  #       stream.write("\n")
  #       false
  #     rescue IOError => e
  #       stream.close
  #       true
  #     end
  #   end
  # end
  # task.execute

end

at_exit do
  $bunny.close
end

Signal.trap("INT") do
  $streams.each(&:close)
  raise Interrupt.new
end
