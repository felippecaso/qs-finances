build:
	meltano install

ls-run:
	meltano invoke label-studio:start

rill-install:
	curl -s https://cdn.rilldata.com/install.sh | bash

rill-build:
	mkdir -p rill
	cd rill && rill init
	cd rill && for file in ../data/catalog/*.parquet; do rill source add $$file; done

rill-run:
	cd rill && rill start

rill-visuals:
	make rill-install
	make rill-build
	make rill-run