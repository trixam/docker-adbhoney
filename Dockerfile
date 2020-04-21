FROM alpine:latest

# Include dist/
ADD dist/ /root/dist/ 

# Install packages
RUN apk add --no-cache --update-cache \
        git \
        libcap \
        python3 \
        python3-dev && \
    # Install adbhoney from git
    git clone --depth=1 https://github.com/huuck/ADBHoney /opt/adbhoney && \
    cp /root/dist/adbhoney.cfg /opt/adbhoney && \
    sed -i 's/dst_/dest_/' /opt/adbhoney/adbhoney/core.py && \
    # Setup user, groups and configs
    addgroup -g 2000 adbhoney && \
    adduser -S -H -s /bin/ash -u 2000 -D -g 2000 adbhoney && \
    chown -R adbhoney:adbhoney /opt/adbhoney && \
    setcap cap_net_bind_service=+ep /usr/bin/python3.8 && \
    # Clean up
    apk del --purge \
        git \
        python3-dev && \
    rm -rf /root/* && \
    rm -rf /var/cache/apk/*

# Set workdir and start adbhoney
STOPSIGNAL SIGKILL
USER adbhoney:adbhoney
WORKDIR /opt/adbhoney
CMD /usr/bin/python3 run.py
