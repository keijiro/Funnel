Funnel
======

![Screenshot][Screenshot]

*Funnel* is a Syphon server plugin for [Unity][Unity]. It allows Unity to share
rendered frames with other applications that supports the [Syphon][Syphon]
protocol (e.g., [MadMapper][MadMapper], [VDMX][VDMX]) without introducing any
performance loss.

Compatibility Note
------------------

This version is redesigned and optimized for [the new OpenGL backend (OpenGL
Core)][GLCore] and not compatible with the legacy OpenGL backend. If it's
required to support legacy OpenGL, use [the legacy version][Legacy] instead.

System Requirements
-------------------

- Mac OS X 10.8 or later
- Unity 5.3 or later

This version only supports the 64-bit runtime and the OpenGL Core API mode.
[The legacy version][Legacy] is available for legacy setups.

Setting Up
----------

- Download and import [the plugin package][Package].
- Add the Funnel script to a camera that's to be shared.

That's all! It automatically sets up a Syphon server and starts publishing
rendered frames towards Syphon client applications.

The name of the Syphon server is set in the following manner:

    [Process Name]-[Game Object Name]

It's useful to identify the server on the client side.

Properties
----------

**Screen Width/Height, Anti Aliasing** - Configures the screen to be sent.

**Discard Alpha** - Clears the alpha channel with 1.0 (completely opaque)
before sending.

**Render Mode** - Determines how the frame is shared.
 - Send Only - Sends the frame and doesn't keep it. The rendered frame is only
   available on the client side.
 - Render To Target - Sends the frame and copies it to the render texture.
 - Preview On Game View - Sends the frame and display it on the Game view.

License
-------

Copyright (C) 2013-2016 Keijiro Takahashi

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[Screenshot]: http://keijiro.github.io/Funnel/screenshot.png
[Legacy]:     https://github.com/keijiro/Funnel/tree/gllegacy
[Inspector]:  http://keijiro.github.io/Funnel/inspector.png
[Package]:    https://github.com/keijiro/Funnel/raw/master/Funnel.unitypackage
[Unity]:      http://unity3d.com
[Syphon]:     http://syphon.v002.info
[VDMX]:       http://vidvox.net
[MadMapper]:  http://madmapper.com
[GLCore]:     http://docs.unity3d.com/Manual/OpenGLCoreDetails.html
