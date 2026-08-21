##[>] 🤖🤖
_ar_meta='http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token'
_ar_raw=""
if command -v curl >/dev/null 2>&1; then
  _ar_raw="$(curl -fsS --connect-timeout 2 -H 'Metadata-Flavor: Google' "$_ar_meta" 2>/dev/null || true)"
elif command -v wget >/dev/null 2>&1; then
  _ar_raw="$(wget -qO- -T 2 --header='Metadata-Flavor: Google' "$_ar_meta" 2>/dev/null || true)"
fi
_ar_token="$(printf '%s' "$_ar_raw" | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')"
if [ -n "$_ar_token" ] && [ -n "${HOME:-}" ] && command -v base64 >/dev/null 2>&1; then
  _ar_auth="$(printf 'oauth2accesstoken:%s' "$_ar_token" | base64 | tr -d '\n')"
  mkdir -p "$HOME/.docker"
  printf '{"auths":{"%s":{"auth":"%s"}}}\n' "$_ar_host" "$_ar_auth" > "$HOME/.docker/config.json"
  chmod 600 "$HOME/.docker/config.json"
fi
unset _ar_host _ar_meta _ar_raw _ar_token _ar_auth
##[<] 🤖🤖
