# Creating Custom Side Panel in Base Browser (Ungoogled-Chromium)

## Overview

This guide shows how to add a custom side panel (Reading Mode example) to Base Browser using our patch-based workflow. Unlike standard Chromium development, we maintain all modifications as patches that apply cleanly to ungoogled-chromium source.

## Architecture

We use the `basedev_` prefix for all custom side panels to clearly distinguish them from Chromium's built-in panels.

```
base-core/
├── ungoogled-chromium/
│   ├── build/
│   │   └── src/                                    # Chromium source (patched)
│   │       └── chrome/browser/ui/
│   │           ├── views/side_panel/
│   │           │   └── basedev_*/                  # Our coordinators
│   │           └── webui/side_panel/
│   │               └── basedev_*/                  # Our WebUI implementations
│   └── patches/
│       ├── series                                  # Patch order
│       └── ungoogled-chromium/
│           └── basedev-*.patch                     # Our patches
├── patches/
│   └── ungoogled-chromium/
│       ├── base-branding-strings.patch             # Branding
│       └── basedev-sidepanel-reading.patch         # Custom side panels
└── guides/
    └── SIDEPANEL_BASE.md                           # This file
```

**Naming Convention**:
- Patch files: `basedev-sidepanel-{feature}.patch`
- Side panel ID: `kBaseOneReadingMode`
- WebUI directories: `basedev_{feature}/`
- URL host: `basedev-{feature}-side-panel`
- Coordinator class: `BaseOneReadingModeSidePanelCoordinator`

## Prerequisites

- Base Browser build environment set up
- Chromium source at: `/Volumes/External/BaseChrome/base-core/ungoogled-chromium/build/src`
- Understanding of unified diff patches
- Basic knowledge of Chromium architecture

## Implementation Steps

### 1. Define the Side Panel Entry

**What we're modifying**: `chrome/browser/ui/views/side_panel/side_panel_entry.h`

Create patch file: `/Volumes/External/BaseChrome/base-core/patches/ungoogled-chromium/basedev-sidepanel-reading.patch`

```diff
--- a/chrome/browser/ui/views/side_panel/side_panel_entry.h
+++ b/chrome/browser/ui/views/side_panel/side_panel_entry.h
@@ -42,6 +42,7 @@ class SidePanelEntry {
     kAssistant,
     kBookmarks,
     kHistoryClusters,
+    kBaseOneReadingMode,  // BaseOne: Custom reading mode panel
     kReadingList,
     kReadAnything,
     kSearchCompanion,
@@ -65,6 +66,10 @@ class SidePanelEntry {
     static Key HistoryClusters() {
       return Key(Id::kHistoryClusters);
     }
+
+    static Key BaseOneReadingMode() {
+      return Key(Id::kBaseOneReadingMode);
+    }

     static Key ReadingList() {
       return Key(Id::kReadingList);
```

### 2. Create WebUI Backend

**New files to create** (will be added via patch):

#### 2.1 Header File

Create: `chrome/browser/ui/webui/side_panel/basedev_reading/basedev_reading_ui.h`

```cpp
#ifndef CHROME_BROWSER_UI_WEBUI_SIDE_PANEL_BASEDEV_READING_BASEDEV_READING_UI_H_
#define CHROME_BROWSER_UI_WEBUI_SIDE_PANEL_BASEDEV_READING_BASEDEV_READING_UI_H_

#include "chrome/browser/ui/webui/side_panel/basedev_reading/basedev_reading.mojom.h"
#include "chrome/common/webui_url_constants.h"
#include "content/public/browser/web_ui_controller.h"
#include "mojo/public/cpp/bindings/pending_receiver.h"
#include "mojo/public/cpp/bindings/receiver.h"
#include "ui/webui/mojo_bubble_web_ui_controller.h"

class BaseOneReadingModeUI : public ui::MojoBubbleWebUIController,
                      public basedev_reading::mojom::PageHandler {
 public:
  explicit BaseOneReadingModeUI(content::WebUI* web_ui);
  ~BaseOneReadingModeUI() override;

  BaseOneReadingModeUI(const BaseOneReadingModeUI&) = delete;
  BaseOneReadingModeUI& operator=(const BaseOneReadingModeUI&) = delete;

  void BindInterface(
      mojo::PendingReceiver<basedev_reading::mojom::PageHandler> receiver);

  // basedev_reading::mojom::PageHandler:
  void ExtractContent(const GURL& url) override;
  void UpdateFontSize(int32_t size) override;
  void UpdateTheme(const std::string& theme) override;

 private:
  void OnContentExtracted(const std::string& title,
                         const std::string& content,
                         const std::string& author,
                         const std::string& date);

  mojo::Receiver<basedev_reading::mojom::PageHandler> receiver_{this};
  mojo::Remote<basedev_reading::mojom::Page> page_;

  base::WeakPtrFactory<BaseOneReadingModeUI> weak_factory_{this};

  WEB_UI_CONTROLLER_TYPE_DECL();
};

#endif  // CHROME_BROWSER_UI_WEBUI_SIDE_PANEL_BASEDEV_READING_BASEDEV_READING_UI_H_
```

