#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

rules="$ROOT/default/hypr/apps/system.lua"
class_rule='class = "(sublime_text|DesktopEditors|org.gnome.Nautilus|soffice|soffice.bin)"'

grep -F "$class_rule" "$rules" >/dev/null ||
  fail "LibreOffice native file dialogs are covered by the floating dialog rule"

grep -F 'o.window({ class = "(soffice|soffice.bin)", title = "Open" }, { tag = "+floating-window" })' "$rules" >/dev/null ||
  fail "LibreOffice's Open dialog, titled just Open, receives the floating-window tag"

grep -A2 -F "$class_rule" "$rules" | grep -F 'tag = "+floating-window"' >/dev/null ||
  fail "LibreOffice native file dialogs receive the floating-window tag"

pass "LibreOffice native file dialogs use the standard floating dialog treatment"
