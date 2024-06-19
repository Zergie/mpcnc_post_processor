
Fusion 360 CAM posts processor and Macros for MPCNC running Klipper
====

This is modified fork of https://github.com/flyfisher604/mpcnc_post_processor that originated from https://github.com/guffy1234/mpcnc_posts_processor which was originally forked https://github.com/martindb/mpcnc_posts_processor.

CAM posts processor for use with Fusion 360 and [MPCNC](https://www.v1engineering.com).

Supported firmware:
- Klipper

Installation:
- The post processor consists of a single file, mpcnc.cps.
- It can be simply installed by selecting Manage->Post Library from the Fusion 360 menubar; alternatively the mpcnc.cps can be copied into a directory and selecting each time prior to a post operation. If there is an existing mpcnc.cps installed select it prior to installing and use the trash can icon to delete it
- The desired post processor can be selected during a post using the Setup button and selecting Use Personal Post Library
- For installation of the **needed** klipper macros see [klipper/README.md](klipper/README.md)

Some design points:
- Rapids movements use two G0 moves. The first moves Z and the second moves XY. Moves are seperate to allow retraction from the work surface prior to horizontal travel. Moves use independent travel speeds for Z and XY.
- Arcs support on XY plane (Marlin/Repetier/RepRap) or all panes (Grbl)
- Support 2 coolant channels. You may attach relays to control external devices - as example air jet valve.
- Customizable level of verbosity of comments

   ![screenshot](/screenshot.png "screenshot")

# Properties

> WARNING: If you are using the Fusion 360 for Personal Use license, formally know as the Fusion 360 Hobbyist license, please respect the [limitations of that license](https://knowledge.autodesk.com/support/fusion-360/learn-explore/caas/sfdcarticles/sfdcarticles/Fusion-360-Free-License-Changes.html).
>
>Fusion 360 for Personal Use restricts all moves not to exceed the maximum cut speed. This has been implemented not by reducing the speed of G0s but by changing all G0 (moves) to G1 (cut) commands. The side effect of this was to unintentionally introduce situations where tool dragging and/or work piece collisions occur, general at the start of jobs or after tool changes.



## Group 1: DEBUG
| Title              | Description                                                                         | Default  |
|--------------------|-------------------------------------------------------------------------------------|----------|
| Job: Comment Level | Controls a increasing level of comments to be included: Off, Important, Info, Debug | **Info** |

## Group 2: Movement
If [Map: G1s -> G0s] is true then allows G1 XY cut movements (i.e. no change in Z) that occur
at a height greater or equal to [Map: Safe Z to Rapid] to be converted to G0 Rapids.
Note: this assumes that any Z above [Map: Safe Z to Rapid] is a movement in the air and clear of
obstacles. Can be defined as a number or one of F360's planes (Feed, Retract or Clearance).

Map: Safe Z for Rapids may be defined as:
* As a constant numeric value - safe Z will then always be this value for all sections, or
* As a reference to a F360 Height - safe Z will then follow the Height defined within the operation's Height tab. Allowable Heights are: Feed, Retract, or Clearance. The Height must be followed by a ":" and then a numeric value. The value will be used if Height is not defined for a section.

If [Map: Allow Rapid Z] is true then G1 Z cut movements that either move straight up
and end above [Map: Safe Z to Rapid], or straight down with the start and end positions both
above [Map: Safe Z to Rapid] are included. Only occurs if [Map: G1s -> G0s] is also true.

| Title                  | Description                                                                                                                                                                                                            | Default                                                         | Format                                                                   |
|------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------|--------------------------------------------------------------------------|
| Map: G1s -> G0s        | Allow G1 cuts to be converted to Rapid G0 moves when safe and appropriate.                                                                                                                                             | **false**                                                       |                                                                          |
| Map: Safe Z for Rapids | A G1 cut's Z must be >= to this to be mapped to a Rapid G0. Can be two formats (1) a number which will be used for all sections, or (2) a reference to F360's Height followed by a default if Height is not available. | **Retract:15** (use the Retract height and if not available 15) | \<number\> or \<F360 Height\>:\<number\>; e.g. 10 or Retract:7 or Feed:5 |
|Map: Allow Rapid Z|Include the mapping of vertical cuts if they are safe.|**false**|

## Group 3: Coolant
Coolant has two channels, A and B. Each channel can be configured to be off or set to 1 of the 8 coolant modes that Fusion 360 allows on operation. If a tool's collant requirements match a channel's setting then that channel is enabled. A warning is generated if a tool askes for coolant and there is not a channel that matches.

If a channel matches the coolant requested the Channel becomes enabled. When a channel is enabled the post processor will include the text associated with the corresponding property [Coolant \<A or B\> Enable]. Note, Marlin and Grbl values are included as options, you must select based on your actual configuration. The firmware selected in property [Job: CNC Firmware] will not override your selection.

If a channel needs to be Disabled because it no longer matchs the coolant requested then the channel is physically disabled by the post processor by including the text associated with the corresponding property [Coolant \<A or B\> Disable]. Note, Marlin and Grbl values are included as options, you must select based on your actual configuration. The firmware selected in the propery [Job: CNC Firmware] will not override your selection.

For coolant requests, like "Flood and Mist" or "Flood and Through Tool" you may want to enable one or
two channels dependent on if your hardware uses one connections to enable both or a seperate connection for each. Two channels may be enabled by placing the same coolant code in both. For example, setting both channels to "Flood and Mist" will result in enabling both channel A and channel B when the tool requests "Flood and Mist". Correspondingly channels A's enable value will be output (to enable flooding) and channel B's enable value will be output (to enable Mist).

Four custom coolant text strings can be defined for both Channel A and B's on and off values. Use these if the predefine values do not match your hardware. To enable, set the corresponding coolant channel to 'Use custom'.

| Title              | Description                                    | Default | Values                                                                                   |
|--------------------|------------------------------------------------|---------|------------------------------------------------------------------------------------------|
| Coolant: A Mode    | Enable channel A when tool is set this coolant | **off** | off, flood, mist, throughTool, air, airThroughTool, suction, floodMist, floodThroughTool |
| Coolant: A Enable  | GCode to turn On coolant channel A             | **M7**  |                                                                                          |
| Coolant: A Disable | GCode to turn Off coolant channel A            | **M9**  |                                                                                          |
| Coolant: B Mode    | Enable channel B when tool is set this coolant | **off** | off, flood, mist, throughTool, air, airThroughTool, suction, floodMist, floodThroughTool |
| Coolant: B Enable  | GCode to turn On coolant channel B             | **M8**  |                                                                                          |
| Coolant: B Disable | GCode to turn Off coolant channel B            | **M9**  |                                                                                          |

## Group 4: Klipper
Given the url for klipper, the post processor will upload the finished gcode directly to klipper.

| Title              | Description                                         |
|--------------------|-----------------------------------------------------|
| Klipper url        | Url of your klipper installation (e.g. http://<ip>) |
| Start After Upload | Automatically start the gcode after upload          |


# Resources

[Marlin G-codes](http://marlinfw.org/meta/gcode/)

[PostProcessor Class Reference](https://cam.autodesk.com/posts/reference/classPostProcessor.html)

[Post Processor Training Guide (PDF document)](https://cam.autodesk.com/posts/posts/guides/Post%20Processor%20Training%20Guide.pdf)

[Enhancements to the post processor property definitions](https://forums.autodesk.com/t5/hsm-post-processor-forum/enhancements-to-the-post-processor-property-definitions/td-p/7325350)

[Dumper PostProcessor](https://cam.autodesk.com/hsmposts?p=dump)

[Library of exist post processors](https://cam.autodesk.com/hsmposts)

[Post processors forum](https://forums.autodesk.com/t5/hsm-post-processor-forum/bd-p/218)

[How to set up a 4/5 axis machine configuration](https://forums.autodesk.com/t5/hsm-post-processor-forum/how-to-set-up-a-4-5-axis-machine-configuration/td-p/6488176)

[Beginners Guide to Editing Post Processors in Fusion 360! FF121 (Youtube video)](https://www.youtube.com/watch?v=5EodQIY25tU)

[Klipper G-Codes](https://www.klipper3d.org/G-Codes.html)

[Klipper Configuration reference](https://www.klipper3d.org/Config_Reference.html)