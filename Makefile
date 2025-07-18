.PHONY: megalint, megalint-apply, clean-megalint
megalint: ## Run Megalinter
	docker run --platform linux/amd64 --rm \
		-v /var/run/docker.sock:/var/run/docker.sock:rw \
		-v $(shell pwd):/tmp/lint:rw \
		oxsecurity/megalinter-terraform:v8.8.0

megalint-apply: ## Run Megalinter & apply fixes
	docker run --platform linux/amd64 --rm \
		-v /var/run/docker.sock:/var/run/docker.sock:rw \
		-v $(shell pwd):/tmp/lint:rw \
                -e APPLY_FIXES=all \
		oxsecurity/megalinter-terraform:v8.8.0

clean-megalint: ## Clean the temporary files.
	rm -rf megalinter-reports
