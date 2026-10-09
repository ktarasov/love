# The Love

[🇷🇺 Русская версия ниже](#the-love-1) — or jump directly to [Russian section](#the-love-1).

A simple joke utility that does only one thing — after launching, it outputs the phrase "I love you!" to the console.

If you pass a parameter with a name, the phrase will include that name. For example: "I love you, Jane!".

## Features

- Written in [Zig](https://ziglang.org/) — requires **Zig 0.17.0** or later.
- Detects the system locale automatically and localizes the output (English and Russian are built in).
- Cross-platform: Linux, Windows, and macOS (x86_64 and aarch64 for macOS).
- On Windows, the console output code page is switched to UTF-8 automatically.

## Usage

```sh
love            # I love you!
love Jane       # I love you, Jane!
```

## Build

Build the executable with the standard Zig build system:

```sh
zig build
```

The binary will be placed in the `zig-out/bin` directory.

Run it directly through the build system:

```sh
zig build run            # without arguments
zig build run -- Jane    # with a name argument
```

Run the tests:

```sh
zig build test
```

### Release build

Build optimized (`ReleaseSmall`) binaries for all supported targets (Linux x86_64, Windows x86_64, macOS x86_64, macOS aarch64) and pack them into archives:

```sh
zig build release
```

The archives (`zip` for Windows, `tar.gz` for Linux and macOS) are written to `zig-out/compressed`.

Notes:

- Building the Windows archive requires [7-Zip](https://www.7-zip.org/) (`7z`) to be installed.
- Building the Linux/macOS archives uses the system `tar` utility.

## Localization

The phrase is localized in English and Russian. You can add your localizations in the [`messages.zig`](src/messages.zig) file to the `Strings` array, using a locale code as the key:

```zig
const Strings = [_]MessagesEntity{
    .{ .key = "en_US", .value = "I love you" },
    .{ .key = "ru_RU", .value = "Я люблю тебя" },
};
```

If the system locale has no matching entry, the English message (`en_US`) is used as a fallback.

## Project structure

| File | Description |
| --- | --- |
| [`src/main.zig`](src/main.zig) | Entry point: output, arguments, Windows UTF-8 setup |
| [`src/locale.zig`](src/locale.zig) | System locale detection (Linux, macOS, Windows) |
| [`src/messages.zig`](src/messages.zig) | Localized message strings |
| [`build.zig`](build.zig) | Build script: regular, test, and release steps |

---

# The Love 🇷🇺

[🇬🇧 English version above](#the-love)

Простая шуточная утилита, которая делает только одно — после запуска выводит в консоль фразу «Я люблю тебя!».

Если передать параметр с именем, фраза будет содержать это имя. Например: «Я люблю тебя, Джейн!».

## Возможности

- Написана на [Zig](https://ziglang.org/) — требуется **Zig 0.17.0** или новее.
- Автоматически определяет системную локаль и локализует вывод (встроены английский и русский языки).
- Кроссплатформенность: Linux, Windows и macOS (x86_64 и aarch64 для macOS).
- В Windows кодовая страница консоли автоматически переключается на UTF-8.

## Использование

```sh
love            # Я люблю тебя!
love Джейн      # Я люблю тебя, Джейн!
```

## Сборка

Сборка выполняется стандартной системой сборки Zig:

```sh
zig build
```

Исполняемый файл будет размещён в каталоге `zig-out/bin`.

Запуск напрямую через систему сборки:

```sh
zig build run            # без аргументов
zig build run -- Джейн   # с аргументом-именем
```

Запуск тестов:

```sh
zig build test
```

### Релизная сборка

Сборка оптимизированных (`ReleaseSmall`) бинарников для всех поддерживаемых платформ (Linux x86_64, Windows x86_64, macOS x86_64, macOS aarch64) с упаковкой в архивы:

```sh
zig build release
```

Архивы (`zip` для Windows, `tar.gz` для Linux и macOS) записываются в каталог `zig-out/compressed`.

Примечания:

- Для сборки архива Windows требуется установленный [7-Zip](https://www.7-zip.org/) (`7z`).
- Для сборки архивов Linux/macOS используется системная утилита `tar`.

## Локализация

Фраза локализована на английском и русском языках. Свои локализации можно добавить в файл [`messages.zig`](src/messages.zig) в массив `Strings`, указав код локали в качестве ключа:

```zig
const Strings = [_]MessagesEntity{
    .{ .key = "en_US", .value = "I love you" },
    .{ .key = "ru_RU", .value = "Я люблю тебя" },
};
```

Если для системной локали нет совпадения, используется английское сообщение (`en_US`) как вариант по умолчанию.

## Структура проекта

| Файл | Описание |
| --- | --- |
| [`src/main.zig`](src/main.zig) | Точка входа: вывод, аргументы, настройка UTF-8 в Windows |
| [`src/locale.zig`](src/locale.zig) | Определение системной локали (Linux, macOS, Windows) |
| [`src/messages.zig`](src/messages.zig) | Локализованные строки сообщений |
| [`build.zig`](build.zig) | Скрипт сборки: обычная сборка, тесты и релиз |
