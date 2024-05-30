/*
https://github.com/Zergie/mpcnc_posts_processor
MPCNC posts processor for milling and laser/plasma cutting.
 */

description = "MPCNC Milling - Klipper";
vendor = "Zergie";
vendorUrl = "https://github.com/Zergie/mpcnc_post_processor";


// Internal properties
certificationLevel = 2;
extension = "gcode";
setCodePage("ascii");
capabilities = CAPABILITY_MILLING;

var eComment = {
  Off: 0,
  Important: 1,
  Info: 2,
  Debug: 3,
  prop: {
    0: { name: "Off", value: 0 },
    1: { name: "Important", value: 1 },
    2: { name: "Info", value: 2 },
    3: { name: "Debug", value: 3 }
  }
};

var eCoolant = {
  Off: 0,
  Flood: 1,
  Mist: 2,
  ThroughTool: 3,
  Air: 4,
  AirThroughTool: 5,
  Suction: 6,
  FloodMist: 7,
  FloodThroughTool: 8,
  prop: {
    0: { name: "Off", value: 0 },
    1: { name: "Flood", value: 1 },
    2: { name: "Mist", value: 2 },
    3: { name: "ThroughTool", value: 3 },
    4: { name: "Air", value: 4 },
    5: { name: "AirThroughTool", value: 5 },
    6: { name: "Suction", value: 6 },
    7: { name: "Flood and Mist", value: 7 },
    8: { name: "Flood and ThroughTool", value: 8 },
  }
};


// user-defined properties
properties = {
  job3_CommentLevel: eComment.Info,      // The level of comments included

  fr0_TravelSpeedXY: 5000,             // High speed for travel movements X & Y (mm/min)
  fr1_TravelSpeedZ: 300,               // High speed for travel movements Z (mm/min)
  frA_ScaleFeedrate: false,            // Will feedrated be scaled
  frB_MaxCutSpeedXY: 3000,              // Max speed for cut movements X & Y (mm/min)
  frC_MaxCutSpeedZ: 180,               // Max speed for cut movements Z (mm/min)
  frD_MaxCutSpeedXYZ: 10000,            // Max feedrate after scaling

  mapD_RestoreFirstRapids: false,      // Map first G01 --> G00
  mapE_RestoreRapids: false,           // Map G01 --> G00 for SafeTravelsAboveZ
  mapF_SafeZ: "Retract:15",            // G01 mapped to G00 if Z is >= jobSafeZRapid
  mapG_AllowRapidZ: false,             // Allow G01 --> G00 for vertical retracts and Z descents above safe

  gcodeStart: "START_PRINT",           // Gcode command for start
  gcodeStop: "END_PRINT",              // Gcode command for end

  cl0_coolantA_Mode: eCoolant.Off,     // Enable issuing g-codes for control Coolant channel A
  cl1_cust_coolantAOn: "M7",           // GCode command to turn on Coolant channel A
  cl2_cust_coolantAOff: "M9",          // Gcode command to turn off Coolant channel A
  cl3_coolantB_Mode: eCoolant.Off,     // Use issuing g-codes for control Coolant channel B
  cl4_cust_coolantBOn: "M8",           // GCode command to turn on Coolant channel B
  cl5_cust_coolantBOff: "M9",          // Gcode command to turn off Coolant channel B

  klipper0_url: "",                    // url of the klipper instance (e.g. http://10.0.0.99)
  klipper1_startAfterUpload: false,    // start machining after upload to klipper
};

