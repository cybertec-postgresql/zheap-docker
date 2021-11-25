FROM debian

ENV REPO https://github.com/cybertec-postgresql/postgres.git
ENV BRANCH zheap_undo_record_set

ENV LANG en_US.utf8

ENV PG_MAJOR 10
ENV PG_VERSION 10.1
ENV PGDATA /u02/pgdata
ENV PGDATABASE "zheap"
ENV PGUSERNAME "zheap"
ENV PGPASSWOD "zheap"

ENV TRIPLET "x86_64-pc-linux-gnu"

RUN set -ex \
        \
        && apt-get update && apt-get install -y \
           ca-certificates \
           curl \
           procps \
           sysstat \
           libldap2-dev \
           libpython-dev \
           libreadline-dev \
           libssl-dev \
           bison \
           flex \
           libghc-zlib-dev \
           libcrypto++-dev \
           libxml2-dev \
           libxslt1-dev \
           bzip2 \
           make \
	   git \
	   gcc \
	   build-essential \
	   autoconf \
           unzip \
           python \
           locales \
        \
        && rm -rf /var/lib/apt/lists/* \
        && localedef -i en_US -c -f UTF-8 en_US.UTF-8 \
        && mkdir /u01/ \
        \
        && groupadd -r postgres --gid=999 \
        && useradd -m -r -g postgres --uid=999 postgres \
        && chown postgres:postgres /u01/ \
        && mkdir -p "$PGDATA" \
        && chown -R postgres:postgres "$PGDATA" \
        && chmod 700 "$PGDATA" \
        \
        && mkdir -p /home/postgres/src \
        && chown -R postgres:postgres /home/postgres \
        && su postgres -c "git clone \
                $REPO \
		/home/postgres/src" \
        && cd /home/postgres/src \
	&& git checkout -b $BRANCH \
        && su postgres -c "./configure \
                --enable-integer-datetimes \
                --enable-thread-safety \
                --with-pgport=5432 \
                --prefix=/u01/app/postgres/product/$PG_VERSION \\
                --with-ldap \
                --with-python \
                --with-openssl \
                --with-libxml \
                --with-libxslt \
		--build $TRIPLET \
		--host $TRIPLET \
		--target $TRIPLET" \
        && su postgres -c "make -j 4 all" \
        && su postgres -c "make install" \
        && su postgres -c "make -C contrib install" \
        && rm -rf /home/postgres/src \
        \
        && apt-get update && apt-get purge --auto-remove -y \
           libldap2-dev \
           libpython-dev \
           libreadline-dev \
           libssl-dev \
           libghc-zlib-dev \
           libcrypto++-dev \
           libxml2-dev \
           libxslt1-dev \
           bzip2 \
           gcc \
           make \
           unzip \
        && apt-get install -y libxml2 \
        && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

STOPSIGNAL SIGINT
USER postgres
EXPOSE 5432
CMD ["postgres"]

