function msg_data = handle_uplinkRawData(flags,sock)

% Read the data out of the receive buffer
msg_data=pnet(sock,'read',15,'double','intel');
