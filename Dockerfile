# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.2.0
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips pkg-config libpq-dev

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Set execute permissions for all scripts in bin directory
RUN chmod +x bin/*

# Create public/assets directory and set permissions
RUN mkdir -p public/assets && chmod -R 755 public

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Final stage for app image
FROM base AS final

# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libsqlite3-0 libvips libpq5 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Set execute permissions for scripts
RUN chmod +x bin/*

# Create public/assets directory and set permissions
RUN mkdir -p public/assets && chmod -R 755 public

# Create a non-root user
RUN useradd --create-home --shell /bin/bash rails

# Change ownership of the app directory to the rails user
RUN chown -R rails:rails /rails

# Switch to the rails user
USER rails

# Expose port 8080
EXPOSE 8080

# Start the application
CMD ["./bin/docker-entrypoint", "./bin/rails", "server", "-b", "0.0.0.0", "-p", "8080"]
