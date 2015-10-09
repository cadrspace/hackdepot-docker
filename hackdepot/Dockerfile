# Dockerfile for HackDepot

FROM 32bit/debian:jessie
MAINTAINER Artyom V. Poptsov <poptsov.artyom@gmail.com>

# Import the needed GPG keys.
RUN gpg --keyserver hkp://keys.gnupg.net \
    --recv-keys 9D6D8F6BC857C906 7638D0442B90D010

# Install required packages (including those that are normally pulled
# in as dependencies by the RVM installer.)
RUN apt-get update -qq && apt-get -qqy install \
    autoconf \
    automake \
    bison \
    bzip2 \
    curl \
    g++ \
    gawk \
    git \
    imagemagick \
    libffi-dev \
    libgdbm-dev \
    libmagickcore-dev \
    libmagickwand-dev \
    libncurses5-dev \
    libreadline6-dev \
    libsqlite3-dev \
    libssl-dev \
    libyaml-dev \
    make \
    sqlite3 \
    sudo

RUN useradd -ms /bin/bash hackdepot
RUN echo 'hackdepot ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Clone HackDepot sources.
ENV HACKDEPOT_DIR /srv/hackdepot
RUN [ -d /srv/ ] || mkdir /srv
RUN git clone https://github.com/cadrspace/hackdepot.git $HACKDEPOT_DIR

RUN chown -R hackdepot: $HACKDEPOT_DIR
USER hackdepot

# Install RVM.
RUN \curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN \curl -sSL https://get.rvm.io | bash -s stable --ruby

RUN /bin/bash -l -c "source ~/.rvm/scripts/rvm"
RUN /bin/bash -l -c "echo 'gem: --no-ri --no-rdoc' > ~/.gemrc"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"
RUN sudo apt-get -qqy install ruby-execjs
RUN /bin/bash -l -c "cd $HACKDEPOT_DIR && bundle install"
RUN /bin/bash -l -c "gem install mongo mongoid bson_ext --no-ri --no-rdoc"

ENV RAILS_ENV 'development'

# XXX: Overwrite MongoDB configuration to fix it.  Normally the right
# 'config/mongoid.yml' should be shipped along with HackDepot.
# COPY config/database.yml $HACKDEPOT_DIR/config/
COPY config/* $HACKDEPOT_DIR/config/
COPY config/environments/* $HACKDEPOT_DIR/config/environments/
COPY config/initializers/* $HACKDEPOT_DIR/config/initializers/

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3000
CMD ["hackdepot"]

# Dockerfile ends here.
