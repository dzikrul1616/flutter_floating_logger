const String kWebInspectorHtml = r'''<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Floating Logger - Realtime Web Inspector</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    :root, [data-theme="dark"] {
      --bg-base: #080d16;
      --bg-surface: #0f172a;
      --bg-card: #131c2e;
      --bg-card-hover: #1e293b;
      --border-color: #243048;
      --border-subtle: #182235;
      --text-primary: #f8fafc;
      --text-secondary: #94a3b8;
      --text-muted: #64748b;
      --accent-blue: #38bdf8;
      --accent-indigo: #6366f1;
      --scrollbar-thumb: #334155;
      --scrollbar-thumb-hover: #475569;
      --modal-overlay: rgba(0, 0, 0, 0.7);

      /* Method Colors */
      --color-get: #10b981;
      --color-post: #eab308;
      --color-put: #3b82f6;
      --color-patch: #8b5cf6;
      --color-delete: #ef4444;
      --color-options: #0d9488;

      /* JSON Syntax Highlighting */
      --json-key: #38bdf8;
      --json-string: #34d399;
      --json-number: #fbbf24;
      --json-boolean: #c084fc;
      --json-null: #94a3b8;
    }

    [data-theme="light"] {
      --bg-base: #f1f5f9;
      --bg-surface: #ffffff;
      --bg-card: #ffffff;
      --bg-card-hover: #f8fafc;
      --border-color: #cbd5e1;
      --border-subtle: #e2e8f0;
      --text-primary: #0f172a;
      --text-secondary: #475569;
      --text-muted: #94a3b8;
      --accent-blue: #0284c7;
      --accent-indigo: #4f46e5;
      --scrollbar-thumb: #cbd5e1;
      --scrollbar-thumb-hover: #94a3b8;
      --modal-overlay: rgba(15, 23, 42, 0.4);

      /* Method Colors */
      --color-get: #16a34a;
      --color-post: #ca8a04;
      --color-put: #2563eb;
      --color-patch: #7c3aed;
      --color-delete: #dc2626;
      --color-options: #0f766e;

      /* JSON Syntax Highlighting */
      --json-key: #0284c7;
      --json-string: #16a34a;
      --json-number: #d97706;
      --json-boolean: #9333ea;
      --json-null: #64748b;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    /* Custom Sleek Scrollbars */
    ::-webkit-scrollbar {
      width: 6px;
      height: 6px;
    }
    ::-webkit-scrollbar-track {
      background: transparent;
    }
    ::-webkit-scrollbar-thumb {
      background: var(--scrollbar-thumb);
      border-radius: 9999px;
    }
    ::-webkit-scrollbar-thumb:hover {
      background: var(--scrollbar-thumb-hover);
    }

    body {
      background-color: var(--bg-base);
      color: var(--text-primary);
      font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
      height: 100vh;
      overflow: hidden;
      display: flex;
      flex-direction: column;
      transition: background-color 0.2s ease, color 0.2s ease;
    }

    /* Top Navbar */
    header {
      height: 56px;
      background: var(--bg-surface);
      border-bottom: 1px solid var(--border-color);
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 16px;
      position: relative;
      z-index: 500;
    }

    .brand {
      display: flex;
      align-items: center;
      gap: 10px;
      font-weight: 700;
      font-size: 15px;
      letter-spacing: -0.01em;
    }

    .brand-icon {
      width: 30px;
      height: 30px;
      background: linear-gradient(135deg, #0284c7, #6366f1);
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-family: 'JetBrains Mono', monospace;
      font-size: 13px;
      font-weight: 700;
      color: #fff;
      box-shadow: 0 2px 8px rgba(2, 132, 199, 0.25);
    }

    .brand-title {
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .brand-subtitle {
      font-size: 11px;
      font-weight: 600;
      color: var(--text-muted);
      background: var(--border-subtle);
      padding: 2px 8px;
      border-radius: 6px;
      border: 1px solid var(--border-color);
    }

    .device-badge {
      display: none;
      align-items: center;
      gap: 6px;
      font-size: 11px;
      font-weight: 600;
      padding: 4px 10px;
      border-radius: 6px;
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      color: var(--text-secondary);
      user-select: none;
    }

    .header-actions {
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .status-badge {
      display: flex;
      align-items: center;
      gap: 6px;
      font-size: 11px;
      font-weight: 700;
      letter-spacing: 0.05em;
      padding: 4px 10px;
      border-radius: 9999px;
      background: rgba(16, 185, 129, 0.12);
      color: #10b981;
      border: 1px solid rgba(16, 185, 129, 0.3);
    }

    .status-dot {
      width: 7px;
      height: 7px;
      border-radius: 50%;
      background: #10b981;
      box-shadow: 0 0 8px #10b981;
      animation: pulse 2s infinite;
    }

    .status-badge.offline {
      background: rgba(239, 68, 68, 0.12);
      color: #ef4444;
      border-color: rgba(239, 68, 68, 0.3);
    }

    .status-badge.offline .status-dot {
      background: #ef4444;
      box-shadow: none;
      animation: none;
    }

    @keyframes pulse {
      0%, 100% { opacity: 1; transform: scale(1); }
      50% { opacity: 0.4; transform: scale(0.85); }
    }

    .btn {
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      color: var(--text-primary);
      padding: 6px 12px;
      border-radius: 8px;
      font-size: 12px;
      font-weight: 600;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 6px;
      transition: all 0.15s ease;
      user-select: none;
      position: relative;
    }

    .btn:hover {
      background: var(--bg-card-hover);
      border-color: var(--text-muted);
    }

    .btn-primary {
      background: var(--accent-indigo);
      border-color: var(--accent-indigo);
      color: #fff;
    }

    .btn-primary:hover {
      background: #4f46e5;
      border-color: #4f46e5;
    }

    .btn-danger:hover {
      background: rgba(239, 68, 68, 0.12);
      border-color: #ef4444;
      color: #ef4444;
    }

    .btn-icon {
      padding: 6px 10px;
      font-size: 14px;
    }

    /* Main Container */
    .main-container {
      display: flex;
      flex: 1;
      height: calc(100vh - 56px);
      overflow: hidden;
    }

    /* Sidebar (Logs List) */
    .sidebar {
      width: 460px;
      min-width: 340px;
      background: var(--bg-surface);
      border-right: 1px solid var(--border-color);
      display: flex;
      flex-direction: column;
    }

    .sidebar-toolbar {
      padding: 12px 14px;
      border-bottom: 1px solid var(--border-color);
      display: flex;
      flex-direction: column;
      gap: 10px;
    }

    .search-box {
      position: relative;
    }

    .search-input {
      width: 100%;
      background: var(--bg-base);
      border: 1px solid var(--border-color);
      border-radius: 8px;
      padding: 8px 12px 8px 34px;
      color: var(--text-primary);
      font-size: 13px;
      outline: none;
      transition: all 0.15s ease;
    }

    .search-input:focus {
      border-color: var(--accent-blue);
      box-shadow: 0 0 0 2px rgba(56, 189, 248, 0.15);
    }

    .search-icon {
      position: absolute;
      left: 11px;
      top: 50%;
      transform: translateY(-50%);
      color: var(--text-muted);
      font-size: 14px;
      pointer-events: none;
    }

    /* Filter Chips (No scrollbar visible, smooth horizontal scroll) */
    .filter-chips {
      display: flex;
      gap: 6px;
      overflow-x: auto;
      scrollbar-width: none;
      -ms-overflow-style: none;
      padding-bottom: 2px;
    }

    .filter-chips::-webkit-scrollbar {
      display: none;
    }

    .chip {
      background: var(--bg-base);
      border: 1px solid var(--border-color);
      padding: 4px 10px;
      border-radius: 6px;
      font-size: 11px;
      font-weight: 700;
      letter-spacing: 0.03em;
      color: var(--text-secondary);
      cursor: pointer;
      user-select: none;
      white-space: nowrap;
      transition: all 0.15s ease;
    }

    .chip:hover {
      border-color: var(--text-muted);
      color: var(--text-primary);
    }

    .chip.active {
      background: rgba(56, 189, 248, 0.15);
      border-color: var(--accent-blue);
      color: var(--accent-blue);
    }

    .logs-list {
      flex: 1;
      overflow-y: auto;
      padding: 8px 12px;
    }

    /* Log Item (Card matching Floating Logger in Flutter app) */
    .log-item {
      padding: 12px 14px;
      border-radius: 12px;
      margin-bottom: 8px;
      cursor: pointer;
      border: 1px solid var(--border-color);
      background: var(--bg-card);
      transition: all 0.12s ease;
      display: flex;
      flex-direction: column;
      gap: 8px;
      position: relative;
    }

    .log-item:hover {
      background: var(--bg-card-hover);
      border-color: var(--text-muted);
    }

    .log-item.selected {
      background: rgba(56, 189, 248, 0.08);
      border-color: var(--accent-blue);
      box-shadow: 0 0 10px rgba(56, 189, 248, 0.12);
    }

    .log-item.is-simulation {
      border-left: 3.5px solid #a855f7;
    }

    .log-item-top {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 8px;
    }

    .log-item-left {
      display: flex;
      align-items: center;
      gap: 6px;
      flex-wrap: wrap;
    }

    .log-index {
      font-size: 12px;
      font-weight: 700;
      color: var(--text-muted);
      min-width: 16px;
    }

    /* Pill Badges exactly like Floating Logger app */
    .badge-pill {
      font-family: 'Plus Jakarta Sans', sans-serif;
      font-size: 10px;
      font-weight: 700;
      padding: 2.5px 8px;
      border-radius: 6px;
      letter-spacing: 0.04em;
      text-transform: uppercase;
      color: #ffffff;
      display: inline-flex;
      align-items: center;
      gap: 3px;
      white-space: nowrap;
    }

    .bg-get { background: #10b981; }
    .bg-post { background: #eab308; }
    .bg-put { background: #3b82f6; }
    .bg-patch { background: #8b5cf6; }
    .bg-delete { background: #ef4444; }
    .bg-options { background: #0d9488; }

    .bg-req { background: #64748b; }
    .bg-res { background: #2563eb; }
    .bg-err { background: #dc2626; }
    .bg-success { background: #16a34a; }
    .bg-sim { background: #7c3aed; }
    .bg-bin { background: #0891b2; }

    .badge-info-pill {
      font-family: 'JetBrains Mono', monospace;
      font-size: 10px;
      font-weight: 600;
      padding: 2px 6px;
      border-radius: 5px;
      background: var(--bg-base);
      color: var(--text-secondary);
      border: 1px solid var(--border-color);
    }

    .log-path {
      font-family: 'JetBrains Mono', monospace;
      font-size: 12px;
      font-weight: 600;
      color: var(--text-primary);
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      line-height: 1.4;
    }

    /* Detail View */
    .detail-view {
      flex: 1;
      display: flex;
      flex-direction: column;
      background: var(--bg-base);
      overflow: hidden;
    }

    .detail-empty {
      flex: 1;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      color: var(--text-muted);
      gap: 12px;
      font-size: 14px;
    }

    .detail-header {
      padding: 14px 20px;
      background: var(--bg-surface);
      border-bottom: 1px solid var(--border-color);
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
    }

    .detail-url-container {
      display: flex;
      align-items: center;
      gap: 8px;
      flex: 1;
      overflow: hidden;
      flex-wrap: nowrap;
    }

    .detail-url {
      font-family: 'JetBrains Mono', monospace;
      font-size: 13px;
      font-weight: 600;
      color: var(--text-primary);
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .detail-tabs {
      display: flex;
      background: var(--bg-surface);
      border-bottom: 1px solid var(--border-color);
      padding: 0 20px;
      gap: 4px;
    }

    .tab-btn {
      background: none;
      border: none;
      border-bottom: 2px solid transparent;
      color: var(--text-secondary);
      font-size: 13px;
      font-weight: 600;
      padding: 10px 16px;
      cursor: pointer;
      transition: all 0.15s ease;
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .tab-btn:hover {
      color: var(--text-primary);
    }

    .tab-btn.active {
      color: var(--accent-blue);
      border-bottom-color: var(--accent-blue);
    }

    .detail-content {
      flex: 1;
      overflow-y: auto;
      padding: 20px;
    }

    /* Simulation Alert Banner */
    .sim-alert {
      background: rgba(168, 85, 247, 0.12);
      border: 1px solid rgba(168, 85, 247, 0.3);
      border-radius: 8px;
      padding: 12px 16px;
      margin-bottom: 16px;
      display: flex;
      align-items: flex-start;
      gap: 10px;
      color: #c084fc;
      font-size: 13px;
    }

    .code-container {
      background: var(--bg-surface);
      border: 1px solid var(--border-color);
      border-radius: 10px;
      overflow: hidden;
      margin-bottom: 16px;
    }

    .code-header {
      padding: 10px 14px;
      background: var(--bg-card);
      border-bottom: 1px solid var(--border-color);
      display: flex;
      align-items: center;
      justify-content: space-between;
      font-size: 12px;
      font-weight: 700;
      color: var(--text-secondary);
    }

    .code-body {
      padding: 14px;
      font-family: 'JetBrains Mono', monospace;
      font-size: 12px;
      line-height: 1.6;
      color: var(--text-primary);
      overflow-x: auto;
      white-space: pre-wrap;
      word-break: break-all;
    }

    /* JSON Syntax Colors */
    .json-key { color: var(--json-key); font-weight: 600; }
    .json-string { color: var(--json-string); }
    .json-number { color: var(--json-number); }
    .json-boolean { color: var(--json-boolean); font-weight: 600; }
    .json-null { color: var(--json-null); font-style: italic; }

    .meta-table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 16px;
      background: var(--bg-surface);
      border: 1px solid var(--border-color);
      border-radius: 10px;
      overflow: hidden;
    }

    .meta-table td {
      padding: 10px 14px;
      border-bottom: 1px solid var(--border-subtle);
      font-size: 13px;
    }

    .meta-table tr:last-child td {
      border-bottom: none;
    }

    .meta-table td.key {
      width: 170px;
      color: var(--text-muted);
      font-weight: 700;
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    .meta-table td.val {
      color: var(--text-primary);
      font-family: 'JetBrains Mono', monospace;
      font-size: 13px;
    }

    /* Binary Preview Container */
    .binary-container {
      background: var(--bg-surface);
      border: 1px solid var(--border-color);
      border-radius: 10px;
      padding: 20px;
      display: flex;
      flex-direction: column;
      gap: 14px;
      margin-bottom: 16px;
    }

    .binary-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      flex-wrap: wrap;
      gap: 10px;
    }

    .binary-title {
      display: flex;
      align-items: center;
      gap: 8px;
      font-weight: 700;
      font-size: 14px;
    }

    .binary-actions {
      display: flex;
      gap: 8px;
    }

    .pdf-frame {
      width: 100%;
      height: 600px;
      border: 1px solid var(--border-color);
      border-radius: 8px;
      background: #333;
    }

    .img-preview {
      max-width: 100%;
      max-height: 500px;
      object-fit: contain;
      border-radius: 8px;
      border: 1px solid var(--border-color);
      background: repeating-conic-gradient(#808080 0% 25%, transparent 0% 50%) 50% / 20px 20px;
    }

    /* Modern Modal System */
    .modal-overlay {
      position: fixed;
      inset: 0;
      background: var(--modal-overlay);
      backdrop-filter: blur(3px);
      display: none;
      align-items: center;
      justify-content: center;
      z-index: 9000;
    }

    .modal-overlay.active {
      display: flex;
    }

    .modal-card {
      background: var(--bg-surface);
      border: 1px solid var(--border-color);
      border-radius: 14px;
      width: 440px;
      max-width: 90vw;
      overflow: hidden;
      box-shadow: 0 20px 40px -15px rgba(0, 0, 0, 0.5);
      animation: modalIn 0.2s cubic-bezier(0.16, 1, 0.3, 1);
    }

    @keyframes modalIn {
      from { opacity: 0; transform: scale(0.95) translateY(10px); }
      to { opacity: 1; transform: scale(1) translateY(0); }
    }

    .modal-header {
      padding: 16px 20px;
      border-bottom: 1px solid var(--border-color);
      display: flex;
      align-items: center;
      justify-content: space-between;
    }

    .modal-header h3 {
      font-size: 15px;
      font-weight: 700;
      color: var(--text-primary);
    }

    .modal-body {
      padding: 20px;
      display: flex;
      flex-direction: column;
      gap: 12px;
    }

    .modal-footer {
      padding: 14px 20px;
      border-top: 1px solid var(--border-color);
      background: var(--bg-base);
      display: flex;
      justify-content: flex-end;
      gap: 10px;
    }

    .export-option {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 12px 14px;
      border-radius: 10px;
      border: 1px solid var(--border-color);
      background: var(--bg-base);
      cursor: pointer;
      margin-bottom: 10px;
      transition: all 0.15s ease;
    }

    .export-option:hover {
      border-color: var(--accent-blue);
      background: var(--bg-card-hover);
      transform: translateY(-1px);
    }

    .export-option-icon {
      font-size: 24px;
    }

    .export-option-info {
      flex: 1;
    }

    .export-option-title {
      font-weight: 700;
      font-size: 13px;
      color: var(--text-primary);
      margin-bottom: 2px;
    }

    .export-option-desc {
      font-size: 11px;
      color: var(--text-muted);
    }

    .clear-warning-box {
      background: rgba(239, 68, 68, 0.08);
      border: 1px solid rgba(239, 68, 68, 0.2);
      border-radius: 8px;
      padding: 12px;
      font-size: 13px;
      line-height: 1.5;
      color: var(--text-muted);
    }

    /* Modern Toast Notification */
    .toast-container {
      position: fixed;
      bottom: 24px;
      right: 24px;
      display: flex;
      flex-direction: column;
      gap: 8px;
      z-index: 10000;
      pointer-events: none;
    }

    .toast {
      display: flex;
      align-items: center;
      gap: 10px;
      background: var(--bg-surface);
      color: var(--text-primary);
      border: 1px solid var(--border-color);
      padding: 12px 18px;
      border-radius: 10px;
      font-size: 13px;
      font-weight: 600;
      box-shadow: 0 10px 30px -5px rgba(0, 0, 0, 0.4);
      transform: translateY(20px);
      opacity: 0;
      transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
      pointer-events: auto;
    }

    .toast.show {
      transform: translateY(0);
      opacity: 1;
    }

    .toast.toast-success {
      border-left: 4px solid #10b981;
    }

    .toast.toast-danger {
      border-left: 4px solid #ef4444;
    }

    .toast.toast-info {
      border-left: 4px solid #38bdf8;
    }

    /* Mobile Back Button */
    .mobile-back-btn {
      display: none;
    }

    /* Mobile Actions Dropdown Menu */
    .mobile-menu-wrapper {
      display: none;
      position: relative;
    }

    .mobile-dropdown-menu {
      display: none;
      position: absolute;
      top: calc(100% + 8px);
      right: 0;
      width: 260px;
      background: var(--bg-surface);
      border: 1px solid var(--border-color);
      border-radius: 12px;
      box-shadow: 0 12px 36px rgba(0, 0, 0, 0.45);
      z-index: 1000;
      padding: 8px;
      animation: menuFadeIn 0.15s ease;
    }

    .mobile-dropdown-menu.show {
      display: block;
    }

    @keyframes menuFadeIn {
      from { opacity: 0; transform: translateY(-6px); }
      to { opacity: 1; transform: translateY(0); }
    }

    .menu-device-header {
      padding: 10px 12px;
      border-radius: 8px;
      background: var(--bg-base);
      display: flex;
      align-items: center;
      justify-content: space-between;
      cursor: pointer;
      border: 1px solid var(--border-color);
      transition: background 0.15s ease;
      margin-bottom: 4px;
    }
    .menu-device-header:hover {
      background: var(--bg-card-hover);
    }

    .menu-divider {
      height: 1px;
      background: var(--border-color);
      margin: 6px 0;
    }

    .menu-item {
      width: 100%;
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 9px 12px;
      border-radius: 8px;
      border: none;
      background: transparent;
      color: var(--text-primary);
      font-size: 12px;
      font-weight: 600;
      text-align: left;
      cursor: pointer;
      transition: background 0.15s ease;
    }
    .menu-item:hover {
      background: var(--bg-card-hover);
    }
    .menu-item-danger {
      color: #ef4444;
    }
    .menu-item-danger:hover {
      background: rgba(239, 68, 68, 0.12);
    }

    /* Mobile Responsive Layout (Screens <= 768px) */
    @media (max-width: 768px) {
      header {
        padding: 0 12px;
        height: 52px;
        gap: 6px;
      }
      .brand-title {
        font-size: 13px;
      }
      .brand-subtitle {
        display: none;
      }
      .desktop-only {
        display: none !important;
      }
      .mobile-menu-wrapper {
        display: block !important;
      }
      .header-actions {
        gap: 6px;
      }
      .btn {
        padding: 6px 10px;
        font-size: 11px;
      }

      .main-container {
        position: relative;
        width: 100%;
        overflow: hidden;
        z-index: 1;
      }

      .sidebar {
        width: 100%;
        min-width: 100%;
        border-right: none;
      }

      .detail-view {
        width: 100%;
        min-width: 100%;
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: var(--bg-base);
        z-index: 20;
        display: none;
      }

      body.mobile-detail-open .sidebar {
        display: none;
      }
      body.mobile-detail-open .detail-view {
        display: flex;
      }

      .mobile-back-btn {
        display: inline-flex !important;
      }

      .detail-header {
        padding: 8px 10px;
        gap: 6px;
      }
      .detail-tabs {
        padding: 0 8px;
        overflow-x: auto;
        white-space: nowrap;
        scrollbar-width: none;
      }
      .detail-tabs::-webkit-scrollbar {
        display: none;
      }
      .tab-btn {
        padding: 8px 10px;
        font-size: 11px;
      }
      .detail-content {
        padding: 10px;
      }
      .meta-table td.key {
        width: 95px;
        font-size: 11px;
      }
      .toast-container {
        bottom: 12px;
        right: 12px;
        left: 12px;
      }
    }
  </style>
</head>
<body>

  <header>
    <div class="brand">
      <div class="brand-icon">&lt;/&gt;</div>
      <div class="brand-title">
        <span>Floating Logger</span>
        <span class="brand-subtitle">Web Inspector</span>
      </div>
      <div class="device-badge desktop-only" id="device-badge" onclick="showDeviceInfoPopup()" title="Click for full device details" style="cursor: pointer;">
        <span id="device-icon" style="display:inline-flex; align-items:center;"></span>
        <span id="device-name">Device</span>
      </div>
    </div>
    <div class="header-actions">
      <div class="status-badge desktop-only" id="ws-status">
        <div class="status-dot"></div>
        <span id="ws-text">Connecting...</span>
      </div>
      <button class="btn btn-icon" id="theme-btn" onclick="toggleTheme()" title="Toggle Dark/Light Mode">
        <span id="theme-icon">☀️</span>
      </button>

      <!-- Import Button -->
      <button class="btn desktop-only" onclick="triggerImport()" title="Import Floating Logger JSON or HAR file">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
        Import
      </button>
      <input type="file" id="import-file-input" accept=".json,.har" style="display: none;" onchange="handleFileImport(event)">

      <!-- Export Button -->
      <button class="btn desktop-only" onclick="openExportModal()" title="Export logs in multiple formats">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
        Export <span style="font-size: 9px; opacity: 0.7;">▼</span>
      </button>

      <!-- Clear Button -->
      <button class="btn btn-danger desktop-only" onclick="openClearModal()" title="Clear all logs">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
        Clear
      </button>

      <!-- Mobile Menu Button (⋮) & Dropdown -->
      <div class="mobile-menu-wrapper">
        <button class="btn btn-icon" id="mobile-menu-btn" onclick="toggleMobileMenu(event)" title="Options">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
            <circle cx="12" cy="5" r="2.2"/>
            <circle cx="12" cy="12" r="2.2"/>
            <circle cx="12" cy="19" r="2.2"/>
          </svg>
        </button>

        <!-- Mobile Floating Menu Dropdown -->
        <div class="mobile-dropdown-menu" id="mobile-dropdown-menu" onclick="event.stopPropagation()">
          <div class="menu-device-header" onclick="showDeviceInfoPopup(); closeMobileMenu();">
            <div style="display: flex; align-items: center; gap: 8px;">
              <span id="menu-device-icon" style="display:inline-flex; align-items:center;"></span>
              <div>
                <div style="font-size: 12px; font-weight: 700; color: var(--text-primary);" id="menu-device-name">Device</div>
                <div style="font-size: 10px; color: var(--text-muted);" id="menu-device-sub">Tap for system details</div>
              </div>
            </div>
            <span style="font-size: 11px; color: var(--accent-blue); font-weight: 600;">Details ›</span>
          </div>
          <div class="menu-divider"></div>
          <button class="menu-item" onclick="triggerImport(); closeMobileMenu();">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
            <span>Import Logs</span>
          </button>
          <button class="menu-item" onclick="openExportModal(); closeMobileMenu();">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
            <span>Export Logs (HAR, Postman)</span>
          </button>
          <div class="menu-divider"></div>
          <button class="menu-item menu-item-danger" onclick="openClearModal(); closeMobileMenu();">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
            <span>Clear All Logs</span>
          </button>
        </div>
      </div>
    </div>
  </header>

  <div class="main-container">
    <!-- Sidebar -->
    <aside class="sidebar">
      <div class="sidebar-toolbar">
        <div class="search-box">
          <svg class="search-icon" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
          <input type="text" id="search-input" class="search-input" placeholder="Search URL, method, status..." oninput="onSearchChange()">
        </div>
        <div class="filter-chips">
          <div class="chip active" onclick="setFilter('ALL')">ALL</div>
          <div class="chip" onclick="setFilter('GET')">GET</div>
          <div class="chip" onclick="setFilter('POST')">POST</div>
          <div class="chip" onclick="setFilter('PUT')">PUT</div>
          <div class="chip" onclick="setFilter('DELETE')">DELETE</div>
          <div class="chip" onclick="setFilter('ERRORS')">ERRORS</div>
        </div>
      </div>
      <div class="logs-list" id="logs-list">
        <!-- Dynamic logs cards matching Floating Logger -->
      </div>
    </aside>

    <!-- Detail View -->
    <main class="detail-view" id="detail-view">
      <div class="detail-empty" id="detail-empty">
        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        <span>Select an entry from the list to inspect details</span>
      </div>

      <div id="detail-active" style="display: none; height: 100%; flex-direction: column;">
        <div class="detail-header">
          <button class="btn mobile-back-btn" onclick="closeMobileDetail()" title="Back to Logs" style="padding: 4px 8px;">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="15 18 9 12 15 6"/></svg>
            Back
          </button>
          <div class="detail-url-container" id="detail-badge-row">
            <!-- Dynamic Badges -->
            <span class="detail-url" id="detail-url"></span>
          </div>
          <div style="display: flex; gap: 8px;">
            <button class="btn" id="btn-copy-curl" onclick="copyCurrentCurl()">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
              Copy cURL
            </button>
          </div>
        </div>

        <div class="detail-tabs" id="tabs-container">
          <!-- Dynamic tabs -->
        </div>

        <div class="detail-content" id="detail-content">
          <!-- Dynamic tab content -->
        </div>
      </div>
    </main>
  </div>

  <!-- Export Modal -->
  <div class="modal-overlay" id="export-modal" onclick="closeExportModal(event)">
    <div class="modal-card" onclick="event.stopPropagation()">
      <div class="modal-header">
        <span>Export Recorded Logs</span>
        <button class="btn btn-icon" onclick="closeExportModal()" style="border: none; background: none; font-size: 16px;">✕</button>
      </div>
      <div class="modal-body">
        <p style="margin-bottom: 14px; font-size: 12px; color: var(--text-muted);">
          Choose your preferred format to export the captured network logs:
        </p>

        <div class="export-option" onclick="exportHar()">
          <span class="export-option-icon">🌐</span>
          <div class="export-option-info">
            <div class="export-option-title">HTTP Archive (.har)</div>
            <div class="export-option-desc">Universal standard for Chrome DevTools, Postman, Charles & Proxyman</div>
          </div>
        </div>

        <div class="export-option" onclick="exportPostman()">
          <span class="export-option-icon">📮</span>
          <div class="export-option-info">
            <div class="export-option-title">Postman Collection v2.1 (.json)</div>
            <div class="export-option-desc">Directly importable into Postman with endpoints, headers & parameters</div>
          </div>
        </div>

        <div class="export-option" onclick="exportRawJson()">
          <span class="export-option-icon">📦</span>
          <div class="export-option-info">
            <div class="export-option-title">Floating Logger JSON (.json)</div>
            <div class="export-option-desc">Raw logger archive format compatible with Import in this Inspector</div>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn" onclick="closeExportModal()">Close</button>
      </div>
    </div>
  </div>

  <!-- Clear Confirmation Modal -->
  <div class="modal-overlay" id="clear-modal" onclick="closeClearModal(event)">
    <div class="modal-card" onclick="event.stopPropagation()">
      <div class="modal-header">
        <span>Clear Logs Confirmation</span>
        <button class="btn btn-icon" onclick="closeClearModal()" style="border: none; background: none; font-size: 16px;">✕</button>
      </div>
      <div class="modal-body">
        <div style="display: flex; gap: 14px; align-items: flex-start;">
          <div style="font-size: 28px;">🗑️</div>
          <div>
            <strong style="color: var(--text-primary); font-size: 14px; display: block; margin-bottom: 4px;">Clear all logs?</strong>
            Are you sure you want to remove all captured entries from this Web Inspector view? This action cannot be undone.
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn" onclick="closeClearModal()">Cancel</button>
        <button class="btn btn-danger" onclick="confirmClearLogs()">Clear All</button>
      </div>
    </div>
  </div>

  <!-- Toast Container -->
  <div class="toast-container" id="toast-container"></div>

  <script>
    let allLogs = [];
    let currentFilter = 'ALL';
    let searchQuery = '';
    let selectedLog = null;
    let currentTab = 'overview';
    let socket = null;

    // Theme Management
    function initTheme() {
      const saved = localStorage.getItem('floating_logger_theme') || 'dark';
      setTheme(saved);
    }

    function toggleTheme() {
      const current = document.documentElement.getAttribute('data-theme') || 'dark';
      const next = current === 'dark' ? 'light' : 'dark';
      setTheme(next);
    }

    function setTheme(theme) {
      document.documentElement.setAttribute('data-theme', theme);
      localStorage.setItem('floating_logger_theme', theme);
      const icon = document.getElementById('theme-icon');
      if (icon) icon.innerText = theme === 'dark' ? '☀️' : '🌙';
    }

    // Connect WebSocket for live logs
    function connectWs() {
      const wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
      const wsUrl = `${wsProtocol}//${window.location.host}/ws`;
      socket = new WebSocket(wsUrl);

      const statusBadge = document.getElementById('ws-status');
      const statusText = document.getElementById('ws-text');

      socket.onopen = () => {
        statusBadge.classList.remove('offline');
        statusText.innerText = 'LIVE';
      };

      socket.onmessage = (event) => {
        try {
          const newLog = JSON.parse(event.data);
          allLogs.unshift(newLog);
          renderLogsList();
        } catch (e) {
          console.error("Error parsing WS message", e);
        }
      };

      socket.onclose = () => {
        statusBadge.classList.add('offline');
        statusText.innerText = 'DISCONNECTED';
        setTimeout(connectWs, 3000);
      };
    }

    // High-quality sleek vector SVG icons for platforms
    const PLATFORM_ICONS = {
      apple: '<svg width="13" height="13" viewBox="0 0 170 170" fill="currentColor" style="display:inline-block; vertical-align:-1px;"><path d="M150.37 130.25c-2.45 5.66-5.35 10.87-8.71 15.66-4.58 6.53-8.33 11.05-11.22 13.56-4.48 4.12-9.28 6.23-14.42 6.35-3.69 0-8.14-1.05-13.32-3.18-5.19-2.12-9.97-3.17-14.34-3.17-4.58 0-9.49 1.05-14.75 3.17-5.26 2.13-9.5 3.24-12.74 3.35-4.35.13-9.16-1.9-14.42-6.08-3.7-3.07-7.6-7.85-11.7-14.34-6.3-9.98-11.19-21.3-14.67-33.95-3.48-12.65-5.22-24.28-5.22-34.9 0-14.28 3.8-25.88 11.4-34.8 7.6-8.93 17.3-13.48 29.1-13.65 4.69 0 10.23 1.25 16.63 3.75 6.4 2.5 10.45 3.83 12.15 3.98 2.02-.27 6.43-1.74 13.23-4.42 6.8-2.67 12.56-3.88 17.27-3.63 13.4.67 23.95 5.55 31.64 14.64-11.83 7.15-17.61 16.9-17.34 29.25.26 9.8 4.1 17.88 11.53 24.24 7.42 6.36 16.14 10.02 26.15 10.99-2.42 7.74-5.32 15.17-8.7 22.3zM119.22 33.15c0-6.9 2.5-13.3 7.5-19.2 5-5.9 11.2-9.9 18.6-12 1.4 6.7 1 12.9-1.2 18.6-2.2 5.7-5.9 10.5-11.1 14.4-4.2 3.1-8.7 4.9-13.5 5.4-.2-2.4-.3-4.8-.3-7.2z"/></svg>',
      android: '<svg width="13" height="13" viewBox="0 0 24 24" fill="currentColor" style="display:inline-block; vertical-align:-1px;"><path d="M6 18c0 .55.45 1 1 1h1v3.5c0 .83.67 1.5 1.5 1.5s1.5-.67 1.5-1.5V19h2v3.5c0 .83.67 1.5 1.5 1.5s1.5-.67 1.5-1.5V19h1c.55 0 1-.45 1-1V8H6v10zM3.5 8C2.67 8 2 8.67 2 9.5v7c0 .83.67 1.5 1.5 1.5S5 17.33 5 16.5v-7C5 8.67 4.33 8 3.5 8zm17 0c-.83 0-1.5.67-1.5 1.5v7c0 .83.67 1.5 1.5 1.5s1.5-.67 1.5-1.5v-7c0-.83-.67-1.5-1.5-1.5zm-4.97-5.84l1.3-1.3c.2-.2.2-.51 0-.71-.2-.2-.51-.2-.71 0l-1.48 1.48C13.68 1.24 12.87 1 12 1s-1.68.24-2.64.63L7.88.15c-.2-.2-.51-.2-.71 0-.2.2-.2.51 0 .71l1.3 1.3C6.73 3.23 5.43 4.98 5.16 7h13.68c-.27-2.02-1.57-3.77-3.31-4.84zM9 5H8V4h1v1zm7 0h-1V4h1v1z"/></svg>',
      desktop: '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display:inline-block; vertical-align:-1px;"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="2" y1="20" x2="22" y2="20"/></svg>'
    };

    let latestDeviceInfo = null;

    // Load device platform info
    async function fetchDeviceInfo() {
      try {
        const res = await fetch('/api/device-info');
        if (res.ok) {
          latestDeviceInfo = await res.json();
          const badge = document.getElementById('device-badge');
          const icon = document.getElementById('device-icon');
          const name = document.getElementById('device-name');

          // Mobile menu elements
          const menuIcon = document.getElementById('menu-device-icon');
          const menuName = document.getElementById('menu-device-name');
          const menuSub = document.getElementById('menu-device-sub');

          const plat = (latestDeviceInfo.platform || '').toLowerCase();
          let iconSvg = PLATFORM_ICONS.desktop;
          let displayName = latestDeviceInfo.device_name || latestDeviceInfo.platform || 'Device';

          let osVersion = latestDeviceInfo.os_version || '';
          if (plat.includes('ios')) {
            iconSvg = PLATFORM_ICONS.apple;
            if (!latestDeviceInfo.is_simulator) {
              const match = osVersion.match(/Version\s+([\d\.]+)/i);
              osVersion = match ? `iOS ${match[1]}` : 'iOS';
            }
          } else if (plat.includes('android')) {
            iconSvg = PLATFORM_ICONS.android;
            const match = osVersion.match(/(\d+)/);
            if (!latestDeviceInfo.is_simulator) {
              osVersion = match ? `Android ${match[1]}` : 'Android';
            }
          } else if (plat.includes('macos')) {
            iconSvg = PLATFORM_ICONS.apple;
            const match = osVersion.match(/Version\s+([\d\.]+)/i);
            osVersion = match ? `macOS ${match[1]}` : 'macOS';
          } else if (plat.includes('windows')) {
            iconSvg = PLATFORM_ICONS.desktop;
            osVersion = 'Windows';
          } else if (plat.includes('linux')) {
            iconSvg = PLATFORM_ICONS.desktop;
            osVersion = 'Linux';
          }

          let badgeTitle = osVersion;
          if (displayName && !displayName.toLowerCase().includes(osVersion.toLowerCase())) {
            badgeTitle = `${osVersion} • ${displayName}`;
          } else if (displayName) {
            badgeTitle = displayName;
          }

          if (icon) icon.innerHTML = iconSvg;
          if (name) name.innerText = badgeTitle;
          if (badge) {
            badge.style.display = 'inline-flex';
            badge.setAttribute('title', `${latestDeviceInfo.os_version || ''} (${latestDeviceInfo.processors || 1} CPU cores, Dart ${latestDeviceInfo.dart_version || ''}) - Click for details`);
          }

          if (menuIcon) menuIcon.innerHTML = iconSvg;
          if (menuName) menuName.innerText = badgeTitle;
          if (menuSub) menuSub.innerText = `${latestDeviceInfo.processors || 1} Cores • Dart ${latestDeviceInfo.dart_version || ''}`;
        }
      } catch (_) {}
    }

    function showDeviceInfoPopup() {
      if (!latestDeviceInfo) return;
      const os = latestDeviceInfo.os_version || latestDeviceInfo.platform;
      const dev = latestDeviceInfo.device_name || latestDeviceInfo.hostname || 'Device';
      const cpus = latestDeviceInfo.processors ? `${latestDeviceInfo.processors} CPU Cores` : '';
      const dart = latestDeviceInfo.dart_version ? `Dart SDK ${latestDeviceInfo.dart_version}` : '';
      showToast(`${os} | ${dev} | ${cpus} | ${dart}`, 'info');
    }

    // Mobile Menu Toggle & Click Outside Handler
    function toggleMobileMenu(event) {
      if (event) event.stopPropagation();
      const menu = document.getElementById('mobile-dropdown-menu');
      if (menu) menu.classList.toggle('show');
    }

    function closeMobileMenu() {
      const menu = document.getElementById('mobile-dropdown-menu');
      if (menu) menu.classList.remove('show');
    }

    document.addEventListener('click', (e) => {
      const menu = document.getElementById('mobile-dropdown-menu');
      const btn = document.getElementById('mobile-menu-btn');
      if (menu && menu.classList.contains('show')) {
        if (!menu.contains(e.target) && (!btn || !btn.contains(e.target))) {
          menu.classList.remove('show');
        }
      }
    });

    // Load initial logs
    async function fetchInitialLogs() {
      try {
        const res = await fetch('/api/logs');
        if (res.ok) {
          allLogs = await res.json();
          renderLogsList();
        }
      } catch (e) {
        console.error("Failed to fetch initial logs", e);
      }
    }

    function setFilter(filter) {
      currentFilter = filter;
      document.querySelectorAll('.filter-chips .chip').forEach(c => {
        c.classList.toggle('active', c.innerText.trim() === filter);
      });
      renderLogsList();
    }

    function onSearchChange() {
      searchQuery = document.getElementById('search-input').value.toLowerCase();
      renderLogsList();
    }

    function isSimulated(log) {
      return log && (log.is_simulation === true || log.isSimulation === true);
    }

    function hasContent(val) {
      if (val == null) return false;
      const s = val.toString().trim();
      if (s === '' || s === '{}' || s === '[]' || s === 'null' || s === 'None' || s === 'Empty') return false;
      try {
        const parsed = JSON.parse(s);
        if (typeof parsed === 'object' && parsed !== null) {
          return Object.keys(parsed).length > 0;
        }
      } catch (_) {}
      return true;
    }

    function formatBytes(bytes) {
      if (!bytes || bytes <= 0) return '0 B';
      if (bytes < 1024) return bytes + ' B';
      if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
      return (bytes / (1024 * 1024)).toFixed(2) + ' MB';
    }

    function getPayloadSize(log) {
      const bin = detectBinaryData(log);
      if (bin && bin.size) return bin.size;

      const raw = log.responseData || log.response_data || (log.type !== 'REQUEST' ? log.data : null);
      if (!raw) return 0;
      const str = typeof raw === 'string' ? raw : JSON.stringify(raw);
      if (!str || str === 'null' || str === '[]' || str === '{}') return 0;
      return new Blob([str]).size;
    }

    function getDuration(log) {
      if (!log) return null;
      const d = log.responseTime != null ? log.responseTime : (log.response_time != null ? log.response_time : null);
      if (d != null && !isNaN(d)) return Number(d);
      return null;
    }

    // Detect Binary (PDF, Image, etc.) from base64 or byte array
    function detectBinaryData(log) {
      if (!log) return null;

      if (log.base64_data) {
        const contentType = log.content_type || 'application/octet-stream';
        const isPdf = contentType.toLowerCase().includes('pdf');
        const isImg = contentType.toLowerCase().startsWith('image/');
        return {
          isBinary: true,
          isPdf,
          isImage: isImg,
          contentType,
          dataUrl: `data:${contentType};base64,${log.base64_data}`,
          size: Math.round((log.base64_data.length * 3) / 4)
        };
      }

      let raw = log.responseData || log.response_data;
      if (!raw && log.type !== 'REQUEST') raw = log.data;
      if (!raw) return null;

      let byteArray = null;
      if (Array.isArray(raw) && typeof raw[0] === 'number') {
        byteArray = raw;
      } else if (typeof raw === 'string' && raw.trim().startsWith('[')) {
        try {
          const parsed = JSON.parse(raw);
          if (Array.isArray(parsed) && typeof parsed[0] === 'number') {
            byteArray = parsed;
          }
        } catch (_) {}
      }

      if (byteArray && byteArray.length > 8) {
        // %PDF magic bytes = [37, 80, 68, 70]
        const isPdf = byteArray[0] === 37 && byteArray[1] === 80 && byteArray[2] === 68 && byteArray[3] === 70;
        // PNG = [137, 80, 78, 71]
        const isPng = byteArray[0] === 137 && byteArray[1] === 80 && byteArray[2] === 78 && byteArray[3] === 71;
        // JPEG = [255, 216, 255]
        const isJpg = byteArray[0] === 255 && byteArray[1] === 216 && byteArray[2] === 255;
        // GIF = [71, 73, 70]
        const isGif = byteArray[0] === 71 && byteArray[1] === 73 && byteArray[2] === 70;
        // WEBP = [82, 73, 70, 70]
        const isWebp = byteArray[0] === 82 && byteArray[1] === 73 && byteArray[2] === 70 && byteArray[3] === 70;

        let mime = 'application/octet-stream';
        if (isPdf) mime = 'application/pdf';
        else if (isPng) mime = 'image/png';
        else if (isJpg) mime = 'image/jpeg';
        else if (isGif) mime = 'image/gif';
        else if (isWebp) mime = 'image/webp';

        try {
          const uint8 = new Uint8Array(byteArray);
          const blob = new Blob([uint8], { type: mime });
          const objectUrl = URL.createObjectURL(blob);
          return {
            isBinary: true,
            isPdf,
            isImage: isPng || isJpg || isGif || isWebp,
            contentType: mime,
            size: byteArray.length,
            objectUrl
          };
        } catch (_) {}
      }

      if (log.is_binary || log.isBinaryResponse) {
        return {
          isBinary: true,
          isPdf: (log.content_type || '').includes('pdf'),
          isImage: (log.content_type || '').startsWith('image/'),
          contentType: log.content_type || 'application/octet-stream',
          size: 0
        };
      }

      return null;
    }

    function hasRequestBody(log) {
      if (!log) return false;
      if (log.method === 'GET' || log.method === 'HEAD') return false;
      if (!hasContent(log.data)) return false;

      const bin = detectBinaryData({ data: log.data });
      if (bin && bin.isBinary) return false;

      return true;
    }

    function getFilteredLogs() {
      return allLogs.filter(log => {
        if (currentFilter === 'ERRORS') {
          if (log.type !== 'ERROR' && !(log.response && (log.response.toString().startsWith('4') || log.response.toString().startsWith('5')))) {
            return false;
          }
        } else if (currentFilter !== 'ALL' && log.method !== currentFilter) {
          return false;
        }

        if (searchQuery) {
          const matchPath = (log.path || '').toLowerCase().includes(searchQuery);
          const matchMethod = (log.method || '').toLowerCase().includes(searchQuery);
          const matchStatus = (log.response || '').toString().toLowerCase().includes(searchQuery);
          const matchMsg = (log.message || '').toLowerCase().includes(searchQuery);
          return matchPath || matchMethod || matchStatus || matchMsg;
        }

        return true;
      });
    }

    // Render list cards matching Floating Logger in Flutter app
    function renderLogsList() {
      const listEl = document.getElementById('logs-list');
      const filtered = getFilteredLogs();

      if (filtered.length === 0) {
        listEl.innerHTML = '<div style="padding: 30px; text-align: center; color: var(--text-muted); font-size: 13px;">No logs match your filter</div>';
        return;
      }

      listEl.innerHTML = filtered.map((log, index) => {
        const isSelected = selectedLog === log;
        const sim = isSimulated(log);
        const bin = detectBinaryData(log);
        const payloadSize = getPayloadSize(log);

        // 1. Method Class
        const method = (log.method || 'GET').toUpperCase();
        let methodBg = 'bg-get';
        if (method === 'POST') methodBg = 'bg-post';
        else if (method === 'PUT') methodBg = 'bg-put';
        else if (method === 'PATCH') methodBg = 'bg-patch';
        else if (method === 'DELETE') methodBg = 'bg-delete';
        else if (method === 'OPTIONS' || method === 'HEAD') methodBg = 'bg-options';

        // 2. Type Pill: REQUEST (grey), RESPONSE (blue), ERROR (red)
        let typePill = '';
        if (log.type === 'REQUEST') {
          typePill = '<span class="badge-pill bg-req">REQUEST</span>';
        } else if (log.type === 'ERROR') {
          typePill = '<span class="badge-pill bg-err">ERROR</span>';
        } else {
          typePill = '<span class="badge-pill bg-res">RESPONSE</span>';
        }

        // 3. Right-side Status Pill
        // IMPORTANT: For REQUEST, NO status label / NO "Outgoing" text!
        let rightPill = '';
        if (log.type === 'REQUEST') {
          rightPill = '';
        } else if (log.type === 'ERROR') {
          const errCode = log.response || 'ERROR';
          rightPill = `<span class="badge-pill bg-err">${errCode.toString().includes('ERROR') ? errCode : errCode + ' ERROR'}</span>`;
        } else {
          const statusCode = log.response || '200';
          if (statusCode.toString().startsWith('2')) {
            rightPill = `<span class="badge-pill bg-success">${statusCode} SUCCESS</span>`;
          } else if (statusCode.toString().startsWith('4') || statusCode.toString().startsWith('5')) {
            rightPill = `<span class="badge-pill bg-err">${statusCode} ERROR</span>`;
          } else {
            rightPill = `<span class="badge-pill bg-res">${statusCode}</span>`;
          }
        }

        // 4. Binary Tag
        let binTag = '';
        if (bin && bin.isPdf) binTag = '<span class="badge-pill bg-bin">📄 PDF</span>';
        else if (bin && bin.isImage) binTag = '<span class="badge-pill bg-bin">🖼️ IMG</span>';

        // 5. Size & Duration Pills
        let metaTags = '';
        if (log.type !== 'REQUEST') {
          const dur = getDuration(log);
          const duration = dur != null ? `${dur} ms` : null;
          const sizeStr = payloadSize > 0 ? formatBytes(payloadSize) : null;
          if (sizeStr || duration) {
            metaTags = `
              <div style="display: flex; gap: 4px; align-items: center;">
                ${sizeStr ? `<span class="badge-info-pill">${sizeStr}</span>` : ''}
                ${duration ? `<span class="badge-info-pill">${duration}</span>` : ''}
              </div>
            `;
          }
        }

        return `
          <div class="log-item ${isSelected ? 'selected' : ''} ${sim ? 'is-simulation' : ''}" onclick="selectLogByIndex(${index})">
            <div class="log-item-top">
              <div class="log-item-left">
                <span class="log-index">${index + 1}.</span>
                <span class="badge-pill ${methodBg}">${method}</span>
                ${typePill}
                ${sim ? '<span class="badge-pill bg-sim">⚡ SIMULATED</span>' : ''}
                ${binTag}
              </div>
              <div style="display: flex; align-items: center; gap: 6px;">
                ${metaTags}
                ${rightPill}
              </div>
            </div>
            <div class="log-path">${escapeHtml(log.path || '-')}</div>
          </div>
        `;
      }).join('');
    }

    function selectLogByIndex(index) {
      const filtered = getFilteredLogs();
      selectedLog = filtered[index] || null;
      renderLogsList();
      renderDetailView();
      if (selectedLog) {
        document.body.classList.add('mobile-detail-open');
      }
    }

    function closeMobileDetail() {
      document.body.classList.remove('mobile-detail-open');
    }

    function getAvailableTabs(log) {
      if (!log) return [];
      const tabs = [{ id: 'overview', label: 'Overview' }];

      if (hasContent(log.queryparameter) || hasContent(log.header)) {
        tabs.push({ id: 'headers', label: 'Headers & Params' });
      }

      if (hasRequestBody(log)) {
        tabs.push({ id: 'request_body', label: 'Request Body' });
      }

      if (log.type !== 'REQUEST') {
        const bin = detectBinaryData(log);
        let label = 'Response';
        if (log.type === 'ERROR') label = 'Error Details';
        else if (bin && bin.isPdf) label = '📄 PDF Preview';
        else if (bin && bin.isImage) label = '🖼️ Image Preview';
        tabs.push({ id: 'response', label });
      }

      if (log.curl && log.curl.trim()) {
        tabs.push({ id: 'curl', label: 'cURL' });
      }

      return tabs;
    }

    function renderDetailView() {
      const emptyEl = document.getElementById('detail-empty');
      const activeEl = document.getElementById('detail-active');

      if (!selectedLog) {
        emptyEl.style.display = 'flex';
        activeEl.style.display = 'none';
        return;
      }

      emptyEl.style.display = 'none';
      activeEl.style.display = 'flex';

      // Header row badges
      const badgeRow = document.getElementById('detail-badge-row');
      const method = (selectedLog.method || 'GET').toUpperCase();
      let methodBg = 'bg-get';
      if (method === 'POST') methodBg = 'bg-post';
      else if (method === 'PUT') methodBg = 'bg-put';
      else if (method === 'PATCH') methodBg = 'bg-patch';
      else if (method === 'DELETE') methodBg = 'bg-delete';
      else if (method === 'OPTIONS' || method === 'HEAD') methodBg = 'bg-options';

      let typePill = selectedLog.type === 'REQUEST'
          ? '<span class="badge-pill bg-req">REQUEST</span>'
          : (selectedLog.type === 'ERROR'
              ? '<span class="badge-pill bg-err">ERROR</span>'
              : '<span class="badge-pill bg-res">RESPONSE</span>');

      let statusPill = '';
      if (selectedLog.type !== 'REQUEST') {
        const st = selectedLog.response || '200';
        if (st.toString().startsWith('2')) statusPill = `<span class="badge-pill bg-success">${st} SUCCESS</span>`;
        else if (st.toString().startsWith('4') || st.toString().startsWith('5')) statusPill = `<span class="badge-pill bg-err">${st} ERROR</span>`;
        else statusPill = `<span class="badge-pill bg-res">${st}</span>`;
      }

      const simPill = isSimulated(selectedLog) ? '<span class="badge-pill bg-sim">⚡ SIMULATED</span>' : '';

      badgeRow.innerHTML = `
        <span class="badge-pill ${methodBg}">${method}</span>
        ${typePill}
        ${statusPill}
        ${simPill}
        <span class="detail-url" id="detail-url">${escapeHtml(selectedLog.path || '-')}</span>
      `;

      // Available tabs
      const availableTabs = getAvailableTabs(selectedLog);
      if (!availableTabs.some(t => t.id === currentTab)) {
        currentTab = availableTabs.length > 0 ? availableTabs[0].id : 'overview';
      }

      // Render tab buttons
      const tabsContainer = document.getElementById('tabs-container');
      tabsContainer.innerHTML = availableTabs.map(tab => {
        const isActive = tab.id === currentTab;
        return `<button class="tab-btn ${isActive ? 'active' : ''}" onclick="setTab('${tab.id}')">${tab.label}</button>`;
      }).join('');

      renderTabContent();
    }

    function setTab(tabId) {
      currentTab = tabId;
      document.querySelectorAll('.detail-tabs .tab-btn').forEach(btn => {
        btn.classList.toggle('active', btn.getAttribute('onclick') === `setTab('${tabId}')`);
      });
      renderTabContent();
    }

    function renderTabContent() {
      const contentEl = document.getElementById('detail-content');
      if (!selectedLog) return;

      const sim = isSimulated(selectedLog);
      let simAlert = '';
      if (sim) {
        simAlert = `
          <div class="sim-alert">
            <span style="font-size: 16px;">⚡</span>
            <div>
              <strong>Simulation Mode Active</strong>
              <div style="margin-top: 2px; color: var(--text-secondary); font-size: 12px;">
                This entry was generated by Floating Logger Network Simulator. It reflects simulated behavior rather than a live remote server transaction.
              </div>
            </div>
          </div>
        `;
      }

      if (currentTab === 'overview') {
        const bin = detectBinaryData(selectedLog);
        const payloadSize = getPayloadSize(selectedLog);
        const dur = getDuration(selectedLog);
        let binaryOverview = '';
        if (bin && bin.isBinary) {
          binaryOverview = `
            <tr><td class="key">Binary Type</td><td class="val">${bin.isPdf ? '📄 PDF Document' : (bin.isImage ? '🖼️ Image' : 'Binary File')} (${bin.contentType})</td></tr>
          `;
        }

        contentEl.innerHTML = `
          ${simAlert}
          <table class="meta-table">
            <tr><td class="key">Full Url</td><td class="val" style="word-break: break-all; color: var(--accent-blue); font-weight: 600;">${escapeHtml(selectedLog.path || '-')}</td></tr>
            <tr><td class="key">Method</td><td class="val">${selectedLog.method || '-'}</td></tr>
            <tr><td class="key">Status Code</td><td class="val">${selectedLog.type === 'REQUEST' ? 'Outgoing Request (In Flight)' : (selectedLog.response || '-')}</td></tr>
            <tr><td class="key">Duration</td><td class="val">${selectedLog.type === 'REQUEST' ? 'In Flight' : (dur != null ? dur + ' ms' : '-')}</td></tr>
            <tr><td class="key">Payload Size</td><td class="val">${payloadSize > 0 ? formatBytes(payloadSize) : '-'}</td></tr>
            <tr><td class="key">Log Type</td><td class="val">${selectedLog.type || '-'}</td></tr>
            <tr><td class="key">Message</td><td class="val">${escapeHtml(selectedLog.message || '-')}</td></tr>
            ${binaryOverview}
            <tr><td class="key">Simulation</td><td class="val">${sim ? 'Yes (Local Simulation)' : 'No (Live Network)'}</td></tr>
          </table>
        `;
      } else if (currentTab === 'headers') {
        let qParamHtml = '';
        if (hasContent(selectedLog.queryparameter)) {
          qParamHtml = `
            <div class="code-container">
              <div class="code-header">
                <span>Query Parameters</span>
                <button class="btn" style="padding: 2px 8px; font-size: 11px;" onclick="copyQueryParams()">Copy</button>
              </div>
              <div class="code-body">${renderHighlighted(selectedLog.queryparameter)}</div>
            </div>
          `;
        }

        let headerHtml = '';
        if (hasContent(selectedLog.header)) {
          headerHtml = `
            <div class="code-container">
              <div class="code-header">
                <span>Headers</span>
                <button class="btn" style="padding: 2px 8px; font-size: 11px;" onclick="copyHeaders()">Copy</button>
              </div>
              <div class="code-body">${renderHighlighted(selectedLog.header)}</div>
            </div>
          `;
        }

        contentEl.innerHTML = `
          ${simAlert}
          ${qParamHtml}
          ${headerHtml}
        `;
      } else if (currentTab === 'request_body') {
        contentEl.innerHTML = `
          ${simAlert}
          <div class="code-container">
            <div class="code-header">
              <span>Request Body Payload</span>
              <button class="btn" style="padding: 2px 8px; font-size: 11px;" onclick="copyRequestBody()">Copy</button>
            </div>
            <div class="code-body">${renderHighlighted(selectedLog.data)}</div>
          </div>
        `;
      } else if (currentTab === 'response') {
        const bin = detectBinaryData(selectedLog);

        if (bin && bin.isBinary) {
          const fileUrl = bin.objectUrl || bin.dataUrl;
          const sizeKb = bin.size ? `${(bin.size / 1024).toFixed(1)} KB` : '';

          if (bin.isPdf) {
            contentEl.innerHTML = `
              ${simAlert}
              <div class="binary-container">
                <div class="binary-header">
                  <div class="binary-title">
                    <span style="font-size: 20px;">📄</span>
                    <div>
                      <div>PDF Document Preview</div>
                      <div style="font-size: 11px; color: var(--text-muted); font-weight: normal;">${bin.contentType} ${sizeKb ? '• ' + sizeKb : ''}</div>
                    </div>
                  </div>
                  <div class="binary-actions">
                    <a href="${fileUrl}" target="_blank" class="btn" style="text-decoration: none;">Open in New Tab</a>
                    <a href="${fileUrl}" download="document.pdf" class="btn" style="text-decoration: none;">Download PDF</a>
                  </div>
                </div>
                <iframe src="${fileUrl}" class="pdf-frame"></iframe>
              </div>
            `;
          } else if (bin.isImage) {
            contentEl.innerHTML = `
              ${simAlert}
              <div class="binary-container">
                <div class="binary-header">
                  <div class="binary-title">
                    <span style="font-size: 20px;">🖼️</span>
                    <div>
                      <div>Image Preview</div>
                      <div style="font-size: 11px; color: var(--text-muted); font-weight: normal;">${bin.contentType} ${sizeKb ? '• ' + sizeKb : ''}</div>
                    </div>
                  </div>
                  <div class="binary-actions">
                    <a href="${fileUrl}" target="_blank" class="btn" style="text-decoration: none;">Open Image</a>
                    <a href="${fileUrl}" download="image" class="btn" style="text-decoration: none;">Download</a>
                  </div>
                </div>
                <div style="text-align: center; padding: 10px;">
                  <img src="${fileUrl}" class="img-preview" alt="Preview" />
                </div>
              </div>
            `;
          } else {
            contentEl.innerHTML = `
              ${simAlert}
              <div class="binary-container">
                <div class="binary-header">
                  <div class="binary-title">
                    <span style="font-size: 20px;">📦</span>
                    <div>
                      <div>Binary Data (${bin.contentType})</div>
                      <div style="font-size: 11px; color: var(--text-muted); font-weight: normal;">${sizeKb}</div>
                    </div>
                  </div>
                  <div class="binary-actions">
                    <a href="${fileUrl}" download="binary_data" class="btn" style="text-decoration: none;">Download File</a>
                  </div>
                </div>
              </div>
            `;
          }
        } else {
          const resData = selectedLog.responseData || (selectedLog.type !== 'REQUEST' ? selectedLog.data : null);
          const pSize = getPayloadSize(selectedLog);
          const sizeNote = pSize > 0 ? ` (${formatBytes(pSize)})` : '';

          contentEl.innerHTML = `
            ${simAlert}
            <div class="code-container">
              <div class="code-header">
                <span>${selectedLog.type === 'ERROR' ? 'Error / Server Response' : 'Response Payload'}${sizeNote}</span>
                <button class="btn" style="padding: 2px 8px; font-size: 11px;" onclick="copyResponseData()">Copy</button>
              </div>
              <div class="code-body">${renderHighlighted(resData || selectedLog.message || 'No response body')}</div>
            </div>
          `;
        }
      } else if (currentTab === 'curl') {
        contentEl.innerHTML = `
          ${simAlert}
          <div class="code-container">
            <div class="code-header">
              <span>cURL Command</span>
              <button class="btn" style="padding: 2px 8px; font-size: 11px;" onclick="copyCurrentCurl()">Copy cURL</button>
            </div>
            <div class="code-body">${escapeHtml(selectedLog.curl || 'No cURL command available')}</div>
          </div>
        `;
      }
    }

    function renderHighlighted(raw) {
      if (raw == null || raw === '') return '<span style="color: var(--text-muted);">Empty</span>';

      if (typeof raw === 'object') {
        return syntaxHighlightJson(JSON.stringify(raw, null, 2));
      }

      const str = raw.toString().trim();
      if ((str.startsWith('{') && str.endsWith('}')) || (str.startsWith('[') && str.endsWith(']'))) {
        try {
          const parsed = JSON.parse(str);
          return syntaxHighlightJson(JSON.stringify(parsed, null, 2));
        } catch (_) {}
      }

      return escapeHtml(str);
    }

    function syntaxHighlightJson(jsonStr) {
      const escaped = escapeHtml(jsonStr);
      return escaped.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+-]?\d+)?)/g, function (match) {
        let cls = 'json-number';
        if (/^"/.test(match)) {
          if (/:$/.test(match)) {
            cls = 'json-key';
          } else {
            cls = 'json-string';
          }
        } else if (/true|false/.test(match)) {
          cls = 'json-boolean';
        } else if (/null/.test(match)) {
          cls = 'json-null';
        }
        return '<span class="' + cls + '">' + match + '</span>';
      });
    }

    function escapeJson(val) {
      if (val == null) return '';
      if (typeof val === 'object') return JSON.stringify(val);
      return val.toString().replace(/'/g, "\\'");
    }

    function escapeHtml(str) {
      return (str || '').toString()
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
    }

    function copyQueryParams() {
      if (!selectedLog || !selectedLog.queryparameter) {
        showToast('No query parameters to copy', 'info');
        return;
      }
      const raw = typeof selectedLog.queryparameter === 'string'
        ? selectedLog.queryparameter
        : JSON.stringify(selectedLog.queryparameter, null, 2);
      copyRaw(raw);
    }

    function copyHeaders() {
      if (!selectedLog || !selectedLog.header) {
        showToast('No headers to copy', 'info');
        return;
      }
      const raw = typeof selectedLog.header === 'string'
        ? selectedLog.header
        : JSON.stringify(selectedLog.header, null, 2);
      copyRaw(raw);
    }

    function copyRequestBody() {
      if (!selectedLog || !selectedLog.data) {
        showToast('No request body to copy', 'info');
        return;
      }
      const raw = typeof selectedLog.data === 'string'
        ? selectedLog.data
        : JSON.stringify(selectedLog.data, null, 2);
      copyRaw(raw);
    }

    function copyResponseData() {
      if (!selectedLog) return;
      const raw = selectedLog.responseData || selectedLog.response_data || (selectedLog.type !== 'REQUEST' ? selectedLog.data : null) || selectedLog.message || '';
      if (!raw) {
        showToast('No response data to copy', 'info');
        return;
      }
      const text = typeof raw === 'string' ? raw : JSON.stringify(raw, null, 2);
      copyRaw(text);
    }

    function copyCurrentCurl() {
      if (!selectedLog) {
        showToast('No log selected', 'info');
        return;
      }

      let curl = selectedLog.curl;
      if (!curl || !curl.trim()) {
        const method = (selectedLog.method || 'GET').toUpperCase();
        const url = selectedLog.path || '';
        let parts = [`curl -X ${method} "${url}"`];

        if (hasContent(selectedLog.header)) {
          try {
            const h = typeof selectedLog.header === 'string' ? JSON.parse(selectedLog.header) : selectedLog.header;
            for (const [k, v] of Object.entries(h)) {
              parts.push(`-H "${k}: ${v}"`);
            }
          } catch (_) {}
        }

        if (hasRequestBody(selectedLog)) {
          const b = typeof selectedLog.data === 'string' ? selectedLog.data : JSON.stringify(selectedLog.data);
          parts.push(`--data '${b.replace(/'/g, "\\'")}'`);
        }

        curl = parts.join(' \\\n  ');
      }

      copyRaw(curl);
    }

    function copyRaw(text) {
      if (!text) {
        showToast('Nothing to copy', 'info');
        return;
      }

      // Try modern clipboard API in secure contexts
      if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(text).then(() => {
          showToast('Copied to clipboard!', 'success');
        }).catch(() => {
          fallbackCopy(text);
        });
        return;
      }

      // Fallback for non-secure HTTP context (e.g. http://192.168.x.x:21616)
      fallbackCopy(text);
    }

    function fallbackCopy(text) {
      try {
        const textArea = document.createElement("textarea");
        textArea.value = text;
        textArea.style.position = "fixed";
        textArea.style.top = "0";
        textArea.style.left = "0";
        textArea.style.width = "2em";
        textArea.style.height = "2em";
        textArea.style.padding = "0";
        textArea.style.border = "none";
        textArea.style.outline = "none";
        textArea.style.boxShadow = "none";
        textArea.style.background = "transparent";
        textArea.style.opacity = "0";
        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();
        textArea.setSelectionRange(0, 99999);

        const successful = document.execCommand('copy');
        document.body.removeChild(textArea);
        if (successful) {
          showToast('Copied to clipboard!', 'success');
        } else {
          showToast('Failed to copy', 'danger');
        }
      } catch (err) {
        console.error('Copy fallback error', err);
        showToast('Failed to copy', 'danger');
      }
    }

    // Modern Toast Notification
    function showToast(msg, type = 'success') {
      const container = document.getElementById('toast-container');
      const toast = document.createElement('div');
      toast.className = `toast toast-${type}`;

      let icon = '✓';
      if (type === 'danger') icon = '🗑️';
      else if (type === 'info') icon = 'ℹ️';

      toast.innerHTML = `<span style="font-size: 15px;">${icon}</span> <span>${msg}</span>`;
      container.appendChild(toast);

      requestAnimationFrame(() => {
        toast.classList.add('show');
      });

      setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 250);
      }, 2600);
    }

    // Modal Handlers
    function openExportModal() {
      document.getElementById('export-modal').classList.add('active');
    }

    function closeExportModal() {
      document.getElementById('export-modal').classList.remove('active');
    }

    function openClearModal() {
      document.getElementById('clear-modal').classList.add('active');
    }

    function closeClearModal() {
      document.getElementById('clear-modal').classList.remove('active');
    }

    function confirmClearLogs() {
      closeClearModal();
      allLogs = [];
      selectedLog = null;
      renderLogsList();
      renderDetailView();
      showToast('All logs have been cleared.', 'danger');
    }

    // File Download Helper
    function downloadFile(content, fileName, mimeType) {
      const blob = new Blob([content], { type: mimeType });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = fileName;
      document.body.appendChild(a);
      a.click();
      setTimeout(() => {
        a.remove();
        URL.revokeObjectURL(url);
      }, 100);
    }

    // 1. Export HAR Format
    function exportHar() {
      closeExportModal();
      if (allLogs.length === 0) {
        showToast('No logs to export', 'info');
        return;
      }

      const entries = allLogs.map(log => {
        const started = new Date().toISOString();
        const duration = getDuration(log) || 50;

        // Parse headers
        let headersList = [];
        if (log.header) {
          try {
            const h = typeof log.header === 'string' ? JSON.parse(log.header) : log.header;
            headersList = Object.entries(h).map(([k, v]) => ({ name: k, value: String(v) }));
          } catch (_) {}
        }

        // Parse query params
        let queryList = [];
        if (log.queryparameter) {
          try {
            const q = typeof log.queryparameter === 'string' ? JSON.parse(log.queryparameter) : log.queryparameter;
            queryList = Object.entries(q).map(([k, v]) => ({ name: k, value: String(v) }));
          } catch (_) {}
        }

        // Post data
        let postData = null;
        if (hasRequestBody(log)) {
          postData = {
            mimeType: 'application/json',
            text: typeof log.data === 'string' ? log.data : JSON.stringify(log.data)
          };
        }

        // Response content
        const resText = log.responseData || (log.type !== 'REQUEST' ? log.data : '') || '';
        const resStr = typeof resText === 'string' ? resText : JSON.stringify(resText);
        const statusCode = parseInt(log.response) || (log.type === 'ERROR' ? 500 : 200);

        return {
          startedDateTime: started,
          time: duration,
          request: {
            method: log.method || 'GET',
            url: log.path || 'http://unknown',
            httpVersion: 'HTTP/1.1',
            cookies: [],
            headers: headersList,
            queryString: queryList,
            postData: postData,
            headersSize: -1,
            bodySize: postData ? postData.text.length : 0
          },
          response: {
            status: statusCode,
            statusText: log.response || 'OK',
            httpVersion: 'HTTP/1.1',
            cookies: [],
            headers: [],
            content: {
              size: resStr.length,
              mimeType: log.content_type || 'application/json',
              text: resStr
            },
            redirectURL: '',
            headersSize: -1,
            bodySize: resStr.length
          },
          cache: {},
          timings: {
            send: 0,
            wait: duration,
            receive: 0
          }
        };
      });

      const harObj = {
        log: {
          version: '1.2',
          creator: {
            name: 'Floating Logger Web Inspector',
            version: '1.0'
          },
          entries: entries
        }
      };

      downloadFile(JSON.stringify(harObj, null, 2), `floating_logger_${Date.now()}.har`, 'application/json');
      showToast(`Exported ${entries.length} requests as HAR`, 'success');
    }

    // 2. Export Postman Collection v2.1
    function exportPostman() {
      closeExportModal();
      if (allLogs.length === 0) {
        showToast('No logs to export', 'info');
        return;
      }

      const items = allLogs.map((log, idx) => {
        let headersList = [];
        if (log.header) {
          try {
            const h = typeof log.header === 'string' ? JSON.parse(log.header) : log.header;
            headersList = Object.entries(h).map(([k, v]) => ({ key: k, value: String(v), type: 'text' }));
          } catch (_) {}
        }

        let queryList = [];
        if (log.queryparameter) {
          try {
            const q = typeof log.queryparameter === 'string' ? JSON.parse(log.queryparameter) : log.queryparameter;
            queryList = Object.entries(q).map(([k, v]) => ({ key: k, value: String(v) }));
          } catch (_) {}
        }

        let bodyObj = null;
        if (hasRequestBody(log)) {
          bodyObj = {
            mode: 'raw',
            raw: typeof log.data === 'string' ? log.data : JSON.stringify(log.data, null, 2),
            options: { raw: { language: 'json' } }
          };
        }

        const fullUrl = log.path || 'http://localhost';

        // 1. Clean Title for Postman sidebar
        let itemName = fullUrl;
        let urlObject = null;
        try {
          const parsed = new URL(fullUrl.startsWith('/') ? 'http://localhost' + fullUrl : fullUrl);
          itemName = parsed.pathname || fullUrl;
          if (itemName.endsWith('/') && itemName.length > 1) {
            itemName = itemName.slice(0, -1);
          }

          const hostParts = parsed.hostname ? parsed.hostname.split('.') : ['localhost'];
          const pathParts = parsed.pathname ? parsed.pathname.split('/').filter(p => p.length > 0) : [];
          const queryParts = [];
          parsed.searchParams.forEach((val, key) => {
            queryParts.push({ key: key, value: val });
          });

          urlObject = {
            raw: fullUrl,
            protocol: parsed.protocol ? parsed.protocol.replace(':', '') : 'http',
            host: hostParts,
            path: pathParts
          };
          if (parsed.port) {
            urlObject.port = parsed.port;
          }
          if (queryParts.length > 0) {
            urlObject.query = queryParts;
          }
        } catch (_) {
          urlObject = {
            raw: fullUrl,
            host: [fullUrl]
          };
        }

        return {
          name: itemName,
          request: {
            method: log.method || 'GET',
            header: headersList,
            body: bodyObj,
            url: urlObject
          }
        };
      });

      const postmanObj = {
        info: {
          name: `Floating Logger - ${new Date().toLocaleDateString()}`,
          schema: 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json'
        },
        item: items
      };

      downloadFile(JSON.stringify(postmanObj, null, 2), `floating_logger_postman_${Date.now()}.json`, 'application/json');
      showToast(`Exported ${items.length} requests for Postman`, 'success');
    }

    // 3. Export Raw JSON
    function exportRawJson() {
      closeExportModal();
      if (allLogs.length === 0) {
        showToast('No logs to export', 'info');
        return;
      }
      downloadFile(JSON.stringify(allLogs, null, 2), `floating_logger_export_${Date.now()}.json`, 'application/json');
      showToast(`Exported ${allLogs.length} logs as JSON`, 'success');
    }

    // Import Logs Feature
    function triggerImport() {
      document.getElementById('import-file-input').click();
    }

    function handleFileImport(event) {
      const file = event.target.files[0];
      if (!file) return;

      const reader = new FileReader();
      reader.onload = (e) => {
        try {
          const content = JSON.parse(e.target.result);

          // Detect HAR file format
          if (content.log && Array.isArray(content.log.entries)) {
            const parsed = content.log.entries.map(ent => {
              const req = ent.request || {};
              const res = ent.response || {};
              return {
                type: res.status ? 'RESPONSE' : 'REQUEST',
                method: req.method || 'GET',
                response: String(res.status || '200'),
                path: req.url || '',
                responseTime: Math.round(ent.time || 0),
                response_time: Math.round(ent.time || 0),
                header: req.headers ? JSON.stringify(req.headers.reduce((acc, cur) => { acc[cur.name] = cur.value; return acc; }, {}), null, 2) : '',
                queryparameter: req.queryString ? JSON.stringify(req.queryString.reduce((acc, cur) => { acc[cur.name] = cur.value; return acc; }, {}), null, 2) : '',
                data: req.postData ? req.postData.text : '',
                responseData: res.content ? res.content.text : '',
                curl: '',
                message: res.statusText || 'Imported from HAR'
              };
            });

            allLogs = [...parsed, ...allLogs];
            renderLogsList();
            if (parsed.length > 0) selectLogByIndex(0);
            showToast(`Imported ${parsed.length} requests from HAR!`, 'success');
          } else if (Array.isArray(content)) {
            // Native Floating Logger JSON array
            allLogs = [...content, ...allLogs];
            renderLogsList();
            if (content.length > 0) selectLogByIndex(0);
            showToast(`Imported ${content.length} logs!`, 'success');
          } else {
            showToast('Unsupported file format. Please upload Floating Logger JSON or HAR.', 'danger');
          }
        } catch (err) {
          console.error("Failed to parse imported file", err);
          showToast('Invalid JSON file.', 'danger');
        }
        event.target.value = '';
      };
      reader.readAsText(file);
    }

    // Initialize
    initTheme();
    fetchDeviceInfo();
    fetchInitialLogs();
    connectWs();
  </script>
</body>
</html>
''';
