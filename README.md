Raziel is a Hiera backend, that allows you to encrypt certain Hiera
keys. So passwords can be securely store (eg. on GitHub).

Raziel works with Puppet 2.7 and Puppet 3.x. Latest tested version is Puppet 3.2.1.

# Intro

We want to treat infrastructure as code. So code is version controlled
(we use git). But what about passwords/credentials?

Puppet uses a project call "hiera" to read settings from a
configuration db. The configuration db is different per environment
and values come from a `.yaml` file.

Now one has to protect the `.yaml` file as is contains production
passwords. - What to do? - Raziel is the answer! It will encrypt the stuff.

# What is Raziel?

[Talk at Berlin DevOps Q1/2013](https://plus.google.com/115677043219034820589/posts/XyWJqnune8M)

Raziel comes with two parts

1. A frontend for you handle all the encryption.
2. A hiera backend, that will decrypt the values transparently.

## Current state

Raziel is used in production since December 2012. It's been used on 5
Puppetmasters and ~70 servers.

Raziel currently just works, but it could need some love. It started
as proof-of-concept and you still see this in parts of the code...

# Installation

It's recommended to run Raziel with Ruby 1.9. It SHOULD run with 1.8
and is UNTESTED with 2.0.

## On OS-X

Basic Ruby Version Manager (RVM) setup
- is needs Ruby 1.9 (due to the yaml engine changes in Ruby 1.8 -> 1.9)
  - install RVM: `curl -L https://get.rvm.io | bash -s stable --ruby`
  - add to your `.bashrc`, delete `.bash_profile`
  - make the system Ruby the default (otherwise may get errors with Vagrant, etc): `rvm reset`
- Raziel was NOT tested with Ruby 2.0 - happy to see your feedback and pull requests

```bash
brew install gpgme
gem install gpgme -v 2.0.2
gem install aruba cucumber ptools highline
```

- make sure Ruby 1.9.3 is the active version

## Ubuntu

Build the package via `dpkg build-package`

# How to run?

See all available commands:
`cd <raziel.git>`
`. ENVIRONMENT`
`raziel`

How to simply edit a file:
`./bin/raziel edit <your_file>`

### Run the tests

- on Mac ```cucumber -p mac```
- anywhere else just ```cucumber```

# Tech doc

## Used file extensions

- `.yaml.enc` -> YAML files with encrypted keys: ENC(...)
- `.yaml.plain` -> YAML files with plain keys: PLAIN(...)
- `.yaml.key`-> settings used for encryption/decryption
  - password: used for symmetric encryption
  - recipients: used to encrypt the file itself
- `.yaml.key.asc`-> encrypted settings

## How does it look?

Inside the `.yaml` files protect your sensitive information by putting
`PLAIN( ... )` around it. Everything withing the braces will be
encrypted and the result will be stores as `ENC( .... )`.

# Alternative solutions

[Hiera-GPG](https://github.com/crayfishx/hiera-gpg)

Raziel could be re-written to work as an additional layer on top of
other backends. So other backends (like Mongo) could be used.
