#!/bin/bash

case $1 in
  console)
    echo "Starting IRB Console"
    bundle exec irb -I./ -rconfig/environment
    ;;
  start)
    echo "Starting Development Server"
    source ./env
    bundle exec foreman start
    ;;
esac
