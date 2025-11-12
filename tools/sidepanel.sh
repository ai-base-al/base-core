#!/usr/bin/env bash
# BaseChrome Side Panel Generator
# Generates all necessary files for a new side panel and creates a patch
#
# Usage: ./tools/sidepanel.sh <PanelName> [options]
# Example: ./tools/sidepanel.sh Reading --desc="Clean reading mode" --side=right

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="$ROOT_DIR/ungoogled-chromium/build/src"

# Check if we're in the right directory
if [ ! -d "$ROOT_DIR/ungoogled-chromium" ]; then
    echo -e "${RED}Error: Must be run from base-core directory${NC}"
    echo -e "${DIM}Run from: $(basename "$ROOT_DIR")${NC}"
    exit 1
fi

# Default values
PANEL_SIDE="right"  # left or right
PANEL_TYPE="standard"  # standard or custom
PANEL_DESC=""

# Parse arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}Error: Panel name required${NC}"
    echo ""
    echo -e "${BOLD}Usage:${NC}"
    echo -e "  $0 <PanelName> [options]"
    echo ""
    echo -e "${BOLD}Options:${NC}"
    echo -e "  --desc=\"description\"       Panel description"
    echo -e "  --side=left|right         Side panel position (default: right)"
    echo -e "  --type=standard|custom    Panel type (default: standard)"
    echo ""
    echo -e "${BOLD}Examples:${NC}"
    echo -e "  $0 Reading --desc=\"Clean reading mode\""
    echo -e "  $0 Notes --desc=\"Quick notes\" --side=left"
    echo -e "  $0 Translate --desc=\"Translation\" --side=right --type=custom"
    echo ""
    exit 1
fi

PANEL_NAME="$1"
shift  # Remove panel name from arguments

# Parse options
while [ $# -gt 0 ]; do
    case "$1" in
        --desc=*)
            PANEL_DESC="${1#*=}"
            ;;
        --side=*)
            PANEL_SIDE="${1#*=}"
            if [[ "$PANEL_SIDE" != "left" && "$PANEL_SIDE" != "right" ]]; then
                echo -e "${RED}Error: --side must be 'left' or 'right'${NC}"
                exit 1
            fi
            ;;
        --type=*)
            PANEL_TYPE="${1#*=}"
            if [[ "$PANEL_TYPE" != "standard" && "$PANEL_TYPE" != "custom" ]]; then
                echo -e "${RED}Error: --type must be 'standard' or 'custom'${NC}"
                exit 1
            fi
            ;;
        *)
            # Support legacy positional description argument
            if [ -z "$PANEL_DESC" ]; then
                PANEL_DESC="$1"
            else
                echo -e "${YELLOW}Warning: Unknown option: $1${NC}"
            fi
            ;;
    esac
    shift
done

# Set default description if not provided
if [ -z "$PANEL_DESC" ]; then
    PANEL_DESC="Custom side panel for Base Browser"
fi

# Derive names
PANEL_LOWER=$(echo "$PANEL_NAME" | tr '[:upper:]' '[:lower:]')
PANEL_UPPER=$(echo "$PANEL_NAME" | tr '[:lower:]' '[:upper:]')
PANEL_TITLE="$PANEL_NAME Mode"

# Naming convention
DIR_NAME="basedev_${PANEL_LOWER}"
CLASS_PREFIX="BaseOne${PANEL_NAME}Mode"
URL_HOST="basedev-${PANEL_LOWER}-side-panel"
ENUM_ID="kBaseOne${PANEL_NAME}Mode"
MOJOM_MODULE="basedev_${PANEL_LOWER}"
RESOURCE_PREFIX="BASEDEV_${PANEL_UPPER}_MODE"
PATCH_FILE="basedev-sidepanel-${PANEL_LOWER}.patch"

