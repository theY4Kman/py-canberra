# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.1] - 2020-05-23
### Added
 - Cython wrapper around libcanberra
 - Feature parity with GSound: support for creating contexts, setting driver, changing properties, playing sounds, and canceling sounds
 - Additional features not exposed by GSound: checking whether sounds are playing, and changing the audio device sounds are played from (dependent on driver)
