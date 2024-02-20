# [START cloudrun_go_qr_code_generator_dockerfile]
# [START run_go_qr_code_generator_dockerfile]

# Use the offical golang image to create a binary.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:1.21.0 as builder

# Create and change to the app directory.
WORKDIR /app

# Retrieve application dependencies.
# This allows the container build to reuse cached dependencies.
# Expecting to copy go.mod and if present go.sum.
COPY go.* ./
RUN go mod download

# Copy local code to the container image.
COPY . ./

# Build the binary.
RUN CGO_ENABLED=0 GOOS=linux go build -v -o server

# Use the official Debian slim image for a lean production container.
# https://hub.docker.com/_/debian
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM gcr.io/distroless/base-debian11
# RUN set -x && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
#     ca-certificates && \
#     rm -rf /var/lib/apt/lists/*

WORKDIR /

# Copy the binary to the production image from the builder stage.
COPY --from=builder /app/server /app/server

ENV PORT 8080
USER nonroot:nonroot

# Run the web service on container startup.
CMD ["/app/server"]

# [END run_go_qr_code_generator_dockerfile]
# [END cloudrun_go_qr_code_generator_dockerfile]
