from libs.simpleosc import *

server = OSCServer (("127.0.0.1", 9000))
server.addDefaultHandlers()


initOSCClient(port=9000)
sendOSCMsg("/test", [.1])
closeOSC()

