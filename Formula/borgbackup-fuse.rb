require "digest"

class OsxfuseRequirement < Requirement
  fatal true

  satisfy(build_env: false) { self.class.binary_osxfuse_installed? }

  def self.binary_osxfuse_installed?
    File.exist?("/usr/local/include/fuse/fuse.h") &&
      !File.symlink?("/usr/local/include/fuse")
  end

  env do
    ENV.append_path "PKG_CONFIG_PATH",
                    "/usr/local/lib/pkgconfig:#{HOMEBREW_PREFIX}/lib/pkgconfig:" \
                    "#{HOMEBREW_PREFIX}/opt/openssl@3/lib/pkgconfig"
    ENV.append_path "BORG_OPENSSL_PREFIX", "#{HOMEBREW_PREFIX}/opt/openssl@3/"

    if HOMEBREW_PREFIX.to_s != "/usr/local"
      ENV.append_path "HOMEBREW_LIBRARY_PATHS", "/usr/local/lib"
      ENV.append_path "HOMEBREW_INCLUDE_PATHS", "/usr/local/include/fuse"
    end
  end

  def message
    "macFUSE is required to build borgbackup-fuse. Please run `brew install --cask macfuse` first."
  end
end

class BorgbackupFuse < Formula
  include Language::Python::Virtualenv

  desc "Deduplicating archiver with compression and authenticated encryption"
  homepage "https://borgbackup.org/"
  url "https://files.pythonhosted.org/packages/eb/38/7fc8c8c7d9dba455f0e29f2ab5b77109313f4e58fe5014d0e1b7855de3cd/borgbackup-1.4.4.tar.gz"
  sha256 "2716bc124a24908efcac9436df31b716d1f0bbd828ad39b18f73bfdd772a651a"
  license "BSD-3-Clause"

  livecheck do
    url "https://github.com/borgbackup/borg/releases/latest"
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
  end

  depends_on OsxfuseRequirement => :build
  depends_on "pkg-config" => :build
  depends_on "libb2"
  depends_on "lz4"
  depends_on "openssl@3"
  depends_on "python@3.14"
  depends_on "xxhash"
  depends_on "zstd"

  conflicts_with "borgbackup", because: "borgbackup-fuse is a patched version of borgbackup"

  resource "llfuse" do
    url "https://files.pythonhosted.org/packages/e7/21/5a4d639746cb0d32ede867012610233da947165994ff07fa9db965460aa6/llfuse-1.5.2.tar.gz"
    sha256 "3f7fdc86e3db433c48cb6505fe3000ec1b3e84a4a40a84ad67b8df3a847f0697"
  end

  resource "msgpack" do
    url "https://files.pythonhosted.org/packages/4d/f2/bfb55a6236ed8725a96b0aa3acbd0ec17588e6a2c3b62a93eb513ed8783f/msgpack-1.1.2.tar.gz"
    sha256 "3b60763c1373dd60f398488069bcdc703cd08a711477b5d480eecc9f9626f47e"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/65/ee/299d360cdc32edc7d2cf530f3accf79c4fca01e96ffc950d8a52213bd8e4/packaging-26.0.tar.gz"
    sha256 "00243ae351a257117b6a241061796684b084ed1c516a08c48a3f7e147a9d80b4"
  end

  def install
    ENV["BORG_LIBB2_PREFIX"] = Formula["libb2"].prefix
    ENV["BORG_LIBLZ4_PREFIX"] = Formula["lz4"].prefix
    ENV["BORG_LIBXXHASH_PREFIX"] = Formula["xxhash"].prefix
    ENV["BORG_LIBZSTD_PREFIX"] = Formula["zstd"].prefix
    ENV["BORG_OPENSSL_PREFIX"] = Formula["openssl@3"].prefix

    virtualenv_install_with_resources

    man1.install Dir["docs/man/*.1"]
    bash_completion.install "scripts/shell_completions/bash/borg"
    fish_completion.install "scripts/shell_completions/fish/borg.fish"
    zsh_completion.install "scripts/shell_completions/zsh/_borg"
  end

  test do
    # Create a repo and archive, then test extraction.
    cp test_fixtures("test.pdf"), testpath
    Dir.chdir(testpath) do
      system "#{bin}/borg", "init", "-e", "none", "test-repo"
      system "#{bin}/borg", "create", "--compression", "zstd", "test-repo::test-archive", "test.pdf"
    end
    mkdir testpath/"restore" do
      system "#{bin}/borg", "extract", testpath/"test-repo::test-archive"
    end
    assert_path_exists testpath/"restore/test.pdf"
    assert_equal Digest::SHA256.file(testpath/"restore/test.pdf"), Digest::SHA256.file(testpath/"test.pdf")
  end
end
