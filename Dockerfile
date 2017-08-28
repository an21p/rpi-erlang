FROM armv7/armhf-debian:jessie

ENV OTP_VERSION="20.0"

# We'll install the build dependencies for erlang-odbc along with the erlang
# build process:
RUN set -xe \
        && OTP_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${OTP_VERSION}.tar.gz" \
        && OTP_DOWNLOAD_SHA256="548815fe08f5b661d38334ffa480e9e0614db5c505da7cb0dc260e729697f2ab" \
        && runtimeDeps='libodbc1' \
        && buildDeps='\
                      autoconf \
                      build-essential \
                      fop \
                      git \
                      libncurses5-dev \
                      libssl-dev \
                      unixodbc-dev \
                      unixodbc-dev \
                      xsltproc \
                     ' \
        && apt-get update \
        && apt-get install -y --no-install-recommends curl openssl ca-certificates \
        && apt-get install -y --no-install-recommends $runtimeDeps \
        && apt-get install -y --no-install-recommends $buildDeps \
        && curl -fSL -o otp-src.tar.gz "$OTP_DOWNLOAD_URL" \
        && echo "$OTP_DOWNLOAD_SHA256 otp-src.tar.gz" | sha256sum -c - \
        && mkdir -p /usr/src/otp-src \
        && tar -xzf otp-src.tar.gz -C /usr/src/otp-src --strip-components=1 \
        && rm otp-src.tar.gz \
        && cd /usr/src/otp-src \
        && ./otp_build autoconf \
        && ./configure \
        && make -j$(nproc) \
        && make install \
        && find /usr/local -name examples | xargs rm -rf \
        && apt-get purge -y --auto-remove $buildDeps \
        && rm -rf /usr/src/otp-src /var/lib/apt/lists/*

CMD ["erl"]
