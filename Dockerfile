FROM nginx:1.20-alpine as base
RUN apk add --no-cache curl
WORKDIR /test
COPY . .
#########################
FROM base as test
#layer test tools and assets on top as optional test stage
RUN apk add --no-cache apache2-utils
#########################
FROM base as final

FROM golang:alpine as build
COPY httpenv.go /go
RUN go build httpenv.go

FROM alpine as testiamge
RUN apk add --no-cache curl
COPY --from=build /go/httpenv /httpenv

FROM alpine
RUN addgroup -g 1000 httpenv \
    && adduser -u 1000 -G httpenv -D httpenv
COPY --from=build --chown=httpenv:httpenv /go/httpenv /httpenv
EXPOSE 8888
# we're not changing user in this example, but you could:
# USER httpenv
CMD ["/httpenv"]