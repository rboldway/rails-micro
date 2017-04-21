#---
# Excerpted from "Deploying with JRuby 9k",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jkdepj2 for more book information.
#---
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'
threads     (ENV["MIN_PUMA_THREADS"] || 0), (ENV["MAX_PUMA_THREADS"] || 16)
preload_app!
