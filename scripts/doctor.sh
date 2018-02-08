#!/usr/bin/env bash
#
# Check Bay project requirements.
#

URL=http://governor.docker.amazee.io/
TITLE="Governor of Victoria"

################################################################################
#################### DO NOT CHANGE ANYTHING BELOW THIS LINE ####################
################################################################################

#
# Main entry point.
#
main() {
  # Check project requirements.
  status "Checking project requirements"

  [ $(command_exists docker) == "1" ] && error "Please install Docker." && exit 1
  [ $(command_exists docker-compose) == "1" ] && error "Please install docker-compose." && exit 1
  [ $(command_exists composer) == "1" ] && error "Please install composer: visit https://getcomposer.org/" && exit 1
  [ $(command_exists nvm) == "1" ] && error "Please install nvm" && exit 1
  [ $(command_exists pygmy) == "1" ] && error "Please install pygmy" && exit 1

  [ ! ~/.bash_profile ] && error " ~/.bash_profile does not exist. Run 'touch  ~/.bash_profile && source ~/.bashrc'" && exit 1

  # Check what is listening on port 80.
  if ! lsof -i :80 | grep -q LISTEN; then
    error "Nothing is listening on port 80. Run 'pygmy up' to start pygmy." && exit 1
  elif ! lsof -i :80 | grep LISTEN | grep -q vpnkit; then
    error "Port 80 is occupied by other service. Stop this service and run 'pygmy up'"
  else
    pygmy_status=$(pygmy status)
    [ "$?" == "1" ] && error "pygmy is not running. Run 'pygmy up' to start pygmy." && exit 1
    # @todo: Add more checks for pygmy's services.
  fi

  curl -L -s -o /dev/null -w "%{http_code}" $URL | grep -q -v 200 && error "Unable to access $URL" && exit 1

  if curl -L -s -N $URL | grep -q "$TITLE"; then
    success "Successfully bootstrapped $URL"
  else
    error "Website is running, but cannot be bootstrapped. Try pulling latest container images with 'composer pull'" && exit 1
  fi
}

#
# Check that command exists.
#
command_exists() {
  local cmd=$1
  command -v $cmd | grep -ohq $cmd
  local res=$?

  # Try homebrew lookup.
  if [ "$res" == "1" ] ; then
    brew --prefix $cmd > /dev/null
    res=$?
  fi

  echo $res
}

#
# Status echo.
#
status() {
  cecho blue "==> $1";
}

#
# Success echo.
#
success() {
  cecho green "✓ $1";
}

#
# Error echo.
#
error() {  
  cecho red "✘ $1";
}

#
# Colored echo.
#
cecho() {
  local prefix="\033["
  local input_color=$1
  local message="$2"

  local color=""
  case "$input_color" in
    black  | bk) color="${prefix}0;30m";;
    red    |  r) color="${prefix}1;31m";;
    green  |  g) color="${prefix}1;32m";;
    yellow |  y) color="${prefix}1;33m";;
    blue   |  b) color="${prefix}1;34m";;
    purple |  p) color="${prefix}1;35m";;
    cyan   |  c) color="${prefix}1;36m";;
    gray   | gr) color="${prefix}0;37m";;
    *) message="$1"
  esac

  # Format message with color codes, but only if a correct color was provided.
  [ -n "$color" ] && message="${color}${message}${prefix}0m"

  echo -e "$message"
}

main "$@"
