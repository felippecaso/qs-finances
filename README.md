# qs-mds

A Quantified Self project using the Modern Data Stack.

## Usage
- Include raw files to be used in taps inside `/data/raw` and edit the `config` section in `meltano.yml` if necessary.
- Edit files in `/data/input` as necessary.
- Include files in `/data/input/private` that shouldn't be tracked in git.
- Add secrets to `.env` as necessary.