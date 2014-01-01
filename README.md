Funnel
======

![Screenshot](http://keijiro.github.io/Funnel/screenshot.png)

*Funnel* is a minimal [Syphon](http://syphon.v002.info) server plugin for
Unity Pro. It allows Unity to share frames with other application in
realtime. It works not only on built apps but also on the Editor, therefore you
can edit a scene on the Editor and simultaneously show it on Syphon clients
(e.g. MadMapper, VDMX, et cetera).

System Requirements
-------------------

- Mac OS X
- Unity Pro
- Syphon client app.

Setting Up
----------

- [Download the plugin package]
  (http://keijiro.github.io/Funnel/funnel-0.5.unitypackage).
- Import the package into your project.
- Add Funnel script component to a camera.

Basically that's all! It publishes frames on this camera in play mode.
It uses the name of the game object as the name of the Syphon server, and
therefore you can identify servers with their names.

Options
-------

There are some options you can see on the inspector.

![Inspector](http://keijiro.github.io/Funnel/inspector.png)

- Screen Width/Height - the size of frames published to Syphon clients.
- Draw Game View - draws the frames on the game view. If this option is
  disabled, the frames on this camera is only viewable on Syphon clients.
- Preview - shows the frames on this camera (on very low frame rate).

Related Project
---------------

[Symon](https://github.com/keijiro/Symon) is a minimal Syphon client app
which is designed to use in combination with Funnel. It allows the Unity
Editor to show frames on Retina-enabled displays or external displays
in full-screen mode.

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
