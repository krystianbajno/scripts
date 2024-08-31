import socket

HOST = '0.0.0.0'
PORT = 65510

key_hex = "4f130123a70d83b551efed9191e71a30ef5ed5dc660c5cbe8fc468547de2425c62345e470706d3566d046a467b71000160d119efe51a63286d04de4d5cad3159"
key = bytes.fromhex(key_hex)

server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind((HOST, PORT))
server_socket.listen()

print(f"Server listening on {HOST}:{PORT}")
while True:
    client_socket, client_addr = server_socket.accept()
    print(f"Accepted connection from {client_addr}")

    client_socket.send(key)
    print(f"Distributed key {key_hex} to {client_addr}")

    client_socket.close()