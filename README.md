# Functional Geomerty Lua/LÖVE module

This implements the algebra of pictures described in the paper [Functional Geometry](http://eprints.soton.ac.uk/257577/1/funcgeo2.pdf) by Peter Henderson

This [MIT Open courseware video](http://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-001-structure-and-interpretation-of-computer-programs-spring-2005/video-lectures/3a-henderson-escher-example/) was also referenced during implementation.


As is, this is set up for use with LÖVE, but you can redefine the drawLine function in funcgeo.lua to use whatever graphics library you are using. The drawLine function should have the following signature: drawLine(x1,y1, x2, y2) 
