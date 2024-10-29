# sourceforge-downloader

A folder/file SourceForge downloader for the linux shell

## Usage:
```shell
sf-downloader.sh <sourceforge folder url> [output directory]
```

---

- `<required> sourceforge folder url`
    - example: `https://sourceforge.net/projects/orangefox-device-xiaomi-tapas/files/2023-12-09`

- `[optional] output directory`
    - example: `orangefox-tapas`

## Note:
- POSIX shell variants (like `dash`) might not work correctly with this script due to their missing features.
- `bash/ksh/zsh/busybox-ash` are confirmed to work.
