# Use the official Alpine Linux base image
FROM alpine:3.20

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    ruby \
    ruby-dev \
    ruby-rake \
    ruby-bundler \
    sqlite-dev \
    sqlite \
    imagemagick \
    imagemagick-dev 

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy the Gemfile and Gemfile.lock (if it exists)
COPY Gemfile ./
COPY Gemfile.lock ./

# Install the Ruby gems using Bundler
RUN bundle install --jobs=$(nproc) --retry=3

# Copy in the code
COPY . .

# copy bootstrap libraries into ./public/assets/
ADD https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css ./public/assets/css/
ADD https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js ./public/assets/js/

# create the initial scheduler user
# set up the DB
RUN rake db:migrate
RUN rake db:add_sysop_user

# run the damn thing
CMD ["./run-app.sh"]