#### 2.2 Implementation File

Create: `chrome/browser/ui/webui/side_panel/basedev_reading/basedev_reading_ui.cc`

```cpp
#include "chrome/browser/ui/webui/side_panel/basedev_reading/basedev_reading_ui.h"

#include "chrome/browser/profiles/profile.h"
#include "chrome/browser/ui/webui/webui_util.h"
#include "chrome/common/webui_url_constants.h"
#include "chrome/grit/generated_resources.h"
#include "chrome/grit/basedev_reading_resources.h"
#include "chrome/grit/basedev_reading_resources_map.h"
#include "content/public/browser/web_contents.h"
#include "content/public/browser/web_ui_data_source.h"

BaseOneReadingModeUI::BaseOneReadingModeUI(content::WebUI* web_ui)
    : ui::MojoBubbleWebUIController(web_ui) {
  content::WebUIDataSource* source = content::WebUIDataSource::CreateAndAdd(
      web_ui->GetWebContents()->GetBrowserContext(),
      chrome::kChromeUIReadingModeSidePanelHost);

  // Add localized strings
  source->AddLocalizedString("readingModeTitle", IDS_BASEDEV_READING_MODE_TITLE);
  source->AddLocalizedString("fontSizeLabel", IDS_BASEDEV_READING_MODE_FONT_SIZE);
  source->AddLocalizedString("themeLabel", IDS_BASEDEV_READING_MODE_THEME);

  // Set up resources
  webui::SetupWebUIDataSource(
      source,
      base::make_span(kBaseOneReadingModeResources, kBaseOneReadingModeResourcesSize),
      IDR_BASEDEV_READING_BASEDEV_READING_HTML);

  source->OverrideContentSecurityPolicy(
      network::mojom::CSPDirectiveName::TrustedTypes,
      "trusted-types static-types;");
}

BaseOneReadingModeUI::~BaseOneReadingModeUI() = default;

WEB_UI_CONTROLLER_TYPE_IMPL(BaseOneReadingModeUI)

void BaseOneReadingModeUI::BindInterface(
    mojo::PendingReceiver<basedev_reading::mojom::PageHandler> receiver) {
  receiver_.reset();
  receiver_.Bind(std::move(receiver));
}

void BaseOneReadingModeUI::ExtractContent(const GURL& url) {
  // Content extraction logic
  OnContentExtracted("Sample Title", "<p>Sample content</p>", "Author", "Date");
}

void BaseOneReadingModeUI::OnContentExtracted(const std::string& title,
                                       const std::string& content,
                                       const std::string& author,
                                       const std::string& date) {
  if (page_) {
    page_->OnContentExtracted(title, content, author, date);
  }
}

void BaseOneReadingModeUI::UpdateFontSize(int32_t size) {
  Profile* profile = Profile::FromWebUI(web_ui());
  profile->GetPrefs()->SetInteger("reading_mode.font_size", size);
}

void BaseOneReadingModeUI::UpdateTheme(const std::string& theme) {
  Profile* profile = Profile::FromWebUI(web_ui());
  profile->GetPrefs()->SetString("reading_mode.theme", theme);
}
```

### 3. Create Mojom Interface

**New file**: `chrome/browser/ui/webui/side_panel/basedev_reading/basedev_reading.mojom`

```mojom
module basedev_reading.mojom;

import "url/mojom/url.mojom";

// Browser-side handler for requests from Reading Mode page
interface PageHandler {
  ExtractContent(url.mojom.Url url);
  UpdateFontSize(int32 size);
  UpdateTheme(string theme);
};

// Renderer-side handler for responses from browser
interface Page {
  OnContentExtracted(string title, string content, string author, string date);
  OnReadingStatsUpdated(int32 words_read, int32 time_spent);
};
```

