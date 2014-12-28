from libs.simpleosc import *
import wx

class OSCSlider(wx.Panel):
    ''' A GUI slider '''
    def __init__(self, parent, label, min_value=0, max_value=100, default_value=0):
        ''' Constructor '''
        wx.Panel.__init__(self, parent)
        sizer=wx.BoxSizer(wx.HORIZONTAL)
        self.indicator=wx.StaticText(self, label=label)
        sizer.Add(self.indicator, 0, wx.RIGHT, 10)
        self.slider=wx.Slider(self, value=default_value, minValue=min_value, maxValue=max_value)
        sizer.Add(self.slider, 1, wx.EXPAND)
        self.SetSizerAndFit(sizer)
        self.slider.Bind(wx.EVT_SCROLL, self.update)

    def update(self, evt):
        """ Send OSC messages """
        value=float(self.slider.GetValue())
        sendOSCMsg("/test", [value])


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
        wx.Frame.__init__(self, None, title="Controls", size=(500,100))
        self.Bind(wx.EVT_CLOSE, self.quit)

        # The main sizer
        self.mainsizer = wx.BoxSizer(wx.HORIZONTAL)

        self.slider=OSCSlider(self, "Input gain", default_value=50)
        self.mainsizer.Add(self.slider, 1, wx.ALL, 5)

        # Put things together
        self.SetSizerAndFit(self.mainsizer)
        self.Show()
        self.SetSize((700,500))


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
