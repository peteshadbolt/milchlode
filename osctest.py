from simpleOSC import *

initOSCClient(port=9000)
sendOSCMsg("/test", [.1])
closeOSC()
