#!/bin/bash
function _main() {
  zenity --question \
    --title="備份腳本" \
    --text="今日要進行資料備份嗎？" || exit
  _backup scripts
  _backup config
  _backup vimwiki
}

function _backup() {
  BACKUP_DIR="$1"
  TAR_NAME="${BACKUP_DIR}.tar"
  (
  notify-send -i "face-smirk" "備份腳本" "$1 開始進行備份"
  # Get in directory.
  cd ${HOME}/docs/backups 

  # Zip and compression the directory.
  echo "30"; echo "# $1 -- 封裝備份資料..."
  tar hcvf ${TAR_NAME} ${BACKUP_DIR}
  if [ -f "${TAR_NAME}.xz" ]; then
    rm $TAR_NAME.xz;
    echo "50"; echo "# $1 -- 刪除前一個備份壓縮檔..."; sleep 5
  fi
  echo "60"; echo "# $1 -- 壓縮備份資料...";
  xz ${TAR_NAME}

  
  echo "80"; echo "# $1 -- 上傳壓縮資料...";
  # And Start Upload the file.
  ${HOME}/scripts/bin/dropbox_uploader.sh upload ${TAR_NAME}.xz backups/${TAR_NAME}.xz
  rm $TAR_NAME.xz;

  notify-send -i "face-wink" "備份腳本" "$1 已經備份完成"
  ) |
  zenity --progress \
    --title="備份腳本 -- $1" \
    --text="$1 -- 掃描備份文件..." \
    --auto-close \
    --percentage=0

  if [ "$?" = -1 ] ; then
          zenity --error \
            --text="Backup canceled."
  fi
}
_main
