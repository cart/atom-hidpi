# Atom HiDPI / Retina

Atom Hidpi scales Atom's interface based on the current monitor's resolution.  Currently on Linux Atom does not scale based on DPI, so this package is necessary to make Atom readable on monitors with high resolutions / DPIs.  This package should not be necessary for OSX because it automatically scales.  I have not tested Atom on Windows so I do not know how it behaves.

## Usage

By default Atom's interface will be scaled up 2x when it starts up if the current monitor's width is above 2300px.  If you move Atom to a different monitor, you can update based on the new resolution by opening the command pallet and calling the "HiDPI: Update" function.

DPI cannot be determined by resolution alone.  A 5 inch phone and a 27 inch monitor with similar resolutions will have vastly different DPIs.  Because of this, this package's default behavior will not be desirable on multi-monitor setups where the monitors' DPIs vary significantly.  Use the "Manual Resolution Scale Factors" setting to assign the appropriate scale factor to your monitors.

## Configuration

* "Scale Factor": The amount to scale the interface when the current monitor's width is above "Cutoff Width" (Default: 2.0)
* "Cutoff Width": Any monitor with a width (in pixels) higher than "Cutoff Width" will be scaled by "Scale Factor" (Default: 2300)
* "Cutoff Height": Any monitor with a height (in pixels) higher than "Cutoff Height" will be scaled by "Scale Factor" (Default: 2300)
* "Reopen Current File": If true, will reopen the current file.  You will be prompted to save any unsaved changes (Default: true)
* "Startup Delay": The amount of time (in milliseconds) to wait before scaling the interface on startup.  If this is set too low the interface will not scale (Default: 200)
* "Manual Resolution Scale Factors": A comma separated list of resolutions and scale factor assignments.  This will override the default "Cutoff Width" and "Cutoff Height" behavior. Should be in the format: "1920x1080": 1.5, "2880x1800": 2.5 (Default: '')
* "Update On Resize": If true the scale factor will be updated when the window is resized (Default: true)

## Known Issues

* If a file is open when the interface is scaled, the cursor will be visually shifted but its actual position will remain the same.  Enable "Reopen Current File" to fix this.

## Future Work

* Find out if Atom has a "On Ready" callback to remove the need for the "Startup Delay" option