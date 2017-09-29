These are some PowerShell based binary payload encoders and decoders that I have written to use in an engagement.

You can encode your payload and pipe the resulting encoded string to sed to make it ready to paste into whatever code you're using.

For example to make a VBA/VBS variable do:

cat <encoded_payload> | sed -e 's/^/payload \= payload \+ \"/' | sed -e 's/$/\"/'
