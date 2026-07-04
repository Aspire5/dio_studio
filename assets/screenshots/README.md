# Screenshot Generation and Reproducibility Guide

Use this document to generate and maintain consistent, premium-looking visual assets for the `dio_more` repository.

---

## Technical Recommendations
- **Recommended Terminal Font:** JetBrains Mono or Fira Code
- **Recommended Terminal Width:** 100 characters (to match standard line widths)
- **Terminal Theme:** Dark (e.g. One Half Dark, Dracula, or VS Code Dark Modern)
- **Contrast Padding:** Apply a 16px background padding with subtle drop-shadows on cropped blocks for pub.dev cards.

---

## Screenshot Inventory

### 1. `01_zero_setup.png`
- **Purpose:** Demonstrate the drop-in onboarding experience of cascade initialization.
- **Example to Run:** `dart example/bin/01_zero_setup.dart`
- **Expected Output:**
  ```text
  === Run Example 01: Zero Setup ===
  ┌── [Req#001] GET https://pub.dev/api/packages/dio_more
  │   Headers:
  │     None
  │   Body:
  │     [Empty Body]
  └──────────────────────────────────────────────────────────
  ```
- **Recommended Crop:** Top edge of visual box request header down to the bottom border of the request block.

### 2. `02_endpoint_registry.png`
- **Purpose:** Show logical path parameter compile resolution output.
- **Example to Run:** `dart example/bin/02_endpoint_registry.dart`
- **Expected Output:**
  ```text
  === Run Example 02: Endpoint Registry ===
  ┌── [Req#001] GET https://pub.dev/api/packages/dio_more
  │   Endpoint: pub.get_package (Environment: production)
  │   Headers:
  │     None
  │   Body:
  │     [Empty Body]
  └──────────────────────────────────────────────────────────
  ```
- **Recommended Crop:** Focus on the line `Endpoint: pub.get_package (Environment: production)` and the compiled path resolver header.

### 3. `03_log_only.png`
- **Purpose:** Demonstrate filtering out non-focused request scopes using focus endpoints.
- **Example to Run:** `dart example/bin/03_log_only.dart`
- **Expected Output:** Displays only the logs corresponding to `pub.get_package`, leaving the publisher query silent.

### 4. `04_error_logging.png`
- **Purpose:** Demonstrate visual red error box formatting for failing requests under `Logging.errorsOnly`.
- **Example to Run:** `dart example/bin/04_error_logging.dart`
- **Expected Output:** A red box outputting the HTTP response status, error type, message, and underlying stacktrace.
