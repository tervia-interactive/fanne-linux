.PHONY: help check iso clean

help:
	@echo "Fanne Linux build targets"
	@echo "  make check  Validate repository configuration"
	@echo "  make iso    Build the live ISO (requires root)"
	@echo "  make clean  Remove generated live-build files"

check:
	@./scripts/check.sh

iso: check
	@./scripts/build.sh

clean:
	@./scripts/clean.sh
