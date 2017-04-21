#---
# Excerpted from "Deploying with JRuby 9k",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jkdepj2 for more book information.
#---

class DeleteOldStatuses

  def initialize(options = {})
    #@max_age = options["max_age"]
    #@max_age ||= 30
    puts "init job!"
  end

  def run
    #ids = Status.where("created_at < ?", @max_age.days.ago)

    puts "doing..."
  end

end
