updater = File.exists?("updater.exe") ? "updater.exe" : "updater"

print(
  "Run updater to download the game files.\n\nLocation: " + File.join(Dir.pwd, updater)
)
