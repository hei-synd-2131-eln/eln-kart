from cmath import pi
import tkinter as tk
import tkinter.messagebox
import serial
import serial.tools.list_ports
from threading import Thread
import pathlib

VERSION = "0.1_dev"
MOD_AUTHOR = ""
MOD_DESCR = ""
TITLE = "EBS3 UART Interpreter"
ICON = "ELN_kart.ico"

NB_LEDS = 4
NB_ENDSW = 1
NB_HALL = 1
NB_PROXI = 0
WHEEL_DIAMETER_MM = 100

# Reading the serial port
class UartHandler(serial.Serial, Thread):

    def __init__(self, port, baudrate):
        Thread.__init__(self)
        self._terminated = False
        self._bytecounter = 0
        self._frame_valid = False
        self._tx_data = [0] * 5
        self._rx_data = [0] * 5
        try:
            serial.Serial.__init__(self, port=port, baudrate=baudrate, timeout=1)
            self.start()
            self.started = True
        except Exception as e:
            self.started = False
            raise e

    def close_com(self):
        if self.started:
            self._terminated = True
            self.join()
        self.close()

    def __del__(self):
        self.close_com()

    def receiving(self):
        return self._bytecounter != 0

    def frame_valid(self) -> bool:
        return self._frame_valid

    def tx_data(self):
        return self._tx_data

    def rx_data(self):
        return self._rx_data

    def run(self):
        while not self._terminated:
            try:
                b = self.read()
                if len(b) == 0:
                    continue
                b = int.from_bytes(b, 'big')
                # Header
                if self._bytecounter == 0:
                    self._frame_valid = False
                    if b == 0xAA:
                        self._bytecounter += 1
                    self._rx_data[0] = b
                # CRC8-itu check
                elif self._bytecounter == 4:
                    self._rx_data[4] = b
                    self._bytecounter = 0
                    self._frame_valid = self.crc8_itu(self._rx_data[0:4]) == self._rx_data[4]
                # Normal data
                else:
                    self._rx_data[self._bytecounter] = b
                    self._bytecounter += 1
            except serial.SerialException as e:
                pass
                print(e)
            except Exception as e:
                pass
                print(e)

    def send_data(self, addr : int, data : int):
        self._tx_data[0] = 0xAA
        self._tx_data[1] = addr
        self._tx_data[2] = (data >> 8) & 0xFF
        self._tx_data[3] = data & 0xFF
        self._tx_data[4] = self.crc8_itu(self._tx_data[0:4])
        self.write(bytes(self._tx_data))
    
    def crc8_itu(self, data):
        g = 1 << 8 | 0x07
        crc = 0x00
        for d in data:
            crc ^= d
            for _ in range(8):
                crc <<= 1
                if crc & (1<<8):
                    crc ^= g
        crc ^= 0x55
        return crc




