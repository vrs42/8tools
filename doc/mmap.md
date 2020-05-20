mmap outputs bitmap for a .bin file

A single .bin file is read and checked for format and
checksum.

The bitmap of the areas that would be loaded is output 
on the standard output.  Normally, each memory location
will get a "0" or a "1" indicating if it was loaded.

Locations loaded more than once will get "2", "3", or
however many times the location was loaded, except
locations which were loaded 10 or more times will
report "9".

Verifying which locations were loaded and how many times 
can be valuable in verifying that code is assembling as 
intened, etc.
