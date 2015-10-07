# Dockerfile for HackDepot

FROM 32bit/debian:jessie
MAINTAINER Artyom V. Poptsov -- poptsov.artyom@gmail.com

# Import the needed GPG keys.
RUN gpg --keyserver hkp://keys.gnupg.net \
    --recv-keys 9D6D8F6BC857C906 7638D0442B90D010

# Install required packages.
RUN apt-get update -qq && apt-get -qqy install \
    curl \
    git \
    imagemagick \
    libmagickcore-dev \
    libmagickwand-dev \
    mongodb \
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

ENV RAILS_ENV 'development'

# XXX: Overwrite MongoDB configuration to fix it.  Normally the right
# 'config/mongoid.yml' should be shipped along with HackDepot.
RUN rm $HACKDEPOT_DIR/config/mongoid.yml
RUN /bin/bash -l -c "cd $HACKDEPOT_DIR && rails g mongoid:config"

# Setup the database.
RUN /bin/bash -l -c "cd $HACKDEPOT_DIR && rake db:setup"

EXPOSE 3000

# Dockerfile ends here.
