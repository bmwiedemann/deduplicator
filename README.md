
deduplicator allows to quickly find duplicated files
among large numbers of files without using much RAM

usage: find /target/dir -xdev -size +1000 -type f -print0 | deduplicator.rb
