JOB ?= jobs/dino-scale-v3b-a1mini-pla-mintlime-orca.yaml
ARTIFACT ?= DS-V3B-0001
MARK ?= D3B001

.PHONY: bootstrap artifact mark mark-render finish-pass finish-revise

bootstrap:
	bash bootstrap/ubuntu-install.sh

artifact:
	python3 scripts/new-artifact.py --project-code DS --model-version V3B

mark:
	python3 scripts/build-marked-artifact.py --job $(JOB) --artifact-id $(ARTIFACT) --physical-mark $(MARK)

mark-render:
	python3 scripts/build-marked-artifact.py --job $(JOB) --artifact-id $(ARTIFACT) --physical-mark $(MARK) --render

finish-pass:
	python3 scripts/finish-print.py $(ARTIFACT) --status QA_PASS --notes "$(NOTES)"

finish-revise:
	python3 scripts/finish-print.py $(ARTIFACT) --status QA_REVISE --notes "$(NOTES)"
