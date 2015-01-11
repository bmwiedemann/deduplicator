test:
	mkdir -p testdir
	cd testdir ; echo x > x1 ; echo x > x2 ; echo x > x\ space ; echo y > y1 ; find -type f -print0 | ../deduplicator.rb
