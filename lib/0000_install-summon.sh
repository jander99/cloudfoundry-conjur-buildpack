#!/usr/bin/env bash

BUILD_DIR=$1
ESCAPED_BUILD_DIR=$(echo $BUILD_DIR | sed -e 's/[\/&]/\\&/g')

curl -sSL https://raw.githubusercontent.com/cyberark/summon/master/install.sh | sed -e 's/sudo //' -e "s/\/usr\/local\/bin/$ESCAPED_BUILD_DIR/" -e "s/-d \"\/etc\/bash_completion.d\"/\! 1/" | bash
curl -sSL https://raw.githubusercontent.com/cyberark/summon-conjur/master/install.sh | sed -e 's/sudo //' -e "s/\/usr\/local\/lib\/summon/$ESCAPED_BUILD_DIR/" | bash
