#!/usr/bin/ruby -w
# zypper in ruby19-doc-ri
# ri IO::pipe
require 'dbm'
require 'digest'
require 'tmpdir'
$size_hash = {}

def found_duplicate(file1, file2)
    puts "found_duplicate #{file1} #{file2}"
end

def add_hash_to_db(dbfilename, file)
  hashobj = Digest::SHA1.file file
  hash = hashobj.hexdigest
  puts "sizedup hash:#{hash} file:#{file}"
  db = DBM.open(dbfilename, 0666, DBM::WRCREAT)
  if db.has_key?(hash) && db[hash] != file
    found_duplicate(file, db[hash])
  else
    db[hash] = file
  end
  db.close
end

# this function is called when we found more than one file with size size
def add_sizedup(file, size)
  dbfilename="#{$tmpdir}/dup-#{size}.dbm"
  if not File.exist?(dbfilename+".pag")
    puts `ls -l #{dbfilename}*`
    puts "#{dbfilename} not found, so dumping existing data from RAM"
    add_hash_to_db(dbfilename, $size_hash[size])
  end
  add_hash_to_db(dbfilename, file)
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
Dir.mktmpdir("deduplicator-db-") {|dir|
  $tmpdir=dir
  open("| find " + find_opts, 'r') do |subprocess|
    subprocess.each("\000") do |file|
      file.chop!
      add_file(file)
    end
  end
}

