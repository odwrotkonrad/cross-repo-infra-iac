##[>] 🤖🤖
_go_proxy_host="${_go_proxy%%/*}"
_go_proxy_meta='http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token'
_go_proxy_raw=""
if command -v curl >/dev/null 2>&1; then
  _go_proxy_raw="$(curl -fsS --connect-timeout 2 -H 'Metadata-Flavor: Google' "$_go_proxy_meta" 2>/dev/null || true)"
elif command -v wget >/dev/null 2>&1; then
  _go_proxy_raw="$(wget -qO- -T 2 --header='Metadata-Flavor: Google' "$_go_proxy_meta" 2>/dev/null || true)"
fi
_go_proxy_token="$(printf '%s' "$_go_proxy_raw" | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')"
if [ -n "$_go_proxy_token" ] && [ -n "${HOME:-}" ]; then
  touch "$HOME/.netrc"
  chmod 600 "$HOME/.netrc"
  grep -v "^machine $_go_proxy_host " "$HOME/.netrc" > "$HOME/.netrc.go-proxy" || true
  printf 'machine %s login oauth2accesstoken password %s\n' "$_go_proxy_host" "$_go_proxy_token" >> "$HOME/.netrc.go-proxy"
  mv "$HOME/.netrc.go-proxy" "$HOME/.netrc"
  export GOPROXY="https://$_go_proxy,https://proxy.golang.org"
fi
unset _go_proxy _go_proxy_host _go_proxy_meta _go_proxy_raw _go_proxy_token
##[<] 🤖🤖
