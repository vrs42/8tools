**binsvcmp** compares the contents of a .bin format file to a .sv file.

Each argument will be loaded into an array, checking for valid format.
Then, a side-by-side listing of the differences, sorted by address,
will be output.  All locations set in both files, but to different
value will be reported.  A value of "XXXX" will be reported for
locations which were not loaded in one or the other image.

Note that it is permitted for a location to be set in the .sv file
that is not loaded by the .bin file.  This is because the granularity
of the .sv file is pages, not words.  Location set in .sv pages which
are not loaded at all by the .bin file will be reported as differences.
