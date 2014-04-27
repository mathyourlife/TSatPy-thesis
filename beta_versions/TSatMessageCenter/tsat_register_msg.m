function tsat_register_msg(msgnum,flags,msgsize,handler)

global tsat_msg_headers tsat_msg_handlers tsat_msg_flags

tsat_msg_handlers{msgnum} = handler;
tsat_msg_flags(msgnum) = flags;

tsat_msg_headers{msgnum}=[uint8(msgnum),uint8(flags),uint8(floor(msgsize/256)),...
                                           uint8(mod(msgsize,256)),uint8(0)];

reply=sprintf('Message %d registered\n',msgnum);
disp(reply);
