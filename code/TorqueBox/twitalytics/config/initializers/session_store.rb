#---
# Excerpted from "Deploying with JRuby 9k",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jkdepj2 for more book information.
#---
# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: '_twitalytics_session'
