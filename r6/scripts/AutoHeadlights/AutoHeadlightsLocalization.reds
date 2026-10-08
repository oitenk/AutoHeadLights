// Auto Headlights: text shown by the mod, registered with Codeware's localization
// system so it can be translated.
//
// To add a language, copy AHL_LanguageEnglish into a new class (in a file of its own),
// translate the second string of every line and leave the first alone, then return
// the new class for that language from AHL_LocalizationProvider.GetPackage below.
//
// The Mod Settings page is written in English only.
module AutoHeadlights

import Codeware.Localization.*

public class AHL_LocalizationProvider extends ModLocalizationProvider {
  public func GetPackage(language: CName) -> ref<ModLocalizationPackage> {
    switch language {
      // case n"fr-fr": return new AHL_LanguageFrench();
      default: return new AHL_LanguageEnglish();
    }
  }

  public func GetFallback() -> CName {
    return n"en-us";
  }
}

public class AHL_LanguageEnglish extends ModLocalizationPackage {
  protected func DefineTexts() -> Void {
    // On-screen messages when auto mode is paused or resumed
    this.Text("AutoHeadlights-Paused", "Auto headlights paused");
    this.Text("AutoHeadlights-Resumed", "Auto headlights resumed");

    // On-screen message when the pause/resume key is pressed while the mod is switched off
    this.Text("AutoHeadlights-Disabled", "Auto headlights are disabled in Mod Settings");
  }
}

// Text in the language the game is set to.
public func AHL_Text(key: String) -> String {
  let text: String = GetLocalizedTextByKey(StringToName(key));
  return Equals(text, "") || Equals(text, key) ? key : text;
}