# Tkinter app
class App(tk.Tk):
    
    # Create UI window
    def __init__(self):
        tk.Tk.__init__(self)
        self.iconbitmap(pathlib.Path(__file__).parent.resolve().__str__() + "/" + ICON)
        self.title(TITLE)
        self.geometry("500x300")
        self.resizable(False, False)
        self.create_menus()
        self.create_footer()
        # Create for uart frame
        self.tx_label = tk.Label(self, text="")
        self.rx_label = tk.Label(self, text="")
        self.rx_expl_label = tk.Label(self, text="")
        self.tx_label.pack()
        self.rx_label.pack()
        self.rx_expl_label.pack()

        # Tx options
        self.tx_gridframe = tk.Frame(self)
        self.tx_gridframe.configure(pady=30)
            # Module and register selection
        self.tx_register = tk.StringVar()
        self.tx_register_menu = tk.OptionMenu(self.tx_gridframe, self.tx_register, "None")
        self.tx_module = tk.StringVar()
        self.tx_module_menu = tk.OptionMenu(self.tx_gridframe, self.tx_module, "DC Motor", "Stepper Motor", "Sensors", "CReg")
        self.tx_module.trace("w", self.update_tx_module)
        self.tx_module.set("DC Motor")
            # Add a value textbox from 0 to 65535
        self.tx_value = tk.StringVar()
        self.tx_value_entry = tk.Entry(self.tx_gridframe, textvariable=self.tx_value)
            # Create a grid composed of labels "Module", "Register", "Value" and the corresponding entrys
        self.tx_module_label = tk.Label(self.tx_gridframe, text="Module")
        self.tx_register_label = tk.Label(self.tx_gridframe, text="Register")
        self.tx_value_label = tk.Label(self.tx_gridframe, text="Value")
        self.tx_module_label.grid(row=0, column=0)
        self.tx_module_menu.grid(row=1, column=0, padx=10)
        self.tx_register_label.grid(row=0, column=1)
        self.tx_register_menu.grid(row=1, column=1, padx=10)
        self.tx_value_label.grid(row=0, column=2)
        self.tx_value_entry.grid(row=1, column=2, padx=10)
            # Lay out tx_module_menu and tx_register_menu side by side with a header text
        self.tx_module_menu.config(width=10, font=("Arial", 10), justify="center", state="disabled", anchor="w")
        self.tx_register_menu.config(width=10, font=("Arial", 10), justify="center", state="disabled", anchor="w")
        self.tx_value_entry.config(width=10, font=("Arial", 10), justify="right", state="disabled")
            # Create a button to send adn read the data
        self.tx_write_button = tk.Button(self.tx_gridframe, text="Write", command=self.write_reg, state="disabled")
        self.tx_write_button.grid(row=0, column=4, rowspan=2, sticky="ns", padx=10)
        self.tx_read_button = tk.Button(self.tx_gridframe, text="Read", command=self.read_reg, state="disabled")
        self.tx_read_button.grid(row=0, column=5, rowspan=2, sticky="ns", padx=10)
            # Finalize
        self.tx_gridframe.pack()

        # Scrollable text box to log rx commands taking all width
        self.last_txt = ""
        self.rx_frame = tk.Frame(self)
        self.rx_frame.configure(pady=10)
            # Add clear button on the left
        self.rx_clear_button = tk.Button(self.rx_frame, text="Clear", command=self.clear_rx_text, width=6)
        self.rx_clear_button.pack(side="left", fill='y', padx=5)
            # Add textbox
        self.rx_text = tk.Text(self.rx_frame)
        self.rx_text.configure(font=("Arial", 8), padx=5)
        self.rx_text.tag_configure("red", foreground="red")
        self.rx_text.tag_configure("green", foreground="green")
        self.rx_text.tag_configure("blue", foreground="blue")
        #self.rx_text.configure(state="disabled")
            # Add scrollbar
        self.rx_scrollbar = tk.Scrollbar(self.rx_frame, orient="vertical", command=self.rx_text.yview, width=15)
        self.rx_text.configure(yscrollcommand=self.rx_scrollbar.set)
        self.rx_scrollbar.pack(side="right", fill="y", padx=2)
        self.rx_text.pack(side="left")
            # Pack
        self.rx_frame.pack()

        # Periodic update
        self.update_data_labels()
        self.after(100, self.update_data_labels)
        # Catch closing to stop UARt thread
        self.protocol("WM_DELETE_WINDOW", self.on_closing)


    def clear_rx_text(self):
        self.rx_text.delete(1.0, tk.END)

    def write_reg(self):
        self.send_data(False)

    def read_reg(self):
        self.send_data(True)

    def send_data(self, isRead : bool):
        if isRead:
            txd = 0
        else:
            try:
                # Retrieve text from tx_data
                txd = self.tx_value.get()
                # Parse txd if begins with 0x or 0b or none
                if len(txd) == 0:
                    raise Exception("No value entered")
                elif txd.startswith("0x"):
                    txd = int(txd[2:],16)
                elif txd.startswith("0b"):
                    txd = int(txd[2:],2)
                else:
                    txd = int(txd)
            except Exception as e:
                tkinter.messagebox.showerror("Error", e)
                return
        # Retrieve module and register
        module = self.tx_module.get()
        register = self.tx_register.get()
        if module == "DC Motor":
            module = 0x00 if isRead else 0x20
            if register == "Prescaler":
                pass
            elif register == "Speed":
                module += 1
            else:
                print("Error : unknown register")
                return
        elif module == "Stepper Motor":
            module = 0x40 if isRead else 0x60
            if register == "Prescaler":
                pass
            elif register == "Target angle":
                module += 1
            elif register == "Current angle":
                module += 2
            elif register == "HW orientation":
                module += 3
        elif module == "Sensors":
            module = 0x80 if isRead else 0xA0
            if register == "Refresh proxi":
                pass
            elif register.startswith("LED"):
                module += int(register[3:])
            elif register == "Voltage":
                module += NB_LEDS + 1
            elif register == "Current":
                module += NB_LEDS + 2
            elif register == "Ranger":
                module += NB_LEDS + 3
            elif register == "EndSW":
                module += NB_LEDS + 4
            elif register.startswith("Hall"):
                module += NB_LEDS + 4 + int(register[4:])
            elif register.startswith("Proxi"):
                module += NB_LEDS + 4 + NB_HALL + int(register[5:])
            elif register.startswith("Ambient"):
                module += NB_LEDS + 4 + NB_HALL + NB_PROXI + int(register[7:])
        else:
            module = 0xC0 if isRead else 0xE0
            if register == "HW Control":
                pass
        # Send data
        self.uart_handler.send_data(module, txd)
        

    def update_tx_module(self, *args):
        self.tx_register_menu['menu'].delete(0, tk.END)
        if self.tx_module.get() == "DC Motor":
            self.tx_register_menu['menu'].add_command(label="Prescaler", command=lambda: self.tx_register.set("Prescaler"))
            self.tx_register_menu['menu'].add_command(label="Speed", command=lambda: self.tx_register.set("Speed"))
            self.tx_register.set("Prescaler")
        elif self.tx_module.get() == "Stepper Motor":
            self.tx_register_menu['menu'].add_command(label="Prescaler", command=lambda: self.tx_register.set("Prescaler"))
            self.tx_register_menu['menu'].add_command(label="Target angle", command=lambda: self.tx_register.set("Target angle"))
            self.tx_register_menu['menu'].add_command(label="Current angle", command=lambda: self.tx_register.set("Current angle"))
            self.tx_register_menu['menu'].add_command(label="HW orientation", command=lambda: self.tx_register.set("HW orientation"))
            self.tx_register.set("Prescaler")
        elif self.tx_module.get() == "Sensors":
            self.tx_register_menu['menu'].add_command(label="Refresh proxi", command=lambda: self.tx_register.set("Refresh proxi"))
            for i in range(NB_LEDS):
                self.tx_register_menu['menu'].add_command(label="LED" + str(i+1), command=lambda i=i: self.tx_register.set("LED" + str(i+1)))
            self.tx_register_menu['menu'].add_command(label="Voltage", command=lambda: self.tx_register.set("Voltage"))
            self.tx_register_menu['menu'].add_command(label="Current", command=lambda: self.tx_register.set("Current"))
            self.tx_register_menu['menu'].add_command(label="Ranger", command=lambda: self.tx_register.set("Ranger"))
            self.tx_register_menu['menu'].add_command(label="EndSW", command=lambda: self.tx_register.set("EndSW"))
            for i in range(NB_HALL):
                self.tx_register_menu['menu'].add_command(label="Hall" + str(i+1), command=lambda i=i: self.tx_register.set("Hall" + str(i+1)))
            for i in range(NB_PROXI):
                self.tx_register_menu['menu'].add_command(label="Proxi" + str(i+1), command=lambda i=i: self.tx_register.set("Proxi" + str(i+1)))
            for i in range(NB_PROXI):
                self.tx_register_menu['menu'].add_command(label="Ambient" + str(i+1) + " threshold", command=lambda i=i: self.tx_register.set("Ambient" + str(i+1)))
            self.tx_register.set("LED1")
        elif self.tx_module.get() == "CReg":
            self.tx_register_menu['menu'].add_command(label="HW Control", command=lambda: self.tx_register.set("HW Control"))
            self.tx_register.set("HW Control")

    def on_closing(self):
        if self.uart_handler:
            self.uart_handler.close_com()
        self.destroy()
               
    def update_data_labels(self):
        txl = "Tx: "
        rxl = "Rx: "
        rx_exp = ""
        col = "black"
        if self.uart_handler is not None:
            self.tx_module_menu.config(state="normal")
            self.tx_register_menu.config(state="normal")
            self.tx_value_entry.config(state="normal")
            self.tx_read_button.config(state="normal")
            self.tx_write_button.config(state="normal")
            rxd = [0] * 5
            if self.uart_handler.receiving():
                col = "blue"
            else:
                if self.uart_handler.frame_valid():
                    col = "green"
                else:
                    col = "red"
            for i in range(5):
                txl += " " + "{0:#0{1}x}".format(self.uart_handler.tx_data()[i], 4)
                rxl += " " + "{0:#0{1}x}".format(self.uart_handler.rx_data()[i], 4)
                rxd[i] = self.uart_handler.rx_data()[i]

            # Parse received data
            t = "Event: " if rxd[1] & 0x20 else "Read: "
            r = rxd[1] & 0x1F
            if rxd[1] >= 0 and rxd[1] < 0x40:
                t += "DC Motor "
                if r == 0:
                    t += " | Prescaler | " + str(rxd[2] << 8 | rxd[3]) + " - freq = " + ((str(10000000 / (16*int(rxd[2] << 8 | rxd[3]))) + " Hz") if int(rxd[2] << 8 | rxd[3]) != 0 else "error - presc = 0")
                elif r == 1:
                    v = rxd[2] << 8 | rxd[3]
                    t += " | Speed | " + (str(v-65536) if rxd[2] & 0x80 else str(v))
                else:
                    t += " | Unknown"
            elif rxd[1] >= 0x40 and rxd[1] < 0x80:
                t += "Stepper Motor "
                if r == 0:
                    t += " | Prescaler | " + str(rxd[2] << 8 | rxd[3]) + " - freq = " + ((str(100000 / (int(rxd[2] << 8 | rxd[3]))) + " Hz") if int(rxd[2] << 8 | rxd[3]) != 0 else "error - presc = 0")
                elif r == 1:
                    t += " | Target angle | " + str(rxd[2] << 8 | rxd[3])
                elif r == 2:
                    t += " | Actual angle | " + str(rxd[2] << 8 | rxd[3])
                elif r == 3:
                    t += " | Stepper HW | stepper " + ("closed" if rxd[3] & 0x01 else "open") + " - position " + ("reached" if rxd[3] & 0x02 else "not reached")
                else:
                    t += " | Unknown"
            elif rxd[1] >= 0x80 and rxd[1] < 0xC0:
                t += "Sensors "
                if r == 0:
                    t += " | Refresh proxi"
                elif r >= 1 and r <= NB_LEDS:
                    t += " | Led " + str(r) + " | " + ("on" if rxd[2] & 0x80 else "off") + " - period of " + str((rxd[2] & 0x7F) << 8 | rxd[3]) + " ms"
                elif r == NB_LEDS + 1:
                    t += " | Voltage | " + str((rxd[2] << 8 | rxd[3]) * 7.8 * 0.00025) + " V"
                elif r == NB_LEDS + 2:
                    t += " | Current | " + str(((rxd[2] << 8 | rxd[3]) * 0.00025 * 1000)/(100*0.005)) + " mA"
                elif r == NB_LEDS + 3:
                    v = (rxd[2] << 8 | rxd[3])
                    t += " | Distance | " + (str(v * 25.4 / 147) if v > 26 else "indefinite (too low)") + " mm"
                elif r == NB_LEDS + 4:
                    t += " | EndSW | " + str(format((rxd[2] << 8 | rxd[3]), "016b"))
                elif r >= NB_LEDS + 5 and r <= NB_LEDS + NB_HALL + 4:
                    turns = (rxd[2] & 0xE0)>>5
                    timems = ((rxd[2] & 0x1F) << 8 | rxd[3]) * 0.25
                    t += " | Hall " + str(r - NB_LEDS - 4) + " | turns : " + str(turns) + " in " + str(timems) + " ms" + " - speed of " + ((str(turns * (pi*WHEEL_DIAMETER_MM) / (timems / 1000)) + " mm/s") if timems != 0 else "error : time = 0")
                elif r >= NB_LEDS + NB_HALL + 5 and r <= NB_LEDS + NB_HALL + NB_PROXI + 4:
                    t += " | Proxi " + str(r - NB_LEDS - NB_HALL - 4) + " | " + str(rxd[2] << 8 | rxd[3]) + " (higher is closer)"
                elif r >= NB_LEDS + NB_HALL + NB_PROXI + 5 and r <= NB_LEDS + NB_HALL + 2*NB_PROXI + 4:
                    t += " | Ambient " + str(r - NB_LEDS - NB_HALL - NB_PROXI - 4) + " | light of " + str((rxd[2] << 8 | rxd[3])*0.25) + " lux" 
                else:
                    t += " | Unknown"
            else:
                t += "Control Registers "
                if r == 0:
                    t += " | Hardware Control | " + ("forwards" if rxd[2] & 0x01 else "backwards") + " - " + ("right" if rxd[2] & 0x02 else "left") + \
                        " - " + ("CW" if rxd[2] & 0x04 else "CCW") + " - stepper " + ("on" if rxd[2] & 0x08 else "off") + " - " + ("restart" if rxd[2] & 0x10 else "no restart") \
                        + " - BT " + ("connected" if rxd[2] & 0x20 else "disconnected")
                else:
                    t += " | Unknown"
            rx_exp = t
            # Add to rx_text
            if len(self.last_txt) != 0 and self.last_txt != rx_exp:
                self.last_txt = rx_exp
                if col == "red":
                    self.rx_text.insert(tk.END, rx_exp + "\n", "red")
                elif rx_exp.startswith("Event"):
                    self.rx_text.insert(tk.END, rx_exp + "\n", "blue")
                else:
                    self.rx_text.insert(tk.END, rx_exp + "\n", "green")
                # Scroll bar if text too long
                self.rx_text.see("end")             
            else:
                self.last_txt = rx_exp
        else:
            txl = "Serial port not connected"
            rxl = ""
            self.tx_module_menu.config(state="disabled")
            self.tx_register_menu.config(state="disabled")
            self.tx_value_entry.config(state="disabled")
            self.tx_read_button.config(state="disabled")
            self.tx_write_button.config(state="disabled")
        self.tx_label.config(text=txl)
        self.rx_label.config(text=rxl, fg=col)
        self.rx_expl_label.config(text=rx_exp, fg=col)

        self.after(100, self.update_data_labels)

    def create_footer(self):
        # show port_label and baud_label in status bar
        self.port_label = tk.Label(self, text="Port: none")
        self.baud_label = tk.Label(self, text="Baud Rate: 115200")
        self.status = tk.Label(self, text="", relief=tk.SUNKEN, anchor="w")
        self.status.pack(side="bottom", fill="x")
        self.update_status()

    def create_menus(self):
        self.menu = tk.Menu(self)
        self.config(menu=self.menu)
        self.uart_handler = None
        self.port_menu = tk.Menu(self.menu, tearoff="off")
        self.menu.add_cascade(label="Serial", menu=self.port_menu)
        self.create_com_menu(self.port_menu)
        self.create_baud_menu(self.port_menu)
        # Add about menu
        self.menu.add_command(label="About", command=self.about)
        # Add exit menu
        self.menu.add_command(label="Exit", command=self.quit)

    def about(self):
        tk.messagebox.showinfo("About", "Custom serial terminal base by Axamm\n\n" + \
                               "Version: " + VERSION + "\n\n" + \
                                ("Modded by: " + MOD_AUTHOR + "\n" + MOD_DESCR if MOD_AUTHOR != "" else \
                                "Handles frames like:\n          0xAA|Addr|DataH|DataL|CRC8-itu\n\nDesigned for the EBS3 Summer School Kart testing"))

    _com_init = False
    def create_com_menu(self, root : tk.Menu):
        if not self._com_init:
            self.port = ""
            self._com_init = True
            self.com_menu = tk.Menu(root, tearoff="off")
            root.add_cascade(label="Port", menu=self.com_menu)
        else:
            self.com_menu.delete(0, tk.END)
            
        for port in serial.tools.list_ports.comports():
            self.com_menu.add_command(label=port[0], command=lambda x=port[0]: self.select_port(x))

    def create_baud_menu(self, root: tk.Menu):
        self.baud_rate = 115200
        self.baud_menu = tk.Menu(root, tearoff="off")
        root.add_cascade(label="Baud Rate", menu=self.baud_menu)
        #standard baudrates list
        for baud in [9600, 19200, 38400, 57600, 115200, 230400, 460800, 921600]:
            self.baud_menu.add_command(label=baud, command=lambda x=baud: self.select_baud(x))

    # Update status bar label
    def update_status(self):
        self.status.config(text=self.port_label.cget("text") + " | " + self.baud_label.cget("text"))
        
    def select_port(self, port: str):
        self.port = port
        # If self.ser is open, close it
        if self.uart_handler is not None:
            self.uart_handler.close_com()
            self.uart_handler = None
        #Open COM port and handle errors
        try:
            self.uart_handler = UartHandler(port, self.baud_rate) # open serial port
            self.port_label.config(text="Port: " + port)
        except serial.SerialException as e:
            self.port_label.config(text="Port: none")
            # display error in messagebox
            tkinter.messagebox.showerror("Error", e)
        self.update_status()

    # Define a menu entry to select between serial baud rate
    def select_baud(self, baud: int):
        self.baud_rate = baud
        self.baud_label.config(text="Baud Rate: " + str(baud))
        if self.uart_handler is not None:
            self.select_port(self.port)
        else:
            self.update_status()

# Main
if __name__ == "__main__":
    root = App()
    root.mainloop()
    exit()
