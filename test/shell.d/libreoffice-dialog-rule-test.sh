#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

# The rules system.lua actually hands Hyprland, one class<TAB>title<TAB>tag per line.
emitted_rules() {
  OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

hl = {
  window_rule = function(rule)
    print((rule.match.class or "") .. "\t" .. (rule.match.title or "") .. "\t" .. (rule.tag or ""))
  end,
}

require("default.hypr.helpers")
require("default.hypr.apps.system")
LUA
}

rules=$(emitted_rules) || fail "system.lua loads" "$rules"

grep -P '^\(sublime_text\|DesktopEditors\|org\.gnome\.Nautilus\|soffice\|soffice\.bin\)\t\^\(Open\.\*Files\?\|.*\|Save\|.*\t\+floating-window$' <<<"$rules" >/dev/null ||
  fail "LibreOffice's Save dialog receives the floating-window tag" "$rules"

grep -Fx $'(soffice|soffice.bin)\tOpen\t+floating-window' <<<"$rules" >/dev/null ||
  fail "LibreOffice's Open dialog, titled just Open, receives the floating-window tag" "$rules"

pass "LibreOffice native file dialogs use the standard floating dialog treatment"
