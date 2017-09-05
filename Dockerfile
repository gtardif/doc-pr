FROM golang:1.8.1-alpine as hub_builder

RUN apk add --no-cache git
RUN go get github.com/github/hub

FROM alpine:3.5

RUN apk add --no-cache \
  curl \
  git \
  jq \
  tar \ 
  wget

ENV GITHUB_TOKEN ""
ENV USER_NAME ""
ENV USER_EMAIL ""
ENV CHANNEL ""
ENV BUILD_NUMBER ""
ENV VERSION ""
ENV BASE ""

COPY --from=hub_builder /go/bin/hub /usr/bin
COPY run.sh .
RUN chmod +x run.sh
CMD ["./run.sh"]
