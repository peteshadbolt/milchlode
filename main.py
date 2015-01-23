#!/usr/bin/python
# coding: utf-8
from libs.simpleosc import *
import wx

def sendOSCSafe(channel, data):
    try:
        #print channel, data
        sendOSCMsg(channel, data)
    except OSCClientError:
        print "OSC comms error"


class OSCSlider(wx.Panel):

    """ A GUI slider """

    def __init__(self, parent, label, min_value=0, max_value=1, default_value=0, align=True, rescale=100.):
        """ Constructor """
        self.rescale = rescale
        wx.Panel.__init__(self, parent)
        sizer = wx.BoxSizer(wx.HORIZONTAL)
        label = wx.StaticText(self, label=label, size=(100, 15) if align else None)
        sizer.Add(label, 0, wx.RIGHT, 10)
        self.slider = wx.Slider(self, value=default_value * self.rescale,
                                minValue=min_value * self.rescale, maxValue=max_value * self.rescale)
        sizer.Add(self.slider, 1, wx.EXPAND)

        self.SetSizerAndFit(sizer)
        self.Bind = self.slider.Bind

    def GetValue(self):
        """ Make sure that we rescale """
        return self.slider.GetValue() / self.rescale


class CommsPanel(wx.Panel):

    """ OSC comms """

    def __init__(self, parent):
        wx.Panel.__init__(self, parent)
        sizer = wx.BoxSizer(wx.HORIZONTAL)

        label = wx.StaticText(self, label="Sync:")
        font = label.GetFont()
        font.SetWeight(wx.BOLD)
        label.SetFont(font)
        sizer.Add(label, 0, wx.TOP | wx.BOTTOM | wx.RIGHT | wx.EXPAND, 5)

        choices = ["Master", "Minion"]
        self.master = wx.ComboBox(self, choices=choices, style=wx.CB_READONLY, size=(25, 25))
        sizer.Add(self.master, 1, wx.ALL, 3)
        self.master.SetValue(choices[0])

        self.ip = wx.TextCtrl(self, value="127.0.0.1")
        sizer.Add(self.ip, 0, wx.ALL, 3)

        self.port = wx.TextCtrl(self, value="9000")
        sizer.Add(self.port, 0, wx.ALL, 3)

        self.SetSizerAndFit(sizer)


class InputPanel(wx.Panel):

    """ Handle the ADC input settings """

    def __init__(self, parent):
        """ Constructor """
        wx.Panel.__init__(self, parent)
        sizer = wx.BoxSizer(wx.HORIZONTAL)

        label = wx.StaticText(self, label="Input:")
        font = label.GetFont()
        font.SetWeight(wx.BOLD)
        label.SetFont(font)
        sizer.Add(label, 0, wx.TOP | wx.BOTTOM | wx.RIGHT, 5)

        self.gain = OSCSlider(self, "Gain", default_value=.5, max_value = 1.2, align=False)
        sizer.Add(self.gain, 1, wx.ALL, 5)
        self.thru = OSCSlider(self, "Thru", default_value=1, max_value = 1.2, align=False)
        sizer.Add(self.thru, 1, wx.ALL, 5)

        self.mute = wx.ToggleButton(self, 0, "Mute")
        # self.mute.SetValue(1)
        sizer.Add(self.mute, 0)
        self.SetSizerAndFit(sizer)

        self.gain.Bind(wx.EVT_SCROLL, self.update)
        self.thru.Bind(wx.EVT_SCROLL, self.update)
        self.mute.Bind(wx.EVT_TOGGLEBUTTON, self.update)

        self.update()

    def update(self, evt=None):
        """ Send OSC messages """
        gain = self.gain.GetValue() 
        thru = self.thru.GetValue() 
        if self.mute.GetValue():
            gain, thru = 0., 0.
        sendOSCSafe("/input", [gain, thru])


class DelayPanel(wx.Panel):

    """ Handle the ADC input settings """

    def __init__(self, parent):
        """ Constructor """
        wx.Panel.__init__(self, parent)
        sizer = wx.BoxSizer(wx.HORIZONTAL)

        label = wx.StaticText(self, label="Loop:")
        font = label.GetFont()
        font.SetWeight(wx.BOLD)
        label.SetFont(font)
        sizer.Add(label, 0, wx.TOP | wx.BOTTOM | wx.RIGHT, 5)

        self.delayTime = OSCSlider(self, "Time", default_value=2, max_value=10, min_value=0.5, align=False)
        sizer.Add(self.delayTime, 1, wx.ALL, 5)

        self.feedback = OSCSlider(self, "Hold", default_value=.99, align=False)
        sizer.Add(self.feedback, 1, wx.ALL, 5)

        self.metronome = wx.ToggleButton(self, 0, "Metronome")
        sizer.Add(self.metronome, 0)

        self.SetSizerAndFit(sizer)
        self.delayTime.Bind(wx.EVT_SCROLL, self.update)
        self.feedback.Bind(wx.EVT_SCROLL, self.update)
        self.metronome.Bind(wx.EVT_TOGGLEBUTTON, self.switchMetronome)
        self.update(None)

    def update(self, evt):
        """ Send OSC messages """
        a = self.delayTime.GetValue() 
        b = self.feedback.GetValue() 
        sendOSCSafe("/delay", [a, b])

    def switchMetronome(self, evt):
        """ Send OSC messages """
        sendOSCSafe("/metronome", [int(self.metronome.GetValue())])


