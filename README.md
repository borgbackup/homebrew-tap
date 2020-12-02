# BorgBackup [Homebrew](https://brew.sh/) tap

## How do I install borgbackup from here?

```shell
brew install borgbackup/tap/borgbackup-llfuse
```

This will install latest stable `borgbackup` including the latest stable `llfuse`.

Using this, `borg mount` will work if you also have `FUSE for macOS` (aka `osxfuse`) installed.
If you do not have `osxfuse` installed, everything will still work, except `borg mount`.

## How do I install formulas from here in general?

```shell
brew install borgbackup/tap/<formula>
```

Or `brew tap borgbackup/tap` and then `brew install <formula>`.

## Documentation

`brew help`, `man brew` or check [Homebrew’s documentation](https://docs.brew.sh).
