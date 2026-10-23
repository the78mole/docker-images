# Pandoc + Chromium

Schlankes Image zum Rendern von Markdown nach PDF: Pandoc erzeugt HTML,
Chromium im Headless-Modus druckt es als PDF. Enthält außerdem `git` und die
GitHub-CLI `gh`, damit es direkt als Container eines GitHub-Actions-Jobs taugt
(Checkout, Upload an Releases).

`CHROME` zeigt auf `/usr/bin/chromium`. Chromium läuft als root und braucht
daher `--no-sandbox`.

## Beispiel

```bash
docker run --rm -v "$PWD":/workspace ghcr.io/the78mole/pandoc-chromium:latest bash -c '
  pandoc README.md --standalone --embed-resources -o /tmp/out.html &&
  chromium --headless --no-sandbox --disable-gpu --no-pdf-header-footer \
    --print-to-pdf=README.pdf file:///tmp/out.html'
```

## GitHub Actions

```yaml
jobs:
  pdf:
    runs-on: ubuntu-latest
    container: ghcr.io/the78mole/pandoc-chromium:latest
    steps:
      - uses: actions/checkout@v7
      - run: git config --global --add safe.directory "$GITHUB_WORKSPACE"
      - run: pandoc --version && chromium --version
```