echo ""
echo -e "${CYAN}${BOLD}════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}   BaseOne Side Panel Generator${NC}"
echo -e "${CYAN}${BOLD}════════════════════════════════════════${NC}"
echo ""
echo -e "${BOLD}Panel Configuration:${NC}"
echo -e "  Name:        ${CYAN}$PANEL_NAME${NC}"
echo -e "  Description: ${DIM}$PANEL_DESC${NC}"
echo -e "  Side:        ${CYAN}$PANEL_SIDE${NC}"
echo -e "  Type:        ${CYAN}$PANEL_TYPE${NC}"
echo ""
echo -e "${BOLD}Generated Names:${NC}"
echo -e "  Directory:   ${CYAN}$DIR_NAME${NC}"
echo -e "  Class:       ${CYAN}${CLASS_PREFIX}UI${NC}"
echo -e "  Enum ID:     ${CYAN}$ENUM_ID${NC}"
echo -e "  URL:         ${CYAN}chrome://$URL_HOST/${NC}"
echo -e "  Patch:       ${CYAN}$PATCH_FILE${NC}"
echo ""

# Check if source directory exists
if [ ! -d "$SRC_DIR" ]; then
    echo -e "${YELLOW}⚠️  Chromium source not found${NC}"
    echo -e "${DIM}Build first or extract source${NC}"
    exit 1
fi

# Create a git branch for changes
echo -e "${BOLD}Step 1: Creating git branch...${NC}"
cd "$SRC_DIR"

BRANCH_NAME="basedev/${PANEL_LOWER}-panel"
if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Branch $BRANCH_NAME already exists${NC}"
    echo -e "   Deleting and recreating..."
    git checkout main 2>/dev/null || git checkout master 2>/dev/null || true
    git branch -D "$BRANCH_NAME" 2>/dev/null || true
fi

git checkout -b "$BRANCH_NAME"
echo -e "${GREEN}✓${NC} Created branch: ${CYAN}$BRANCH_NAME${NC}"

# 1. Create WebUI Backend files
echo ""
echo -e "${BOLD}Step 2: Creating WebUI backend files...${NC}"

WEBUI_DIR="$SRC_DIR/chrome/browser/ui/webui/side_panel/$DIR_NAME"
mkdir -p "$WEBUI_DIR"

# Header file
cat > "$WEBUI_DIR/${PANEL_LOWER}_ui.h" << EOF
// Copyright $(date +%Y) The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef CHROME_BROWSER_UI_WEBUI_SIDE_PANEL_${PANEL_UPPER}_${PANEL_UPPER}_UI_H_
#define CHROME_BROWSER_UI_WEBUI_SIDE_PANEL_${PANEL_UPPER}_${PANEL_UPPER}_UI_H_

#include "chrome/browser/ui/webui/side_panel/${DIR_NAME}/${PANEL_LOWER}.mojom.h"
#include "chrome/common/webui_url_constants.h"
#include "content/public/browser/web_ui_controller.h"
#include "mojo/public/cpp/bindings/pending_receiver.h"
#include "mojo/public/cpp/bindings/receiver.h"
#include "ui/webui/mojo_bubble_web_ui_controller.h"

// BaseOne: ${PANEL_DESC}
class ${CLASS_PREFIX}UI : public ui::MojoBubbleWebUIController,
                          public ${MOJOM_MODULE}::mojom::PageHandler {
 public:
  explicit ${CLASS_PREFIX}UI(content::WebUI* web_ui);
  ~${CLASS_PREFIX}UI() override;

  ${CLASS_PREFIX}UI(const ${CLASS_PREFIX}UI&) = delete;
  ${CLASS_PREFIX}UI& operator=(const ${CLASS_PREFIX}UI&) = delete;

  void BindInterface(
      mojo::PendingReceiver<${MOJOM_MODULE}::mojom::PageHandler> receiver);

  // ${MOJOM_MODULE}::mojom::PageHandler:
  void DoAction() override;

 private:
  mojo::Receiver<${MOJOM_MODULE}::mojom::PageHandler> receiver_{this};
  mojo::Remote<${MOJOM_MODULE}::mojom::Page> page_;

  base::WeakPtrFactory<${CLASS_PREFIX}UI> weak_factory_{this};

  WEB_UI_CONTROLLER_TYPE_DECL();
};

