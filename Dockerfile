FROM composer:1.5.2

RUN apk --no-cache add git wget

# add a non-root user and give them ownership
RUN adduser -D -u 9000 app && \
    # repo
    mkdir /repo && \
    chown -R app:app /repo && \
    # actor code
    mkdir /usr/src/actor && \
    chown -R app:app /usr/src/actor

# add the pullrequest utility to easily create pull requests on different git hosts
WORKDIR /usr/src/actor
ENV PULLREQUEST_VERSION=0.3.0
RUN wget https://github.com/dependencies-io/pullrequest/releases/download/${PULLREQUEST_VERSION}/pullrequest_${PULLREQUEST_VERSION}_linux_amd64.tar.gz && \
    mkdir pullrequest && \
    tar -zxvf pullrequest_${PULLREQUEST_VERSION}_linux_amd64.tar.gz -C pullrequest && \
    ln -s /usr/src/actor/pullrequest/pullrequest /usr/local/bin/pullrequest

# run everything from here on as non-root
USER app

RUN git config --global user.email "bot@dependencies.io"
RUN git config --global user.name "Dependencies.io Bot"

ADD entrypoint.php /usr/src/actor

WORKDIR /repo

ENTRYPOINT ["php", "/usr/src/actor/entrypoint.php"]
