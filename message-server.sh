#!/usr/bin/env python

# This particular script will simply create a print-hello.sh script file that 
# will be executed by Cloud Foundry at this application's startup.

# This is a _very_ silly socket server that simply accepts requests and sends 
# back the message from the message.msg file

import sys
import os
import socket
import select

def main():
    # Open stdout and stderr buffered
    sys.stdout = os.fdopen(sys.stdout.fileno(), 'wb', 0)
    sys.stderr = os.fdopen(sys.stderr.fileno(), 'wb', 0)

    DROPLET_DIR = os.path.dirname(os.path.dirname(sys.argv[0]))
    MESSAGE_FILE=os.path.join(DROPLET_DIR, 'message.msg')

    # Read the message
    message = sys.argv[1] if len(sys.argv) > 1 else 'Default message'

    try:
        with open(MESSAGE_FILE, 'rt') as messageFile:
            message = messageFile.read()
    except:
        print 'Using default message'

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM) # Create a socket object
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1) # Reuse TIME_WAIT sockets
    host = os.environ.get('VCAP_APP_HOST', '0.0.0.0') # Get local machine address
    port = int(os.environ.get('VCAP_APP_PORT', '5959')) # Use the assigned port.
    s.bind((host, port))        # Bind to the port

    print "Listening on host {h} and port {p}...".format(h=host,p=port)
 
    s.listen(5)                 # Now wait for client connection.
    while True:
        try:
            client, addr = s.accept()
            ready = select.select([client,],[], [],2)
            if ready[0]:
                try:
                  print 'Getting data'
                  data = client.recv(4096)
                  print 'Sending response'
                  client.sendall('HTTP/1.1 200 OK\n\n')
                  client.sendall(message)
                  print 'Prepare to close'
                  client.shutdown(socket.SHUT_RDWR)
                  print 'Close'
                  client.close()
                except socket.error, msg:
                  print 'Client connection error:', msg
        except KeyboardInterrupt:
            print
            print "Stop."
            break
        except socket.error, msg:
            print "Socket error! %s" % msg
            break
     
#########################################################
 
if __name__ == "__main__":
    main()
