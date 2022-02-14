FROM golang:1.16 as builder
WORKDIR /workspace

COPY go.mod go.mod
COPY go.sum go.sum

RUN go mod download

COPY cmd/ cmd/
COPY internal/ internal/
COPY vendor/ vendor/

ENV REMOTETAGS="remote exclude_graphdriver_btrfs btrfs_noversion exclude_graphdriver_devicemapper containers_image_openpgp"
RUN	mkdir -p ./bin
RUN	CGO_ENABLED=$CGO_ENABLED go build $BUILD_OPTIONS -tags "$REMOTETAGS" -o ./bin ./cmd/device-worker

FROM gcr.io/distroless/static:nonroot
ENV USER_UID=10001
WORKDIR /
COPY --from=builder /workspace/bin/device-worker /device-worker

USER ${USER_UID}

ENTRYPOINT ["/device-worker"]