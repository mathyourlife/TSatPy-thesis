function msg_data = handle_ackMesg(flags,sock)

theMesg=pnet(sock,'read',1,'char','intel');

msg_data = ceil(theMesg);

