# README

## TODO

- [ ] Update Godot version to 4.6
- [ ] Copy a more recent intro variant with debug skip

## Tools

To set up auto-deploy to itch:

- [ ] In /.github/workflows/deploy.yml set and check the following settings:
    - GODOT_VERSION
    - EXPORT_NAME
    - ITCH_USERNAME
    - ITCH_GAME_ID

- [ ] set the BUTLER_API_KEY
    - generate a key at: https://itch.io/user/settings/api-keys
    - store the repository secret on github

Itch project settings

- [ ] SharedArrayBuffer support" should be checked

Local VSCode tasks

- [ ] make sure that _godot_ is on the path
- [ ] make sure that _gdtools_ is installed and _gdformat_ and gdlint are on the path