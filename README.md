Funnel
======

![Screenshot][Screenshot]

*Funnel* is a Syphon server plugin for [Unity][Unity]. It allows Unity to share
rendered frames with other applications that supports the [Syphon][Syphon]
protocol (e.g., [MadMapper][MadMapper], [VDMX][VDMX]) at almost zero
performance loss.

System Requirements
-------------------

- Mac OS X 10.6 (Snow Leopard) or later.
- Unity 5.0 or later.

Setting Up
----------

- Download and import [the plugin package][Package].
- Add the Funnel script to cameras that share rendered frames.

Basically that's all! It automatically sets up a Syphon server and starts
publishing rendered frames to Syphon client applications.

The name of the Syphon server is set in the following manner:

    [Process Name]-[Game Object Name]

It's useful to identify the server on the client side.

Properties
----------

![Inspector][Inspector]

**Screen Width/Height, Anti Aliasing** - Screen resolution of the shared frames.

**Alpha Channel** - Determines if the alpha channel of the frames are to be
shared. When set to off, the server clears the alpha channel before sharing.

In most cases, the alpha channel of the rendered frames has no useful
information, and it can cause glitches on the Syphon client side. Therefore,
it's recommended to be kept off unless using a special setup.

**Render Mode** - Determines how the frames are shared.
- Send Only - Sends the frames and doesn't keep them. In this mode,
rendered frames are available only on the Syphon client side and are not
available for using on the Unity side. This mode is slightly faster than the
other modes.
- Render To Target - Sends the frames and keeps them in a RenderTexture.
- Preview On Game View - Sends the frames and display them on the Game View.

License
-------

Copyright (C) 2014, 2015 Keijiro Takahashi

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
[Inspector]:  http://keijiro.github.io/Funnel/inspector.png
[Package]:    https://github.com/keijiro/Funnel/raw/master/Funnel.unitypackage
[Unity]:      http://unity3d.com
[Syphon]:     http://syphon.v002.info
[VDMX]:       http://vidvox.net
[MadMapper]:  http://madmapper.com
