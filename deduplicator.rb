#!/usr/bin/ruby -w
# zypper in ruby19-doc-ri
# ri IO::pipe
require 'dbm'
require 'digest'
require 'tmpdir'
require 'json'

$size_hash = {}
$debug = (ENV['DEBUG'] == "1")
$ignore_filemetadata = false # owner, timestamp, permissions

def debugputs(string)
  puts string if $debug
end

def found_duplicate(file1, file2)
  puts "ln -f '#{file1}' '#{file2}'"
end

def stat_to_hash(s)
  return {"mtime"=>s.mtime.to_i, "mode"=>s.mode, "uid"=>s.uid, "gid"=>s.gid}
end

def metadata_match?(stathash, other)
  other.keys.each do |k|
    return false if stathash[k] != other[k]
  end
  return true
end

# go through the list of other files with same hash
# and find those with same metadata
def find_metadata_match(file, others)
  return nil if others.empty?
  stathash=stat_to_hash(File.stat(file))
  others.keys.each do |other|
    return other if $ignore_filemetadata or metadata_match?(stathash,others[other])
  end
  return nil
end

def add_hash_to_db(db, file)
  hashobj = Digest::SHA1.file file
  hash = hashobj.hexdigest
  debugputs "sizedup hash:#{hash} file:#{file}"
  entry = {}
  if db.has_key?(hash)
    entry = JSON.parse(db[hash])
  end
  match = find_metadata_match(file, entry)
  if match
    found_duplicate(file, match)
  else
    entry[file] = stat_to_hash(File.stat(file))
    db[hash] = JSON.generate(entry)
    debugputs "new db entry: #{db[hash]}"
  end
end

# this function is called when we found more than one file with size size
def add_sizedup(file, size)
  dbfilename="#{$tmpdir}/dup-#{size}.dbm"
  db = DBM.open(dbfilename, 0666, DBM::WRCREAT)
  if db.empty?
    debugputs "#{dbfilename} was empty, so dumping existing data from RAM"
    add_hash_to_db(db, $size_hash[size])
  end
  add_hash_to_db(db, file)
  db.close
end

def add_file(file)
  size = File.stat(file).size
  debugputs "size:#{size} file:#{file}"
  if(!$size_hash[size])
    $size_hash[size]=file
  else
    add_sizedup(file, size)
  end
end

find_opts = (ENV["find_opts"]||"") + " -type f -print0"
Dir.mktmpdir("deduplicator-db-") {|dir|
  $tmpdir=dir
  open("| find -xdev " + find_opts, 'r') do |subprocess|
    subprocess.each("\000") do |file|
      file.chop!
      add_file(file)
    end
  end
}

