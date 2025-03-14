import serial
import struct

#UART config
SERIAL_PORT = "COM8"
BAUD_RATE = 115200

#Operation codes
OPCODES = {
    "ec": 0xec,  #Echo
    "ac": 0xac,  #Multiplication
    "ad": 0xad,  #Addition
    "d1": 0xd1   #Division
}

def construct_packet(opcode, num1=None, num2=None, echo_data=None):
    """Constructs the packet based on the operation type."""
    reserved = 0x00

    if opcode == 0xec:
        data = echo_data.encode("utf-8")
        length = 4 + len(data)
        msb = (length >> 8) & 0xFF
        lsb = length & 0xFF
        packet = [opcode, reserved, lsb, msb] + list(data)
    else:
        length = 12
        msb = 0x00
        lsb = length & 0xFF
        data0 = list(struct.pack(">I", num1))
        data1 = list(struct.pack(">I", num2))
        packet = [opcode, reserved, lsb, msb] + data0 + data1

    return bytearray(packet)

def main():
    ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)

    print("Enter operation (ec for echo, ac for multiplication, ad for addition, d1 for division):")
    operation = input().strip().lower()

    if operation not in OPCODES:
        print("Invalid operation.")
        return

    opcode = OPCODES[operation]

    if operation == "ec":
        echo_message = input("Enter the message to echo: ")
        packet = construct_packet(opcode, echo_data=echo_message)
    else:
        num1 = int(input("Enter first number: "))
        num2 = int(input("Enter second number: "))
        packet = construct_packet(opcode, num1, num2)

    ser.write(packet)

    formatted_packet = "".join(f"{b:02x}" for b in packet)
    print("Packet sent:", formatted_packet)

    response = ser.read(256)
    if response:
        formatted_response = response.hex().lstrip("0")


        if not formatted_response:
            formatted_response = "0"

        print("Received (Hex):", formatted_response)


        try:
            decimal_value = int(formatted_response, 16)
            print("Received (Decimal):", decimal_value)
        except ValueError:
            print("Received (Text):", bytes.fromhex(formatted_response).decode(errors="ignore"))

    ser.close()


if __name__ == "__main__":
    main()
