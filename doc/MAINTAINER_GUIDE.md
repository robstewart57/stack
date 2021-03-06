The following should be tested minimally before a release is considered good
to go. This list will likely expand over time:

* Run `etc/scripts/release.hs check` on Linux (32-bit and 64-bit), Windows (`--arch=i386` and `--arch=x86_64`), and OS X. See its
  [README](../etc/scripts/README.md#release.hs) for build and invocation instructions.
  This performs the following checks automatically:
    * `stack install && stack clean && stack install --pedantic && stack test --flag stack:integration-tests` on Linux, Windows, and OS X, which covers:
        * Self-hosting
        * Unit tests
        * Integration tests
        * stack can install GHC
    * Working tree is clean.
* Ensure that `stack --version` gives the correct version number and Git hash, and does not have a dirty tree
* stack can build the wai repo
* Running `stack build` a second time on either stack or wai is a no-op
* Build something that depends on `happy` (suggestion: `hlint`), since `happy` has special logic for moving around the `dist` directory
* Make sure to bump the version number in the .cabal file and the ChangeLog appropriately
* Review man page and other documentation for any changes that need to be made.

Release checklist after testing:

* Create a draft Github release with tag `vX.Y.Z` (where X.Y.Z is the stack package's version).
* Run `etc/scripts/release.hs release` on Linux (Debian 7 32-bit [Vagrantfile](https://github.com/commercialhaskell/stack/tree/master/etc/vagrant/debian-7-i386)/64-bit [Vagrantfile](https://github.com/commercialhaskell/stack/tree/master/etc/vagrant/debian-7-amd64)), Windows (`--arch=i386` and `--arch=x86_64`), and OS X.  This performs the following tasks automatically:
    * Binaries for Linux, Windows, and OS X uploaded to draft Github release.
* Run `etc/scripts/release.hs --binary-variant=gmp4 release` on CentOS 6 32-bit [Vagrantfile](https://github.com/commercialhaskell/stack/tree/master/etc/vagrant/centos-6-i386)/64-bit [Vagrantfile](centos-6-x86_64)).
* Run `etc/scripts/release.hs ubuntu-upload debian-upload` in Linux (Ubuntu or Debian - [Vagrantfile](https://github.com/commercialhaskell/stack/tree/master/etc/vagrant/debian-7-amd64))
* Run `etc/scripts/release.hs centos-upload fedora-upload` on Linux (CentOS or Fedora - [Vagrantfile](https://github.com/commercialhaskell/stack/tree/master/etc/vagrant/centos-7-x86_64))
* Upload Arch Linux packages (manual process)
* Build new MinGHC distribution (See https://github.com/fpco/minghc/commit/51490f398e6722672364548a3855a0bfcba48ffe)

After binaries uploaded:

* Push signed Git tag (matching Github release tag name).
* Publish Github release.
* Upload package to Hackage.
* Announce to haskell-cafe, commercialhaskell, and haskell-stack mailing lists.

For more information, see: https://github.com/commercialhaskell/stack/issues/324
