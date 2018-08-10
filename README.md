# Haskell Mandelbrot set rendering engine
This engine supports multiprocessing, custom color schemes, custom smoothing, custom subsampling.
It has an outstanding performance when running on multiple cores due to Haskell's smart built-in computation distribution strategies.
<br>Also <B>explore.py</B> let's you conveniently search for sights worthy of high resolution rendering (it runs on 12 cores by default, so make sure you change that if nescessary).
The control buttons in the matplotlib window are also overriden; It shouldn't be too hard to figure out what they do. For example the "home" button
takes you back to the initial viewport.
<br>The purpose of this project is to demonstrate the power, reliability and flexibility modern functional languages have, especially when fused with those that are more 
suitable for interacting with OS API. In fact I myself find this engine very useful, since I'm not aware of any other Mandelbrot set
rendering software that has such decent performance and incredible flexibility at the same time.
<br><br>P.S. by flexibility I actually meant flexibility in terms of how easy it is to customise this thing for a programmer. I couldn't be bothered 
to create according user interfaces that would take advantage of it, although it's entirely possible and easy to implement.
