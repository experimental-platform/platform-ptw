FROM dockerregistry.protorz.net/ubuntu:latest

# Install Ruby.
RUN \
  apt-get update && \
  apt-get install -y \
    openssh-client \
    curl \
    git \
  && \
  rm -rf /var/lib/apt/lists/*

RUN cd ~ \
  && git clone git://github.com/sstephenson/rbenv.git ~/.rbenv \
  && git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build \
  && git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash \
  && echo 'export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc \
  && echo 'eval "$(rbenv init -)"' >> ~/.bashrc \
  && . ~/.bashrc \
  && rbenv install 2.2.2 \
  && rbenv global 2.2.2 \
  && echo "gem: --no-ri --no-rdoc" > ~/.gemrc \
  && gem install bundler

# Copy Gem into Container
COPY publish_to_web-1.1.0.gem /tmp/
# Install gem
RUN gem install /tmp/publish_to_web-1.1.0.gem

ENV PROTONET_CONFIG /config
COPY start_publish_to_web.rb /bin/start_publish_to_web
RUN chmod 755 /bin/start_publish_to_web

CMD ["start_publish_to_web"]
