require 'formula'

class GstRtsp < Formula
  version "010"
  homepage 'http://gstreamer.freedesktop.org/'
  url 'http://gstreamer.freedesktop.org/src/gst-rtsp/gst-rtsp-0.10.8.tar.bz2'
  sha256 '9915887cf8515bda87462c69738646afb715b597613edc7340477ccab63a6617'

  depends_on 'pkg-config' => :build
  depends_on 'gettext'
  depends_on 'homebrew/versions/gst-plugins-base@010'

  def install
    system "./configure",  "--disable-debug", "--disable-dependency-tracking",
                           "--prefix=#{prefix}",
                           "--disable-gtk-doc"
    system "make"
    system "make install"
  end
end
