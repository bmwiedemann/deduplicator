#!/usr/bin/ruby -w
# zypper in ruby19-doc-ri
# ri IO::pipe

$size_hash = {}

# this function is called when we found more than one file with size size
def add_sizedup(file, size)
  puts "sizedup size:#{size} file:#{file}"
end

def add_file(file)
  size = File.stat(file).size
  puts "size:#{size} file:#{file}"
  if(!$size_hash[size])
    $size_hash[size]=file
  else
    add_sizedup(file, size)
  end
end

find_opts = (ENV["find_opts"]||"") + " -type f -print0"
open("| find " + find_opts, 'r') do |subprocess|
  subprocess.each("\000") do |file|
    file.chop!
    add_file(file)
  end
end

