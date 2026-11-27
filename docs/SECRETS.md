# Secrets and authentication

## SSH

- Key: `~/.ssh/id_ed25519` (ed25519, currently no passphrase)
- GitHub authentication is configured; the remote is
  `git@github.com:FrogMerk/LaptopConfigs.git`
- Add a passphrase when convenient:

  ```bash
  ssh-keygen -p -f ~/.ssh/id_ed25519
  ```

- With a passphrase, start an agent from the shell:

  ```bash
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519
  ```

Never commit `~/.ssh`, tokens, Wi-Fi credentials or passphrases. The bootstrap
`config.env` is gitignored.

## Git identity

```bash
git config --global user.name "FrogMerk"
git config --global user.email "edwincrooks@live.com"
```

## Commit signing

SSH signing reuses the existing key. Add the same public key to GitHub as a
**Signing Key**, then:

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
```

Alternatively, use GPG:

```bash
gpg --full-generate-key
gpg --list-secret-keys --keyid-format=long
git config --global user.signingkey <KEY_ID>
git config --global commit.gpgsign true
```

Commit signing is optional; it is not enabled by default here.

## Passwords and tokens

Use `pass` + GPG or `age` for a password store once needed. Keep secrets outside
`LaptopConfigs`; the repo is for configuration, not credentials.
