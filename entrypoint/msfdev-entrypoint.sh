#!/bin/bash
set -e

# Get vars out of .env
export $(egrep -v '^#' .env | xargs)

create_msfdev_user(){
    adduser --disabled-password --gecos "" msfdev
    mkdir -p /etc/sudoers.d/
    touch /etc/sudoers.d/10_msfdev
    echo 'msfdev ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/10_msfdev
}

setup_git_repo(){
    pushd $HOME
    git clone $GIT_REPO
    cd metasploit-framework
    git remote add upstream git://github.com/rapid7/metasploit-framework.git
    git fetch upstream
    git checkout -b upstream-master --track upstream/master
    popd
}

install_rvm(){
    curl -sSL https://rvm.io/mpapis.asc | gpg --import -
    curl -L https://get.rvm.io | bash -s stable
}

install_and_configure_ruby(){
    source ~/.rvm/scripts/rvm
    cd ~/metasploit-framework
    rvm --install $(cat .ruby-version)
    echo 'source ~/.rvm/scripts/rvm' >> ~/.bashrc
    echo 'rvm use $(cat ~/metasploit-framework/.ruby-version)' >> ~/.bashrc
    bundle install --deployment
}

setup_git_config(){
    pushd $HOME/metasploit-framework
    $HOME/.rvm/rubies/ruby-$(cat ~/metasploit-framework/.ruby-version)/bin/ruby tools/dev/add_pr_fetch.rb
    ln -sf tools/dev/pre-commit-hook.rb .git/hooks/pre-commit
    ln -sf tools/dev/pre-commit-hook.rb .git/hooks/post-merge
    git config --global user.name $GIT_USERNAME
    git config --global user.email $GIT_EMAIL
    git config --global github.user $GIT_USER
    popd
}

install_and_configure_pgsql(){
    mkdir $HOME/.msf4
    sudo -kS update-rc.d postgresql enable &&
    sudo -S service postgresql start &&
    cat <<EOF> $HOME/pg-utf8.sql
update pg_database set datallowconn = TRUE where datname = 'template0';
\c template0
update pg_database set datistemplate = FALSE where datname = 'template1';
drop database template1;
create database template1 with template = template0 encoding = 'UTF8';
update pg_database set datistemplate = TRUE where datname = 'template1';
\c template1
update pg_database set datallowconn = FALSE where datname = 'template0';
\q
EOF
    sudo -u postgres psql -f $HOME/pg-utf8.sql &&
    sudo -u postgres createuser msfdev -dRS &&
    sudo -u postgres psql -c "ALTER USER msfdev with ENCRYPTED PASSWORD '$POSTGRES_PW';" &&
    sudo -u postgres createdb --owner msfdev msf_dev_db &&
    sudo -u postgres createdb --owner msfdev msf_test_db &&
    cat <<EOF> $HOME/.msf4/database.yml
# Development Database
development: &pgsql
  adapter: postgresql
  database: msf_dev_db
  username: msfdev
  password: $POSTGRES_PW
  host: localhost
  port: 5432
  pool: 5
  timeout: 5

# Production database -- same as dev
production: &production
  <<: *pgsql

# Test database -- not the same, since it gets dropped all the time
test:
  <<: *pgsql
  database: msf_test_db
EOF
}

create_msfdev_user
export -f setup_git_repo
su msfdev -c 'bash -c setup_git_repo'
export -f install_rvm
su msfdev -c 'bash -c install_rvm'
export -f install_and_configure_ruby
su msfdev -c 'bash -c install_and_configure_ruby'
export -f setup_git_config
su msfdev -c 'bash -c setup_git_config'
export -f install_and_configure_pgsql
su msfdev -c 'bash -c install_and_configure_pgsql'
