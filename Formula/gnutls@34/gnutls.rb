# This formula tracks GnuTLS stable-next. This is currently the 3.4.x branch.
class Gnutls < Formula
  version "34"
  homepage "http://gnutls.org"
  url "ftp://ftp.gnutls.org/gcrypt/gnutls/v3.4/gnutls-3.4.1.tar.xz"
  mirror "http://mirrors.dotsrc.org/gcrypt/gnutls/v3.4/gnutls-3.4.1.tar.xz"
  sha256 "e9b5f58becf34756464216056cd5abbf04315eda80a374d02699dee83f80b12e"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    cellar :any
    sha256 "272bcb3fc248f0f7173a8fa867e6398ff70f5fe57ed2b5affdac54a44c174ef4" => :yosemite
    sha256 "20a2b304a5d72f8b5b52b60cc16162e35dec917d0b87b262152fe55becdd0330" => :mavericks
    sha256 "20a9b14a422870a14ab0ef6cf6271bd1eafc63ab0983f1951b8d9cee1207f616" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "libtasn1"
  depends_on "gmp"
  depends_on "nettle@3"
  depends_on "guile" => :optional
  depends_on "unbound" => :optional
  depends_on "libidn" => :optional

  keg_only "Conflicts with GnuTLS in main repository and is not API compatible."

  fails_with :llvm do
    build 2326
    cause "Undefined symbols when linking"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-static
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --with-default-trust-store-file=#{etc}/openssl/cert.pem
      --disable-heartbeat-support
      --without-p11-kit
    ]

    if build.with? "guile"
      args << "--enable-guile"
      args << "--with-guile-site-dir=no"
    end

    system "./configure", *args
    system "make", "install"

    # certtool shadows the OS X certtool utility
    mv bin+"certtool", bin+"gnutls-certtool"
    mv man1+"certtool.1", man1+"gnutls-certtool.1"
  end

  def post_install
    keychains = %w[
      /Library/Keychains/System.keychain
      /System/Library/Keychains/SystemRootCertificates.keychain
    ]

    openssldir = etc/"openssl"
    openssldir.mkpath
    (openssldir/"cert.pem").atomic_write `security find-certificate -a -p #{keychains.join(" ")}`
  end

  test do
    system bin/"gnutls-cli", "--version"
  end
end
