
# GitHub:       https://github.com/gohugoio
# Twitter:      https://twitter.com/gohugoio
# Website:      https://gohugo.io/

FROM golang:1.11-stretch AS build


WORKDIR /go/src/github.com/gohugoio/hugo
RUN apt-get update && apt-get -y install \
    git patch gcc g++ binutils patch
RUN git clone https://github.com/gohugoio/hugo.git /go/src/github.com/gohugoio/hugo
ENV GO111MODULE=on
RUN go get -d .
COPY ./presslabs.patch /root/
RUN patch -u /go/pkg/mod/github.com/russross/blackfriday@v1.5.3-0.20190124082335-a477dd164691/html.go -i /root/presslabs.patch

ARG CGO=0
ENV CGO_ENABLED=${CGO}
ENV GOOS=linux

# default non-existent build tag so -tags always has an arg
ARG BUILD_TAGS="99notag"
RUN go install -ldflags '-w -extldflags "-static"' -tags ${BUILD_TAGS}

# ---

FROM alpine:3.9
RUN apk add --no-cache ca-certificates git
COPY --from=build /go/bin/hugo /hugo
ARG  WORKDIR="/site"
WORKDIR ${WORKDIR}
VOLUME  ${WORKDIR}
EXPOSE  1313
ENTRYPOINT [ "/hugo" ]

 # CMD [ "--ignoreCache" ]