class ButtonArray(wx.Panel):

    """ Handle the ADC input settings """

    def __init__(self, parent, index):
        wx.Panel.__init__(self, parent)
        w = 40
        sizer = wx.BoxSizer(wx.HORIZONTAL)
        self.record = wx.ToggleButton(self, 0, "Arm", size=(w, 25))
        sizer.Add(self.record, 1, wx.ALL, 0)
        self.mute = wx.ToggleButton(self, 0, "Mute", size=(w, 25))
        sizer.Add(self.mute, 1, wx.ALL, 0)
        self.clear = wx.Button(self, 0, "Clear", size=(w, 25))
        sizer.Add(self.clear, 1, wx.ALL, 0)
        self.buttons = (self.record, self.mute, self.clear)
        self.SetSizerAndFit(sizer)


class Channel(wx.Panel):

    """ A single channel """

    def __init__(self, parent, index):
        self.index = index
        wx.Panel.__init__(self, parent)
        sizer = wx.BoxSizer(wx.VERTICAL)

        self.gain = OSCSlider(self, "Gain", default_value=1, max_value=1.3, align=False)
        sizer.Add(self.gain, 0, wx.ALL | wx.EXPAND, 3)

        self.pan = OSCSlider(self, "Pan", default_value=0, min_value=-1, max_value=1, align=False)
        sizer.Add(self.pan, 0, wx.ALL | wx.EXPAND, 3)

        self.fxsend = OSCSlider(self, "Dry/Wet", default_value=0, min_value=0, max_value=1, align=False)
        sizer.Add(self.fxsend, 0, wx.ALL | wx.EXPAND, 3)

        self.buttons = ButtonArray(self, index)
        self.record, self.mute, self.clear = self.buttons.buttons
        sizer.Add(self.buttons, 0, wx.ALL | wx.EXPAND, 3)

        choices = ["1 bar", "2 bars", "4 bars", "Dephase", "1/2 rate"]
        self.speed = wx.ComboBox(self, choices=choices, style=wx.CB_READONLY, size=(25, 25))
        self.speed.SetValue(choices[0])
        sizer.Add(self.speed, 0, wx.ALL | wx.EXPAND, 3)

        choices = ["Forward", "Back", "Half", "Double"]
        self.direction = wx.ComboBox(self, choices=choices, style=wx.CB_READONLY, size=(25, 25))
        self.direction.SetValue(choices[0])
        sizer.Add(self.direction, 0, wx.ALL | wx.EXPAND, 3)

        self.SetSizerAndFit(sizer)

        self.gain.Bind(wx.EVT_SCROLL, self.update)
        self.pan.Bind(wx.EVT_SCROLL, self.update)
        self.fxsend.Bind(wx.EVT_SCROLL, self.update)
        self.speed.Bind(wx.EVT_COMBOBOX, self.update_multiplier)
        self.direction.Bind(wx.EVT_COMBOBOX, self.update_direction)
        self.mute.Bind(wx.EVT_TOGGLEBUTTON, self.update)
        self.update()

    def update(self, evt=None):
        gain = self.gain.GetValue() 
        pan = self.pan.GetValue() 
        fxsend = self.fxsend.GetValue() 
        if self.mute.GetValue(): gain = 0.0
        sendOSCSafe("/channel", [self.index, gain, pan, fxsend])

    def update_multiplier(self, evt=None):
        multiplierTable = {"1 bar": 1., "2 bars": 2., "4 bars": 4., "Dephase": 1.3}
        multiplier = multiplierTable[self.speed.GetValue()]
        sendOSCSafe("/multiplier", [self.index, multiplier])

    def update_direction(self, evt=None):
        #multiplierTable = {"1 bar": 1., "2 bars": 2., "4 bars": 4., "Dephase": 1.3}
        directionTable = {"Forward":1., "Back":-1., "Half":.5, "Double":2.}

        direction = directionTable[self.direction.GetValue()]
        sendOSCSafe("/direction", [self.index, direction])




