dood outputs successive bytes in octal

When given a list of file names, dood will (over)write
a .od file for each one, consisting of a single octal 
4 digit byte value for each input byte.

These are extremely helpful for visualizing the data
when doing forensics on paper tape images.

The extra "0" digit at the front may be helpful for
tools and individuals which can interpret leading
zero as indicating octal radix.
