#!/usr/bin/env bash

_conjur_BUILD_DIR=$1
_conjur_BIN_DIR="$_conjur_BUILD_DIR/bin"
_conjur_ESCAPED_BIN_DIR=$(echo "$_conjur_BIN_DIR" | sed -e 's/[\/&]/\\&/g')

mkdir -p ${_conjur_BIN_DIR}
curl -sSL https://raw.githubusercontent.com/cyberark/summon/master/install.sh | sed -e 's/sudo //' -e "s/\/usr\/local\/bin/$_conjur_ESCAPED_BIN_DIR/" -e "s/-d \"\/etc\/bash_completion.d\"/\! 1/" | bash
curl -sSL https://raw.githubusercontent.com/cyberark/summon-conjur/master/install.sh | sed -e 's/sudo //' -e "s/\/usr\/local\/lib\/summon/$_conjur_ESCAPED_BIN_DIR/" | bash

unset -f _conjur_ESCAPED_BIN_DIR _conjur_BIN_DIR _conjur_ESCAPED_BIN_DIR
