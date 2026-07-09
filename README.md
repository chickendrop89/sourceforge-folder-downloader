# sourceforge-downloader

A recursive sourceforge folder downloader for the linux shell 

## Usage:
```shell
sf-downloader.sh <sourceforge folder url> [output directory] [-ow, --overwrite] [-nr, --no-resume] [-q, --quiet]
```

---

- `<required> sourceforge folder url`
    - example: `https://sourceforge.net/projects/winscp/files/WinSCP/2.0%20beta/`

- `[optional] output directory`
    - example: `winscp-2.0`

- `[optional] -ow, --overwrite`
    - Whether to overwrite files if they exist
    - This option will also remove any existing .part files of the requested file

- `[optional] -nr, --no-resume`
    - Whether to not create .part files, or resume downloads if they were interrupted

- `[optional] -q, --quiet`
    - Whether to be quiet and indicate error through exit codes

## Requirements:
- Basic linux utilities that are present on every system like: `sed`, `grep`, and `curl`
- Any posix-compliant linux shell
