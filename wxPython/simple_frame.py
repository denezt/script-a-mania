#!/usr/bin/env python3

# First things, first. Import the wxPython package.
import wx

# Next, create an application object.
app = wx.App()

# Then a frame.
frm = wx.Frame(None, title="Basic Frame")

# Show it.
frm.Show()

# Start the event loop.
app.MainLoop()
