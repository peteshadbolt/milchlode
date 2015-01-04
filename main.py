from libs.simpleosc import *
import wx

def sendOSCSave(channel, data):
    try:
        sendOSCMsg(channel, data)
    except OSCClientError:
        print "OSC comms error"

class OSCSlider(wx.Panel):
    ''' A GUI slider '''
    def __init__(self, parent, label, min_value=0, max_value=1, default_value=0, align=True):
        ''' Constructor '''
        wx.Panel.__init__(self, parent)
        sizer=wx.BoxSizer(wx.HORIZONTAL)
        label=wx.StaticText(self, label=label, size=(100,15) if align else None)
        sizer.Add(label, 0, wx.RIGHT, 10)
        self.slider=wx.Slider(self, value=default_value*100, minValue=min_value*100, maxValue=max_value*100)
        sizer.Add(self.slider, 1, wx.EXPAND)
        self.SetSizerAndFit(sizer)
        self.Bind=self.slider.Bind
        self.GetValue=self.slider.GetValue


class CommsPanel(wx.Panel):
    """ OSC comms """
    def __init__(self, parent):
        wx.Panel.__init__(self, parent)
        sizer = wx.BoxSizer(wx.HORIZONTAL)

        label = wx.StaticText(self, label="Sync:")
        font = label.GetFont(); font.SetWeight(wx.BOLD); label.SetFont(font) 
        sizer.Add(label, 0, wx.TOP|wx.BOTTOM|wx.RIGHT|wx.EXPAND, 5)

        self.master = wx.ToggleButton(self, 1, "Master/Minion")
        sizer.Add(self.master, 0, wx.ALL, 3)

        self.ip=wx.TextCtrl(self, value="127.0.0.1")
        sizer.Add(self.ip, 0, wx.ALL, 3)

        self.port=wx.TextCtrl(self, value="9000")
        sizer.Add(self.port, 0, wx.ALL, 3)

        self.SetSizerAndFit(sizer)


class InputPanel(wx.Panel):
    ''' Handle the ADC input settings '''
    def __init__(self, parent):
        ''' Constructor '''
        wx.Panel.__init__(self, parent)
        sizer = wx.BoxSizer(wx.HORIZONTAL)

        label = wx.StaticText(self, label="Line in:")
        font = label.GetFont(); font.SetWeight(wx.BOLD); label.SetFont(font) 
        sizer.Add(label, 0, wx.TOP|wx.BOTTOM|wx.RIGHT, 5)

        self.gain = OSCSlider(self, "Gain", default_value=.5, align=False)
        sizer.Add(self.gain, 1, wx.ALL, 5)
        self.thru = OSCSlider(self, "Thru", default_value=.5, align=False)
        sizer.Add(self.thru, 1, wx.ALL, 5)

        self.mute = wx.ToggleButton(self, 1, "Mute")
        #self.mute.SetValue(1)
        sizer.Add(self.mute, 0)
        self.SetSizerAndFit(sizer)
        
        self.gain.Bind(wx.EVT_SCROLL, self.update)
        self.thru.Bind(wx.EVT_SCROLL, self.update)
        self.mute.Bind(wx.EVT_TOGGLEBUTTON, self.update)

        self.update()

    def update(self, evt=None):
        """ Send OSC messages """
        gain=self.gain.slider.GetValue()/100.
        thru=self.thru.slider.GetValue()/100.
        if self.mute.GetValue(): gain, thru = 0.,0.
        sendOSCMsg("/input", [gain, thru])

class DelayPanel(wx.Panel):
    ''' Handle the ADC input settings '''
    def __init__(self, parent):
        ''' Constructor '''
        wx.Panel.__init__(self, parent)
        sizer = wx.BoxSizer(wx.VERTICAL)

        label = wx.StaticText(self, label="Delay lines:")
        font = label.GetFont(); font.SetWeight(wx.BOLD); label.SetFont(font) 
        sizer.Add(label, 0, wx.TOP|wx.BOTTOM|wx.RIGHT, 5)

        self.delayTime=OSCSlider(self, "Delay time (s)", default_value=1, max_value=10)
        sizer.Add(self.delayTime, 0, wx.EXPAND|wx.ALL, 5)

        self.feedback=OSCSlider(self, "Feedback", default_value=.99)
        sizer.Add(self.feedback, 0, wx.EXPAND|wx.ALL, 5)

        self.metronome=wx.ToggleButton(self, 0, "Metronome")
        sizer.Add(self.metronome, 0, wx.EXPAND|wx.ALL, 5)

        self.SetSizerAndFit(sizer)
        self.delayTime.Bind(wx.EVT_SCROLL, self.update)
        self.feedback.Bind(wx.EVT_SCROLL, self.update)
        self.metronome.Bind(wx.EVT_TOGGLEBUTTON, self.switchMetronome)
        self.update(None)

    def update(self, evt):
        """ Send OSC messages """
        a=self.delayTime.slider.GetValue()/100.
        b=self.feedback.slider.GetValue()/100.
        sendOSCMsg("/delay", [a, b])

    def switchMetronome(self, evt):
        """ Send OSC messages """
        sendOSCMsg("/metronome", [int(self.metronome.GetValue())])