#endif  // CHROME_BROWSER_UI_WEBUI_SIDE_PANEL_${PANEL_UPPER}_${PANEL_UPPER}_UI_H_
EOF

echo -e "${GREEN}✓${NC} Created ${DIM}chrome/browser/ui/webui/side_panel/$DIR_NAME/${PANEL_LOWER}_ui.h${NC}"

# Implementation file
cat > "$WEBUI_DIR/${PANEL_LOWER}_ui.cc" << EOF
// Copyright $(date +%Y) The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "chrome/browser/ui/webui/side_panel/${DIR_NAME}/${PANEL_LOWER}_ui.h"

#include "chrome/browser/profiles/profile.h"
#include "chrome/browser/ui/webui/webui_util.h"
#include "chrome/common/webui_url_constants.h"
#include "chrome/grit/generated_resources.h"
#include "chrome/grit/${PANEL_LOWER}_resources.h"
#include "chrome/grit/${PANEL_LOWER}_resources_map.h"
#include "content/public/browser/web_contents.h"
#include "content/public/browser/web_ui_data_source.h"

${CLASS_PREFIX}UI::${CLASS_PREFIX}UI(content::WebUI* web_ui)
    : ui::MojoBubbleWebUIController(web_ui) {
  content::WebUIDataSource* source = content::WebUIDataSource::CreateAndAdd(
      web_ui->GetWebContents()->GetBrowserContext(),
      chrome::kChromeUI${CLASS_PREFIX}SidePanelHost);

  // Add localized strings
  source->AddLocalizedString("title", IDS_${RESOURCE_PREFIX}_TITLE);
  source->AddLocalizedString("description", IDS_${RESOURCE_PREFIX}_DESC);

  // Set up resources
  webui::SetupWebUIDataSource(
      source,
      base::make_span(k${CLASS_PREFIX}Resources, k${CLASS_PREFIX}ResourcesSize),
      IDR_${RESOURCE_PREFIX}_HTML);

  source->OverrideContentSecurityPolicy(
      network::mojom::CSPDirectiveName::TrustedTypes,
      "trusted-types static-types;");
}

${CLASS_PREFIX}UI::~${CLASS_PREFIX}UI() = default;

WEB_UI_CONTROLLER_TYPE_IMPL(${CLASS_PREFIX}UI)

void ${CLASS_PREFIX}UI::BindInterface(
    mojo::PendingReceiver<${MOJOM_MODULE}::mojom::PageHandler> receiver) {
  receiver_.reset();
  receiver_.Bind(std::move(receiver));
}

void ${CLASS_PREFIX}UI::DoAction() {
  // BaseOne: Implement your panel action here
  if (page_) {
    page_->OnActionComplete("Action completed");
  }
}
EOF

echo -e "${GREEN}✓${NC} Created ${DIM}chrome/browser/ui/webui/side_panel/$DIR_NAME/${PANEL_LOWER}_ui.cc${NC}"

# Mojom file
cat > "$WEBUI_DIR/${PANEL_LOWER}.mojom" << EOF
// Copyright $(date +%Y) The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

module ${MOJOM_MODULE}.mojom;

// BaseOne: Browser-side handler for ${PANEL_NAME} Mode panel
interface PageHandler {
  // Perform the main action
  DoAction();
};

// BaseOne: Renderer-side handler for responses from browser
interface Page {
  // Called when action is complete
  OnActionComplete(string result);
};
EOF

echo -e "${GREEN}✓${NC} Created ${DIM}chrome/browser/ui/webui/side_panel/$DIR_NAME/${PANEL_LOWER}.mojom${NC}"

# BUILD.gn for WebUI
cat > "$WEBUI_DIR/BUILD.gn" << EOF
# Copyright $(date +%Y) The Chromium Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

import("//mojo/public/tools/bindings/mojom.gni")

