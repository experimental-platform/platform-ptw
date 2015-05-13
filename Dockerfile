FROM dockerregistry.protorz.net/ubuntu:latest

# Install Ruby.
RUN \
  apt-get update && \
  apt-get install -y \
    openssh-client \
    curl \
    ruby \
    ruby-dev \
    ruby-bundler \
  && \
  rm -rf /var/lib/apt/lists/*

# Copy Gem into Container
COPY publish_to_web-1.1.0.gem /tmp/
# Install gem
RUN gem install /tmp/publish_to_web-1.1.0.gem

ENV PROTONET_CONFIG /config
COPY start_publish_to_web.rb /bin/start_publish_to_web
RUN chmod 755 /bin/start_publish_to_web

CMD ["start_publish_to_web"]
