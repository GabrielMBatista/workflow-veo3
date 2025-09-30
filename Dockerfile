FROM n8nio/n8n:latest

USER root

# Install dependencies
RUN apk add --no-cache \
    ffmpeg \
    python3 \
    py3-pip \
    bash \
    curl \
    imagemagick

# Create necessary directories
RUN mkdir -p /tmp/videos /files && \
    chown -R node:node /tmp/videos /files

# Add custom scripts (opcional)
# COPY scripts/ /scripts/
# RUN chmod +x /scripts/*.sh

USER node

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:5678/healthz || exit 1

CMD ["n8n"]