mojom("mojo_bindings") {
  sources = [ "${PANEL_LOWER}.mojom" ]

  webui_module_path = "chrome://$URL_HOST/"
}

source_set("${DIR_NAME}") {
  sources = [
    "${PANEL_LOWER}_ui.cc",
    "${PANEL_LOWER}_ui.h",
  ]

  deps = [
    ":mojo_bindings",
    "//chrome/app:generated_resources",
    "//chrome/browser/profiles",
    "//chrome/browser/ui/webui",
    "//chrome/common",
    "//content/public/browser",
    "//mojo/public/cpp/bindings",
    "//ui/webui",
  ]
}
EOF

echo -e "${GREEN}✓${NC} Created ${DIM}chrome/browser/ui/webui/side_panel/$DIR_NAME/BUILD.gn${NC}"

# 2. Create Coordinator files
echo ""
echo -e "${BOLD}Step 3: Creating coordinator files...${NC}"

COORD_DIR="$SRC_DIR/chrome/browser/ui/views/side_panel"

# Coordinator header
cat > "$COORD_DIR/${DIR_NAME}_side_panel_coordinator.h" << EOF
// Copyright $(date +%Y) The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef CHROME_BROWSER_UI_VIEWS_SIDE_PANEL_${PANEL_UPPER}_SIDE_PANEL_COORDINATOR_H_
#define CHROME_BROWSER_UI_VIEWS_SIDE_PANEL_${PANEL_UPPER}_SIDE_PANEL_COORDINATOR_H_

#include <memory>
#include "base/memory/raw_ptr.h"
#include "chrome/browser/ui/browser_user_data.h"

class Browser;
class SidePanelRegistry;

// BaseOne: Coordinator for ${PANEL_NAME} Mode side panel
class ${CLASS_PREFIX}SidePanelCoordinator
    : public BrowserUserData<${CLASS_PREFIX}SidePanelCoordinator> {
 public:
  explicit ${CLASS_PREFIX}SidePanelCoordinator(Browser* browser);
  ~${CLASS_PREFIX}SidePanelCoordinator() override;

  void CreateAndRegisterEntry(SidePanelRegistry* global_registry);
  void Toggle();
  bool IsAvailable() const;

 private:
  friend class BrowserUserData<${CLASS_PREFIX}SidePanelCoordinator>;

  std::unique_ptr<views::View> CreateWebView();

  raw_ptr<Browser> browser_;

  BROWSER_USER_DATA_KEY_DECL();
};

#endif  // CHROME_BROWSER_UI_VIEWS_SIDE_PANEL_${PANEL_UPPER}_SIDE_PANEL_COORDINATOR_H_
EOF

echo -e "${GREEN}✓${NC} Created ${DIM}chrome/browser/ui/views/side_panel/${DIR_NAME}_side_panel_coordinator.h${NC}"

# Coordinator implementation
cat > "$COORD_DIR/${DIR_NAME}_side_panel_coordinator.cc" << EOF
// Copyright $(date +%Y) The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "chrome/browser/ui/views/side_panel/${DIR_NAME}_side_panel_coordinator.h"

#include "chrome/app/vector_icons/vector_icons.h"
#include "chrome/browser/ui/browser.h"
#include "chrome/browser/ui/views/frame/browser_view.h"
#include "chrome/browser/ui/views/side_panel/side_panel_coordinator.h"
#include "chrome/browser/ui/views/side_panel/side_panel_entry.h"
#include "chrome/browser/ui/views/side_panel/side_panel_web_ui_view.h"
#include "chrome/browser/ui/webui/side_panel/${DIR_NAME}/${PANEL_LOWER}_ui.h"
#include "chrome/common/webui_url_constants.h"
#include "chrome/grit/generated_resources.h"
#include "ui/base/l10n/l10n_util.h"

${CLASS_PREFIX}SidePanelCoordinator::${CLASS_PREFIX}SidePanelCoordinator(
    Browser* browser)
    : browser_(browser) {}

${CLASS_PREFIX}SidePanelCoordinator::~${CLASS_PREFIX}SidePanelCoordinator() = default;

