# 10x Dependency Upgrades Project

## Background

This is the main software and Infrastructure-as-Code repository for the 10x Dependency Upgrade (DUX) Phase 2 project,including an evaluation of just-in-time dependency analysis of software at deployment time using the open-source [vuls](https://vuls.io) project.

The original Phase 1 research and our additive research that led to this prototype can be found [here and interested parties can request access from 10x](https://docs.google.com/document/d/1YrzVQLwB-yKCzeMfvDiBVxDNKAoO-KNV4g7-JnPQf5s/edit#heading=h.y1ih0miqjijl).

The determination at the conclusion of 10x Dependency Upgrades Phase 2 was a no, meaning this project will not move forward. The code is provided for historical review and/or to be potentially revived by other researchers or engineers.

More information about the overall 10x process can bee found on [the 10x website](https://10x.gsa.gov/).

## Project Documentation

Project documentation is in the [./docs](./docs) directory.

## Project Directory Structure

- Custom container build components are in the [./docker](./docker) directory.
- Project documentation is in the [./docs](./docs) directory.
- Custom shell scripts for DevOps and container runtime are in [./scripts](./scripts).
- Deprecated copy of Terraform modules for direct deployment, now converted to CloudFoundry, are in [./terraform](./terraform).

## Source Code Repositories

1. [10x-dux-vuls-eval](https://github.com/18F/10x-dux-vuls-eval): this repository, the umbrella source code and IaC repository.
1. [vuls-cloudfoundry-buildpack](https://github.com/flexion/vuls-cloudfoundry-buildpack/): source code for the sidecar buildpack to mediate communication between a client [cloud.gov](https://cloud.gov) and the target server for aggregating vulnerability data.
1. [10x-dux-app](https://github.com/18F/10x-dux-app): an example vulnerable application with a sample Python vulnerability ([CVE-2019-7164](https://nvd.nist.gov/vuln/detail/CVE-2019-7164)) to illustrate the importance of risk management and environmental context of reported dependency vulnerabilities.
1. [vuls](https://github.com/18F/vuls/): a fork of upstream vuls source code to evaluate custom requirements for this project.
2. [vulsrepo](https://github.com/18F/vulsrepo/): a fork of upstream vulsrepo source code to evaluate custom requirements for a user interface for this project.