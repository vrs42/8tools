**ascat** Output TSS .asc format as text.

This reads a file format consisting of word pairs embedded
in 16 bits:
	0000aaaa aaaabbbb 000bbbb cccccccc
It extracts and prints the three characters:
	0aaaaaaa 0bbbbbbb 0ccccccc
thus unpacking the characters in TSS bit order and also stripping mark parity.
The parity bits are stripped off so that you can recognize the characters.
