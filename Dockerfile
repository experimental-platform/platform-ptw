FROM ruby:2.3.0

COPY publish_to_web-2.0.0.gem /tmp/
RUN gem install /tmp/publish_to_web-2.0.0.gem --no-rdoc --no-ri

COPY start_publish_to_web /bin/start_publish_to_web
RUN chmod 755 /bin/start_publish_to_web

CMD ["/bin/start_publish_to_web"]
