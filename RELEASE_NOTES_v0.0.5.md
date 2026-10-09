# Release Notes — The Love

[🇷🇺 Русская версия ниже](#release-notes--the-love-1) — or jump directly to [Russian section](#release-notes--the-love-1).

## Version 0.0.5

### Overview

This release modernizes the project for the latest Zig compiler versions (0.16.0 and 0.17.0) and significantly improves the release build process: `zig build release` now compiles optimized binaries for all supported platforms and packs them into distributable archives automatically.

### Changes

- **Zig 0.17.0 support.** The codebase has been refactored for the Zig 0.16.0 and 0.17.0 APIs. The minimum required compiler version is now **Zig 0.17.0** (previously 0.15.2). See [`build.zig.zon`](build.zig.zon).
- **Release build improvements.** The `release` step in [`build.zig`](build.zig) has been reworked and optimized:
  - Builds `ReleaseSmall` binaries for Linux x86_64, Windows x86_64, macOS x86_64, and macOS aarch64.
  - Automatically packs the binaries into archives: `zip` for Windows, `tar.gz` for Linux and macOS. The archives are written to `zig-out/compressed`.
  - The build script now adapts to both the Zig 0.16 (`b.args`) and 0.17 (`addPassthruArgs()`) argument-passing APIs.
- **Windows console output.** Added an explicit WinAPI declaration for `SetConsoleOutputCP` in [`src/main.zig`](src/main.zig), used to switch the console code page to UTF-8 on Windows.
- **Documentation.** The [`README.md`](README.md) file has been expanded and restructured: it now includes usage examples, build instructions (including the `release` step), a localization guide, and a project structure overview.
- **Cleanup.** The obsolete [`build.sh`](build.sh) helper script has been removed; all build logic now lives in [`build.zig`](build.zig).

### Upgrade notes

- Make sure you build the project with **Zig 0.17.0** or later — older compiler versions are no longer supported.

---

# Release Notes — The Love 🇷🇺

[🇬🇧 English version above](#release-notes--the-love)

## Версия 0.0.5

### Обзор

Этот релиз адаптирует проект под последние версии компилятора Zig (0.16.0 и 0.17.0) и существенно улучшает процесс релизной сборки: `zig build release` теперь компилирует оптимизированные бинарники для всех поддерживаемых платформ и автоматически упаковывает их в архивы для распространения.

### Изменения

- **Поддержка Zig 0.17.0.** Код переработан под API Zig 0.16.0 и 0.17.0. Минимальная требуемая версия компилятора теперь — **Zig 0.17.0** (ранее 0.15.2). См. [`build.zig.zon`](build.zig.zon).
- **Улучшения релизной сборки.** Шаг `release` в [`build.zig`](build.zig) переработан и оптимизирован:
  - Сборка бинарников в режиме `ReleaseSmall` для Linux x86_64, Windows x86_64, macOS x86_64 и macOS aarch64.
  - Автоматическая упаковка бинарников в архивы: `zip` для Windows, `tar.gz` для Linux и macOS. Архивы записываются в каталог `zig-out/compressed`.
  - Сборочный скрипт теперь работает как с API передачи аргументов Zig 0.16 (`b.args`), так и 0.17 (`addPassthruArgs()`).
- **Вывод в консоль в Windows.** Добавлено явное объявление WinAPI-функции `SetConsoleOutputCP` в [`src/main.zig`](src/main.zig) — она используется для переключения кодовой страницы консоли на UTF-8 в Windows.
- **Документация.** Файл [`README.md`](README.md) расширен и реструктурирован: добавлены примеры использования, инструкции по сборке (включая шаг `release`), описание механизма локализации и обзор структуры проекта.
- **Очистка.** Удалён устаревший вспомогательный скрипт [`build.sh`](build.sh); вся логика сборки теперь находится в [`build.zig`](build.zig).

### Замечания по обновлению

- Убедитесь, что проект собирается компилятором **Zig 0.17.0** или новее — более старые версии компилятора больше не поддерживаются.
