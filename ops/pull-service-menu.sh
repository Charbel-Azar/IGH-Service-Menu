#!/usr/bin/env bash
set -euo pipefail
umask 077

readonly state="$HOME/.igh-service-menu-deploy"
readonly production="$HOME/public_html/Services-Menu"
readonly stage="$state/staging"
readonly archive_url='https://codeload.github.com/Charbel-Azar/IGH-Service-Menu/zip/refs/heads/cpanel-release'
readonly -a files=(
  'favicon.png' 'logo-IGH.png' 'kidneys (1).png'
  'icons/cupping.png' 'icons/dry-needling.png' 'icons/facials.png'
  'icons/genetic.png' 'icons/infrared.png' 'icons/prp.png'
  'index.html'
)

case "${1:-}" in
  stage) destination=$stage ;;
  production) destination=$production ;;
  *) echo 'Expected stage or production.' >&2; exit 2 ;;
esac

[[ ! -L "$state" ]] || exit 1
mkdir -p -- "$state"
exec 9>"$state/lock"
flock -n 9 || exit 0

if [[ "$destination" == "$stage" ]]; then
  [[ ! -L "$stage" && ! -L "$stage/icons" ]] || exit 1
  mkdir -p -- "$stage/icons"
fi
[[ "$(realpath -e -- "$destination")" == "$destination" &&
   "$(realpath -e -- "$destination/icons")" == "$destination/icons" ]] || exit 1

temp=$(mktemp -d "$state/work.XXXXXXXX")
trap 'rm -rf -- "$temp"' EXIT
curl -fsS --proto '=https' --proto-redir '=https' --connect-timeout 10 --max-time 45 \
  --max-filesize 10485760 "$archive_url" -o "$temp/release.zip"
unzip -Z1 "$temp/release.zip" > "$temp/entries"
if ! grep -Ex 'IGH-Service-Menu-cpanel-release/index\.html' "$temp/entries" >/dev/null; then
  echo 'Archive has an unexpected root.' >&2
  exit 1
fi

mkdir -- "$temp/site" "$temp/site/icons"
for file in "${files[@]}"; do
  entry="IGH-Service-Menu-cpanel-release/$file"
  [[ $(grep -Fxc -- "$entry" "$temp/entries") == 1 ]]
  unzip -p "$temp/release.zip" "$entry" > "$temp/site/$file"
  [[ -s "$temp/site/$file" && ! -L "$destination/$file" ]]
done

changed=()
for file in "${files[@]}"; do
  if ! cmp -s -- "$temp/site/$file" "$destination/$file"; then
    changed+=("$file")
  fi
done

if [[ ${#changed[@]} == 0 ]]; then
  exit 0
fi

backup=
if [[ "$destination" == "$production" ]]; then
  [[ ! -L "$state/rollback" ]] || exit 1
  mkdir -p -- "$state/rollback"
  backup=$(mktemp -d "$state/rollback/$(date -u +%Y%m%dT%H%M%S).XXXXXXXX")
  mkdir -- "$backup/icons"
  for file in "${changed[@]}"; do
    [[ -f "$destination/$file" ]]
    cp -p -- "$destination/$file" "$backup/$file"
    cmp -s -- "$destination/$file" "$backup/$file"
  done
fi

publish_file() {
  local source=$1 target=$2 pending
  pending=$(mktemp "${target%/*}/.igh-deploy.XXXXXXXX") || return 1
  if ! install -m 0644 -- "$source" "$pending" || ! mv -fT -- "$pending" "$target"; then
    rm -f -- "$pending"
    return 1
  fi
}

published=()
for file in "${changed[@]}"; do
  if ! publish_file "$temp/site/$file" "$destination/$file"; then
    if [[ -n "$backup" ]]; then
      for completed in "${published[@]}"; do
        publish_file "$backup/$completed" "$destination/$completed" ||
          echo "Restore failed for $completed from $backup" >&2
      done
    fi
    echo "Publish failed for $file" >&2
    exit 1
  fi
  published+=("$file")
done

for file in "${files[@]}"; do
  cmp -s -- "$temp/site/$file" "$destination/$file"
done
printf '%s %s: published %d verified files\n' "$(date -u +%FT%TZ)" "$1" "${#changed[@]}" >> "$state/deploy.log"
