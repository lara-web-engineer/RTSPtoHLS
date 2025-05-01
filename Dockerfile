# Use the official Golang image as a base image
FROM golang:1.20-alpine as builder

# Set the working directory
WORKDIR /app

# Copy the go modules manifest and download the dependencies
COPY go.mod go.sum ./
RUN go mod tidy

# Copy the rest of the application code including config.json
COPY . .

# Build the Go binary
RUN go build -o app .

# Start a new image from a smaller Alpine-based image
FROM alpine:latest

# Install required dependencies (e.g., for serving static files, etc.)
RUN apk --no-cache add ca-certificates

# Set the working directory
WORKDIR /app

# Copy the built Go binary from the builder stage
COPY --from=builder /app/app /usr/local/bin/app

# Copy config.json to /app in the final container
COPY --from=builder /app/config.json ./config.json

# Copy any other required files (like templates or static assets)
COPY --from=builder /app/web ./web

# Expose the port on which the Go server will run
EXPOSE 8083

# Command to run the Go application
CMD ["/usr/local/bin/app"]
