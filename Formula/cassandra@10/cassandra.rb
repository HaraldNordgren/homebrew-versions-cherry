class Cassandra < Formula
  version "10"
  desc "Eventually consistent, distributed key-value store"
  homepage "https://cassandra.apache.org"
  url "https://archive.apache.org/dist/cassandra/1.0.12/apache-cassandra-1.0.12-bin.tar.gz"
  sha256 "97f2896263960aa53faa201b07d5a89d531d5e2ab3d9d788e5fc5bc5e9ef985a"

  def install
    (var/"lib/cassandra").mkpath
    (var/"log/cassandra").mkpath
    (etc/"cassandra").mkpath

    inreplace "conf/cassandra.yaml", "/var/lib/cassandra", "#{var}/lib/cassandra"
    inreplace "conf/log4j-server.properties", "/var/log/cassandra", "#{var}/log/cassandra"
    inreplace "conf/cassandra-env.sh", "/lib/", "/"

    inreplace "bin/cassandra.in.sh" do |s|
      s.gsub! "CASSANDRA_HOME=`dirname $0`/..", "CASSANDRA_HOME=#{libexec}"
      # Store configs in etc, outside of keg
      s.gsub! "CASSANDRA_CONF=$CASSANDRA_HOME/conf", "CASSANDRA_CONF=#{etc}/cassandra"
      # Jars installed to prefix, no longer in a lib folder
      s.gsub! "CASSANDRA_HOME/lib/*.jar", "CASSANDRA_HOME/*.jar"
    end

    rm Dir["bin/*.bat"]

    (etc/"cassandra").install Dir["conf/*"]
    libexec.install Dir["*.txt", "{bin,interface,javadoc,pylib,lib/licenses}"]
    libexec.install Dir["lib/*.jar"]
    bin.write_exec_script Dir["#{libexec}/bin/*"]

    share.install [libexec/"bin/cassandra.in.sh", libexec/"bin/stop-server"]
    inreplace Dir["#{libexec}/bin/cassandra*", "#{libexec}/bin/debug-cql",
                  "#{libexec}/bin/json2sstable", "#{libexec}/bin/nodetool",
                  "#{libexec}/bin/sstable*"],
              %r{`dirname "?\$0"?`\/cassandra.in.sh},
              "#{share}/cassandra.in.sh"
  end

  def caveats; <<-EOS.undent
    If you plan to use the CQL shell (cqlsh), you will need the Python CQL library
    installed. Since Homebrew prefers using pip for Python packages, you can
    install that using:

      pip install cql
  EOS
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/cassandra</string>
            <string>-f</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}/lib/cassandra</string>
      </dict>
    </plist>
  EOS
  end
end
