# Metal001DrawLoop

Putting static images on the screen is one thing but what we
really want to see is things moving. To make that happen I
have to get connected into the draw loop.

If I remember right this requires giving a delegate to the
MTKView that can be called each time a new frame needs to be
drawn.