class Channel(wx.Panel):
    """ A single channel """
    def __init__(self, parent, index):
        self.index=index
        wx.Panel.__init__(self, parent)
        sizer = wx.BoxSizer(wx.VERTICAL)

        label = wx.StaticText(self, label="CH%d" % self.index)
        font = label.GetFont(); font.SetWeight(wx.BOLD); label.SetFont(font) 
        sizer.Add(label, 0, wx.TOP|wx.BOTTOM|wx.RIGHT, 5)

        self.gain = OSCSlider(self, "Gain", default_value=1, max_value=1.3, align=False)
        sizer.Add(self.gain, 0, wx.ALL|wx.EXPAND, 3)

        self.pan = OSCSlider(self, "Pan", default_value=0, min_value=-1, max_value=1, align=False)
        sizer.Add(self.pan, 0, wx.ALL|wx.EXPAND, 3)

        self.record = wx.ToggleButton(self, 1, "Arm")
        sizer.Add(self.record, 0, wx.ALL|wx.EXPAND if index==0 else wx.ALL|wx.EXPAND, 3)

        self.mute = wx.ToggleButton(self, 1, "Mute")
        sizer.Add(self.mute, 0, wx.ALL|wx.EXPAND, 3)
        self.clear = wx.Button(self, 1, "Clear")
        sizer.Add(self.clear, 0, wx.ALL|wx.EXPAND, 3)
        self.SetSizerAndFit(sizer)

        self.gain.Bind(wx.EVT_SCROLL, self.update)
        self.pan.Bind(wx.EVT_SCROLL, self.update)
        self.mute.Bind(wx.EVT_TOGGLEBUTTON, self.update)
        self.update()

    def update(self, evt=None):
        gain=self.gain.GetValue()/100.
        pan=self.pan.GetValue()/100.
        if self.mute.GetValue(): gain=0.0;
        sendOSCMsg("/channel", [self.index, gain, pan])


class Mixer(wx.Panel):
    ''' All the channels '''
    def __init__(self, parent):
        ''' Constructor '''
        wx.Panel.__init__(self, parent)
        sizer = wx.BoxSizer(wx.HORIZONTAL)

        self.channels=[]
        for i in range(4):
            c=Channel(self, index=i)
            c.record.Bind(wx.EVT_TOGGLEBUTTON, self.switch_record)
            c.record.index=i
            c.clear.Bind(wx.EVT_BUTTON, self.clear_channel)
            c.clear.index=i
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
        sendOSCMsg("/arm", [index if value else -1])

    def clear_channel(self, evt):
        """ Send OSC message to clear a channel """
        index = evt.GetEventObject().index
        sendOSCMsg("/clear", [index])



class MainGUI(wx.Frame):
    """ A simple GUI to talk to Chuck """
    def __init__(self):
        """ Constructor """
        # Build the interface
        self.app = wx.App(False)
        self.build()
        self.app.MainLoop()

    def build(self):
        """ Builds the various pieces of the GUI """
        wx.Frame.__init__(self, None, title="DELAY LORD")
        self.Bind(wx.EVT_CLOSE, self.quit)

        # The main sizer
        self.mainsizer = wx.BoxSizer(wx.VERTICAL)

        self.commsPanel = CommsPanel(self)
        self.mainsizer.Add(self.commsPanel, 0, wx.EXPAND|wx.ALL, 5)

        line=wx.StaticLine(self); self.mainsizer.Add(line, 0, wx.EXPAND|wx.ALL, 1)

        self.inputPanel = InputPanel(self)
        self.mainsizer.Add(self.inputPanel, 0, wx.EXPAND|wx.ALL, 5)

        line=wx.StaticLine(self); self.mainsizer.Add(line, 0, wx.EXPAND|wx.ALL, 1)

        self.delayPanel = DelayPanel(self)
        self.mainsizer.Add(self.delayPanel, 0, wx.EXPAND|wx.ALL, 5)

        line=wx.StaticLine(self); self.mainsizer.Add(line, 0, wx.EXPAND|wx.ALL, 1)

        self.mixer = Mixer(self)
        self.mainsizer.Add(self.mixer, 1, wx.EXPAND|wx.ALL, 5)

        # Put things together
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
    g=MainGUI()
    closeOSC()
