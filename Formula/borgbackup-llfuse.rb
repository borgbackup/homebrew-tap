class BorgbackupLlfuse < Formula
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

  conflicts_with "borgbackup", because: "borgbackup-llfuse is a patched version of borgbackup"

  depends_on osxfuse: :build
  depends_on "pkg-config" => :build
  depends_on "libb2"
  depends_on "lz4"
  depends_on "openssl@1.1"
  depends_on "python@3.9"
  depends_on "zstd"

  resource "llfuse" do
    url "https://files.pythonhosted.org/packages/8f/73/d35aaf5f650250756b40c1e718ee6a2d552700729476dee24c9837608e1b/llfuse-1.3.8.tar.gz"
    sha256 "b9b573108a840fbaa5c8f037160cc541f21b8cbdc15c5c8a39d5ac8c1b6c4cbc"
  end

  def install
    virtualenv_install_with_resources
  end
end