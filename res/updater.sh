#!/bin/bash

get_latest_release() {
  curl --silent "https://api.github.com/repos/ChugunovRoman/figma-linux-font-helper/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/';
}

get_latest_release_link_download() {
  curl --silent "https://api.github.com/repos/ChugunovRoman/figma-linux-font-helper/releases/latest" | grep '"browser_download_url":' | sed -E 's/.*"([^"]+)".*/\1/';
}

have_new_version() {
  local current=`/opt/FontHelper/fonthelper -v`;
  local latest=$(get_latest_release);

  if [ ! $current == $latest ]; then
    echo "Need update your version on $latest";
    download;
    install;
  else
    echo "You have latest version";
  fi

}

download() {
  local link=$(get_latest_release_link_download);

  cd /tmp;
  rm -rf ./fonthelper.tar*
  wget "$link";
}

install() {
  cd /opt/FontHelper;
  tar xJf /tmp/fonthelper.tar.xz ./fonthelper
  tar xJf /tmp/fonthelper.tar.xz ./updater.sh
  chmod +x ./fonthelper ./updater.sh

  cd /lib/systemd/system
  tar xJf /tmp/fonthelper.tar.xz ./fonthelper.service
  tar xJf /tmp/fonthelper.tar.xz ./fonthelper-updater.service

  chmod 644 /lib/systemd/system/fonthelper.service
  chmod 644 /lib/systemd/system/fonthelper-updater.service

  systemctl daemon-reload

  systemctl restart fonthelper.service
  systemctl restart fonthelper-updater.service

  systemctl enable fonthelper.service
  systemctl enable fonthelper-updater.service
}

main() {
  if [[ $EUID -ne 0 ]]; then
    echo "Need run under root";
    echo "Abort";
    exit 1;
  fi

  have_new_version;
}

while true; do
  main;
  sleep 360;
done
