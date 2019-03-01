# SerialTerm is a very simple command line tool that outputs data received from a serial device.
# Copyright (C) 2019 Cian Guinee

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require "sterm/version"
require "optparse"
require "rainbow"
require "serialport"

module Sterm
  class Error < StandardError; end

  def sterm(arguments)
    # Parse the arguments provided by the user
    arguments << '-h' if arguments.empty?
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

      options.on("-e STRING", "--ends-with", "The string (in hex) that terminates each line (Default: \"0D0A\")") do |ending|
        opts[:ending] = ending
      end

      options.on("-n", "--[no-]line-numbers", "Print numbers at the start of each line of output (Default: true)") do |nums|
        opts[:line_numbers] = nums
      end

      options.on_tail("-v", "--version", "Show version") do
        puts Rainbow("SerialTerm version:").aqua + " #{Sterm::VERSION}"
        exit
      end
    end
    op.parse!(arguments)

    # Ensure the device path is given...
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

    if opts[:line_numbers].nil?
      opts[:line_numbers] = true
    end

    begin 
      sp = SerialPort.new(device_path, baud_rate, data_bits, stop_bits, SerialPort::NONE)
    rescue Errno::ENOENT
      STDERR.puts Rainbow("ERROR:").red + " Device not found at " + device_path
      exit(13)
    end

    if sp.nil?
      puts Rainbow("ERROR:").red + " Couldn't initialize device at path " + device_path
      exit(12)
    end

    puts Rainbow("CONNECT: ").green + " Connected to device at " + device_path
    
    line_num = 1

    begin
      while (line = sp.readline(line_end))
        nspaces = (6 - (line_num.to_s.length))
        nspaces = 1 if nspaces < 1
        line_num_text = "[#{line_num}]" + (" " * nspaces)

        if opts[:line_numbers]
          puts line_num_text + Rainbow(device_path + ": ").yellow + line.chomp!
          line_num += 1
        else
          puts Rainbow(device_path + ": ").yellow + line.chomp!
        end
      end
    rescue EOFError
      puts "\n" + Rainbow("ERROR:").red + " Device disconnected"
      exit 14
    end
  end
end
