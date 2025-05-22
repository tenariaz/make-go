# syntax=docker/dockerfile:1.4

ARG TARGETOS
ARG TARGETARCH

FROM --platform=$BUILDPLATFORM golang:1.21.6-alpine3.19 AS builder
ARG TARGETOS
ARG TARGETARCH

WORKDIR /app
COPY go.mod .
COPY main.go .

RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /out/app .

FROM scratch
COPY --from=builder /out/app /app
ENTRYPOINT ["/app"]