propertyDefinitions = {
  job3_CommentLevel: {
    title: "Job: Comment Level", description: "Controls the comments include", group: 1,
    type: "integer", default_mm: eComment.Info, default_in: eComment.Info,
    values: [
      { title: eComment.prop[eComment.Off].name, id: eComment.Off },
      { title: eComment.prop[eComment.Important].name, id: eComment.Important },
      { title: eComment.prop[eComment.Info].name, id: eComment.Info },
      { title: eComment.prop[eComment.Debug].name, id: eComment.Debug },
    ]
  },

  fr0_TravelSpeedXY: {
    title: "Feed: Travel speed X/Y", description: "High speed for Rapid movements X & Y (mm/min; in/min)", group: 2,
    type: "spatial", default_mm: 7800, default_in: 100
  },
  fr1_TravelSpeedZ: {
    title: "Feed: Travel Speed Z", description: "High speed for Rapid movements z (mm/min; in/min)", group: 2,
    type: "spatial", default_mm: 300, default_in: 12
  },
  frA_ScaleFeedrate: {
    title: "Feed: Scale Feedrate", description: "Scale feedrate based on X, Y, Z axis maximums", group: 2,
    type: "boolean", default_mm: false, default_in: false
  },
  frB_MaxCutSpeedXY: {
    title: "Feed: Max XY Cut Speed", description: "Maximum X or Y axis cut speed (mm/min; in/min)", group: 2,
    type: "spatial", default_mm: 900, default_in: 35.43
  },
  frC_MaxCutSpeedZ: {
    title: "Feed: Max Z Cut Speed", description: "Maximum Z axis cut speed (mm/min; in/min)", group: 2,
    type: "spatial", default_mm: 180, default_in: 7.08
  },
  frD_MaxCutSpeedXYZ: {
    title: "Feed: Max Toolpath Speed", description: "Maximum scaled feedrate for toolpath (mm/min; in/min)", group: 2,
    type: "spatial", default_mm: 1000, default_in: 39.37
  },

  mapD_RestoreFirstRapids: {
    title: "Map: First G1 -> G0 Rapid", description: "Ensure move to start of a cut is with a G0 Rapid", group: 3,
    type: "boolean", default_mm: false, default_in: false
  },
  mapE_RestoreRapids: {
    title: "Map: G1s -> G0 Rapids", description: "Enable to convert G1s to G0 Rapids when safe", group: 3,
    type: "boolean", default_mm: false, default_in: false
  },
  mapF_SafeZ: {
    title: "Map: Safe Z to Rapid", description: "Must be above or equal to this value to map G1s --> G0s; constant or keyword (see docs)", group: 3,
    type: "string", default_mm: "Retract:15", default_in: "Retract:15"
  },
  mapG_AllowRapidZ: {
    title: "Map: Allow Rapid Z", description: "Enable to include vertical retracts and safe descents", group: 3,
    type: "boolean", default_mm: false, default_in: true
  },

  gcodeStart: {
    title: "Start Gcode", description: "Gcode for start", group: 7,
    type: "string", default_mm: "", default_in: ""
  },
  gcodeStop: {
    title: "Stop/End Gcode", description: "Gcode for end", group: 7,
    type: "string", default_mm: "", default_in: ""
  },

  // Coolant
  cl0_coolantA_Mode: {
    title: "Coolant: A Mode", description: "Enable channel A when tool is set this coolant", group: 8,
    type: "integer", default_mm: 0, default_in: 0,
    values: [
      { title: eCoolant.prop[eCoolant.Off].name, id: eCoolant.Off },
      { title: eCoolant.prop[eCoolant.Flood].name, id: eCoolant.Flood },
      { title: eCoolant.prop[eCoolant.Mist].name, id: eCoolant.Mist },
      { title: eCoolant.prop[eCoolant.ThroughTool].name, id: eCoolant.ThroughTool },
      { title: eCoolant.prop[eCoolant.Air].name, id: eCoolant.Air },
      { title: eCoolant.prop[eCoolant.AirThroughTool].name, id: eCoolant.AirThroughTool },
      { title: eCoolant.prop[eCoolant.Suction].name, id: eCoolant.Suction },
      { title: eCoolant.prop[eCoolant.FloodMist].name, id: eCoolant.FloodMist },
      { title: eCoolant.prop[eCoolant.FloodThroughTool].name, id: eCoolant.FloodThroughTool }
    ]
  },
  cl1_cust_coolantAOn: {
    title: "Coolant: A Enable", description: "GCode to turn On coolant channel A", group: 8,
    type: "string", default_mm: "", default_in: "",
  },
  cl2_cust_coolantAOff: {
    title: "Coolant: A Disable", description: "Gcode to turn Off coolant A", group: 8,
    type: "string", default_mm: "", default_in: "",
  },
  cl3_coolantB_Mode: {
    title: "Coolant: B Mode", description: "Enable channel B when tool is set this coolant", group: 8,
    type: "integer", default_mm: 0, default_in: 0,
    values: [
      { title: eCoolant.prop[eCoolant.Off].name, id: eCoolant.Off },
      { title: eCoolant.prop[eCoolant.Flood].name, id: eCoolant.Flood },
      { title: eCoolant.prop[eCoolant.Mist].name, id: eCoolant.Mist },
      { title: eCoolant.prop[eCoolant.ThroughTool].name, id: eCoolant.ThroughTool },
      { title: eCoolant.prop[eCoolant.Air].name, id: eCoolant.Air },
      { title: eCoolant.prop[eCoolant.AirThroughTool].name, id: eCoolant.AirThroughTool },
      { title: eCoolant.prop[eCoolant.Suction].name, id: eCoolant.Suction },
      { title: eCoolant.prop[eCoolant.FloodMist].name, id: eCoolant.FloodMist },
      { title: eCoolant.prop[eCoolant.FloodThroughTool].name, id: eCoolant.FloodThroughTool }
    ]
  },
  cl4_cust_coolantBOn: {
    title: "Coolant: B Enable", description: "GCode to turn On coolant channel B", group: 8,
    type: "string", default_mm: "", default_in: "",
  },
  cl5_cust_coolantBOff: {
    title: "Coolant: B Disable", description: "Gcode to turn Off coolant B", group: 8,
    type: "string", default_mm: "", default_in: "",
  },

  // klipper
  klipper0_url : {
    title: "Klipper url", description: "URL to upload to (must start with http:// or https://)", group: 9,
    type: "string", default_mm: "", default_in: "",
  },

  klipper1_startAfterUpload : {
    title: "Start After Upload", description: "Start machine after upload", group: 9,
    type: "boolean", default_mm: false, default_in: false,
  },
};

// Formats
var gFormat = createFormat({ prefix: "G", decimals: 1 });
var mFormat = createFormat({ prefix: "M", decimals: 0 });

var xyzFormat = createFormat({ decimals: (unit == MM ? 3 : 4) });
var xFormat = createFormat({ prefix: "X", decimals: (unit == MM ? 3 : 4) });
var yFormat = createFormat({ prefix: "Y", decimals: (unit == MM ? 3 : 4) });
var zFormat = createFormat({ prefix: "Z", decimals: (unit == MM ? 3 : 4) });
var iFormat = createFormat({ prefix: "I", decimals: (unit == MM ? 3 : 4) });
var jFormat = createFormat({ prefix: "J", decimals: (unit == MM ? 3 : 4) });
var kFormat = createFormat({ prefix: "K", decimals: (unit == MM ? 3 : 4) });

var speedFormat = createFormat({ decimals: 0 });
var sFormat = createFormat({ prefix: "S", decimals: 0 });

var pFormat = createFormat({ prefix: "P", decimals: 0 });
var oFormat = createFormat({ prefix: "O", decimals: 0 });

var feedFormat = createFormat({ decimals: (unit == MM ? 0 : 2) });
var fFormat = createFormat({ prefix: "F", decimals: (unit == MM ? 0 : 2) });

