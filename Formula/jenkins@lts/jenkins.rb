require "formula"

class Jenkins < Formula
  version "lts"
  homepage "http://jenkins-ci.org/#stable"
  url "http://mirrors.jenkins-ci.org/war-stable/1.580.1/jenkins.war"
  sha1 "b9320b2c1ea28247f035bbf0f313948e8a735b78"

  def install
    libexec.install "jenkins.war"
    bin.write_jar_script libexec/"jenkins.war", "jenkins-lts"
  end

  plist_options :manual => "jenkins-lts"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>/usr/bin/java</string>
          <string>-Dmail.smtp.starttls.enable=true</string>
          <string>-jar</string>
          <string>#{opt_prefix}/libexec/jenkins.war</string>
          <string>--httpListenAddress=127.0.0.1</string>
          <string>--httpPort=8080</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
    EOS
  end

  def caveats; <<-EOS.undent
    Note: When using launchctl the port will be 8080.
    EOS
  end
end
