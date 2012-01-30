#
# husk-scheme
# http://github.com/justinethier/husk-scheme
#
# Written by Justin Ethier
#
# Make file used to build husk and run test cases.
#

HUSKC = huskc
HUSKI = huski
UNIT_TEST_DIR = tests

husk: huski huskc

# Run a "simple" build using GHC directly 
# ghc options for profiling: -prof -auto-all -rtsopts 
huski: hs-src/shell.hs hs-src/Language/Scheme/Core.hs hs-src/Language/Scheme/Macro.hs hs-src/Language/Scheme/Numerical.hs hs-src/Language/Scheme/Parser.hs hs-src/Language/Scheme/Types.hs hs-src/Language/Scheme/Variables.hs hs-src/Language/Scheme/Primitives.hs hs-src/Language/Scheme/Macro/Matches.hs hs-src/Language/Scheme/FFI.hs
	ghc -cpp -Wall --make -package parsec -package ghc -fglasgow-exts -o huski hs-src/shell.hs hs-src/Language/Scheme/Core.hs hs-src/Language/Scheme/Macro.hs hs-src/Language/Scheme/Numerical.hs hs-src/Language/Scheme/Parser.hs hs-src/Language/Scheme/Types.hs hs-src/Language/Scheme/Variables.hs Paths_husk_scheme.hs hs-src/Language/Scheme/Primitives.hs hs-src/Language/Scheme/Macro/Matches.hs hs-src/Language/Scheme/FFI.hs

huskc: hs-src/huskc.hs hs-src/Language/Scheme/Core.hs hs-src/Language/Scheme/Macro.hs hs-src/Language/Scheme/Numerical.hs hs-src/Language/Scheme/Parser.hs hs-src/Language/Scheme/Types.hs hs-src/Language/Scheme/Variables.hs hs-src/Language/Scheme/Primitives.hs hs-src/Language/Scheme/Macro/Matches.hs hs-src/Language/Scheme/FFI.hs hs-src/Language/Scheme/Compiler.hs hs-src/Language/Scheme/Compiler/Helpers.hs
	ghc -cpp -Wall --make -package parsec -package ghc -fglasgow-exts -o huskc hs-src/huskc.hs hs-src/Language/Scheme/Macro.hs hs-src/Language/Scheme/Numerical.hs hs-src/Language/Scheme/Parser.hs hs-src/Language/Scheme/Types.hs hs-src/Language/Scheme/Variables.hs Paths_husk_scheme.hs hs-src/Language/Scheme/Primitives.hs hs-src/Language/Scheme/Macro/Matches.hs hs-src/Language/Scheme/FFI.hs hs-src/Language/Scheme/Compiler.hs hs-src/Language/Scheme/Compiler/Helpers.hs

# An experimental target to create a smaller, dynamically linked executable using GHC directly 
# See: http://stackoverflow.com/questions/699908/making-small-haskell-executables
#
husk-small: hs-src/shell.hs hs-src/Language/Scheme/Core.hs hs-src/Language/Scheme/Macro.hs hs-src/Language/Scheme/Numerical.hs hs-src/Language/Scheme/Parser.hs hs-src/Language/Scheme/Types.hs hs-src/Language/Scheme/Variables.hs hs-src/Language/Scheme/Primitives.hs hs-src/Language/Scheme/Macro/Matches.hs
	ghc -cpp -Wall --make -package parsec -package ghc -fglasgow-exts -o huski hs-src/shell.hs hs-src/Language/Scheme/Core.hs hs-src/Language/Scheme/Macro.hs hs-src/Language/Scheme/Numerical.hs hs-src/Language/Scheme/Parser.hs hs-src/Language/Scheme/Types.hs hs-src/Language/Scheme/Variables.hs Paths_husk_scheme.hs hs-src/Language/Scheme/Primitives.hs hs-src/Language/Scheme/Macro/Matches.hs hs-src/Language/Scheme/FFI.hs
#	ghc -dynamic -Wall --make -package parsec -package ghc -fglasgow-exts -o huski hs-src/shell.hs hs-src/Language/Scheme/Core.hs hs-src/Language/Scheme/Macro.hs hs-src/Language/Scheme/Numerical.hs hs-src/Language/Scheme/Parser.hs hs-src/Language/Scheme/Types.hs hs-src/Language/Scheme/Variables.hs Paths_husk_scheme.hs hs-src/Language/Scheme/Primitives.hs hs-src/Language/Scheme/Macro/Matches.hs hs-src/Language/Scheme/FFI.hs
	strip -p --strip-unneeded --remove-section=.comment -o huski-small huski

# Create files for distribution
dist:
	runhaskell Setup.hs configure --prefix=$(HOME) --user && runhaskell Setup.hs build && runhaskell Setup.hs install && runhaskell Setup.hs sdist

# Create API documentation
doc:
	runhaskell Setup.hs haddock 

# TODO:
# Build an RPM
#rpm:
#	rpmbuild

# Run all unit tests
test: husk stdlib.scm
	./$(HUSKI) $(UNIT_TEST_DIR)/r5rs_pitfall.scm
	@echo "0" > $(UNIT_TEST_DIR)/scm-unit.tmp
	@echo "0" >> $(UNIT_TEST_DIR)/scm-unit.tmp
	@cd $(UNIT_TEST_DIR) ; ../$(HUSKI) run-tests.scm
	@rm -f $(UNIT_TEST_DIR)/scm-unit.tmp

# Run (experimental) compiler unit tests
testc: huskc stdlib.scm
	./$(HUSKC) $(UNIT_TEST_DIR)/compiler/t-basic.scm
	$(UNIT_TEST_DIR)/compiler/t-basic.scm.out

# Create tag files to ease souce code browsing
tags:
	hasktags hs-src/Language/Scheme/*/*.hs hs-src/Language/Scheme/*.hs hs-src/*.hs *.hs
# Would like to do something like this, to index all .hs files.
#	find . -type f -name "*.hs" -exec hasktags -f {} \;

# Delete all temporary files generated by a build
clean:
	rm -f huski huskc tags TAGS
	rm -rf dist
	find . -type f -name "*.hi" -exec rm -f {} \;
	find . -type f -name "*.o" -exec rm -f {} \;
