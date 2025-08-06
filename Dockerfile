# Multi-stage build for SwiftShare Backend
FROM rust:1.75-alpine as builder

# Install build dependencies
RUN apk add --no-cache \
    musl-dev \
    openssl-dev \
    pkgconfig \
    sqlite-dev

# Set working directory
WORKDIR /app

# Copy Cargo files
COPY backend/Cargo.toml backend/Cargo.lock ./

# Create dummy main.rs to build dependencies
RUN mkdir src && echo "fn main() {}" > src/main.rs

# Build dependencies
RUN cargo build --release

# Remove dummy main.rs and copy actual source
RUN rm -rf src
COPY backend/src ./src

# Build the application
RUN cargo build --release

# Runtime stage
FROM alpine:latest

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    sqlite \
    && rm -rf /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1001 -S swiftshare && \
    adduser -S swiftshare -u 1001

# Set working directory
WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /app/target/release/swiftshare-backend ./swiftshare-backend

# Create necessary directories
RUN mkdir -p /app/downloads /app/data && \
    chown -R swiftshare:swiftshare /app

# Switch to non-root user
USER swiftshare

# Expose ports
EXPOSE 8080 8081

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Run the application
CMD ["./swiftshare-backend"] 