Funnel
======

![Screenshot][Screenshot]

*Funnel* is a Syphon server plugin for [Unity][Unity]. It allows Unity to share
rendered frames with other graphics applications that supports [Syphon][Syphon]
technology (e.g., [MadMapper][MadMapper], [VDMX][VDMX]) at almost zero
performance loss.

System Requirements
-------------------

- Mac OS X
- Unity Pro

Setting Up
----------

- [Download the plugin package][Package]
- Import the package into a project.
- Add the Funnel script to a camera.

Basically that's all! After adding the Funnel script to a camera, it sets up
a Syphon server and starts sharing rendered frames with Syphon clients.

The name of the Syphon server will be determined in the following manner:

    [Process Name]-[Game Object Name]

It's useful to identify the servers when there are more than two servers.

Properties
----------

There are several properties in the Funnel component.

![Inspector][Inspector]

**Screen Width/Height, Anti Aliasing** - Resolution settings of the shared
frames.

**Alpha Channel** - It determines if the alpha channel of the frames will be
shared. If it's set to off, the server will clear the alpha channel before
sharing it.

In most cases, an alpha channel of a rendered frame is filled with garbage and
it causes problems when compositing the frames on Syphon client applications.
Therefore it's recommended to be kept off unless a special setup is used.

**Render Mode** - It determines how the frames are shared.
- Send Only - It only sends the frames and doesn't keep them. In this mode,
rendered frames are only available on Syphon clients and there is no way to
reuse them in Unity. This mode is slightly faster than the others.
- Render To Target - It sends the frames and keep them in a Render Texture.
- Preview On GUI - It sends the frames and display them on the Game View
using OnGUI function.

License
-------

Copyright (C) 2014 Keijiro Takahashi

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
