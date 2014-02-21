import time
import socket


UDP_IP = "127.0.0.1"
UDP_PORT = 9877

with open('104.msg') as f:
    msg104 = f.read()
with open('63.msg') as f:
    msg63 = f.read()
with open('64.msg') as f:
    msg64 = f.read()

print("UDP target IP:", UDP_IP)
print("UDP target port:", UDP_PORT)

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
sock.setblocking(0)
sock.sendto(msg104, (UDP_IP, UDP_PORT))

time.sleep(1)
sock.sendto(msg63, (UDP_IP, UDP_PORT))

time.sleep(1)
sock.sendto(msg64, (UDP_IP, UDP_PORT))

try:
    for _ in range(10):
        print 'in loop'
        time.sleep(1)
        data = sock.recv(1024)
        print data
except socket.error:
    pass

sock.sendto(msg104, (UDP_IP, UDP_PORT))

try:
    for _ in range(10):
        print 'in loop 2'
        time.sleep(1)
        data = sock.recv(1024)
        print data
except socket.error:
    pass
