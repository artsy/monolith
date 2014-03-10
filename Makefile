# Remember to set your text editor to use 4 size non-soft tabs.

BIN = node_modules/.bin

# Start the development server
s:
	foreman run brunch w -s

# Run the tests
test:
	$(BIN)/mocha $(shell find test/* -name '*.coffee')

.PHONY: test
