class Openssl < Formula
  version "098"
  homepage "https://www.openssl.org"
  url "https://www.openssl.org/source/openssl-0.9.8zf.tar.gz"
  mirror "https://raw.githubusercontent.com/DomT4/LibreMirror/master/OpenSSL/openssl-0.9.8zf.tar.gz"
  sha256 "d5245a29128984192acc5b1fc01e37429b7a01c53cadcb2645e546718b300edb"

  bottle do
    root_url "https://downloads.sf.net/project/machomebrew/Bottles/versions"
    sha1 "71f0611fbc56d1485261b37ef39ed1a184a15603" => :yosemite
    sha1 "ce75e2df6aa958aef7d8617da8155b6db826b05c" => :mavericks
    sha1 "92a1614461c028ed0f56fa4c5195d5425a513411" => :mountain_lion
  end

  keg_only :provided_by_osx

  def install
    args = %W[
      --prefix=#{prefix}
      --openssldir=#{etc}/openssl
      no-ssl2
      zlib-dynamic
      shared
    ]

    if MacOS.prefer_64_bit?
      args << "darwin64-x86_64-cc" << "enable-ec_nistp_64_gcc_128"
    else
      args << "darwin-i386-cc"
    end

    system "perl", "./Configure", *args

    ENV.deparallelize # Parallel compilation fails
    system "make"
    system "make", "test"
    system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"
  end

  test do
    (testpath/"testfile.txt").write("This is a test file")
    expected_checksum = "91b7b0b1e27bfbf7bc646946f35fa972c47c2d32"
    system "#{bin}/openssl", "dgst", "-sha1", "-out", "checksum.txt", "testfile.txt"
    open("checksum.txt") do |f|
      checksum = f.read(100).split("=").last.strip
      assert_equal checksum, expected_checksum
    end
  end
end
