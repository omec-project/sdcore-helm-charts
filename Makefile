# SPDX-FileCopyrightText: 2021-present Open Networking Foundation <info@opennetworking.org>
#
# SPDX-License-Identifier: Apache-2.0
.PHONY: all test clean

all:
	test

clean: # @HELP clean up temporary files for omec-control-plane
		rm -rf omec-control-plane/charts omec-control-plane/requirements.lock

test: # @HELP run the acceptance tests
		helm dep update omec-control-plane

help:
	@grep -E '^.*: *# *@HELP' $(MAKEFILE_LIST) \
    | sort \
    | awk ' \
        BEGIN {FS = ": *# *@HELP"}; \
        {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}; \
    '
