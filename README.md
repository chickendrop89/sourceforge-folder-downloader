# sourceforge-downloader

A recursive sourceforge folder downloader for the linux shell 

## Usage:
```shell
sf-downloader.sh <sourceforge folder url> [output directory] [-ow, --overwrite]
```

---

- `<required> sourceforge folder url`
    - example: `https://sourceforge.net/projects/winscp/files/WinSCP/2.0%20beta/`

- `[optional] output directory`
    - example: `winscp-2.0`

- `[optional] -ow, --overwrite`
    - Whenever to overwrite files if they exist

## Requirements:
- Basic linux utilities that are present on every system like: `sed`, `grep`, and `curl`
- Any posix-compliant linux shell
