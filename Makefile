compose-setup: compose-build

compose:
	docker-compose up

compose-sut:
	docker-compose -f docker-compose.test.yml run sut

compose-code-lint:
	docker-compose run exercises make code-lint

compose-description-lint:
	docker-compose run exercises make description-lint

compose-schema-validate:
	docker-compose run exercises make schema-validate

compose-bash:
	docker-compose run exercises bash

compose-build:
	docker-compose build

description-lint:
	yamllint modules

code-lint:
	golint -set_exit_status modules/...

compose-test:
	docker-compose run exercises make test

test:
	@(for i in $$(find modules/** -type f -name Makefile); do make test -C $$(dirname $$i) || exit 1; done)

check: description-lint code-lint schema-validate test

SUBDIRS := $(wildcard modules/**/*/.)

schema-validate: $(SUBDIRS)
$(SUBDIRS):
	yq . $@/description.ru.yml > /tmp/current-description.json && ajv -s /exercises-go/schema.json -d /tmp/current-description.json
	yq . $@/description.en.yml > /tmp/current-description.json && ajv -s /exercises-go/schema.json -d /tmp/current-description.json || true

.PHONY: all test $(SUBDIRS)
