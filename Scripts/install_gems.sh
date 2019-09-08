#!/bin/sh

#  install_gems.sh
#  AsciiDocSpotlight
#
#  Created by Clyde Clements on 2019-09-05.
#  Copyright © 2019 Clyde Clements. All rights reserved.

RESOURCES_PATH="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if test ! -d "${RESOURCES_PATH}"
then
  exit
fi

GEM_INSTALL_PATH="${RESOURCES_PATH}/ruby"
if test -d "${GEM_INSTALL_PATH}/gems"
then
  # Assume asciidoctor gem already installed.
  exit
fi
mkdir -p "${GEM_INSTALL_PATH}"

gem install --norc --install-dir ${GEM_INSTALL_PATH} --no-document \
  --version 2.0.10 asciidoctor
