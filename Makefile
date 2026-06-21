.PHONY: bootstrap artifact mark mark-render finish clean

bootstrap:
	bash bootstrap/ubuntu-install.sh

artifact:
	python3 scripts/new-artifact.py --project dino-scale --model-version v3b

mark:
	python3 scripts/build-marked-artifact.py \
		--job jobs/dino-scale-v3b-a1mini-pla-mintlime-orca.yaml \
		--artifact-id $${ARTIFACT:-DS-V3B-0001} \
		--physical-mark $${MARK:-D3B001}

mark-render:
	python3 scripts/build-marked-artifact.py \
		--job jobs/dino-scale-v3b-a1mini-pla-mintlime-orca.yaml \
		--artifact-id $${ARTIFACT:-DS-V3B-0001} \
		--physical-mark $${MARK:-D3B001} \
		--render

finish:
	python3 scripts/finish-print.py \
		--artifact-id $${ARTIFACT:-DS-V3B-0001} \
		--status $${STATUS:-QA_PASS} \
		--notes "$${NOTES:-}"

clean:
	rm -rf tmp
