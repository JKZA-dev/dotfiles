// Usage: osascript -l JavaScript import-terminal-profile.js <file.terminal> <name> <wallpaper>
// Terminal stores the background as a machine-specific bookmark, so it is rebuilt here.
ObjC.import("Foundation");

function run([file, name, wallpaper]) {
  const profile = $.NSMutableDictionary.dictionaryWithContentsOfFile(file);
  const url = $.NSURL.fileURLWithPath(wallpaper);
  const bookmark = url.bookmarkDataWithOptionsIncludingResourceValuesForKeysRelativeToURLError(0, $(), $(), $());
  profile.setObjectForKey($.NSKeyedArchiver.archivedDataWithRootObject(bookmark), $("BackgroundImageBookmark"));

  const defaults = $.NSUserDefaults.alloc.initWithSuiteName("com.apple.Terminal");
  const profiles = $.NSMutableDictionary.dictionaryWithDictionary(defaults.dictionaryForKey("Window Settings"));
  profiles.setObjectForKey(profile, $(name));
  defaults.setObjectForKey(profiles, $("Window Settings"));
  defaults.setObjectForKey($(name), $("Default Window Settings"));
  defaults.setObjectForKey($(name), $("Startup Window Settings"));
  defaults.synchronize;
}
