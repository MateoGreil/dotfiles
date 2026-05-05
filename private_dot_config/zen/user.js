// Managed by chezmoi (private_dot_config/zen/user.js).
// run_onchange_install-zen-userjs.sh.tmpl syncs this and chrome/userChrome.css
// into the active profile, where Zen reads them on every launch.
// Edit here, run `chezmoi apply`, restart Zen.

user_pref("zen.theme.border-radius", 0);
user_pref("zen.theme.content-element-separation", 0);

// Required so Zen reads chrome/userChrome.css. The CSS overrides
// --zen-webview-border-radius to defeat the 5px min(...) floor that
// zen-theme.css applies even when zen.theme.border-radius is 0.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
