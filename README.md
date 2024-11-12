# BorgBackup [Homebrew](https://brew.sh/) tap

## Why install [Borg](https://www.borgbackup.org/) using this tap vs `brew install borgbackup`?

The `borgbackup-fuse` formula maintained in this tap depends on [macFUSE](https://osxfuse.github.io) and [llfuse](https://github.com/python-llfuse/python-llfuse/) which are required to mount repositories or archives using `borg mount`.

These dependencies have been [removed](https://github.com/Homebrew/homebrew-core/commit/8c2f17e3b653347ada86d353243e2d6b6cb10fda#diff-4a25217474a5eb61d0776ab4cabc43b42689bc7b3efaaed400f799631dcec71f) from Homebrew’s [borgbackup](https://formulae.brew.sh/formula/borgbackup) formula because [FUSE for macOS](https://osxfuse.github.io/) is no longer open source.

If one doesn’t plan on using `borg mount`, installing Borg using `brew install borgbackup` works just fine.

## How to install Borg using this tap?

```shell
brew install --cask macfuse
brew install borgbackup/tap/borgbackup-fuse
```

## How to update to a new BorgBackup version?

1. Get new package URLs and SHAs from [PyPi](https://pypi.org/project/borgbackup/)
2. ~~Lint `brew audit --strict Formula/borgbackup-fuse.rb`~~
3. Install `brew install Formula/borgbackup-fuse.rb`
4. Test `brew test Formula/borgbackup-fuse.rb`

## Documentation

`brew help`, `man brew` or check [Homebrew’s documentation](https://docs.brew.sh).