### 4. Create Side Panel Coordinator

**New files**:

#### 4.1 Header

Create: `chrome/browser/ui/views/side_panel/reading_mode_side_panel_coordinator.h`

```cpp
#ifndef CHROME_BROWSER_UI_VIEWS_SIDE_PANEL_BASEDEV_READING_SIDE_PANEL_COORDINATOR_H_
#define CHROME_BROWSER_UI_VIEWS_SIDE_PANEL_BASEDEV_READING_SIDE_PANEL_COORDINATOR_H_

#include <memory>
#include "base/memory/raw_ptr.h"
#include "chrome/browser/ui/browser_user_data.h"

class Browser;
class SidePanelRegistry;

class BaseOneReadingModeSidePanelCoordinator
    : public BrowserUserData<BaseOneReadingModeSidePanelCoordinator> {
 public:
  explicit BaseOneReadingModeSidePanelCoordinator(Browser* browser);
  ~BaseOneReadingModeSidePanelCoordinator() override;

  void CreateAndRegisterEntry(SidePanelRegistry* global_registry);
  void Toggle();
  bool IsAvailable() const;

 private:
  friend class BrowserUserData<BaseOneReadingModeSidePanelCoordinator>;

  std::unique_ptr<views::View> CreateReadingModeWebView();

  raw_ptr<Browser> browser_;

  BROWSER_USER_DATA_KEY_DECL();
};

#endif
```

#### 4.2 Implementation

Create: `chrome/browser/ui/views/side_panel/reading_mode_side_panel_coordinator.cc`

```cpp
#include "chrome/browser/ui/views/side_panel/reading_mode_side_panel_coordinator.h"

#include "chrome/app/vector_icons/vector_icons.h"
#include "chrome/browser/ui/browser.h"
#include "chrome/browser/ui/views/frame/browser_view.h"
#include "chrome/browser/ui/views/side_panel/side_panel_coordinator.h"
#include "chrome/browser/ui/views/side_panel/side_panel_entry.h"
#include "chrome/browser/ui/views/side_panel/side_panel_web_ui_view.h"
#include "chrome/browser/ui/webui/side_panel/basedev_reading/basedev_reading_ui.h"
#include "chrome/common/webui_url_constants.h"
#include "chrome/grit/generated_resources.h"
#include "ui/base/l10n/l10n_util.h"

BaseOneReadingModeSidePanelCoordinator::BaseOneReadingModeSidePanelCoordinator(
    Browser* browser)
    : browser_(browser) {}

BaseOneReadingModeSidePanelCoordinator::~BaseOneReadingModeSidePanelCoordinator() = default;

BROWSER_USER_DATA_KEY_IMPL(BaseOneReadingModeSidePanelCoordinator)

void BaseOneReadingModeSidePanelCoordinator::CreateAndRegisterEntry(
    SidePanelRegistry* global_registry) {
  global_registry->Register(std::make_unique<SidePanelEntry>(
      SidePanelEntry::Id::kBaseOneReadingMode,
      l10n_util::GetStringUTF16(IDS_BASEDEV_READING_MODE_TITLE),
      ui::ImageModel::FromVectorIcon(kBaseOneReadingModeIcon, ui::kColorIcon),
      base::BindRepeating(
          &BaseOneReadingModeSidePanelCoordinator::CreateReadingModeWebView,
          base::Unretained(this))));
}

std::unique_ptr<views::View>
BaseOneReadingModeSidePanelCoordinator::CreateReadingModeWebView() {
  auto web_view = std::make_unique<SidePanelWebUIViewT<BaseOneReadingModeUI>>(
      base::RepeatingClosure(), base::RepeatingClosure(),
      std::make_unique<BubbleContentsWrapperT<BaseOneReadingModeUI>>(
          GURL(chrome::kChromeUIReadingModeSidePanelURL),
          browser_->profile(),
          IDS_BASEDEV_READING_MODE_TITLE));

  web_view->SetPreferredSize(gfx::Size(320, 400));
  return web_view;
}

void BaseOneReadingModeSidePanelCoordinator::Toggle() {
  auto* browser_view = BrowserView::GetBrowserViewForBrowser(browser_);
  if (!browser_view) return;

  auto* coordinator = browser_view->side_panel_coordinator();
  if (!coordinator) return;

  if (coordinator->GetCurrentEntryId() == SidePanelEntry::Id::kBaseOneReadingMode) {
    coordinator->Close();
  } else {
    coordinator->Show(SidePanelEntry::Id::kBaseOneReadingMode);
  }
}

bool BaseOneReadingModeSidePanelCoordinator::IsAvailable() const {
  content::WebContents* contents =
      browser_->tab_strip_model()->GetActiveWebContents();
  if (!contents) return false;

  return contents->GetURL().SchemeIsHTTPOrHTTPS();
}
```

