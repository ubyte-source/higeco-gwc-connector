FROM amd64/alpine:3.15

ENV STARTUP_COMMAND_RUN_FASTCGIWRAP "fcgiwrap -c 5 -f -s unix:/home/www/fcgiwrap.socket"
ENV STARTUP_COMMAND_RUN_NGINX "nginx"

RUN apk update && \
    apk add --no-cache nginx fcgiwrap bash jq curl openssl && \
    rm -rf /var/cache/apk/*

COPY ./source /app

COPY wrapper.sh /
COPY nginx.conf /etc/nginx/nginx.conf

RUN adduser -D -g www www && \
    chown -R www:www /var/lib/nginx /var/log/nginx /app && \
    chmod +x -R /app && \
    chmod +x wrapper.sh

RUN rm -Rf /etc/nginx/sites-enabled && \
    rm -Rf /etc/nginx/sites-available

USER www

ENTRYPOINT /wrapper.sh