FROM ubuntu:14.04
MAINTAINER Fabian M. Borschel <fabian.borschel@commercetools.de>

# Parameters
ENV RUBY_VERSION 1.9.3-p551

RUN apt-get update
RUN apt-get install -y git curl gawk gcc make zlib1g-dev libgpg-error-dev libassuan-dev libgpgme11-dev

# Setup rbenv and install ruby
RUN git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.rbenvrc
RUN echo 'eval "$(rbenv init -)"' >> ~/.rbenvrc
RUN git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN . ~/.rbenvrc && rbenv install $RUBY_VERSION && rbenv global $RUBY_VERSION

# Setup Raziel
RUN . ~/.rbenvrc && gem install gpgme -- --use-system-libraries
RUN . ~/.rbenvrc && gem install cucumber
RUN . ~/.rbenvrc && gem install aruba
RUN . ~/.rbenvrc && gem install ptools
RUN . ~/.rbenvrc && gem install highline
RUN git clone https://github.com/onibox/raziel.git ~/raziel

# Now run something like:
# docker run -t -i -v $HOME/.gnupg:/root/.gnupg/ -v $HOME/Projects/ops-credentials:/root/ops-credentials/ raziel-docker /bin/bash
