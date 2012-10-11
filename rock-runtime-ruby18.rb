require 'formula'

class RockRuntimeRuby18 < Formula
  homepage 'http://www.ruby-lang.org/en/'
  url 'http://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p370.tar.gz'
  sha1 'ffc5736019c9aa692a05ed95af7fe976afb3da13'

  env :std
  keg_only 'rock'

  depends_on 'readline'
  depends_on 'gdbm'
  depends_on 'libyaml'

  def install_rubygems
    rubygems_version = '1.8.24'

    system 'curl', '-LO', "http://production.cf.rubygems.org/rubygems/rubygems-#{rubygems_version}.tgz"
    system 'tar', '-xzf', "rubygems-#{rubygems_version}.tgz"

    Dir.chdir "rubygems-#{rubygems_version}"

    system 'ruby', 'setup.rb',
      "--prefix=#{prefix}",
      '--rdoc'

    system "mv #{prefix}/lib/*.rb #{prefix}/lib/ruby/1.8"
    system "mv #{prefix}/lib/{rbconfig,rubygems} #{prefix}/lib/ruby/1.8"

    Dir.chdir '..'
  end

  def install_bundler
    bundler_version = '1.1.5'

    system 'curl', '-LO', "http://rubygems.org/downloads/bundler-#{bundler_version}.gem"

    ENV['GEM_HOME'] = "#{prefix}/lib/ruby/gems/1.8"

    system 'gem', 'install',
      '--force',
      '--ignore-dependencies',
      '--no-rdoc',
      '--no-ri',
      '--local',
      '--install-dir', "#{prefix}/lib/ruby/gems/1.8",
      "--bindir", bin,
      "bundler-#{bundler_version}.gem"

    system 'mv', "#{bin}/bundle", "#{bin}/rock-bundle"

    (bin + 'bundle').write <<-EOS.undent
      #!/usr/bin/env bash
      unset RUBYOPT
      exec rock-bundle "$@"
    EOS

    system 'chmod', '755', "#{bin}/bundle"
  end

  def install
    lib.mkpath

    system './configure',
      "--prefix=#{prefix}",
      '--enable-shared'
    system 'make'
    system 'make', 'install'

    ENV['PATH'] = "#{bin}:#{ENV['PATH']}"

    install_rubygems
    install_bundler
  end
end
