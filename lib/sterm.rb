require "sterm/version"
require "optparse"
require "rainbow"
require "serialport"

module Sterm
  class Error < StandardError; end

  def sterm(arguments)
    # Parse the arguments provided by the user
    opts = {}
    op = OptionParser.new do |options|
      options.banner = %Q{SerialTerm is a very simple command line tool to output data received from a serial device.
Usage: sterm DEVICE_PATH [options]\nTry starting with `sterm -h` for help\n\n}

      options.on("-b BAUD_RATE", "--baud-rate", "Baud rate at which the serial device is transmitting (Default: 115200)") do |baud_rate|
        opts[:baud_rate] = baud_rate
      end

      options.on("-d DATA_BITS", "--data-bits", "Data bits by device (Default: 8") do |data_bits|
        opts[:data_bits] = data_bits
      end

      options.on("-s STOP_BITS", "--stop-bits", "Stop bits for device (Default: 1)") do |stop_bits|
        opts[:stop_bits] = stop_bits
      end

      options.on("-e STRING", "--ends-with", "The string (in hex) that terminates each line sent by the device (Default: \"0D0A\" (\\r\\n)") do |ending|
        opts[:ending] = ending
      end
    end
    op.parse!(arguments)

    # Ensure the device path is given
    device_path = ""
    if ARGV.length < 1 
      STDERR.puts Rainbow("ERROR:").red + " No device path specified. Exiting."
      exit(11)
    else
      device_path = ARGV[0]
    end

    # Set the options 
    baud_rate = opts[:baud_rate]
    if baud_rate.nil? || baud_rate.empty?
      baud_rate = 115200
      puts Rainbow("INFO:").aqua + " Using default baud rate of 115200."
    else
      baud_rate = baud_rate.to_i
    end

    data_bits = opts[:data_bits]
    if data_bits.nil? || data_bits.empty?
      data_bits = 8
      puts Rainbow("INFO:").aqua + " Using default of 8 data bits."
    else
      data_bits = data_bits.to_i
    end

    stop_bits = opts[:stop_bits]
    if stop_bits.nil? || stop_bits.empty?
      stop_bits = 1
      puts Rainbow("INFO:").aqua + " Using default of 1 stop bit."
    else
      stop_bits = stop_bits.to_i
    end

    line_end = [opts[:ending]].pack('H*')
    if line_end.nil? || line_end.empty?
      line_end = "\r\n"
      puts Rainbow("INFO:").aqua + " Using default line ending of \"ODOA\" (\\r\\n)."
    end

    sp = SerialPort.new(device_path, baud_rate, data_bits, stop_bits, SerialPort::NONE)

    if sp.nil?
      puts Rainbow("ERROR:").red + " Couldn't initialize device at path " + device_path
      exit(12)
    end

    puts Rainbow("CONNECT: ").green + " Connected to device at " + device_path
  
    while (line = sp.readline(line_end))
      puts Rainbow(device_path + ": ").yellow + line.chomp!
    end
  end
end
