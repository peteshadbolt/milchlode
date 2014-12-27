from libs.simpleosc import *
import wx

def testosc():
    server = OSCServer (("127.0.0.1", 9000))
    server.addDefaultHandlers()

    initOSCClient(port=9000)
    sendOSCMsg("/test", [.1])
    closeOSC()

class gui_head(wx.Frame):
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

        # Bits and pieces
        self.status=wx.StaticText(self, label="Parameter", style=wx.ST_NO_AUTORESIZE)
        self.mainsizer.Add(self.status, 0)

        self.slider=wx.Slider(self, value=0, minValue=0, maxValue=100)
        self.mainsizer.Add(self.slider, 1)

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
    gui_head()
