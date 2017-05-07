src:
	mkdir src

src/%/.dirstamp: src/%.tar.bz2
	tar -C ./src -xf $<
	touch $@

src/%/.dirstamp: src/%.tar.xz
	tar -C ./src -xf $<
	touch $@
