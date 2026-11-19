cask "bluefin-wallpapers" do
  version "2026-11-19"

  name "bluefin-wallpapers"
  desc "Wallpapers for Bluefin"
  homepage "https://github.com/projectbluefin/artwork"

  livecheck do
    url "https://github.com/ublue-os/artwork.git"
    regex(/bluefin-v?(\d{4}-\d{2}-\d{2})/)
    strategy :github_releases
  end

  on_macos do
    url "https://github.com/ublue-os/artwork/releases/download/bluefin-v#{version}/bluefin-wallpapers-macos.tar.zstd"
    sha256 "678a4916e0e913f5594657b8ed437289985b8ad79c6c137dbe33bf3c4b77fc48"

    Dir.glob("#{staged_path}/*").each do |file|
      artifact file, target: "#{Dir.home}/Library/Desktop Pictures/Bluefin/#{File.basename(file)}"
    end
  end

  on_linux do
    destination_dir = "#{Dir.home}/.local/share/backgrounds/bluefin"
    kde_destination_dir = "#{Dir.home}/.local/share/wallpapers/bluefin"

    if File.exist?("/usr/bin/plasmashell")
      url "https://github.com/ublue-os/artwork/releases/download/bluefin-v#{version}/bluefin-wallpapers-kde.tar.zstd"
      sha256 "7e6db092c6ad8eff0c79c54e8fb457c956f785f8d0b29f781fc7f21e7abf1040"

      Dir.glob("#{staged_path}/*").each do |file|
        artifact file, target: "#{kde_destination_dir}/#{File.basename(file)}"
      end
    elsif File.exist?("/usr/bin/gnome-shell") || File.exist?("/usr/bin/mutter")
      url "https://github.com/ublue-os/artwork/releases/download/bluefin-v#{version}/bluefin-wallpapers-gnome.tar.zstd"
      sha256 "8ece06d4191ff33ab8f9dda8461b56cb033e766343ec96de0f98d3fd4dcebd96"

      Dir.glob("#{staged_path}/images/*").each do |file|
        artifact file, target: "#{destination_dir}/#{File.basename(file)}"
      end

      Dir.glob("#{staged_path}/gnome-background-properties/*").each do |file|
        artifact file, target: "#{Dir.home}/.local/share/gnome-background-properties/#{File.basename(file)}"
      end
    else
      url "https://github.com/ublue-os/artwork/releases/download/bluefin-v#{version}/bluefin-wallpapers-png.tar.zstd"
      sha256 "5af11518ebc6c07466dbb7d538d954352c1b7ffe452097d7883a7452312bad7c"

      Dir.glob("#{staged_path}/*").each do |file|
        artifact file, target: "#{destination_dir}/#{File.basename(file)}"
      end
    end
  end

  preflight do
    FileUtils.mkdir_p "#{Dir.home}/Library/Desktop Pictures/Bluefin" if OS.mac?

    if OS.linux?
      FileUtils.mkdir_p "#{Dir.home}/.local/share/backgrounds/bluefin"
      FileUtils.mkdir_p "#{Dir.home}/.local/share/wallpapers/bluefin"
      FileUtils.mkdir_p "#{Dir.home}/.local/share/gnome-background-properties"

      Dir.glob("#{staged_path}/**/*.xml").each do |file|
        contents = File.read(file)
        contents.gsub!("~", Dir.home)
        File.write(file, contents)
      end
    end
  end

  postflight do
    if OS.mac?
      puts "Wallpapers installed to: #{Dir.home}/Library/Desktop Pictures/Bluefin"
      puts "To use: System Settings > Wallpaper > Add Folder"
    end
  end
end