### 5. Create Frontend Resources

**Directory structure**:
```
chrome/browser/resources/side_panel/basedev_reading/
├── basedev_reading.html
├── basedev_reading.css
├── basedev_reading.ts
└── BUILD.gn
```

#### 5.1 HTML

Create: `chrome/browser/resources/side_panel/basedev_reading/basedev_reading.html`

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <link rel="stylesheet" href="chrome://resources/css/text_defaults.css">
  <link rel="stylesheet" href="basedev_reading.css">
</head>
<body>
  <div id="container">
    <div id="header">
      <h1 id="title">Reading Mode</h1>
      <button id="settings-button" aria-label="Settings">⚙️</button>
    </div>

    <div id="settings-panel" hidden>
      <div class="setting-row">
        <label for="font-size">Font Size</label>
        <input type="range" id="font-size" min="12" max="24" value="16">
        <span id="font-size-value">16px</span>
      </div>

      <div class="setting-row">
        <label for="theme">Theme</label>
        <select id="theme">
          <option value="light">Light</option>
          <option value="dark">Dark</option>
          <option value="sepia">Sepia</option>
        </select>
      </div>
    </div>

    <div id="content-container">
      <div id="loading" hidden>
        <div class="spinner"></div>
        <p>Extracting content...</p>
      </div>

      <article id="article-content">
        <header id="article-header">
          <h1 id="article-title"></h1>
          <div id="article-meta">
            <span id="article-author"></span>
            <span id="article-date"></span>
          </div>
        </header>
        <div id="article-body"></div>
      </article>
    </div>
  </div>

  <script type="module" src="basedev_reading.js"></script>
</body>
</html>
```

#### 5.2 CSS

Create: `chrome/browser/resources/side_panel/basedev_reading/basedev_reading.css`

```css
body {
  margin: 0;
  padding: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}

#container {
  display: flex;
  flex-direction: column;
  height: 100vh;
}

#header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-bottom: 1px solid #e0e0e0;
}

#settings-panel {
  padding: 16px;
  background: #f5f5f5;
  border-bottom: 1px solid #e0e0e0;
}

.setting-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

#content-container {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
}

#article-content {
  max-width: 680px;
  margin: 0 auto;
}

#article-title {
  font-size: 32px;
  font-weight: 700;
  margin-bottom: 16px;
}

#article-meta {
  display: flex;
  gap: 16px;
  color: #666;
  margin-bottom: 24px;
}

#article-body {
  font-size: 16px;
  line-height: 1.6;
}

/* Themes */
body.theme-dark {
  background: #1a1a1a;
  color: #e0e0e0;
}

body.theme-sepia {
  background: #f4ecd8;
  color: #5b4636;
}

