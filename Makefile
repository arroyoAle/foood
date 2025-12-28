.PHONY: test
test:
	flutter test --no-test-assets --coverage
	genhtml -o coverage coverage/lcov.info > coverage/output.txt
	open coverage/index.html