BROWSER_USER_DATA_KEY_IMPL(${CLASS_PREFIX}SidePanelCoordinator)

void ${CLASS_PREFIX}SidePanelCoordinator::CreateAndRegisterEntry(
    SidePanelRegistry* global_registry) {
  global_registry->Register(std::make_unique<SidePanelEntry>(
      SidePanelEntry::Id::$ENUM_ID,
      l10n_util::GetStringUTF16(IDS_${RESOURCE_PREFIX}_TITLE),
      ui::ImageModel::FromVectorIcon(kReadLaterIcon, ui::kColorIcon),
      base::BindRepeating(
          &${CLASS_PREFIX}SidePanelCoordinator::CreateWebView,
          base::Unretained(this))));
}

std::unique_ptr<views::View>
${CLASS_PREFIX}SidePanelCoordinator::CreateWebView() {
  auto web_view = std::make_unique<SidePanelWebUIViewT<${CLASS_PREFIX}UI>>(
      base::RepeatingClosure(), base::RepeatingClosure(),
      std::make_unique<BubbleContentsWrapperT<${CLASS_PREFIX}UI>>(
          GURL(chrome::kChromeUI${CLASS_PREFIX}SidePanelURL),
          browser_->profile(),
          IDS_${RESOURCE_PREFIX}_TITLE));

  web_view->SetPreferredSize(gfx::Size(320, 400));
  return web_view;
}

void ${CLASS_PREFIX}SidePanelCoordinator::Toggle() {
  auto* browser_view = BrowserView::GetBrowserViewForBrowser(browser_);
  if (!browser_view) return;

  auto* coordinator = browser_view->side_panel_coordinator();
  if (!coordinator) return;

  if (coordinator->GetCurrentEntryId() == SidePanelEntry::Id::$ENUM_ID) {
    coordinator->Close();
  } else {
    coordinator->Show(SidePanelEntry::Id::$ENUM_ID);
  }
}

bool ${CLASS_PREFIX}SidePanelCoordinator::IsAvailable() const {
  // BaseOne: Add your availability logic here
  return true;
}
EOF

echo -e "${GREEN}✓${NC} Created ${DIM}chrome/browser/ui/views/side_panel/${DIR_NAME}_side_panel_coordinator.cc${NC}"

# 3. Create Frontend Resources
echo ""
echo -e "${BOLD}Step 4: Creating frontend resources...${NC}"

RESOURCES_DIR="$SRC_DIR/chrome/browser/resources/side_panel/$DIR_NAME"
mkdir -p "$RESOURCES_DIR"

# HTML
cat > "$RESOURCES_DIR/${PANEL_LOWER}.html" << 'EOF_HTML'
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <link rel="stylesheet" href="chrome://resources/css/text_defaults.css">
  <link rel="stylesheet" href="PANEL_LOWER.css">
</head>
<body>
  <div id="container">
    <div id="header">
      <h1>PANEL_TITLE</h1>
    </div>

    <div id="content">
      <p>Welcome to PANEL_TITLE!</p>
      <button id="action-button">Do Action</button>
      <div id="result"></div>
    </div>
  </div>

  <script type="module" src="PANEL_LOWER.js"></script>
</body>
</html>
EOF_HTML

sed -i '' "s/PANEL_LOWER/${PANEL_LOWER}/g" "$RESOURCES_DIR/${PANEL_LOWER}.html"
sed -i '' "s/PANEL_TITLE/${PANEL_TITLE}/g" "$RESOURCES_DIR/${PANEL_LOWER}.html"

echo -e "${GREEN}✓${NC} Created ${DIM}chrome/browser/resources/side_panel/$DIR_NAME/${PANEL_LOWER}.html${NC}"

# CSS
cat > "$RESOURCES_DIR/${PANEL_LOWER}.css" << 'EOF'
body {
  margin: 0;
  padding: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}

#container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  padding: 16px;
}

#header {
  margin-bottom: 24px;
}

