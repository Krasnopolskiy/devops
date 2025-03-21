FROM jenkins/ssh-agent:alpine-jdk21

RUN apk add --no-cache --update docker

RUN addgroup jenkins docker

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
