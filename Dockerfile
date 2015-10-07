# Dockerfile for HackDepot

FROM 32bit/debian:jessie
MAINTAINER poptsov.artyom@gmail.com

# Import the needed GPG keys.
RUN gpg --keyserver hkp://keys.gnupg.net \
    --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 \
    	9D6D8F6BC857C906 7638D0442B90D010

# Install required packages.
RUN apt-get update -qq
RUN apt-get -qqy install mongodb git curl imagemagick libmagickcore-dev \
    libmagickwand-dev

# Clone HackDepot sources.
ENV HACKDEPOT_DIR /srv/hackdepot
RUN [ -d /srv/ ] || mkdir /srv
RUN git clone https://github.com/cadrspace/hackdepot.git $HACKDEPOT_DIR

# Install RVM.
RUN \curl -sSL https://get.rvm.io | bash -s stable --ruby

ENV RVM_CONF /usr/local/rvm/scripts/rvm

RUN ["/bin/bash", "-c", ". $RVM_CONF && gem install bundler"]
RUN apt-get -qqy install ruby-execjs
RUN ["/bin/bash", "-c", ". $RVM_CONF && cd $HACKDEPOT_DIR && bundle install"]

ENV RAILS_ENV 'development'

# XXX: Overwrite MongoDB configuration to fix it.  Normally the right
# 'config/mongoid.yml' should be shipped along with HackDepot.
RUN rm $HACKDEPOT_DIR/config/mongoid.yml
RUN ["/bin/bash", "-c", ". $RVM_CONF && cd $HACKDEPOT_DIR && rails g mongoid:config"]

# Setup the database.
RUN ["/bin/bash", "-c", ". $RVM_CONF && cd $HACKDEPOT_DIR && rake db:setup"]

# Dockerfile ends here.