#header h1 {
  font-size: 24px;
  font-weight: 600;
  margin: 0;
}

#content {
  flex: 1;
}

#action-button {
  padding: 8px 16px;
  background: #1a73e8;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

#action-button:hover {
  background: #1557b0;
}

#result {
  margin-top: 16px;
  padding: 12px;
  background: #f0f0f0;
  border-radius: 4px;
}
EOF

echo -e "${GREEN}✓${NC} Created ${DIM}chrome/browser/resources/side_panel/$DIR_NAME/${PANEL_LOWER}.css${NC}"

# TypeScript
cat > "$RESOURCES_DIR/${PANEL_LOWER}.ts" << EOF
import {PageHandlerRemote, Page} from './${PANEL_LOWER}.mojom-webui.js';

class ${PANEL_NAME}ModeApp implements Page {
  private handler: PageHandlerRemote;

  constructor() {
    this.handler = PageHandlerRemote.getRemote();
    this.initializeEventListeners();
  }

  private initializeEventListeners(): void {
    const actionBtn = document.getElementById('action-button');
    actionBtn?.addEventListener('click', () => this.doAction());
  }

  private doAction(): void {
    this.handler.doAction();
  }

  // Implement Page interface
  onActionComplete(result: string): void {
    const resultEl = document.getElementById('result');
    if (resultEl) {
      resultEl.textContent = result;
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  new ${PANEL_NAME}ModeApp();
});
EOF

echo -e "${GREEN}✓${NC} Created ${DIM}chrome/browser/resources/side_panel/$DIR_NAME/${PANEL_LOWER}.ts${NC}"

# BUILD.gn for resources
cat > "$RESOURCES_DIR/BUILD.gn" << EOF
# Copyright $(date +%Y) The Chromium Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

import("//chrome/common/features.gni")
import("//tools/grit/grit_rule.gni")
import("//tools/typescript/ts_library.gni")
import("//ui/webui/resources/tools/generate_grd.gni")

ts_library("build_ts") {
  root_dir = "."
  out_dir = "\$target_gen_dir/tsc"

  in_files = [ "${PANEL_LOWER}.ts" ]

  deps = [
    "//chrome/browser/ui/webui/side_panel/${DIR_NAME}:mojo_bindings_webui_js",
    "//ui/webui/resources/js:build_ts",
  ]
}

generate_grd("build_grd") {
  input_files = [
    "${PANEL_LOWER}.html",
    "${PANEL_LOWER}.css",
  ]

  input_files_base_dir = rebase_path(".", "//")
  deps = [ ":build_ts" ]
  manifest_files = [ "\$target_gen_dir/tsconfig.manifest" ]

  grd_prefix = "${PANEL_LOWER}"
  out_grd = "\$target_gen_dir/\${grd_prefix}_resources.grd"
  resource_path_prefix = "side_panel/${DIR_NAME}"
}

grit("resources") {
  enable_input_discovery_for_gn_analyze = false
  source = "\$target_gen_dir/${PANEL_LOWER}_resources.grd"
  deps = [ ":build_grd" ]

  outputs = [
    "grit/${PANEL_LOWER}_resources.h",
    "grit/${PANEL_LOWER}_resources_map.cc",
    "grit/${PANEL_LOWER}_resources_map.h",
    "${PANEL_LOWER}_resources.pak",
  ]

  output_dir = "\$root_gen_dir/chrome"
}
EOF

echo -e "${GREEN}✓${NC} Created ${DIM}chrome/browser/resources/side_panel/$DIR_NAME/BUILD.gn${NC}"

# 4. Modify side_panel_entry.h
echo ""
echo -e "${BOLD}Step 5: Modifying side_panel_entry.h...${NC}"

ENTRY_FILE="$SRC_DIR/chrome/browser/ui/views/side_panel/side_panel_entry.h"

# Add enum entry (find kBookmarks and add after it)
perl -i -pe '
if (/^\s*kBookmarks,\s*$/) {
    $_ .= "    '"$ENUM_ID"',  // BaseOne: '"$PANEL_DESC"'\n";
}
' "$ENTRY_FILE"

# Add Key method (find kBookmarks Key method and add after it)
perl -i -pe '
if (/^\s*static Key Bookmarks\(\) \{/) {
    my $line = $_;
    $line .= "      return Key(Id::kBookmarks);\n";
    $line .= "    }\n\n";
    $line .= "    static Key '"${PANEL_NAME}"'Mode() {\n";
    $line .= "      return Key(Id::'"$ENUM_ID"');\n";
    $_ = $line;
}
' "$ENTRY_FILE"

echo -e "${GREEN}✓${NC} Modified ${DIM}chrome/browser/ui/views/side_panel/side_panel_entry.h${NC}"

# 5. Add to webui_url_constants.h
echo ""
echo -e "${BOLD}Step 6: Adding URL constants...${NC}"

URL_CONST_FILE="$SRC_DIR/chrome/common/webui_url_constants.h"

# Add after kChromeUINewTabPageThirdPartyURL
perl -i -pe '
if (/kChromeUINewTabPageThirdPartyURL/) {
    $_ .= "inline constexpr char kChromeUI'"${CLASS_PREFIX}"'SidePanelHost[] = \"'"$URL_HOST"'\";\n";
    $_ .= "inline constexpr char kChromeUI'"${CLASS_PREFIX}"'SidePanelURL[] = \"chrome://'"$URL_HOST"'/\";\n";
}
' "$URL_CONST_FILE"

echo -e "${GREEN}✓${NC} Modified ${DIM}chrome/common/webui_url_constants.h${NC}"

# 6. Register WebUI controller
echo ""
echo -e "${BOLD}Step 7: Registering WebUI controller...${NC}"

FACTORY_FILE="$SRC_DIR/chrome/browser/ui/webui/chrome_web_ui_controller_factory.cc"

# Add include
perl -i -pe '
if (/#include "chrome\/browser\/ui\/webui\/side_panel\/reading_list\/reading_list_ui.h"/) {
    $_ .= "#include \"chrome/browser/ui/webui/side_panel/'"$DIR_NAME"'/'"${PANEL_LOWER}"'_ui.h\"\n";
}
' "$FACTORY_FILE"

# Add factory function
perl -i -pe '
if (/if \(url\.host_piece\(\) == chrome::kChromeUIHistoryURL\)/) {
    my $line = "  if (url.host_piece() == chrome::kChromeUI'"${CLASS_PREFIX}"'SidePanelHost) {\n";
    $line .= "    return &NewWebUI<'"${CLASS_PREFIX}"'UI>;\n";
    $line .= "  }\n\n";
    $_ = $line . $_;
}
' "$FACTORY_FILE"

echo -e "${GREEN}✓${NC} Modified ${DIM}chrome/browser/ui/webui/chrome_web_ui_controller_factory.cc${NC}"

# 7. Initialize in BrowserView
echo ""
echo -e "${BOLD}Step 8: Initializing in BrowserView...${NC}"

BROWSER_VIEW_FILE="$SRC_DIR/chrome/browser/ui/views/frame/browser_view.cc"

# Add include
perl -i -pe '
if (/#include "chrome\/browser\/ui\/views\/side_panel\/reading_list_side_panel_coordinator.h"/) {
    $_ .= "#include \"chrome/browser/ui/views/side_panel/'"$DIR_NAME"'_side_panel_coordinator.h\"\n";
}
' "$BROWSER_VIEW_FILE"

# Add initialization
perl -i -pe '
if (/reading_list_coordinator->CreateAndRegisterEntry/) {
    $_ .= "\n  // BaseOne: Initialize '"$PANEL_NAME"' Mode coordinator\n";
    $_ .= "  auto* ${PANEL_LOWER}_coordinator =\n";
    $_ .= "      '"${CLASS_PREFIX}"'SidePanelCoordinator::GetOrCreateForBrowser(browser_.get());\n";
    $_ .= "  ${PANEL_LOWER}_coordinator->CreateAndRegisterEntry(\n";
    $_ .= "      side_panel_coordinator_->GetGlobalSidePanelRegistry());\n";
}
' "$BROWSER_VIEW_FILE"

echo -e "${GREEN}✓${NC} Modified ${DIM}chrome/browser/ui/views/frame/browser_view.cc${NC}"

# 8. Stage all changes and create patch
echo ""
echo -e "${BOLD}Step 9: Creating patch file...${NC}"

git add -A

# Create patch
PATCH_DIR="$ROOT_DIR/patches/ungoogled-chromium"
mkdir -p "$PATCH_DIR"

git diff --cached > "$PATCH_DIR/$PATCH_FILE"

PATCH_SIZE=$(wc -l < "$PATCH_DIR/$PATCH_FILE" | tr -d ' ')
echo -e "${GREEN}✓${NC} Created patch: ${CYAN}$PATCH_FILE${NC} (${PATCH_SIZE} lines)"

# 9. Add to series file
echo ""
echo -e "${BOLD}Step 10: Adding to patch series...${NC}"

SERIES_FILE="$ROOT_DIR/ungoogled-chromium/patches/series"

if ! grep -q "^ungoogled-chromium/$PATCH_FILE\$" "$SERIES_FILE" 2>/dev/null; then
    echo "ungoogled-chromium/$PATCH_FILE" >> "$SERIES_FILE"
    echo -e "${GREEN}✓${NC} Added to ${DIM}ungoogled-chromium/patches/series${NC}"
else
    echo -e "${YELLOW}ℹ${NC}  Already in ${DIM}ungoogled-chromium/patches/series${NC}"
fi

# 10. Cleanup
echo ""
echo -e "${BOLD}Step 11: Cleaning up...${NC}"

cd "$SRC_DIR"
git checkout main 2>/dev/null || git checkout master 2>/dev/null || true
git branch -D "$BRANCH_NAME" 2>/dev/null || true

echo -e "${GREEN}✓${NC} Cleaned up git branch"

# Summary
echo ""
echo -e "${GREEN}${BOLD}✨ Side Panel Created Successfully!${NC}"
echo ""
echo -e "${BOLD}Generated Files:${NC}"
echo -e "  WebUI Backend:      ${CYAN}chrome/browser/ui/webui/side_panel/$DIR_NAME/${NC}"
echo -e "  Coordinator:        ${CYAN}chrome/browser/ui/views/side_panel/${DIR_NAME}_*${NC}"
echo -e "  Frontend Resources: ${CYAN}chrome/browser/resources/side_panel/$DIR_NAME/${NC}"
echo -e "  Patch File:         ${CYAN}patches/ungoogled-chromium/$PATCH_FILE${NC}"
echo ""
echo -e "${BOLD}Modified Files:${NC}"
echo -e "  - ${DIM}chrome/browser/ui/views/side_panel/side_panel_entry.h${NC}"
echo -e "  - ${DIM}chrome/common/webui_url_constants.h${NC}"
echo -e "  - ${DIM}chrome/browser/ui/webui/chrome_web_ui_controller_factory.cc${NC}"
echo -e "  - ${DIM}chrome/browser/ui/views/frame/browser_view.cc${NC}"
echo ""
echo -e "${BOLD}Next Steps:${NC}"
echo -e "  1. Review the patch: ${CYAN}cat patches/ungoogled-chromium/$PATCH_FILE${NC}"
echo -e "  2. Build with patch: ${CYAN}./build/build.sh -d${NC}"
echo -e "  3. Test your panel: ${CYAN}chrome://$URL_HOST/${NC}"
echo ""
echo -e "${BOLD}Customize Your Panel:${NC}"
echo -e "  Edit ${CYAN}chrome/browser/resources/side_panel/$DIR_NAME/${PANEL_LOWER}.ts${NC}"
echo -e "  Add logic in ${CYAN}chrome/browser/ui/webui/side_panel/$DIR_NAME/${PANEL_LOWER}_ui.cc${NC}"
echo ""
