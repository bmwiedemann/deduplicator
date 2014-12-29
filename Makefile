test:
	mkdir -p testdir
	cd testdir ; echo x > x1 ; echo x > x2 ; echo y > y1 ; ../deduplicator.rb
