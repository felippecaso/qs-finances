# qs-mds

Quantified Self project for personal finances data using the Modern Data Stack.

## Usage
- Include raw files to be used in taps inside `/data/raw` and edit the `config` section in `meltano.yml` if necessary.
- Edit files in `/data/input` as necessary.
- Include files in `/data/input/private` that shouldn't be tracked in git.
- Add secrets to `.env` as necessary.
- Create folder `.meltano/dbt_profile` and add `profiles.yml` file without env variables (so that `vscode-dbt-power-user` works). It's worth noting that, in this moment, the extension won't allow querying since env variables are not supported (and this project needs them for external source configuration).

### Configuring Label Studio
1. Run `meltano invoke label-studio:init` to initalize the project.
2. Start the server with `meltano invoke label-studio:start`.
3. Log in with configured email and password and retrieve the API Key from Account & Settings. Create an env variable named `LABEL_STUDIO_API_KEY` with it.
4. Execute `meltano invoke jupyterlab:execute-label-studio-setup` to configure the categorizer project.
