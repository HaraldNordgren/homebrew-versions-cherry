class Ruby < Formula
  version "20"
  homepage "https://www.ruby-lang.org/"
  url "http://cache.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p645.tar.bz2"
  sha256 "2dcdcf9900cb923a16d3662d067bc8c801997ac3e4a774775e387e883b3683e9"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-versions"
    sha256 "aef709b38390371cc198e3d686b19fb1cd3db582e86a57b383ff676d4ca180bb" => :yosemite
    sha256 "a7482f43da1343f92cf32948166fb306ed1ec2d33d151f4299130004642c89e3" => :mavericks
    sha256 "baff2f0a5cb099383800d240dc3219be67b787287a0dbb7d3cfc33384673e67c" => :mountain_lion
  end

  option :universal
  option "with-suffix", "Suffix commands with '20'"
  option "with-doc", "Install documentation"
  option "with-tcltk", "Install with Tcl/Tk support"

  depends_on "pkg-config" => :build
  depends_on "readline" => :recommended
  depends_on "gdbm" => :optional
  depends_on "libffi" => :optional
  depends_on "libyaml"
  depends_on "openssl"
  depends_on :x11 if build.with? "tcltk"

  fails_with :llvm do
    build 2326
  end

  def install
    args = %W[--prefix=#{prefix} --enable-shared]

    if build.universal?
      ENV.universal_binary
      args << "--with-arch=#{Hardware::CPU.universal_archs.join(",")}"
    end

    args << "--program-suffix=20" if build.with? "suffix"
    args << "--with-out-ext=tk" if build.without? "tcltk"
    args << "--disable-install-doc" if build.without? "doc"
    args << "--disable-dtrace" unless MacOS::CLT.installed?

    paths = []

    paths.concat %w[readline gdbm libffi].map { |dep|
      Formula[dep].opt_prefix if build.with? dep
    }.compact

    paths.concat %w[libyaml openssl].map { |dep|
      Formula[dep].opt_prefix
    }

    args << "--with-opt-dir=#{paths.join(":")}"

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  def post_install
    (lib/"ruby/#{abi_version}/rubygems/defaults/operating_system.rb").write rubygems_config
  end

  def abi_version
    "2.0.0"
  end

  def rubygems_config; <<-EOS.undent
    module Gem
      class << self
        alias :old_default_dir :default_dir
        alias :old_default_path :default_path
        alias :old_default_bindir :default_bindir
        alias :old_ruby :ruby
      end

      def self.default_dir
        path = [
          "#{HOMEBREW_PREFIX}",
          "lib",
          "ruby",
          "gems",
          "#{abi_version}"
        ]

        @default_dir ||= File.join(*path)
      end

      def self.private_dir
        path = if defined? RUBY_FRAMEWORK_VERSION then
                 [
                   File.dirname(RbConfig::CONFIG['sitedir']),
                   'Gems',
                   RbConfig::CONFIG['ruby_version']
                 ]
               elsif RbConfig::CONFIG['rubylibprefix'] then
                 [
                  RbConfig::CONFIG['rubylibprefix'],
                  'gems',
                  RbConfig::CONFIG['ruby_version']
                 ]
               else
                 [
                   RbConfig::CONFIG['libdir'],
                   ruby_engine,
                   'gems',
                   RbConfig::CONFIG['ruby_version']
                 ]
               end

        @private_dir ||= File.join(*path)
      end

      def self.default_path
        if Gem.user_home && File.exist?(Gem.user_home)
          [user_dir, default_dir, private_dir]
        else
          [default_dir, private_dir]
        end
      end

      def self.default_bindir
        "#{HOMEBREW_PREFIX}/bin"
      end

      def self.ruby
        "#{opt_bin}/ruby#{"20" if build.with? "suffix"}"
      end
    end
    EOS
  end

  test do
    system bin/"ruby", "--version"
  end
end
