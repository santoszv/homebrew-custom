class Pdns < Formula
  desc "Authoritative nameserver"
  homepage "https://www.powerdns.com"
  url "https://downloads.powerdns.com/releases/pdns-4.3.0.tar.bz2"
  sha256 "6be2e70f100df6f32cb431d5f57ca0aabde1fba6c11d947eccc86d44bdf95d08"
  license "GPL-2.0"

  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "lua"
  depends_on "openssl@1.1"
  depends_on "sqlite"
  depends_on "postgresql"

  uses_from_macos "curl"

  def install
    # Fix "configure: error: cannot find boost/program_options.hpp"
    ENV["SDKROOT"] = MacOS.sdk_path if MacOS.version == :sierra

    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}/powerdns
      --with-lua
      --with-libcrypto=#{Formula["openssl@1.1"].opt_prefix}
      --with-sqlite3
      --with-modules=gsqlite3
      --with-modules=gpgsql
    ]

    system "./bootstrap" if build.head?
    system "./configure", *args
    system "make", "install"
  end

  plist_options manual: "pdns_server start"

  def plist
    <<~EOS
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
          <string>#{opt_bin}/pdns_server</string>
        </array>
        <key>EnvironmentVariables</key>
        <key>KeepAlive</key>
        <true/>
        <key>SHAuthorizationRight</key>
        <string>system.preferences</string>
      </dict>
      </plist>
    EOS
  end

  test do
    output = shell_output("#{sbin}/pdns_server --version 2>&1", 99)
    assert_match "PowerDNS Authoritative Server #{version}", output
  end
end
