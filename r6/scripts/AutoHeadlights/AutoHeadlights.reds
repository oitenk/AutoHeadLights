module AutoHeadlights

import Codeware.*

// ============================================================================
//  Auto Headlights - standalone
//
//  Headlights react to ambient light:
//    - time of day (night)
//    - gloomy weather (rain, fog, pollution, sandstorm, heavy clouds)
//    - being under cover (tunnels, garages, overpasses) - with its own delay
//
//  Motorcycles can optionally keep their headlight on at all times.
//
//  Self-contained: uses only vanilla game APIs and does not reference or
//  modify any other mod. When another mod (or the vanilla game) forces the
//  headlights on as you get in or start the engine, this script runs a short
//  "guard window" that immediately puts them back to what the ambient light
//  calls for.
//
//  Pressing your headlight key while driving pauses auto mode; press the
//  pause/resume key (set in Mod Settings) to hand control back to the mod.
//
//  Requires: Codeware, Mod Settings.
// ============================================================================

// ---------------------------------------------------------------------------
//  Settings - shown in the in-game Mod Settings menu under "Auto Headlights"
// ---------------------------------------------------------------------------
public enum AHL_Modifier {
  None = 0,
  Shift = 1,
  Ctrl = 2,
  Alt = 3
}

public class AHL_Config {
  @runtimeProperty("ModSettings.mod", "Auto Headlights")
  @runtimeProperty("ModSettings.category", "General")
  @runtimeProperty("ModSettings.displayName", "Enable auto headlights")
  @runtimeProperty("ModSettings.description", "Headlights switch on and off automatically based on time of day, weather and tunnels.")
  public let enabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "Auto Headlights")
  @runtimeProperty("ModSettings.category", "General")
  @runtimeProperty("ModSettings.displayName", "Pause / resume key")
  @runtimeProperty("ModSettings.description", "While driving, press to pause automatic headlights, or to resume them after you've switched the lights yourself.")
  public let toggleKey: EInputKey = EInputKey.IK_J;

  @runtimeProperty("ModSettings.mod", "Auto Headlights")
  @runtimeProperty("ModSettings.category", "General")
  @runtimeProperty("ModSettings.displayName", "Pause / resume modifier")
  @runtimeProperty("ModSettings.description", "Optional key to hold together with the pause/resume key. None = just the key on its own.")
  public let toggleModifier: AHL_Modifier = AHL_Modifier.None;

  @runtimeProperty("ModSettings.mod", "Auto Headlights")
  @runtimeProperty("ModSettings.category", "General")
  @runtimeProperty("ModSettings.displayName", "Headlight key pauses auto mode")
  @runtimeProperty("ModSettings.description", "When on, switching the headlights yourself pauses auto mode until you press the resume key or get back in the car.")
  public let manualPauses: Bool = true;

  @runtimeProperty("ModSettings.mod", "Auto Headlights")
  @runtimeProperty("ModSettings.category", "General")
  @runtimeProperty("ModSettings.displayName", "Show notifications")
  @runtimeProperty("ModSettings.description", "Show a short on-screen message when auto mode is paused or resumed.")
  public let notifications: Bool = true;

  @runtimeProperty("ModSettings.mod", "Auto Headlights")
  @runtimeProperty("ModSettings.category", "General")
  @runtimeProperty("ModSettings.displayName", "Motorcycle headlights always on")
  @runtimeProperty("ModSettings.description", "When on, motorcycles keep their headlight on whenever the engine is running, day or night. Cars are unaffected.")
  public let bikesAlwaysOn: Bool = true;

  @runtimeProperty("ModSettings.mod", "Auto Headlights")
  @runtimeProperty("ModSettings.category", "Darkness detection")
  @runtimeProperty("ModSettings.displayName", "Lights on from (hour)")
  @runtimeProperty("ModSettings.description", "In-game hour when it counts as night.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "23")
  @runtimeProperty("ModSettings.step", "1")
  public let duskHour: Int32 = 19;

  @runtimeProperty("ModSettings.mod", "Auto Headlights")
  @runtimeProperty("ModSettings.category", "Darkness detection")
  @runtimeProperty("ModSettings.displayName", "Lights off from (hour)")
  @runtimeProperty("ModSettings.description", "In-game hour when it counts as day again.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "23")
  @runtimeProperty("ModSettings.step", "1")
  public let dawnHour: Int32 = 6;

  @runtimeProperty("ModSettings.mod", "Auto Headlights")
  @runtimeProperty("ModSettings.category", "Darkness detection")
  @runtimeProperty("ModSettings.displayName", "Bad weather turns lights on")
  @runtimeProperty("ModSettings.description", "Rain, fog, pollution, sandstorms and heavy clouds count as dark.")
  public let useWeather: Bool = true;

  @runtimeProperty("ModSettings.mod", "Auto Headlights")
  @runtimeProperty("ModSettings.category", "Darkness detection")
  @runtimeProperty("ModSettings.displayName", "Tunnels turn lights on")
  @runtimeProperty("ModSettings.description", "Tunnels, garages and overpasses count as dark.")
  public let useCover: Bool = true;

  @runtimeProperty("ModSettings.mod", "Auto Headlights")
  @runtimeProperty("ModSettings.category", "Darkness detection")
  @runtimeProperty("ModSettings.displayName", "Tunnel ceiling height (m)")
  @runtimeProperty("ModSettings.description", "How far above the vehicle a roof still counts as cover. Lower this if high overpasses and elevated highways trigger the lights.")
  @runtimeProperty("ModSettings.min", "5.0")
  @runtimeProperty("ModSettings.max", "45.0")
  @runtimeProperty("ModSettings.step", "1.0")
  public let coverHeight: Float = 10.0;

  @runtimeProperty("ModSettings.mod", "Auto Headlights")
  @runtimeProperty("ModSettings.category", "Timing")
  @runtimeProperty("ModSettings.displayName", "Night / weather delay (s)")
  @runtimeProperty("ModSettings.description", "Seconds of night or bad weather before the lights come on.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "10.0")
  @runtimeProperty("ModSettings.step", "0.5")
  public let nightWeatherDelay: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Auto Headlights")
  @runtimeProperty("ModSettings.category", "Timing")
  @runtimeProperty("ModSettings.displayName", "Tunnel delay (s)")
  @runtimeProperty("ModSettings.description", "Seconds under cover before the lights come on. Raise this if short overpasses trigger them.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "15.0")
  @runtimeProperty("ModSettings.step", "0.5")
  public let tunnelDelay: Float = 3.0;

  @runtimeProperty("ModSettings.mod", "Auto Headlights")
  @runtimeProperty("ModSettings.category", "Timing")
  @runtimeProperty("ModSettings.displayName", "Lights off delay (s)")
  @runtimeProperty("ModSettings.description", "Seconds of daylight before the lights switch off again.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "15.0")
  @runtimeProperty("ModSettings.step", "0.5")
  public let offDelay: Float = 4.0;
}

// Background system: owns the settings and listens for the pause/resume key.
public class AHL_System extends ScriptableSystem {
  private let m_config: ref<AHL_Config>;
  private let m_shiftHeld: Bool;
  private let m_ctrlHeld: Bool;
  private let m_altHeld: Bool;

  private func OnAttach() -> Void {
    this.m_config = new AHL_Config();
    ModSettings.RegisterListenerToClass(this.m_config);
    GameInstance.GetCallbackSystem().RegisterCallback(n"Input/Key", this, n"OnKeyInput", true);
  }

  private func OnDetach() -> Void {
    if IsDefined(this.m_config) {
      ModSettings.UnregisterListenerToClass(this.m_config);
    };
    GameInstance.GetCallbackSystem().UnregisterCallback(n"Input/Key", this);
  }

  public func GetConfig() -> ref<AHL_Config> {
    if !IsDefined(this.m_config) {
      this.m_config = new AHL_Config();
      ModSettings.RegisterListenerToClass(this.m_config);
    };
    return this.m_config;
  }

  // Returns true if the key was a modifier (state updated, nothing else to do).
  // Matches by key name so left/right variants are both covered.
  private func TrackModifier(evt: ref<KeyInputEvent>) -> Bool {
    let name: String = EnumValueToString("EInputKey", Cast<Int64>(EnumInt(evt.GetKey())));
    let down: Bool;

    if Equals(evt.GetAction(), EInputAction.IACT_Press) {
      down = true;
    } else {
      if Equals(evt.GetAction(), EInputAction.IACT_Release) {
        down = false;
      } else {
        // Repeats etc. - ignore, but still report modifiers as handled.
        return StrContains(name, "Shift") || StrContains(name, "Control") || StrContains(name, "Ctrl") || StrContains(name, "Alt");
      };
    };

    if StrContains(name, "Shift") {
      this.m_shiftHeld = down;
      return true;
    };
    if StrContains(name, "Control") || StrContains(name, "Ctrl") {
      this.m_ctrlHeld = down;
      return true;
    };
    if StrContains(name, "Alt") {
      this.m_altHeld = down;
      return true;
    };
    return false;
  }

  private func IsModifierSatisfied() -> Bool {
    switch this.GetConfig().toggleModifier {
      case AHL_Modifier.Shift:
        return this.m_shiftHeld;
      case AHL_Modifier.Ctrl:
        return this.m_ctrlHeld;
      case AHL_Modifier.Alt:
        return this.m_altHeld;
      default:
        return true;
    };
  }

  private cb func OnKeyInput(evt: ref<KeyInputEvent>) {
    let player: ref<PlayerPuppet>;
    let vehicle: ref<VehicleObject>;
    let comp: ref<VehicleComponent>;

    // Track Shift / Ctrl / Alt (left or right) as they go down and up.
    if this.TrackModifier(evt) {
      return;
    };

    if !Equals(evt.GetAction(), EInputAction.IACT_Press) {
      return;
    };
    if !Equals(evt.GetKey(), this.GetConfig().toggleKey) {
      return;
    };
    if !this.IsModifierSatisfied() {
      return;
    };

    player = GetPlayer(GetGameInstance());
    if !IsDefined(player) {
      return;
    };

    vehicle = player.GetMountedVehicle();
    if !IsDefined(vehicle) || !vehicle.IsPlayerDriver() {
      return;
    };

    comp = vehicle.GetVehicleComponent();
    if IsDefined(comp) {
      comp.AHL_ToggleAuto();
    };
  }
}

public func AHL_Cfg() -> ref<AHL_Config> {
  let sys: ref<AHL_System> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"AutoHeadlights.AHL_System") as AHL_System;

  if IsDefined(sys) {
    return sys.GetConfig();
  };
  return new AHL_Config();
}

public func AHL_Notify(text: String) -> Void {
  let player: ref<PlayerPuppet>;

  if !AHL_Cfg().notifications {
    return;
  };

  player = GetPlayer(GetGameInstance());
  if IsDefined(player) {
    player.SetWarningMessage(text);
  };
}

public abstract class AHL_Settings {
  public static func Enabled() -> Bool { return AHL_Cfg().enabled; }
  public static func ManualPauses() -> Bool { return AHL_Cfg().manualPauses; }
  public static func BikesAlwaysOn() -> Bool { return AHL_Cfg().bikesAlwaysOn; }
  public static func DuskHour() -> Int32 { return AHL_Cfg().duskHour; }
  public static func DawnHour() -> Int32 { return AHL_Cfg().dawnHour; }
  public static func UseWeather() -> Bool { return AHL_Cfg().useWeather; }
  public static func UseCoverDetection() -> Bool { return AHL_Cfg().useCover; }
  public static func CoverHeight() -> Float { return AHL_Cfg().coverHeight; }
  public static func NightWeatherDelay() -> Float { return AHL_Cfg().nightWeatherDelay; }
  public static func TunnelDelay() -> Float { return AHL_Cfg().tunnelDelay; }
  public static func OffDelay() -> Float { return AHL_Cfg().offDelay; }

  // Internal timings (not in the menu).
  public static func SampleInterval() -> Float { return 0.5; }
  public static func GuardSeconds() -> Float { return 2.0; }
}

// ---------------------------------------------------------------------------
//  State (all prefixed ahl_ to stay clear of other mods)
// ---------------------------------------------------------------------------
@addField(VehicleComponent) public let ahl_active: Bool;
@addField(VehicleComponent) public let ahl_token: Int32;
@addField(VehicleComponent) public let ahl_override: Bool;
@addField(VehicleComponent) public let ahl_hasDecision: Bool;
@addField(VehicleComponent) public let ahl_wantOn: Bool;
@addField(VehicleComponent) public let ahl_envDarkSince: Float;
@addField(VehicleComponent) public let ahl_coverSince: Float;
@addField(VehicleComponent) public let ahl_lightSince: Float;
@addField(VehicleComponent) public let ahl_nextSampleAt: Float;
@addField(VehicleComponent) public let ahl_guardUntil: Float;
@addField(VehicleComponent) public let ahl_exitUntil: Float;
@addField(VehicleComponent) public let ahl_lastEngineOn: Bool;
@addField(VehicleComponent) public let ahl_lastSeenStage: Int32;
@addField(VehicleComponent) public let ahl_settleUntil: Float;
@addField(VehicleComponent) public let ahl_resumePending: Bool;
@addField(VehicleComponent) public let ahl_keyArmedUntil: Float;
@addField(VehicleComponent) public let ahl_keyArmedStage: Int32;

@addField(PlayerPuppet) public let ahl_keyListener: ref<AHL_LightsKeyListener>;

public class AHL_TickCallback extends DelayCallback {
  public let vehComp: wref<VehicleComponent>;
  public let token: Int32;

  public func Call() -> Void {
    if IsDefined(this.vehComp) {
      this.vehComp.AHL_Tick(this.token);
    };
  }
}

// Listens to the vanilla headlight key without consuming it, so whatever
// normally handles the key (vanilla or another mod) still works.
public class AHL_LightsKeyListener {
  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    let player: ref<PlayerPuppet>;
    let vehicle: ref<VehicleObject>;
    let comp: ref<VehicleComponent>;
    let actionType: gameinputActionType;

    if !Equals(ListenerAction.GetName(action), n"CycleLights") {
      return false;
    };
    actionType = ListenerAction.GetType(action);
    if !Equals(actionType, gameinputActionType.BUTTON_PRESSED)
        && !Equals(actionType, gameinputActionType.BUTTON_HOLD_COMPLETE) {
      return false;
    };

    player = GetPlayer(GetGameInstance());
    if !IsDefined(player) {
      return false;
    };

    vehicle = player.GetMountedVehicle();
    if !IsDefined(vehicle) || !vehicle.IsPlayerDriver() {
      return false;
    };

    comp = vehicle.GetVehicleComponent();
    if IsDefined(comp) {
      // Don't pause yet: a tap of the vanilla hold-to-toggle key does nothing.
      // Remember the current light state and pause only if it actually changes.
      comp.AHL_ArmManualCheck();
    };

    return false;
  }
}

// ---------------------------------------------------------------------------
//  Helpers
// ---------------------------------------------------------------------------
@addMethod(VehicleComponent)
private final func AHL_Now() -> Float {
  return EngineTime.ToFloat(GameInstance.GetEngineTime(GetGameInstance()));
}

@addMethod(VehicleComponent)
private final func AHL_IsSupported() -> Bool {
  let vehicle: ref<VehicleObject> = this.GetVehicle();
  return IsDefined(vehicle) && !IsDefined(vehicle as ncartMetroObject);
}

// 0 = off, 1 = low beams, 2 = high beams
@addMethod(VehicleComponent)
private final func AHL_CurrentStage() -> Int32 {
  let ctrlPS: ref<vehicleControllerPS> = this.GetVehicleControllerPS();
  let mode: vehicleELightMode;

  if !IsDefined(ctrlPS) {
    return -1;
  };

  mode = ctrlPS.GetHeadLightMode();
  if Equals(mode, vehicleELightMode.Off) {
    return 0;
  };
  if Equals(mode, vehicleELightMode.On) {
    return 1;
  };
  return 2;
}

@addMethod(VehicleComponent)
private final func AHL_ResetDecision() -> Void {
  this.ahl_hasDecision = false;
  this.ahl_envDarkSince = -1.0;
  this.ahl_coverSince = -1.0;
  this.ahl_lightSince = -1.0;
  this.ahl_nextSampleAt = 0.0;
}

// ---------------------------------------------------------------------------
//  Light output
// ---------------------------------------------------------------------------
// Returns true if it changed (or forced) the lights this call.
@addMethod(VehicleComponent)
private final func AHL_Apply(on: Bool, inGuard: Bool) -> Bool {
  let ctrlPS: ref<vehicleControllerPS> = this.GetVehicleControllerPS();
  let controller: ref<vehicleController> = this.GetVehicleController();
  let stage: Int32 = this.AHL_CurrentStage();

  if !IsDefined(ctrlPS) {
    return false;
  };

  if on {
    // Low beams. If high beams are already on, leave them.
    // Only set the light mode: ToggleLights(true, Head) switches on every
    // headlight lamp, high beams included.
    if stage == 0 {
      ctrlPS.SetHeadLightMode(vehicleELightMode.On);
      return true;
    };
    return false;
  };

  // During a guard window we switch off unconditionally, because some scripts
  // turn the lamps on directly without updating the stored light mode.
  if stage != 0 || inGuard {
    ctrlPS.SetHeadLightMode(vehicleELightMode.Off);
    if IsDefined(controller) {
      controller.ToggleLights(false, vehicleELightType.Head);
    };
    return true;
  };

  return false;
}

// ---------------------------------------------------------------------------
//  "Is it dark?" sensors
// ---------------------------------------------------------------------------
@addMethod(VehicleComponent)
private final func AHL_IsNight(gi: GameInstance) -> Bool {
  let timeSystem: ref<TimeSystem> = GameInstance.GetTimeSystem(gi);
  let hour: Int32;
  let dusk: Int32;
  let dawn: Int32;

  if !IsDefined(timeSystem) {
    return false;
  };

  hour = GameTime.Hours(timeSystem.GetGameTime());
  dusk = AHL_Settings.DuskHour();
  dawn = AHL_Settings.DawnHour();

  // Night window crosses midnight (e.g. on at 19, off at 6).
  if dusk > dawn {
    return hour >= dusk || hour < dawn;
  };

  // Night window within one day (e.g. on at 2, off at 5).
  if dusk < dawn {
    return hour >= dusk && hour < dawn;
  };

  // Same hour for both: no night window.
  return false;
}

@addMethod(VehicleComponent)
private final func AHL_IsGloomyWeather(gi: GameInstance) -> Bool {
  let weatherSystem: ref<WeatherSystem> = GameInstance.GetWeatherSystem(gi);
  let name: String;

  if !IsDefined(weatherSystem) {
    return false;
  };

  let state = weatherSystem.GetWeatherState();
  if !IsDefined(state) {
    return false;
  };

  name = NameToString(state.name);

  return StrContains(name, "rain")
      || StrContains(name, "fog")
      || StrContains(name, "pollution")
      || StrContains(name, "sandstorm")
      || StrContains(name, "heavy_clouds");
}

// Three rays straight up (front, middle, rear). Two hits = under a roof.
@addMethod(VehicleComponent)
private final func AHL_IsUnderCover(vehicle: ref<VehicleObject>) -> Bool {
  let spatial: ref<SpatialQueriesSystem> = GameInstance.GetSpatialQueriesSystem(vehicle.GetGame());
  let pos: Vector4;
  let fwd: Vector4;
  let hits: Int32 = 0;

  if !IsDefined(spatial) {
    return false;
  };

  pos = vehicle.GetWorldPosition();
  fwd = vehicle.GetWorldForward();

  if this.AHL_RayHitsCeiling(spatial, pos + fwd * 1.5) { hits += 1; };
  if this.AHL_RayHitsCeiling(spatial, pos) { hits += 1; };
  if this.AHL_RayHitsCeiling(spatial, pos - fwd * 1.5) { hits += 1; };

  return hits >= 2;
}

@addMethod(VehicleComponent)
private final func AHL_RayHitsCeiling(spatial: ref<SpatialQueriesSystem>, origin: Vector4) -> Bool {
  let traceResult: TraceResult;
  let start: Vector4 = origin + new Vector4(0.0, 0.0, 2.5, 0.0);
  // Ray ends at the configured ceiling height above the vehicle.
  let end: Vector4 = origin + new Vector4(0.0, 0.0, MaxF(AHL_Settings.CoverHeight(), 3.0), 0.0);

  return spatial.SyncRaycastByCollisionGroup(start, end, n"Static", traceResult, false, false);
}

// ---------------------------------------------------------------------------
//  Decision logic (time-based, so tick rate doesn't change the delays)
// ---------------------------------------------------------------------------
@addMethod(VehicleComponent)
private final func AHL_Sample(vehicle: ref<VehicleObject>, now: Float) -> Void {
  let gi: GameInstance = vehicle.GetGame();
  let envDark: Bool;
  let covered: Bool = false;

  // Motorcycles: headlight stays on regardless of ambient light.
  if AHL_Settings.BikesAlwaysOn() && IsDefined(vehicle as BikeObject) {
    this.ahl_wantOn = true;
    this.ahl_hasDecision = true;
    this.ahl_resumePending = false;
    return;
  };

  envDark = this.AHL_IsNight(gi) || (AHL_Settings.UseWeather() && this.AHL_IsGloomyWeather(gi));
  if !envDark && AHL_Settings.UseCoverDetection() {
    covered = this.AHL_IsUnderCover(vehicle);
  };

  // Track how long each condition has held.
  if envDark {
    if this.ahl_envDarkSince < 0.0 { this.ahl_envDarkSince = now; };
  } else {
    this.ahl_envDarkSince = -1.0;
  };

  if covered {
    if this.ahl_coverSince < 0.0 { this.ahl_coverSince = now; };
  } else {
    this.ahl_coverSince = -1.0;
  };

  if !envDark && !covered {
    if this.ahl_lightSince < 0.0 { this.ahl_lightSince = now; };
  } else {
    this.ahl_lightSince = -1.0;
  };

  // First reading after the engine starts: night/weather decides instantly,
  // tunnels still wait for their delay.
  if !this.ahl_hasDecision {
    // After a manual resume, tunnels count right away too.
    this.ahl_wantOn = envDark || (this.ahl_resumePending && covered);
    this.ahl_resumePending = false;
    this.ahl_hasDecision = true;
    return;
  };

  if !this.ahl_wantOn {
    if envDark && (now - this.ahl_envDarkSince) >= AHL_Settings.NightWeatherDelay() {
      this.ahl_wantOn = true;
    } else {
      if covered && (now - this.ahl_coverSince) >= AHL_Settings.TunnelDelay() {
        this.ahl_wantOn = true;
      };
    };
  } else {
    if this.ahl_lightSince >= 0.0 && (now - this.ahl_lightSince) >= AHL_Settings.OffDelay() {
      this.ahl_wantOn = false;
    };
  };
}

// ---------------------------------------------------------------------------
//  Pause / resume
// ---------------------------------------------------------------------------
@addMethod(VehicleComponent)
public final func AHL_PauseFromManual() -> Void {
  if this.ahl_override || !AHL_Settings.Enabled() || !AHL_Settings.ManualPauses() {
    return;
  };

  this.ahl_override = true;
  AHL_Notify("Auto headlights paused");
}

@addMethod(VehicleComponent)
public final func AHL_ArmManualCheck() -> Void {
  // Keep the first snapshot if the key fires twice (press, then hold-complete).
  if this.AHL_Now() < this.ahl_keyArmedUntil {
    return;
  };
  this.ahl_keyArmedStage = this.AHL_CurrentStage();
  this.ahl_keyArmedUntil = this.AHL_Now() + 2.0;
}

@addMethod(VehicleComponent)
public final func AHL_ToggleAuto() -> Void {
  let now: Float = this.AHL_Now();

  if !AHL_Settings.Enabled() {
    AHL_Notify("Auto headlights are disabled in Mod Settings");
    return;
  };

  if !this.ahl_override {
    this.ahl_override = true;
    AHL_Notify("Auto headlights paused");
    return;
  };

  this.ahl_override = false;
  this.AHL_ResetDecision();
  this.ahl_resumePending = true;
  this.ahl_lastSeenStage = -1;
  this.ahl_settleUntil = now + 1.5;
  this.AHL_Start(0.0);
  AHL_Notify("Auto headlights resumed");
}

// ---------------------------------------------------------------------------
//  Monitor loop
// ---------------------------------------------------------------------------
@addMethod(VehicleComponent)
private final func AHL_Start(guardSeconds: Float) -> Void {
  let vehicle: ref<VehicleObject> = this.GetVehicle();
  let now: Float = this.AHL_Now();

  if !AHL_Settings.Enabled() || !this.AHL_IsSupported() {
    return;
  };

  this.ahl_guardUntil = now + guardSeconds;
  this.ahl_exitUntil = 0.0;

  if this.ahl_active {
    return;
  };

  this.ahl_active = true;
  this.ahl_token += 1;
  if this.ahl_token < 1 {
    this.ahl_token = 1;
  };

  this.ahl_lastEngineOn = false;
  this.ahl_lastSeenStage = -1;
  this.AHL_ResetDecision();
  this.AHL_Schedule(vehicle, this.ahl_token, 0.02);
}

@addMethod(VehicleComponent)
private final func AHL_Stop() -> Void {
  this.ahl_active = false;
  this.ahl_token += 1;
  if this.ahl_token < 1 {
    this.ahl_token = 1;
  };
  this.AHL_ResetDecision();
}

@addMethod(VehicleComponent)
private final func AHL_Schedule(vehicle: ref<VehicleObject>, token: Int32, delay: Float) -> Void {
  let cb: ref<AHL_TickCallback>;

  if !IsDefined(vehicle) {
    return;
  };

  cb = new AHL_TickCallback();
  cb.vehComp = this;
  cb.token = token;
  GameInstance.GetDelaySystem(vehicle.GetGame()).DelayCallback(cb, delay, true);
}

@addMethod(VehicleComponent)
public final func AHL_Tick(token: Int32) -> Void {
  let vehicle: ref<VehicleObject>;
  let now: Float;
  let inGuard: Bool;
  let stage: Int32;

  if NotEquals(this.ahl_token, token) || !this.ahl_active {
    return;
  };

  vehicle = this.GetVehicle();
  if !IsDefined(vehicle) || !AHL_Settings.Enabled() {
    this.AHL_Stop();
    return;
  };

  now = this.AHL_Now();

  // --- Player has left the car: briefly hold the lights where they were,
  //     then stop watching this vehicle.
  if !vehicle.IsPlayerDriver() {
    if now < this.ahl_exitUntil && this.ahl_hasDecision && !this.ahl_override {
      this.AHL_Apply(this.ahl_wantOn, true);
      this.AHL_Schedule(vehicle, token, 0.02);
      return;
    };
    this.AHL_Stop();
    return;
  };

  // --- Engine off: nothing to do, but poll quickly so we catch the start.
  if !vehicle.IsEngineTurnedOn() {
    this.ahl_lastEngineOn = false;
    this.ahl_lastSeenStage = -1;
    this.AHL_ResetDecision();
    this.AHL_Schedule(vehicle, token, 0.1);
    return;
  };

  // --- Engine just started: open a guard window.
  if !this.ahl_lastEngineOn {
    this.ahl_lastEngineOn = true;
    this.ahl_guardUntil = now + AHL_Settings.GuardSeconds();
    this.ahl_lastSeenStage = -1;
    this.AHL_ResetDecision();
  };

  inGuard = now < this.ahl_guardUntil;
  stage = this.AHL_CurrentStage();

  // --- Headlight key was pressed recently and the lights really changed.
  if !this.ahl_override && now < this.ahl_keyArmedUntil
      && this.ahl_keyArmedStage >= 0 && stage >= 0 && stage != this.ahl_keyArmedStage {
    this.ahl_keyArmedUntil = 0.0;
    this.AHL_PauseFromManual();
  };

  // --- Backup manual detection: the light mode changed and we didn't do it.
  //     Skipped for a moment after our own changes, because the game reports
  //     the new light mode with a delay.
  if !this.ahl_override && !inGuard && now >= this.ahl_settleUntil
      && this.ahl_lastSeenStage >= 0 && stage != this.ahl_lastSeenStage {
    this.AHL_PauseFromManual();
  };

  if this.ahl_override {
    this.ahl_lastSeenStage = stage;
    this.AHL_Schedule(vehicle, token, AHL_Settings.SampleInterval());
    return;
  };

  if !this.ahl_hasDecision || now >= this.ahl_nextSampleAt {
    this.AHL_Sample(vehicle, now);
    this.ahl_nextSampleAt = now + AHL_Settings.SampleInterval();
  };

  if this.AHL_Apply(this.ahl_wantOn, inGuard) {
    // We just changed the lights: wait for the game to settle, then re-baseline.
    this.ahl_settleUntil = now + 1.5;
    this.ahl_lastSeenStage = -1;
  } else {
    if now >= this.ahl_settleUntil {
      this.ahl_lastSeenStage = this.AHL_CurrentStage();
    };
  };

  if inGuard {
    this.AHL_Schedule(vehicle, token, 0.02);
  } else {
    this.AHL_Schedule(vehicle, token, AHL_Settings.SampleInterval());
  };
}

// ---------------------------------------------------------------------------
//  Lifecycle hooks (vanilla events only)
// ---------------------------------------------------------------------------
@wrapMethod(VehicleComponent)
protected cb func OnVehicleFinishedMountingEvent(evt: ref<VehicleFinishedMountingEvent>) -> Bool {
  let result: Bool = wrappedMethod(evt);
  let vehicle: ref<VehicleObject>;

  if !IsDefined(evt.character) || !evt.character.IsPlayer() {
    return result;
  };

  if !evt.isMounting {
    // Getting out: guard briefly so nothing flips the lights as you leave.
    this.ahl_exitUntil = this.AHL_Now() + AHL_Settings.GuardSeconds();
    return result;
  };

  vehicle = this.GetVehicle();
  if !IsDefined(vehicle) || !vehicle.IsPlayerDriver() {
    return result;
  };

  this.ahl_override = false;
  this.AHL_Start(AHL_Settings.GuardSeconds());

  return result;
}

// Loading a save while sitting in a car.
@wrapMethod(VehicleComponent)
private final func OnGameAttach() -> Void {
  let vehicle: ref<VehicleObject>;

  wrappedMethod();

  vehicle = this.GetVehicle();
  if IsDefined(vehicle) && vehicle.IsPlayerDriver() {
    this.ahl_override = false;
    this.AHL_Start(AHL_Settings.GuardSeconds());
  };
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  let result: Bool = wrappedMethod();

  if !IsDefined(this.ahl_keyListener) {
    this.ahl_keyListener = new AHL_LightsKeyListener();
  };
  this.RegisterInputListener(this.ahl_keyListener, n"CycleLights");

  return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnDetach() -> Bool {
  if IsDefined(this.ahl_keyListener) {
    this.UnregisterInputListener(this.ahl_keyListener);
    this.ahl_keyListener = null;
  };

  return wrappedMethod();
}
