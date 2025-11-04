FROM golang:1.25.3-alpine3.22 AS base
WORKDIR /go/app/base

RUN apk add --no-cache build-base

COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .

FROM golang:1.25.3-alpine3.22 AS builder
WORKDIR /go/app/builder

COPY --from=base /go/app/base /go/app/builder

RUN CGO_ENABLED=0 GOOS=linux go build -o main -ldflags="-s -w"

FROM gcr.io/distroless/static-debian11 AS production
WORKDIR /go/app/bin

COPY --from=builder /go/app/builder/main .

EXPOSE 8081

ENV GIN_MODE=release
CMD ["/go/app/bin/main"]
