FROM golang:1.23-alpine AS src
RUN apk add --no-cache make git

WORKDIR /
RUN git config --global advice.detachedHead false
RUN git clone --branch v0.2.11 https://gitea.com/gitea/act_runner.git
RUN mkdir -p /opt/src
RUN mv /act_runner /opt/src/

# Do not remove `git` here, it is required for getting runner version when executing `make build`

# ARG GOPROXY
# ENV GOPROXY=${GOPROXY:-}

# COPY . /opt/src/act_runner
WORKDIR /opt/src/act_runner

RUN make clean && make build







FROM docker.io/gautada/alpine:latest as act_runner

RUN apk add --no-cache bash kubectl

COPY --from=src /opt/src/act_runner/act_runner /usr/bin/act_runner
COPY --from=src /opt/src/act_runner/scripts/run.sh /usr/bin/run.sh
RUN chmod +x /usr/bin/run.sh
COPY entrypoint /etc/container/entrypoint
COPY container-version /usr/bin/container-version
# COPY container-entrypoint /usr/bin/container-entrypoint
