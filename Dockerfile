FROM ruby:2.3.3

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 && \
    chmod +x /usr/local/bin/dumb-init

RUN gem install publish_to_web --version 2.5.0 --no-rdoc --no-ri

COPY start_publish_to_web /bin/start_publish_to_web
RUN chmod 755 /bin/start_publish_to_web

CMD ["dumb-init", "/bin/start_publish_to_web"]
