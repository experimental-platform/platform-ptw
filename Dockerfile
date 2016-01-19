FROM ruby:2.3.0

RUN gem install publish_to_web --no-rdoc --no-ri

COPY start_publish_to_web /bin/start_publish_to_web
RUN chmod 755 /bin/start_publish_to_web

CMD ["/bin/start_publish_to_web"]
