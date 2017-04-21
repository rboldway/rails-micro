# START:from
FROM heroku/jvm
# END:from

# START:jruby
RUN mkdir -p /usr/lib/jruby
ENV JRUBY_HOME /usr/lib/jruby
RUN curl -s -L  \
 https://s3.amazonaws.com/jruby.org/downloads/9.0.5.0/jruby-bin-9.0.5.0.tar.gz \
 --retry 3 | tar xz -C /usr/lib/jruby --strip-components=1
ENV PATH /usr/lib/jruby/bin:$PATH
# END:jruby

# START:gems
RUN jruby -S gem install bundler -v 1.11.2 --no-ri --no-rdoc
# END:gems

# START:bundle
COPY . /app/user/
RUN bundle install
# END:bundle

# START:env
ENV RACK_ENV development
ENV MAX_PUMA_THREADS 8
# END:env