class Mixer(wx.Panel):

    """ All the channels """

    def __init__(self, parent):
        """ Constructor """
        wx.Panel.__init__(self, parent)
        sizer = wx.BoxSizer(wx.HORIZONTAL)

        self.channels = []
        for i in range(4):
            c = Channel(self, index=i)
            c.record.Bind(wx.EVT_TOGGLEBUTTON, self.switch_record)
            c.record.index = i
            c.clear.Bind(wx.EVT_BUTTON, self.clear_channel)
            c.clear.index = i
            self.channels.append(c)
            sizer.Add(c, 1, wx.EXPAND)

        self.SetSizerAndFit(sizer)

    def switch_record(self, evt):
        """ Send OSC message to switch recording channel """
        index = evt.GetEventObject().index
        value = evt.GetEventObject().GetValue()
        for i, c in enumerate(self.channels):
            c.record.SetValue(0)
        self.channels[index].record.SetValue(value)
        sendOSCSafe("/arm", [index if value else -1])

    def clear_channel(self, evt):
        """ Send OSC message to clear a channel """
        index = evt.GetEventObject().index
        sendOSCSafe("/clear", [index])


class FXPanel(wx.Panel):

    """ Effects chain """

    def __init__(self, parent):
        """ Constructor """
        wx.Panel.__init__(self, parent)
        sizer = wx.BoxSizer(wx.HORIZONTAL)

        label = wx.StaticText(self, label="FX:")
        font = label.GetFont()
        font.SetWeight(wx.BOLD)
        label.SetFont(font)
        sizer.Add(label, 0, wx.EXPAND | wx.TOP | wx.BOTTOM | wx.RIGHT, 5)

        self.lpf = OSCSlider(self, "Lo-pass", default_value=1, align=False)
        sizer.Add(self.lpf, 2, wx.EXPAND | wx.ALL, 5)
        self.lpf.Bind(wx.EVT_SCROLL, self.update)

        self.hpf = OSCSlider(self, "Hi-pass", min_value=0, default_value=0, align=False)
        sizer.Add(self.hpf, 2, wx.EXPAND | wx.ALL, 5)
        self.hpf.Bind(wx.EVT_SCROLL, self.update)

        self.reverb = OSCSlider(self, "Reverb", default_value=.1, align=False)
        sizer.Add(self.reverb, 2, wx.EXPAND | wx.ALL, 5)
        self.reverb.Bind(wx.EVT_SCROLL, self.update)

        self.SetSizerAndFit(sizer)
        self.update(None)

    def update(self, evt):
        a = self.lpf.GetValue() 
        a2 = self.hpf.GetValue() 
        b = self.reverb.GetValue() 
        sendOSCSafe("/fx", [a, a2, b])


class OutputPanel(wx.Panel):

    """ Handle the ADC input settings """

    def __init__(self, parent):
        """ Constructor """
        wx.Panel.__init__(self, parent)
        sizer = wx.BoxSizer(wx.HORIZONTAL)

        label = wx.StaticText(self, label="Output:")
        font = label.GetFont()
        font.SetWeight(wx.BOLD)
        label.SetFont(font)
        sizer.Add(label, 0, wx.TOP | wx.BOTTOM | wx.RIGHT, 5)

        self.level = OSCSlider(self, "Level", default_value=.8, align=False)
        sizer.Add(self.level, 2, wx.EXPAND | wx.ALL, 5)
        self.level.Bind(wx.EVT_SCROLL, self.update)

        self.SetSizerAndFit(sizer)

    def update(self, evt):
        a = self.level.GetValue() 
        sendOSCSafe("/master", [a])


class MainGUI(wx.Frame):

    """ A simple GUI to talk to Chuck """

    def __init__(self):
        """ Constructor """
        # Build the interface
        self.app = wx.App(False)
        self.build()

    def run(self):
        self.app.MainLoop()

    def build(self):
        """ Builds the various pieces of the GUI """
        wx.Frame.__init__(self, None, title="DELAY LORD")
        self.Bind(wx.EVT_CLOSE, self.quit)

        # The main sizer
        self.mainsizer = wx.BoxSizer(wx.VERTICAL)
        self.components = []
        components = (CommsPanel, InputPanel, DelayPanel, Mixer, FXPanel, OutputPanel)

        for index, ctype in enumerate(components):
            if index>0: self.mainsizer.Add(wx.StaticLine(self), 0, wx.EXPAND | wx.ALL, 1)
            c = ctype(self)
            self.components.append(c)
            self.mainsizer.Add(c, 0, wx.EXPAND | wx.ALL, 5)

        self.SetSizerAndFit(self.mainsizer)
        self.Show()

    def populate_left_panel(self):
        """ Populate the left panel """
        # Status boxes

    def quit(self, *args):
        """ Close down gracefully, and then destroy the window """
        self.Destroy()


if __name__ == "__main__":
    initOSCClient(ip="127.0.0.1", port=9000)
    g = MainGUI()
    g.run()
    closeOSC()
