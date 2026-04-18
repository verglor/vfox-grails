FROM eclipse-temurin:17-jre-noble

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root

RUN apt-get update && apt-get install -y curl git lua5.4 luarocks zip && \
    ln -s /usr/bin/lua5.4 /usr/local/bin/lua && \
    rm -rf /var/lib/apt/lists/* && \
    luarocks install busted

# Install bats 1.13.0
RUN git clone --depth=1 --branch v1.13.0 https://github.com/bats-core/bats-core.git /tmp/bats && \
    /tmp/bats/install.sh /usr/local && \
    rm -rf /tmp/bats

# Install vfox via apt
RUN echo "deb [trusted=yes] https://apt.fury.io/versionfox/ /" | tee /etc/apt/sources.list.d/versionfox.list && \
    apt-get update && apt-get install -y vfox && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /plugin

# Copy plugin source (excluding tests) first so grails downloads are cached
# independently of test file changes
COPY hooks/ hooks/
COPY lib/ lib/
COPY metadata.lua Injection.lua LICENSE ./

# Register plugin via vfox add (populates legacy filename mappings) and
# pre-install grails versions required by integration tests
RUN zip -qr /tmp/grails-plugin.zip . && \
    bash -c 'eval "$(vfox activate bash)" && \
    vfox add --source /tmp/grails-plugin.zip grails && \
    vfox install grails@3.3.13 && \
    vfox install grails@6.1.2 && \
    vfox install grails@7.0.7' && \
    rm /tmp/grails-plugin.zip

# Replace installed plugin with symlink to /plugin so integration tests
# always run against the current plugin source (not the zip snapshot)
RUN VFOX_HOME=$(ls -d /root/.vfox /root/.version-fox 2>/dev/null | head -1) && \
    rm -rf "$VFOX_HOME/plugin/grails" && \
    ln -s /plugin "$VFOX_HOME/plugin/grails"

# Copy remaining files including tests (changes here do not invalidate grails downloads)
COPY . .

CMD ["bash", "test/run.sh"]
