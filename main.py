from libs.simpleosc import *
import wx

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


class InputPanel(wx.Panel):
    ''' Handle the ADC input settings '''
    def __init__(self, parent):
        ''' Constructor '''
        wx.Panel.__init__(self, parent)
        sizer = wx.BoxSizer(wx.HORIZONTAL)

        label = wx.StaticText(self, label="Line In:")
        font = label.GetFont(); font.SetWeight(wx.BOLD); label.SetFont(font) 
        sizer.Add(label, 0, wx.TOP|wx.BOTTOM|wx.RIGHT, 5)

        self.gain = OSCSlider(self, "Gain", default_value=.5, align=False)
        sizer.Add(self.gain, 1, wx.ALL, 5)
        self.thru = OSCSlider(self, "Thru", default_value=.5, align=False)
        sizer.Add(self.thru, 1, wx.ALL, 5)

        self.mute = wx.ToggleButton(self, 1, "Mute")
        sizer.Add(self.mute, 0)
        self.SetSizerAndFit(sizer)
        
        self.gain.slider.Bind(wx.EVT_SCROLL, self.update)
        self.thru.slider.Bind(wx.EVT_SCROLL, self.update)
        self.mute.Bind(wx.EVT_TOGGLEBUTTON, self.update)
        self.update()

    def update(self, evt=None):
        """ Send OSC messages """
        gain=self.gain.slider.GetValue()/100.
        thru=self.thru.slider.GetValue()/100.
        if self.mute.GetValue(): gain, thru = 0.,0.
        try:
            sendOSCMsg("/input", [gain, thru])
        except OSCClientError:
            pass

class DelayPanel(wx.Panel):
    ''' Handle the ADC input settings '''
    def __init__(self, parent):
        ''' Constructor '''
        wx.Panel.__init__(self, parent)
        sizer = wx.BoxSizer(wx.VERTICAL)

        label = wx.StaticText(self, label="Delay line:")
        font = label.GetFont(); font.SetWeight(wx.BOLD); label.SetFont(font) 
        sizer.Add(label, 0, wx.TOP|wx.BOTTOM|wx.RIGHT, 5)

        self.delayTime=OSCSlider(self, "Delay time (s)", default_value=1, max_value=10)
        sizer.Add(self.delayTime, 0, wx.EXPAND|wx.ALL, 5)

        self.feedback=OSCSlider(self, "Feedback", default_value=.95)
        sizer.Add(self.feedback, 0, wx.EXPAND|wx.ALL, 5)

        self.SetSizerAndFit(sizer)
        self.delayTime.slider.Bind(wx.EVT_SCROLL, self.update)
        self.feedback.slider.Bind(wx.EVT_SCROLL, self.update)
        self.update(None)

    def update(self, evt):
        """ Send OSC messages """
        a=self.delayTime.slider.GetValue()/100.
        b=self.feedback.slider.GetValue()/100.
        try:
            sendOSCMsg("/delay", [a, b])
        except OSCClientError:
            pass

class Channel(wx.Panel):
    """ A single channel """
    def __init__(self, parent, index):
        self.index=index
        wx.Panel.__init__(self, parent)
        sizer = wx.BoxSizer(wx.VERTICAL)

        label = wx.StaticText(self, label="CH%d" % self.index)
        font = label.GetFont(); font.SetWeight(wx.BOLD); label.SetFont(font) 
        sizer.Add(label, 0, wx.TOP|wx.BOTTOM|wx.RIGHT, 5)

        self.gain = OSCSlider(self, "Gain", default_value=0, align=False)
        sizer.Add(self.gain, 0, wx.ALL|wx.EXPAND, 3)

        self.pan = OSCSlider(self, "Pan", min_value=-1, max_value=1, default_value=0, align=False)
        sizer.Add(self.pan, 0, wx.ALL|wx.EXPAND, 3)

        self.record = wx.ToggleButton(self, 1, "Arm")
        sizer.Add(self.record, 0, wx.ALL|wx.EXPAND, 3)

        self.mute = wx.ToggleButton(self, 1, "Mute")
        sizer.Add(self.mute, 0, wx.ALL|wx.EXPAND, 3)

        self.fx = wx.ToggleButton(self, 1, "FX")
        sizer.Add(self.fx, 0, wx.ALL|wx.EXPAND, 3)

        self.clear = wx.Button(self, 1, "Clear")
        sizer.Add(self.clear, 0, wx.ALL|wx.EXPAND, 3)
        #self.gain.slider.Bind(wx.EVT_SCROLL, self.update)

        self.gain.slider.Bind(wx.EVT_SCROLL, self.update)
        self.pan.slider.Bind(wx.EVT_SCROLL, self.update)

        self.SetSizerAndFit(sizer)

    def update(self, evt=None):
        data = [self.index,
                self.gain.slider.GetValue()/100.,
                self.pan.slider.GetValue()/100.]
                #self.record.GetValue(),
                #self.mute.GetValue(),
                #self.fx.GetValue()]
        try:
            sendOSCMsg("/channel", data)
        except OSCClientError:
            pass

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
        self.ip.SetFont(wx.Font(9, wx.DEFAULT, wx.NORMAL, wx.NORMAL))
        sizer.Add(self.ip, 0, wx.ALL, 3)

        self.port=wx.TextCtrl(self, value="9000")
        self.port.SetFont(wx.Font(9, wx.DEFAULT, wx.NORMAL, wx.NORMAL))
        sizer.Add(self.port, 0, wx.ALL, 3)

        self.SetSizerAndFit(sizer)




class ChannelPanel(wx.Panel):
    ''' All the channels '''
    def __init__(self, parent):
        ''' Constructor '''
        wx.Panel.__init__(self, parent)
        sizer = wx.BoxSizer(wx.HORIZONTAL)

        self.channels=[]
        for i in range(4):
            c=Channel(self, index=i)
            #self.feedback.slider.Bind(wx.EVT_SCROLL, self.update)
            self.channels.append(c)
            sizer.Add(c, 1, wx.EXPAND)

        self.SetSizerAndFit(sizer)
        self.update(None)

    def update(self, evt):
        """ Send OSC messages """
        pass



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

        self.channelPanel = ChannelPanel(self)
        self.mainsizer.Add(self.channelPanel, 1, wx.EXPAND|wx.ALL, 5)

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