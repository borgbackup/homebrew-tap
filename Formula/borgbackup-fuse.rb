class OsxfuseRequirement < Requirement
  fatal true

  satisfy(build_env: false) { self.class.binary_osxfuse_installed? }

  def self.binary_osxfuse_installed?
    File.exist?("/usr/local/include/osxfuse/fuse.h") &&
      !File.symlink?("/usr/local/include/osxfuse")
  end

  env do
    ENV.append_path "PKG_CONFIG_PATH", HOMEBREW_LIBRARY/"Homebrew/os/mac/pkgconfig/fuse"

    unless HOMEBREW_PREFIX.to_s == "/usr/local"
      ENV.append_path "HOMEBREW_LIBRARY_PATHS", "/usr/local/lib"
      ENV.append_path "HOMEBREW_INCLUDE_PATHS", "/usr/local/include/osxfuse"
    end
  end

  def message
    "osxfuse is required to build borgbackup-fuse. Please run `brew install --cask osxfuse` first."
  end
end

class BorgbackupFuse < Formula
  include Language::Python::Virtualenv

  desc "Deduplicating archiver with compression and authenticated encryption"
  homepage "https://borgbackup.org/"
  url "https://github.com/borgbackup/borg/releases/download/1.1.14/borgbackup-1.1.14.tar.gz"
  sha256 "7dbb0747cc948673f695cd6de284af215f810fed2eb2a615ef26ddc7c691edba"
  license "BSD-3-Clause"

  livecheck do
    url "https://github.com/borgbackup/borg/releases/latest"
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
  end

  depends_on OsxfuseRequirement => :build
  depends_on "pkg-config" => :build
  depends_on "libb2"
  depends_on "lz4"
  depends_on "openssl@1.1"
  depends_on "python@3.9"
  depends_on "zstd"

  conflicts_with "borgbackup", because: "borgbackup-fuse is a patched version of borgbackup"

  resource "llfuse" do
    url "https://files.pythonhosted.org/packages/8f/73/d35aaf5f650250756b40c1e718ee6a2d552700729476dee24c9837608e1b/llfuse-1.3.8.tar.gz"
    sha256 "b9b573108a840fbaa5c8f037160cc541f21b8cbdc15c5c8a39d5ac8c1b6c4cbc"
  end

  def install
    virtualenv_install_with_resources
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
    assert_predicate testpath/"restore/test.pdf", :exist?
    assert_equal File.size(testpath/"restore/test.pdf"), File.size(testpath/"test.pdf")
  end
end
