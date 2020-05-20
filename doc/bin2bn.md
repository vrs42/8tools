bin2bn converts .bin to .bn.

In practice, this means to copy input to
output, then pad to a multiple of the
blocksize (384 bytes/256 words) with 0200.
