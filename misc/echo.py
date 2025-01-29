import serial
import threading
import struct

# Configure UART settings
UART_PORT = "/dev/ttyUSB1"  # Replace this with your actual port
BAUD_RATE = 115200
ECHO_OPCODE = 0xEC  # Opcode for the echo operation

# Open the serial port
try:
    ser = serial.Serial(port=UART_PORT, baudrate=BAUD_RATE, timeout=1)
except serial.SerialException as e:
    print(f"Error opening serial port: {e}")
    exit(1)

# Flag to stop the thread
stop_thread = False

def send_packet(opcode, data):
    """
    Constructs and sends a packet over UART.
    :param opcode: Operation code (1 byte)
    :param data: Payload data (bytes)
    """
    length = len(data)
    packet = struct.pack(
        "<BBH", opcode, 0x00, length  # Opcode, Reserved, Length (LSB + MSB)
    ) + data
    ser.write(packet)
    print(f"Sent: {packet.hex()}")

def echo(message):
    """
    Sends an echo packet with the given message.
    :param message: String message to send
    """
    data = message.encode("utf-8")  # Convert string to bytes
    send_packet(ECHO_OPCODE, data)

def receive_data():
    """
    Constantly reads data from the UART and prints it.
    """
    while not stop_thread:
        try:
            if ser.in_waiting > 0:
                data = ser.read(ser.in_waiting)
                print(f"Received: {data.hex()}")
        except OSError as e:
            print(f"Error in receive_data thread: {e}")
            break

# Start a thread to constantly print received data
thread = threading.Thread(target=receive_data, daemon=True)
thread.start()

# Example usage
try:
    echo("Hi")
except KeyboardInterrupt:
    print("Exiting...")
finally:
    # Gracefully stop the thread and close the serial port
    stop_thread = True
    thread.join()  # Wait for the thread to finish
    ser.close()    # Close the serial port
    print("Serial port closed.")
