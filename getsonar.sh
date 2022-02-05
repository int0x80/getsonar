#!/usr/bin/env bash
# -----------------------------------------------------------
# Pull relevant datasets from Sonar
# -----------------------------------------------------------
set -e

API_KEY='YOUR-PROJECT-SONAR-API-KEY'
DIR=$(dirname "$(readlink -f -- "${0}")")
FILESET_URL='https://us.api.insight.rapid7.com/opendata/studies/sonar.fdns_v2/'
OUTPUT_DIR="/data/inetdata/data/cache/sonar"


# -----------------------------------------------------------
# Retrieve the requested archive
# -----------------------------------------------------------
acquire_archive() {
  archive=${1}
  download_url=$(curl -s -H "X-Api-Key: ${API_KEY}" "${FILESET_URL}${archive}/download/" | jq -r '.url') && log "Download URL: ${download_url}"
  lftp -c "set net:idle 5
           set net:max-retries 0
           set net:reconnect-interval-base 3
           set net:reconnect-interval-max 3
           set ssl:verify-certificate no
           pget -n 16 -c ${download_url} -o ${OUTPUT_DIR}/${archive}"
}


# -----------------------------------------------------------
# Retrieve list of available archives
# -----------------------------------------------------------
acquire_fileset() {
  declare -A archives
  curl -s -H "X-Api-Key: ${API_KEY}" "${FILESET_URL}" -o "${DIR}/fileset.json"
  while read archive; do
    [[ ${archive} != *_* ]] && continue
    key=$(echo "${archive}" | awk -F_ '{print $NF}')
    if [[ ! ${archives[$key]+_} ]]; then
      log "Identified archive: ${archive}"
      archives[$key]=${archive}
      acquire_archive ${archive}
    fi
  done < <(jq -r '.sonarfile_set[]' < "${DIR}/fileset.json")
}


# -----------------------------------------------------------
# Check dependencies: curl, jq, lftp
# -----------------------------------------------------------
check_dependcies() {
  return_value=0
  log "Checking dependencies: curl, jq, lftp"
  for dependency in curl jq lftp; do
    command -v ${dependency} || return_value=1
  done
  return ${return_value}
}


# -----------------------------------------------------------
# Logging utility function
# -----------------------------------------------------------
log() {
  echo "[*] $(date -Is) ${@}"
}


# -----------------------------------------------------------
# Say goodbye
# -----------------------------------------------------------
epilogue() {
  log "Work completed, unloading."
}


# -----------------------------------------------------------
# Announce yourself
# -----------------------------------------------------------
prologue() {
  log "Loaded getsonar by int0x80"
}


# -----------------------------------------------------------
# Doing the things
# -----------------------------------------------------------
main() {
  prologue
  if ! check_dependencies; then exit 1; fi
  acquire_fileset
  epilogue
}

main
