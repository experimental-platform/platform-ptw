FROM experimentalplatform/ubuntu:latest

ENV RUBY_MAJOR 2.0
ENV RUBY_VERSION 2.0.0-p645
ENV RUBY_DOWNLOAD_SHA256 5e9f8effffe97cba5ef0015feec6e1e5f3bacf6ace78cd1cdf72708cd71cf4ab

# some of ruby's build scripts are written in ruby
# we purge this later to make sure our final image uses what we just built
RUN apt-get update \
  && apt-get install -y openssh-client curl \
  && apt-get install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev bison ruby \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /usr/src/ruby \
  && curl -fSL -o ruby.tar.gz "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" \
  && echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.gz" | sha256sum -c - \
  && tar -xzf ruby.tar.gz -C /usr/src/ruby --strip-components=1 \
  && rm ruby.tar.gz \
  && cd /usr/src/ruby \
  && autoconf \
  && ./configure --disable-install-doc \
  && make -j"$(nproc)" \
  && make install \
  && apt-get purge -y --auto-remove bison libgdbm-dev ruby \
  && rm -r /usr/src/ruby

# skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> "$HOME/.gemrc"

# install things globally, for great justice
ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH
RUN gem install bundler \
  && bundle config --global path "$GEM_HOME" \
  && bundle config --global bin "$GEM_HOME/bin"

# don't create ".bundle" in all our apps
ENV BUNDLE_APP_CONFIG $GEM_HOME

# Copy Gem into Container
COPY publish_to_web-1.1.0.gem /tmp/
# Install gem
RUN gem install /tmp/publish_to_web-1.1.0.gem

ENV PROTONET_CONFIG /config
COPY start_publish_to_web.rb /bin/start_publish_to_web
RUN chmod 755 /bin/start_publish_to_web

CMD ["start_publish_to_web"]
