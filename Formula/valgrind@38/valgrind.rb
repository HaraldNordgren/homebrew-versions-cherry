require 'formula'

class Valgrind < Formula
  version "38"
  homepage 'http://www.valgrind.org/'
  url 'http://valgrind.org/downloads/valgrind-3.8.1.tar.bz2'
  sha1 'aa7a3b0b9903f59a11ae518874852e8ccb12751c'

  depends_on :macos => :snow_leopard
  env :std if :macos == :snow_leopard

  # Valgrind needs vcpreload_core-*-darwin.so to have execute permissions.
  # See #2150 for more information.
  skip_clean 'lib/valgrind'

  # 1: For Xcode-only systems, we have to patch hard-coded paths, use xcrun &
  #    add missing CFLAGS. See: https://bugs.kde.org/show_bug.cgi?id=295084
  # 2: Fix for 10.7.4 w/XCode-4.5, duplicate symbols. Reported upstream in
  #    https://bugs.kde.org/show_bug.cgi?id=307415
  patch do
    url "https://gist.githubusercontent.com/2bits/3784836/raw/f046191e72445a2fc8491cb6aeeabe84517687d9/patch1.diff"
    sha1 "a2252d977302a37873b0f2efe8aa4a4fed2eb2c2"
  end

  patch do
    url "https://gist.githubusercontent.com/2bits/3784930/raw/dc8473c0ac5274f6b7d2eb23ce53d16bd0e2993a/patch2.diff"
    sha1 "6e57aa087fafd178b594e22fd0e00ea7c0eed438"
  end if MacOS.version == :lion

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]
    if MacOS.prefer_64_bit?
      args << "--enable-only64bit" << "--build=amd64-darwin"
    else
      args << "--enable-only32bit"
    end

    system "./configure", *args
    system 'make'
    system "make install"
  end

  test do
    system "#{bin}/valgrind", "ls", "-l"
  end
end
