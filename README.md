Funnel
======

![Screenshot][Screenshot]

*Funnel* is a Syphon server plugin for [Unity][Unity]. It allows Unity to share
rendered frames with other applications that supports the [Syphon][Syphon]
protocol (e.g., [MadMapper][MadMapper], [VDMX][VDMX]) without introducing any
performance loss.

System Requirements
-------------------

- Mac OS X 10.6 (Snow Leopard) or later
- Unity 5.2 or later

This version uses the new low-level native plugin interface that is only
supported on 5.2 and later versions. If it's required to support 5.1 and earlier
versions, [the legacy version][Legacy] is available for use.

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

![Inspector][Inspector]

**Screen Width/Height, Anti Aliasing** - Screen resolution of shared frames.

**Alpha Channel** - Determines if alpha channel is to be shared. When set to
off, the server clears the alpha channel before publishing.

**Render Mode** - Determines how the frames are shared.
 - Send Only - Sends the frames and doesn't keep them. Rendered frames are only
   available on the client side.
 - Render To Target - Sends the frames and copies them to a render texture.
 - Preview On Game View - Sends the frames and display them on the Game view.

License
-------

Copyright (C) 2014-2016 Keijiro Takahashi

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
