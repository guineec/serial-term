# SerialTerm
SerialTerm is a very simple command line tool to output data received from a serial device using the <a href="https://rubygems.org/gems/serialport/versions/1.3.1" target="_blank">serialport</a> gem.  

## Installation  
To install, just run:  
    $ gem install sterm

## Usage

$ sterm DEVICE_PATH [-b BAUD_RATE -d DATA_BITS -s STOP_BITS -e LINE_ENDING]  
  
Default baud rate is 115200  
Default data bits is 8  
Default stop bits is 1  
  
LINE_ENDING is the **hex** value of the desired terminating string.  
Default line ending is 0d0a (which is "\r\n" in hex).  

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/guineec/sterm.
