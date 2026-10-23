SHELL    := /bin/bash

OUT      := public
SOURCE   := book
SUBDIR   := mspm0-guide
REMOTE   := git@github.com:ntn888/pub.git
BRANCH   := gh-pages
DOMAIN   := pub.simplycreate.online

.PHONY: pages clean publish serve

pages: clean
	sphinx-build -b html $(SOURCE) $(OUT)/$(SUBDIR)
	@touch $(OUT)/.nojekyll
	@printf '%s\n' '$(DOMAIN)' > $(OUT)/CNAME

clean:
	rm -rf $(OUT) _book_build

publish: pages
	@echo "🚀 Deploying book to GitHub Pages..."
	@rm -rf gh-pages-deploy
	@mkdir -p gh-pages-deploy
	@cp -r $(OUT)/. gh-pages-deploy/
	@cd gh-pages-deploy && git init -q
	@cd gh-pages-deploy && git add .
	@cd gh-pages-deploy && git commit -q -m "Publish book $(shell date '+%Y-%m-%d %H:%M')"
	@cd gh-pages-deploy && git push --force $(REMOTE) HEAD:$(BRANCH)
	@rm -rf gh-pages-deploy
	@echo "✅ Deployment complete!"

serve: pages
	@echo "→ http://localhost:8000/$(SUBDIR)/"
	@cd $(OUT) && python3 -m http.server 8000
