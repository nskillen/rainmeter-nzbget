## NZBGet Skin for Rainmeter ##

This Rainmeter skin, done in the style of the default illustro skins provided with Rainmeter, will provide a watcher for NZBGet.

### Setup ###

The following variables need to be set:

* `HOST`: the IP address or domain name of the NZBGet host system, default is `127.0.0.1`
* `PORT`: the port number to connect to NZBGet on, default is 6789

### Changing the number of download rows ###

To add additional rows to the display, do the following steps:

1. Adjust the `NUM_ROWS` variable to match the number of rows you wish to see
2. If deleting rows:
    1. Delete the following meters for each number larger than `NUM_ROWS`:
        * meterLabelDL#
        * meterRemSizeDL#
        * meterBarDL#
    2. Delete the following measure for each number larger than `NUM_ROWS`:
        * MeasureProgressDL#
3. If adding rows:
    1. Copy one of MeasureProgressDL#
    2. Paste copies of MeasureProgressDL# until you have sufficient copies, adjusting the #
    3. Copy a set of meter*DL# meters
    4. Paste copies of the meter sets, until you have sufficient copies, adjusting the #
        * Don't forget to add 20 to the Y value for each additional set you add.