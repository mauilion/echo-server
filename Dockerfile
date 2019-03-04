FROM golang:alpine as builder
RUN apk update && apk add alpine-sdk ca-certificates tzdata
RUN curl https://glide.sh/get | sh
RUN go get github.com/mauilion/echo-server ; exit 0
ENV pkg /go/src/github.com/mauilion/echo-server/
WORKDIR ${pkg}
RUN glide install
RUN find .
WORKDIR ${pkg}/cmd/echo-server
RUN CGO_ENABLED=0 GOOS=linux go build --ldflags="-s -w" -o /opt/echo-server .


FROM scratch
COPY --from=builder /opt/echo-server /bin/echo-server

ENV PORT 8080
ENV SSLPORT 8443

EXPOSE 8080 8443

ENV ADD_HEADERS='{"X-Real-Server": "echo-server"}'

WORKDIR /bin
ENTRYPOINT ["/bin/echo-server"]