var toolFormat = createFormat({ decimals: 0 });
var tFormat = createFormat({ prefix: "T", decimals: 0 });

var taperFormat = createFormat({ decimals: 1, scale: DEG });
var secFormat = createFormat({ decimals: 3, forceDecimal: true }); // seconds - range 0.001-1000

// Linear outputs
var xOutput = createVariable({}, xFormat);
var yOutput = createVariable({}, yFormat);
var zOutput = createVariable({}, zFormat);
var fOutput = createVariable({ force: false }, fFormat);
var sOutput = createVariable({ force: true }, sFormat);

// Circular outputs
var iOutput = createReferenceVariable({}, iFormat);
var jOutput = createReferenceVariable({}, jFormat);
var kOutput = createReferenceVariable({}, kFormat);

// Modals
var gMotionModal = createModal({}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal({ onchange: function () { gMotionModal.reset(); } }, gFormat); // modal group 2 // G17-19
var gAbsIncModal = createModal({}, gFormat); // modal group 3 // G90-91
var gFeedModeModal = createModal({}, gFormat); // modal group 5 // G93-94
var gUnitModal = createModal({}, gFormat); // modal group 6 // G20-21

// Arc support variables
minimumChordLength = spatial(0.01, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = false;
allowedCircularPlanes = undefined;

//---------------- gcode ----------------
// Writes the specified block.
var gcode = "";
function WriteBlock() {
  var line = Array.from(arguments).join(" ");
  gcode += line + "\n";
  writeln(line);
}

function flushMotions() {
  WriteBlock(mFormat.format(400));
}

//---------------- Safe Rapids ----------------

var eSafeZ = {
  CONST: 0,
  FEED: 1,
  RETRACT: 2,
  CLEARANCE: 3,
  ERROR: 4,
  prop: {
    0: { name: "Const", regex: /^\d+\.?\d*$/, numRegEx: /^(\d+\.?\d*)$/, value: 0 },
    1: { name: "Feed", regex: /^Feed:/i, numRegEx: /:(\d+\.?\d*)$/, value: 1 },
    2: { name: "Retract", regex: /^Retract:/i, numRegEx: /:(\d+\.?\d*)$/, alue: 2 },
    3: { name: "Clearance", regex: /^Clearance:/i, numRegEx: /:(\d+\.?\d*)$/, value: 3 },
    4: { name: "Error", regex: /^$/, numRegEx: /^$/, value: 4 }
  }
};

var safeZMode = eSafeZ.CONST;
var safeZHeightDefault = 15;
var safeZHeight;

function parseSafeZProperty() {
  var str = properties.mapF_SafeZ;

  // Look for either a number by itself or 'Feed:', 'Retract:' or 'Clearance:'
  for (safeZMode = eSafeZ.CONST; safeZMode < eSafeZ.ERROR; safeZMode++) {
    if (str.search(eSafeZ.prop[safeZMode].regex) == 0) {
      break;
    }
  }

  // If it was not an error then get the number
  if (safeZMode != eSafeZ.ERROR) {
    safeZHeightDefault = str.match(eSafeZ.prop[safeZMode].numRegEx);

    if ((safeZHeightDefault == null) || (safeZHeightDefault.length != 2)) {
      WriteComment(eComment.Debug, " parseSafeZProperty: " + safeZHeightDefault);
      WriteComment(eComment.Debug, " parseSafeZProperty.length: " + (safeZHeightDefault != null ? safeZHeightDefault.length : "na"));
      WriteComment(eComment.Debug, " parseSafeZProperty: Couldn't find number");
      safeZMode = eSafeZ.ERROR;
      safeZHeightDefault = 15;
    }
    else {
      safeZHeightDefault = safeZHeightDefault[1];
    }
  }

  WriteComment(eComment.Debug, " parseSafeZProperty: safeZMode = '" + eSafeZ.prop[safeZMode].name + "'");
  WriteComment(eComment.Debug, " parseSafeZProperty: safeZHeightDefault = " + safeZHeightDefault);
}

function safeZforSection(_section) {
  if (properties.mapE_RestoreRapids) {
    switch (safeZMode) {
      case eSafeZ.CONST:
        safeZHeight = safeZHeightDefault;
        WriteComment(eComment.Important, " SafeZ using const: " + safeZHeight);
        break;

      case eSafeZ.FEED:
        if (hasParameter("operation:feedHeight_value") && hasParameter("operation:feedHeight_absolute")) {
          let feed = _section.getParameter("operation:feedHeight_value");
          let abs = _section.getParameter("operation:feedHeight_absolute");

          if (abs == 1) {
            safeZHeight = feed;
            WriteComment(eComment.Info, " SafeZ feed level: " + safeZHeight);
          }
          else {
            safeZHeight = safeZHeightDefault;
            WriteComment(eComment.Important, " SafeZ feed level not abs: " + safeZHeight);
          }
        }
        else {
          safeZHeight = safeZHeightDefault;
          WriteComment(eComment.Important, " SafeZ feed level not defined: " + safeZHeight);
        }
        break;

      case eSafeZ.RETRACT:
        if (hasParameter("operation:retractHeight_value") && hasParameter("operation:retractHeight_absolute")) {
          let retract = _section.getParameter("operation:retractHeight_value");
          let abs = _section.getParameter("operation:retractHeight_absolute");

          if (abs == 1) {
            safeZHeight = retract;
            WriteComment(eComment.Info, " SafeZ retract level: " + safeZHeight);
          }
          else {
            safeZHeight = safeZHeightDefault;
            WriteComment(eComment.Important, " SafeZ retract level not abs: " + safeZHeight);
          }
        }
        else {
          safeZHeight = safeZHeightDefault;
          WriteComment(eComment.Important, " SafeZ: retract level not defined: " + safeZHeight);
        }
        break;

      case eSafeZ.CLEARANCE:
        if (hasParameter("operation:clearanceHeight_value") && hasParameter("operation:clearanceHeight_absolute")) {
          var clearance = _section.getParameter("operation:clearanceHeight_value");
          let abs = _section.getParameter("operation:clearanceHeight_absolute");

          if (abs == 1) {
            safeZHeight = clearance;
            WriteComment(eComment.Info, " SafeZ clearance level: " + safeZHeight);
          }
          else {
            safeZHeight = safeZHeightDefault;
            WriteComment(eComment.Important, " SafeZ clearance level not abs: " + safeZHeight);
          }
        }
        else {
          safeZHeight = safeZHeightDefault;
          WriteComment(eComment.Important, " SafeZ clearance level not defined: " + safeZHeight);
        }
        break;

      case eSafeZ.ERROR:
        safeZHeight = safeZHeightDefault;
        WriteComment(eComment.Important, " >>> WARNING: " + propertyDefinitions.mapF_SafeZ.title + "format error: " + safeZHeight);
        break;
    }
  }
}


Number.prototype.round = function (places) {
  return +(Math.round(this + "e+" + places) + "e-" + places);
}

// Returns true if the rules to convert G1s to G0s are satisfied
function isSafeToRapid(x, y, z) {
  if (properties.mapE_RestoreRapids) {

    // Calculat a z to 3 decimal places for zSafe comparison, every where else use z to avoid mixing rounded with unrounded
    var z_round = z.round(3);
    WriteComment(eComment.Debug, "isSafeToRapid z: " + z + " z_round: " + z_round);

    let zSafe = (z_round >= safeZHeight);

    WriteComment(eComment.Debug, "isSafeToRapid zSafe: " + zSafe + " z_round: " + z_round + " safeZHeight: " + safeZHeight);

    // Destination z must be in safe zone.
    if (zSafe) {
      let cur = getCurrentPosition();
      let zConstant = (z == cur.z);
      let zUp = (z > cur.z);
      let xyConstant = ((x == cur.x) && (y == cur.y));
      let curZSafe = (cur.z >= safeZHeight);
      WriteComment(eComment.Debug, "isSafeToRapid curZSafe: " + curZSafe + " cur.z: " + cur.z);

      // Restore Rapids only when the target Z is safe and
      //   Case 1: Z is not changing, but XY are
      //   Case 2: Z is increasing, but XY constant

      // Z is not changing and we know we are in the safe zone
      if (zConstant) {
        return true;
      }

      // We include moves of Z up as long as xy are constant
      else if (properties.mapG_AllowRapidZ && zUp && xyConstant) {
        return true;
      }

      // We include moves of Z down as long as xy are constant and z always remains safe
      else if (properties.mapG_AllowRapidZ && (!zUp) && xyConstant && curZSafe) {
        return true;
      }
    }
  }

  return false;
}

//---------------- Coolant ----------------

function CoolantA(on) {
  coolantText = on ? properties.cl1_cust_coolantAOn : properties.cl2_cust_coolantAOff;
  WriteBlock(coolantText);
}

function CoolantB(on) {
  coolantText = on ? properties.cl4_cust_coolantBOn : properties.cl5_cust_coolantBOff;
  WriteBlock(coolantText);
}

// Manage two channels of coolant by tracking which coolant is being using for
// a channel (0 = disabled). SetCoolant called with desired coolant to use or 0 to disable

var curCoolant = eCoolant.Off;        // The coolant requested by the tool
var coolantChannelA = eCoolant.Off;   // The coolant running in ChannelA
var coolantChannelB = eCoolant.Off;   // The coolant running in ChannelB

function setCoolant(coolant) {
  WriteComment(eComment.Debug, " ---- Coolant: " + coolant + " cur: " + curCoolant + " A: " + coolantChannelA + " B: " + coolantChannelB);

  // If the coolant for this tool is the same as the current coolant then there is nothing to do
  if (curCoolant == coolant) {
    return;
  }

  // We are changing coolant, so disable any active coolant channels
  // before we switch to the other coolant
  if (coolantChannelA != eCoolant.Off) {
    WriteComment((coolant == eCoolant.Off) ? eComment.Important : eComment.Info, " >>> Coolant Channel A: " + eCoolant.prop[eCoolant.Off].name);
    coolantChannelA = eCoolant.Off;
    CoolantA(false);
  }

  if (coolantChannelB != eCoolant.Off) {
    WriteComment((coolant == eCoolant.Off) ? eComment.Important : eComment.Info, " >>> Coolant Channel B: " + eCoolant.prop[eCoolant.Off].name);
    coolantChannelB = eCoolant.Off;
    CoolantB(false);
  }

  // At this point we know that all coolant is off so make that the current coolant
  curCoolant = eCoolant.Off;

  // As long as we are not disabling coolant (coolant = 0), then check if either coolant channel
  // matches the coolant requested. If neither do then issue an warning

  var warn = true;

  if (coolant != eCoolant.Off) {
    if (properties.cl0_coolantA_Mode == coolant) {
      WriteComment(eComment.Important, " >>> Coolant Channel A: " + eCoolant.prop[coolant].name);
      coolantChannelA = coolant;
      curCoolant = coolant;
      warn = false;
      CoolantA(true);
    }

    if (properties.cl3_coolantB_Mode == coolant) {
      WriteComment(eComment.Important, " >>> Coolant Channel B: " + eCoolant.prop[coolant].name);
      coolantChannelB = coolant;
      curCoolant = coolant;
      warn = false;
      CoolantB(true);
    }

    if (warn) {
      WriteComment(eComment.Important, " >>> WARNING: No matching Coolant channel : " + ((coolant <= eCoolant.FloodThroughTool) ? eCoolant.prop[coolant].name : "unknown") + " requested");
    }
  }
}

//---------------- on Entry Points ----------------

// Called in every new gcode file
function onOpen() {
  gMotionModal = createModal({ force: true }, gFormat); // modal group 1 // G0-G3, ...

  // Force F___ on every G0/G1 move
  fOutput = createVariable({ force: true }, fFormat);

  // Determine the safeZHeight to do rapids
  parseSafeZProperty();
}

// Called at end of gcode file
function onClose() {
  flushMotions();
  WriteComment(eComment.Important, " *** STOP begin ***");
  WriteBlock(properties.gcodeStop)
  WriteComment(eComment.Important, " *** STOP end ***");

  const url = properties.klipper0_url;
  if (url.length > 0) {
    var filename = FileSystem.getFilename(getOutputPath());

    const xhr = new XMLHttpRequest();
    xhr.open("POST", `${url}/server/files/upload`, false, null, null);
    xhr.setRequestHeader('Content-Type', ' multipart/form-data; boundary="3a7e4fd3-e5b7-450d-adc4-9bb652adadf2"');
    xhr.send("--3a7e4fd3-e5b7-450d-adc4-9bb652adadf2\r\n" + 
            `Content-Disposition: form-data; name=file; filename=${filename}\r\n` +
            "Content-Type: application/octet-stream\r\n" +
            "\r\n" +
            gcode + 
            "\r\n\r\n" +
            "--3a7e4fd3-e5b7-450d-adc4-9bb652adadf2--\r\n");
    
      if (properties.klipper1_startAfterUpload) {
            const xhr = new XMLHttpRequest();
            xhr.open("POST", `${url}/printer/print/start?filename=${filename}`, false, null, null);
            xhr.send("bob");
    }
  }
}

var forceSectionToStartWithRapid = false;

function onSection() {
  // Every section needs to start with a Rapid to get to the initial location.
  // In the hobby version Rapids have been elliminated and the first command is
  // a onLinear not a onRapid command. This results in not current position being
  // that same as the cut to position which means wecan't determine the direction
  // of the move. Without a direction vector we can't scale the feedrate or convert
  // onLinear moves back into onRapids. By ensuring the first onLinear is treated as
  // a onRapid we have a currentPosition that is correct.

  forceSectionToStartWithRapid = true;

  // Write Start gcode of the documment (after the "onParameters" with the global info)
  if (isFirstSection()) {
    WriteFirstSection();
  }

  WriteComment(eComment.Important, " *** SECTION begin ***");

  // Print min/max boundaries for each section
  vectorX = new Vector(1, 0, 0);
  vectorY = new Vector(0, 1, 0);
  WriteComment(eComment.Info, "   X Min: " + xyzFormat.format(currentSection.getGlobalRange(vectorX).getMinimum()) + " - X Max: " + xyzFormat.format(currentSection.getGlobalRange(vectorX).getMaximum()));
  WriteComment(eComment.Info, "   Y Min: " + xyzFormat.format(currentSection.getGlobalRange(vectorY).getMinimum()) + " - Y Max: " + xyzFormat.format(currentSection.getGlobalRange(vectorY).getMaximum()));
  WriteComment(eComment.Info, "   Z Min: " + xyzFormat.format(currentSection.getGlobalZRange().getMinimum()) + " - Z Max: " + xyzFormat.format(currentSection.getGlobalZRange().getMaximum()));

  // Determine the Safe Z Height to map G1s to G0s
  safeZforSection(currentSection);

  WriteComment(eComment.Info, " " + sectionComment + " - Milling - Tool: " + tool.number + " - " + tool.comment + " " + getToolTypeName(tool.type));

  onCommand(COMMAND_START_SPINDLE);
  onCommand(COMMAND_COOLANT_ON);

  // Display section name in LCD
  display_text(" " + sectionComment);
}

// Called in every section end
function onSectionEnd() {
  resetAll();
  WriteComment(eComment.Important, " *** SECTION end ***");
  WriteComment(eComment.Important, "");
}

function onComment(message) {
  WriteComment(eComment.Important, message);
}

var pendingRadiusCompensation = RADIUS_COMPENSATION_OFF;

function onRadiusCompensation() {
  pendingRadiusCompensation = radiusCompensation;
}

// Rapid movements
function onRapid(x, y, z) {
  forceSectionToStartWithRapid = false;

  rapidMovements(x, y, z);
}

// Feed movements
function onLinear(x, y, z, feed) {
  // If we are allowing Rapids to be recovered from Linear (cut) moves, which is
  // only required when F360 Personal edition is used, then if this Linear (cut)
  // move is the first operationin a Section (milling operation) then convert it
  // to a Rapid. This is OK because Sections normally begin with a Rapid to move
  // to the first cutting location but these Rapids were changed to Linears by
  // the personal edition. If this Rapid is not recovered and feedrate scaling
  // is enabled then the first move to the start of a section will be at the
  // slowest cutting feedrate, generally Z's feedrate.

  if (properties.mapD_RestoreFirstRapids && (forceSectionToStartWithRapid == true)) {
    WriteComment(eComment.Important, " First G1 --> G0");

    forceSectionToStartWithRapid = false;
    onRapid(x, y, z);
  }
  else if (isSafeToRapid(x, y, z)) {
    WriteComment(eComment.Important, " Safe G1 --> G0");

    onRapid(x, y, z);
  }
  else {
    linearMovements(x, y, z, feed, true);
  }
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
  forceSectionToStartWithRapid = false;

  error(localize("Multi-axis motion is not supported."));
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed) {
  forceSectionToStartWithRapid = false;

  error(localize("Multi-axis motion is not supported."));
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  forceSectionToStartWithRapid = false;

  if (pendingRadiusCompensation != RADIUS_COMPENSATION_OFF) {
    error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
    return;
  }
  circular(clockwise, cx, cy, cz, x, y, z, feed)
}

// Called on Dwell Manual NC invocation
function onDwell(seconds) {
  WriteComment(eComment.Important, " >>> Dwell");
  if (seconds > 99999.999) {
    warning(localize("Dwelling time is out of range."));
  }

  seconds = clamp(0.001, seconds, 99999.999);

  WriteBlock(gFormat.format(4), "S" + secFormat.format(seconds));
}

// Called with every parameter in the documment/section
function onParameter(name, value) {

  // Write gcode initial info
  // Product version
  if (name == "generated-by") {
    WriteComment(eComment.Important, value);
    WriteComment(eComment.Important, " Posts processor: " + FileSystem.getFilename(getConfigurationPath()));
  }

  // Date
  else if (name == "generated-at") {
    WriteComment(eComment.Important, " Gcode generated: " + value + " GMT");
  }

  // Document
  else if (name == "document-path") {
    WriteComment(eComment.Important, " Document: " + value);
  }

  // Setup
  else if (name == "job-description") {
    WriteComment(eComment.Important, " Setup: " + value);
  }

  // Get section comment
  else if (name == "operation-comment") {
    sectionComment = value;
  }

  else {
    WriteComment(eComment.Debug, " param: " + name + " = " + value);
  }
}

function onMovement(movement) {
  var id;

  switch (movement) {
    case MOVEMENT_RAPID:
      id = "MOVEMENT_RAPID";
      break;
    case MOVEMENT_LEAD_IN:
      id = "MOVEMENT_LEAD_IN";
      break;
    case MOVEMENT_CUTTING:
      id = "MOVEMENT_CUTTING";
      break;
    case MOVEMENT_LEAD_OUT:
      id = "MOVEMENT_LEAD_OUT";
      break;
    case MOVEMENT_LINK_TRANSITION:
      id = "MOVEMENT_LINK_TRANSITION";
      break;
    case MOVEMENT_LINK_DIRECT:
      id = "MOVEMENT_LINK_DIRECT";
      break;
    case MOVEMENT_RAMP_HELIX:
      id = "MOVEMENT_RAMP_HELIX";
      break;
    case MOVEMENT_RAMP_PROFILE:
      id = "MOVEMENT_RAMP_PROFILE";
      break;
    case MOVEMENT_RAMP_ZIG_ZAG:
      id = "MOVEMENT_RAMP_ZIG_ZAG";
      break;
    case MOVEMENT_RAMP:
      id = "MOVEMENT_RAMP";
      break;
    case MOVEMENT_PLUNGE:
      id = "MOVEMENT_PLUNGE";
      break;
    case MOVEMENT_PREDRILL:
      id = "MOVEMENT_PREDRILL";
      break;
    case MOVEMENT_EXTENDED:
      id = "MOVEMENT_EXTENDED";
      break;
    case MOVEMENT_REDUCED:
      id = "MOVEMENT_REDUCED";
      break;
    case MOVEMENT_HIGH_FEED:
      id = "MOVEMENT_HIGH_FEED";
      break;
    case MOVEMENT_FINISH_CUTTING:
      id = "MOVEMENT_FINISH_CUTTING";
      break;
  }

  if (id == undefined) {
    id = String(movement);
  }

  WriteComment(eComment.Info, " " + id);
}

var currentSpindleSpeed = 0;

function setSpindeSpeed(_spindleSpeed, _clockwise) {
  if (currentSpindleSpeed != _spindleSpeed) {
    if (_spindleSpeed > 0) {
      spindleOn(_spindleSpeed, _clockwise);
    } else {
      spindleOff();
    }
    currentSpindleSpeed = _spindleSpeed;
  }
}

function onSpindleSpeed(spindleSpeed) {
  setSpindeSpeed(spindleSpeed, tool.clockwise);
}

function onCommand(command) {
  WriteComment(eComment.Info, " " + getCommandStringId(command));

  switch (command) {
    case COMMAND_START_SPINDLE:
      onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
      return;
    case COMMAND_SPINDLE_CLOCKWISE:
      setSpindeSpeed(spindleSpeed, true);
      return;
    case COMMAND_SPINDLE_COUNTERCLOCKWISE:
      setSpindeSpeed(spindleSpeed, false);
      return;
    case COMMAND_STOP_SPINDLE:
      setSpindeSpeed(0, true);
      return;
    case COMMAND_COOLANT_ON:
      setCoolant(tool.coolant);
      return;
    case COMMAND_COOLANT_OFF:
      setCoolant(eCoolant.Off);  //COOLANT_DISABLED
      return;
    case COMMAND_LOCK_MULTI_AXIS:
      return;
    case COMMAND_UNLOCK_MULTI_AXIS:
      return;
    case COMMAND_BREAK_CONTROL:
      return;
    case COMMAND_TOOL_MEASURE:
      return;
    case COMMAND_STOP:
      WriteBlock(mFormat.format(0));
      return;
  }
}

function resetAll() {
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
  fOutput.reset();
}

function WriteInformation() {
  // Calcualte the min/max ranges across all sections
  var toolZRanges = {};
  var vectorX = new Vector(1, 0, 0);
  var vectorY = new Vector(0, 1, 0);
  var ranges = {
    x: { min: undefined, max: undefined },
    y: { min: undefined, max: undefined },
    z: { min: undefined, max: undefined },
  };
  var handleMinMax = function (pair, range) {
    var rmin = range.getMinimum();
    var rmax = range.getMaximum();
    if (pair.min == undefined || pair.min > rmin) {
      pair.min = rmin;
    }
    if (pair.max == undefined || pair.max < rmin) {  // was pair.min - changed by DG 1/4/2021
      pair.max = rmax;
    }
  }

  var numberOfSections = getNumberOfSections();
  for (var i = 0; i < numberOfSections; ++i) {
    var section = getSection(i);
    var tool = section.getTool();
    var zRange = section.getGlobalZRange();
    var xRange = section.getGlobalRange(vectorX);
    var yRange = section.getGlobalRange(vectorY);
    handleMinMax(ranges.x, xRange);
    handleMinMax(ranges.y, yRange);
    handleMinMax(ranges.z, zRange);
    if (is3D()) {
      if (toolZRanges[tool.number]) {
        toolZRanges[tool.number].expandToRange(zRange);
      } else {
        toolZRanges[tool.number] = zRange;
      }
    }
  }

  // Display the Range Table
  WriteComment(eComment.Info, " ");
  WriteComment(eComment.Info, " Ranges Table:");
  WriteComment(eComment.Info, "   X: Min=" + xyzFormat.format(ranges.x.min) + " Max=" + xyzFormat.format(ranges.x.max) + " Size=" + xyzFormat.format(ranges.x.max - ranges.x.min));
  WriteComment(eComment.Info, "   Y: Min=" + xyzFormat.format(ranges.y.min) + " Max=" + xyzFormat.format(ranges.y.max) + " Size=" + xyzFormat.format(ranges.y.max - ranges.y.min));
  WriteComment(eComment.Info, "   Z: Min=" + xyzFormat.format(ranges.z.min) + " Max=" + xyzFormat.format(ranges.z.max) + " Size=" + xyzFormat.format(ranges.z.max - ranges.z.min));

  // Display the Tools Table
  WriteComment(eComment.Info, " ");
  WriteComment(eComment.Info, " Tools Table:");
  var tools = getToolTable();
  if (tools.getNumberOfTools() > 0) {
    for (var i = 0; i < tools.getNumberOfTools(); ++i) {
      var tool = tools.getTool(i);
      var comment = "  T" + toolFormat.format(tool.number) + " D=" + xyzFormat.format(tool.diameter) + " CR=" + xyzFormat.format(tool.cornerRadius);
      if ((tool.taperAngle > 0) && (tool.taperAngle < Math.PI)) {
        comment += " TAPER=" + taperFormat.format(tool.taperAngle) + "deg";
      }
      if (toolZRanges[tool.number]) {
        comment += " - ZMIN=" + xyzFormat.format(toolZRanges[tool.number].getMinimum());
      }
      comment += " - " + getToolTypeName(tool.type) + " " + tool.comment;
      WriteComment(eComment.Info, comment);
    }
  }

  // Display the Feedrate and Scaling Properties
  WriteComment(eComment.Info, " ");
  WriteComment(eComment.Info, " Feedrate and Scaling Properties:");
  WriteComment(eComment.Info, "   Feed: Travel speed X/Y = " + properties.fr0_TravelSpeedXY);
  WriteComment(eComment.Info, "   Feed: Travel Speed Z = " + properties.fr1_TravelSpeedZ);
  WriteComment(eComment.Info, "   Feed: Scale Feedrate = " + properties.frA_ScaleFeedrate);
  WriteComment(eComment.Info, "   Feed: Max XY Cut Speed = " + properties.frB_MaxCutSpeedXY);
  WriteComment(eComment.Info, "   Feed: Max Z Cut Speed = " + properties.frC_MaxCutSpeedZ);
  WriteComment(eComment.Info, "   Feed: Max Toolpath Speed = " + properties.frD_MaxCutSpeedXYZ);

  // Display the G1->G0 Mapping Properties
  WriteComment(eComment.Info, " ");
  WriteComment(eComment.Info, " G1->G0 Mapping Properties:");
  WriteComment(eComment.Info, "   Map: First G1 -> G0 Rapid = " + properties.mapD_RestoreFirstRapids);
  WriteComment(eComment.Info, "   Map: G1s -> G0 Rapids = " + properties.mapE_RestoreRapids);
  WriteComment(eComment.Info, "   Map: SafeZ Mode = " + eSafeZ.prop[safeZMode].name + " : default = " + safeZHeightDefault);
  WriteComment(eComment.Info, "   Map: Allow Rapid Z = " + properties.mapG_AllowRapidZ);

  WriteComment(eComment.Info, " ");
}

function WriteFirstSection() {
  // Write out the information block at the beginning of the file
  WriteInformation();

  WriteComment(eComment.Important, " *** START begin ***");
  WriteBlock(properties.gcodeStart);
  WriteComment(eComment.Important, " *** START end ***");
  WriteComment(eComment.Important, " ");
}

// Output a comment
function WriteComment(level, text) {
  if (level <= properties.job3_CommentLevel) {
    WriteBlock(";" + String(text).replace(/[\(\)]/g, ""));
  }
}

// Rapid movements with G1 and differentiated travel speeds for XY
// Changes F360 current XY.
// No longer called for general Rapid only for probing, homing, etc.
function rapidMovementsXY(_x, _y) {
  let x = xOutput.format(_x);
  let y = yOutput.format(_y);

  if (x || y) {
    if (pendingRadiusCompensation != RADIUS_COMPENSATION_OFF) {
      error(localize("Radius compensation mode cannot be changed at rapid traversal."));
    }
    else {
      let f = fOutput.format(propertyMmToUnit(properties.fr0_TravelSpeedXY));
      WriteBlock(gMotionModal.format(0), x, y, f);
    }
  }
}

// Rapid movements with G1 and differentiated travel speeds for Z
// Changes F360 current Z
// No longer called for general Rapid only for probing, homing, etc.
function rapidMovementsZ(_z) {
  let z = zOutput.format(_z);

  if (z) {
    if (pendingRadiusCompensation != RADIUS_COMPENSATION_OFF) {
      error(localize("Radius compensation mode cannot be changed at rapid traversal."));
    }
    else {
      let f = fOutput.format(propertyMmToUnit(properties.fr1_TravelSpeedZ));
      WriteBlock(gMotionModal.format(0), z, f);
    }
  }
}

// Rapid movements with G1 uses the max travel rate (xy or z) and then relies on feedrate scaling
function rapidMovements(_x, _y, _z) {

  rapidMovementsZ(_z);
  rapidMovementsXY(_x, _y);
}

// Calculate the feedX, feedY and feedZ components

function limitFeedByXYZComponents(curPos, destPos, feed) {
  if (!properties.frA_ScaleFeedrate)
    return feed;

  var xyz = Vector.diff(destPos, curPos);       // Translate the cut so curPos is at 0,0,0
  var dir = xyz.getNormalized();                // Normalize vector to get a direction vector
  var xyzFeed = Vector.product(dir.abs, feed);  // Determine the effective x,y,z speed on each axis

  // Get the max speed for each axis
  let xyLimit = propertyMmToUnit(properties.frB_MaxCutSpeedXY);
  let zLimit = propertyMmToUnit(properties.frC_MaxCutSpeedZ);

  // Normally F360 begins a Section (a milling operation) with a Rapid to move to the beginning of the cut.
  // Rapids use the defined Travel speed and the Post Processor does not depend on the current location.
  // This function must know the current location in order to calculate the actual vector traveled. Without
  // the first Rapid the current location is the same as the desination location, which creates a 0 length
  // vector. A zero length vector is unusable and so a instead the slowest of the xyLimit or zLimit is used.
  //
  // Note: if Map: G1 -> Rapid is enabled in the Properties then if the first operation in a Section is a
  // cut (which it should always be) then it will be converted to a Rapid. This prevents ever getting a zero
  // length vector.
  if (xyz.length == 0) {
    var lesserFeed = (xyLimit < zLimit) ? xyLimit : zLimit;

    return lesserFeed;
  }

  // Force the speed of each axis to be within limits
  if (xyzFeed.z > zLimit) {
    xyzFeed.multiply(zLimit / xyzFeed.z);
  }

  if (xyzFeed.x > xyLimit) {
    xyzFeed.multiply(xyLimit / xyzFeed.x);
  }

  if (xyzFeed.y > xyLimit) {
    xyzFeed.multiply(xyLimit / xyzFeed.y);
  }

  // Calculate the new feedrate based on the speed allowed on each axis: feedrate = sqrt(x^2 + y^2 + z^2)
  // xyzFeed.length is the same as Math.sqrt((xyzFeed.x * xyzFeed.x) + (xyzFeed.y * xyzFeed.y) + (xyzFeed.z * xyzFeed.z))

  // Limit the new feedrate by the maximum allowable cut speed

  let xyzLimit = propertyMmToUnit(properties.frD_MaxCutSpeedXYZ);
  let newFeed = (xyzFeed.length > xyzLimit) ? xyzLimit : xyzFeed.length;

  if (Math.abs(newFeed - feed) > 0.01) {
    return newFeed;
  }
  else {
    return feed;
  }
}

// Linear movements
function linearMovements(_x, _y, _z, _feed) {
  if (pendingRadiusCompensation != RADIUS_COMPENSATION_OFF) {
    // ensure that we end at desired position when compensation is turned off
    xOutput.reset();
    yOutput.reset();
  }

  // Force the feedrate to be scaled (if enabled). The feedrate is projected into the
  // x, y, and z axis and each axis is tested to see if it exceeds its defined max. If
  // it does then the speed in all 3 axis is scaled proportionately. The resulting feedrate
  // is then capped at the maximum defined cutrate.

  let feed = limitFeedByXYZComponents(getCurrentPosition(), new Vector(_x, _y, _z), _feed);

  let x = xOutput.format(_x);
  let y = yOutput.format(_y);
  let z = zOutput.format(_z);
  let f = fOutput.format(feed);

  if (x || y || z) {
    if (pendingRadiusCompensation != RADIUS_COMPENSATION_OFF) {
      error(localize("Radius compensation mode is not supported."));
    } else {
      WriteBlock(gMotionModal.format(1), x, y, z, f);
    }
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      fOutput.reset(); // force feed on next line
    } else {
      WriteBlock(gMotionModal.format(1), f);
    }
  }
}

function propertyMmToUnit(_v) {
  return (_v / (unit == IN ? 25.4 : 1));
}

function end() {
  display_text("Job end");
}

function spindleOn(_spindleSpeed, _clockwise) {
  WriteBlock(mFormat.format(_clockwise ? 3 : 4), sOutput.format(spindleSpeed));
}

function spindleOff() {
  WriteBlock(mFormat.format(5));
}

function display_text(txt) {
  WriteBlock(mFormat.format(117), txt);
}

function circular(clockwise, cx, cy, cz, x, y, z, feed) {
  var start = getCurrentPosition();

  // Marlin supports arcs only on XY plane
  if (isFullCircle()) {
    if (isHelical()) {
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
      case PLANE_XY:
        WriteBlock(gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), fOutput.format(feed));
        break;
      default:
        linearize(tolerance);
    }
  } else {
    switch (getCircularPlane()) {
      case PLANE_XY:
        WriteBlock(gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), fOutput.format(feed));
        break;
      default:
        linearize(tolerance);
    }
  }
}

function askUser(text, title, allowJog) {
  WriteBlock(mFormat.format(0), text);
}