.spinner {
  border: 3px solid #f3f3f3;
  border-top: 3px solid #3498db;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin: 0 auto;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
```

#### 5.3 TypeScript

Create: `chrome/browser/resources/side_panel/basedev_reading/basedev_reading.ts`

```typescript
import {PageHandlerRemote, Page} from './basedev_reading.mojom-webui.js';

class ReadingModeApp implements Page {
  private handler: PageHandlerRemote;

  constructor() {
    this.handler = PageHandlerRemote.getRemote();
    this.initializeEventListeners();
    this.loadContent();
  }

  private initializeEventListeners(): void {
    const settingsBtn = document.getElementById('settings-button');
    settingsBtn?.addEventListener('click', () => this.toggleSettings());

    const fontSizeInput = document.getElementById('font-size') as HTMLInputElement;
    fontSizeInput?.addEventListener('input', (e) => {
      const size = parseInt((e.target as HTMLInputElement).value);
      this.updateFontSize(size);
    });

    const themeSelect = document.getElementById('theme') as HTMLSelectElement;
    themeSelect?.addEventListener('change', (e) => {
      const theme = (e.target as HTMLSelectElement).value;
      this.updateTheme(theme);
    });
  }

  private toggleSettings(): void {
    const panel = document.getElementById('settings-panel');
    if (panel) {
      panel.hidden = !panel.hidden;
    }
  }

  private loadContent(): void {
    const loading = document.getElementById('loading');
    if (loading) loading.hidden = false;

    // Request content from current tab
    const url = new URL(window.location.href);
    this.handler.extractContent({url: url.toString()});
  }

  // Implement Page interface
  onContentExtracted(title: string, content: string,
                    author: string, date: string): void {
    const loading = document.getElementById('loading');
    if (loading) loading.hidden = true;

    const titleEl = document.getElementById('article-title');
    if (titleEl) titleEl.textContent = title;

    const bodyEl = document.getElementById('article-body');
    if (bodyEl) bodyEl.innerHTML = content;

    if (author) {
      const authorEl = document.getElementById('article-author');
      if (authorEl) authorEl.textContent = `By ${author}`;
    }

    if (date) {
      const dateEl = document.getElementById('article-date');
      if (dateEl) dateEl.textContent = date;
    }
  }

  onReadingStatsUpdated(wordsRead: number, timeSpent: number): void {
    // Update stats if needed
  }

  private updateFontSize(size: number): void {
    const body = document.getElementById('article-body');
    if (body) body.style.fontSize = `${size}px`;

    const valueEl = document.getElementById('font-size-value');
    if (valueEl) valueEl.textContent = `${size}px`;

    this.handler.updateFontSize(size);
  }

  private updateTheme(theme: string): void {
    document.body.className = `theme-${theme}`;
    this.handler.updateTheme(theme);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  new ReadingModeApp();
});
```

### 6. Build Configuration

Create: `chrome/browser/resources/side_panel/basedev_reading/BUILD.gn`

```gn
import("//chrome/common/features.gni")
import("//mojo/public/tools/bindings/mojom.gni")
import("//tools/grit/grit_rule.gni")
import("//tools/typescript/ts_library.gni")
import("//ui/webui/resources/tools/generate_grd.gni")

mojom("mojo_bindings") {
  sources = [ "basedev_reading.mojom" ]

  public_deps = [
    "//mojo/public/mojom/base",
    "//url/mojom:url_mojom_gurl",
  ]

  webui_module_path = "chrome://basedev-reading-side-panel/"
}

ts_library("build_ts") {
  root_dir = "."
  out_dir = "$target_gen_dir/tsc"

  in_files = [ "basedev_reading.ts" ]

  deps = [
    "//ui/webui/resources/js:build_ts",
  ]

  extra_deps = [ ":copy_mojo" ]
}

generate_grd("build_grd") {
  input_files = [
    "basedev_reading.html",
    "basedev_reading.css",
  ]

  input_files_base_dir = rebase_path(".", "//")
  deps = [ ":build_ts" ]
  manifest_files = [ "$target_gen_dir/tsconfig.manifest" ]

  grd_prefix = "reading_mode"
  out_grd = "$target_gen_dir/${grd_prefix}_resources.grd"
  resource_path_prefix = "side_panel/reading_mode"
}

grit("resources") {
  enable_input_discovery_for_gn_analyze = false
  source = "$target_gen_dir/basedev_reading_resources.grd"
  deps = [ ":build_grd" ]

  outputs = [
    "grit/basedev_reading_resources.h",
    "grit/basedev_reading_resources_map.cc",
    "grit/basedev_reading_resources_map.h",
    "basedev_reading_resources.pak",
  ]

  output_dir = "$root_gen_dir/chrome"
}
```

### 7. Register URL Constants

**Patch**: `chrome/common/webui_url_constants.h`

```diff
--- a/chrome/common/webui_url_constants.h
+++ b/chrome/common/webui_url_constants.h
@@ -200,6 +200,8 @@ inline constexpr char kChromeUIHistoryURL[] = "chrome://history/";
 inline constexpr char kChromeUINewTabURL[] = "chrome://newtab/";
 inline constexpr char kChromeUINewTabPageURL[] = "chrome://new-tab-page/";
 inline constexpr char kChromeUINewTabPageThirdPartyURL[] = "chrome://new-tab-page-third-party/";
+inline constexpr char kChromeUIReadingModeSidePanelHost[] = "basedev-reading-side-panel";
+inline constexpr char kChromeUIReadingModeSidePanelURL[] = "chrome://basedev-reading-side-panel/";
 inline constexpr char kChromeUIPasswordManagerURL[] = "chrome://password-manager/";
```

### 8. Register WebUI Controller

**Patch**: `chrome/browser/ui/webui/chrome_web_ui_controller_factory.cc`

```diff
--- a/chrome/browser/ui/webui/chrome_web_ui_controller_factory.cc
+++ b/chrome/browser/ui/webui/chrome_web_ui_controller_factory.cc
@@ -50,6 +50,7 @@
 #include "chrome/browser/ui/webui/side_panel/bookmarks/bookmarks_side_panel_ui.h"
 #include "chrome/browser/ui/webui/side_panel/history_clusters/history_clusters_side_panel_ui.h"
 #include "chrome/browser/ui/webui/side_panel/reading_list/reading_list_ui.h"
+#include "chrome/browser/ui/webui/side_panel/basedev_reading/basedev_reading_ui.h"

@@ -300,6 +301,10 @@ WebUIFactoryFunction GetWebUIFactoryFunction(WebUI* web_ui,
     return &NewWebUI<ReadingListUI>;
   }

+  if (url.host_piece() == chrome::kChromeUIReadingModeSidePanelHost) {
+    return &NewWebUI<BaseOneReadingModeUI>;
+  }
+
   if (url.host_piece() == chrome::kChromeUIHistoryURL) {
     return &NewWebUI<HistoryUI>;
   }
```

### 9. Initialize in BrowserView

**Patch**: `chrome/browser/ui/views/frame/browser_view.cc`

```diff
--- a/chrome/browser/ui/views/frame/browser_view.cc
+++ b/chrome/browser/ui/views/frame/browser_view.cc
@@ -100,6 +100,7 @@
 #include "chrome/browser/ui/views/side_panel/bookmarks/bookmarks_side_panel_coordinator.h"
 #include "chrome/browser/ui/views/side_panel/history_clusters/history_clusters_side_panel_coordinator.h"
 #include "chrome/browser/ui/views/side_panel/reading_list_side_panel_coordinator.h"
+#include "chrome/browser/ui/views/side_panel/reading_mode_side_panel_coordinator.h"

@@ -2500,6 +2501,11 @@ void BrowserView::InitSidePanelCoordinator() {
   reading_list_coordinator->CreateAndRegisterEntry(
       side_panel_coordinator_->GetGlobalSidePanelRegistry());

+  // Initialize Reading Mode coordinator
+  auto* reading_mode_coordinator =
+      BaseOneReadingModeSidePanelCoordinator::GetOrCreateForBrowser(browser_.get());
+  reading_mode_coordinator->CreateAndRegisterEntry(
+      side_panel_coordinator_->GetGlobalSidePanelRegistry());
 }
```

## Creating the Patch

### Method 1: Manual Patch Creation

1. Make all changes in the source tree at `/Volumes/External/BaseChrome/base-core/ungoogled-chromium/build/src`
2. Generate the patch:

```bash
cd /Volumes/External/BaseChrome/base-core/ungoogled-chromium/build/src

# Create patch from git changes
git diff > /Volumes/External/BaseChrome/base-core/patches/ungoogled-chromium/base-sidepanel-reading.patch
```

### Method 2: Incremental Development

1. Create feature branch:

```bash
cd /Volumes/External/BaseChrome/base-core/ungoogled-chromium/build/src
git checkout -b feature/reading-mode
```

2. Make changes and commit:

```bash
# Add new files
git add chrome/browser/ui/webui/side_panel/basedev_reading/
git add chrome/browser/ui/views/side_panel/reading_mode_side_panel_coordinator.*

# Create commit
git commit -m "Add Reading Mode side panel"
```

3. Generate patch from commit:

```bash
git format-patch -1 HEAD --stdout > \
  /Volumes/External/BaseChrome/base-core/patches/ungoogled-chromium/base-sidepanel-reading.patch
```

4. Clean up:

```bash
git checkout main
git branch -D feature/reading-mode
```

## Adding Patch to Build

1. Add to series file:

```bash
echo "ungoogled-chromium/base-sidepanel-reading.patch" >> \
  /Volumes/External/BaseChrome/base-core/ungoogled-chromium/patches/series
```

2. Verify series file:

```
ungoogled-chromium/macos/build-bindgen.patch
ungoogled-chromium/macos/disable-clang-version-check.patch
...
ungoogled-chromium/disable-rust-version-check.patch
ungoogled-chromium/base-branding-strings.patch
ungoogled-chromium/base-sidepanel-reading.patch
```

## Building with New Patch

```bash
cd /Volumes/External/BaseChrome/base-core

# Clean build (if needed)
rm -rf ungoogled-chromium/build/src
mkdir ungoogled-chromium/build/src

# Build with patches
./build/build.sh -d 2>&1 | tee /tmp/reading_mode_build.log
```

## Testing

After build completes:

```bash
# Launch Base Browser
open ungoogled-chromium/build/src/out/Default/Chromium.app

# In browser:
# 1. Navigate to any article page
# 2. Click side panel icon or use keyboard shortcut
# 3. Select "Reading Mode"
# 4. Verify content extraction works
# 5. Test font size/theme controls
```

## Troubleshooting

### Patch Fails to Apply

```bash
# Check which file failed
grep "FAILED" /tmp/reading_mode_build.log

# Manually apply to see errors
cd ungoogled-chromium/build/src
patch -p1 --dry-run < ../../patches/ungoogled-chromium/base-sidepanel-reading.patch
```

### Build Errors

```bash
# Check for missing dependencies in BUILD.gn
# Verify all includes are correct
# Check resource registration in chrome_resources.grd
```

### WebUI Not Loading

1. Check URL constants are registered
2. Verify WebUI factory function returns correct type
3. Check content security policy settings
4. Look for console errors in DevTools

## Project Structure Reference

```
base-core/
├── ungoogled-chromium/
│   ├── build/
│   │   └── src/                                    # Source tree
│   │       └── chrome/
│   │           ├── browser/
│   │           │   ├── ui/
│   │           │   │   ├── views/side_panel/
│   │           │   │   │   ├── reading_mode_side_panel_coordinator.*
│   │           │   │   │   └── side_panel_entry.h  (modified)
│   │           │   │   └── webui/side_panel/
│   │           │   │       └── basedev_reading/
│   │           │   │           ├── basedev_reading.mojom
│   │           │   │           ├── basedev_reading_ui.*
│   │           │   │           └── BUILD.gn
│   │           │   └── resources/side_panel/
│   │           │       └── basedev_reading/
│   │           │           ├── basedev_reading.html
│   │           │           ├── basedev_reading.css
│   │           │           ├── basedev_reading.ts
│   │           │           └── BUILD.gn
│   │           └── common/
│   │               └── webui_url_constants.h       (modified)
│   └── patches/
│       ├── series                                  # Patch order
│       └── ungoogled-chromium/
│           └── base-sidepanel-reading.patch        # Our patch
└── patches/
    └── ungoogled-chromium/
        └── base-sidepanel-reading.patch            # Copy of patch
```

## Key Differences from Standard Chromium Development

1. **No Direct Edits**: Never edit source files directly in production. Always work through patches.

2. **Patch-Based Workflow**: All changes must be expressible as unified diff patches.

3. **Clean Source Tree**: The source tree at `ungoogled-chromium/build/src` should always be clean (git status shows nothing after patches apply).

4. **Build System**: Use `./build/build.sh` wrapper, not direct `autoninja` commands.

5. **Resource Paths**: All resources must be properly registered in BUILD.gn files and resource maps.

## Next Steps

1. Start with simple side panel (no content extraction)
2. Test basic UI rendering
3. Add Mojo communication
4. Implement content extraction
5. Add user preferences
6. Create comprehensive tests

## See Also

**Base Browser Development:**
- [BASEDEV_NAMING.md](./BASEDEV_NAMING.md) - Naming conventions for all custom features
- [tools/README.md](../tools/README.md) - Side panel generator documentation
- [MAP.md](../MAP.md) - Repository structure

**Chromium Documentation:**
- [Chromium Side Panel Documentation](https://chromium.googlesource.com/chromium/src/+/main/docs/ui/views/side_panel.md)
- [WebUI Best Practices](https://chromium.googlesource.com/chromium/src/+/main/docs/webui_explainer.md)
- [Mojo Documentation](https://chromium.googlesource.com/chromium/src/+/main/mojo/README.md)

## Quick Start

For automated side panel generation, use:
```bash
./tools/sidepanel.sh <PanelName> ["description"]
```

This guide provides the detailed reference for understanding what the generator creates and how to customize it.
