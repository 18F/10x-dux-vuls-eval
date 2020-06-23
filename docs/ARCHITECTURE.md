# 10x Dependency Upgrades Evaluation Pipeline Design

## Rationale

## Design

This pipeline leverages CloudFoundry integration points to deploy one or more buildpacks before the final buildpack. The final buildpack finalizes configuration of the application itself and excutes its processes, whereas our use of [a multi-buildpack deployment strategy](https://docs.cloudfoundry.org/buildpacks/use-multiple-buildpacks.html) loads trusted executables and minimal configuration in advance, before these last steps, and will only then trigger a scan once all deployment phases for all subsequent buildpacks is complete.

Similar open source efforts, [vendor integrations](https://blog.aquasec.com/using-aqua-to-secure-applications-on-pivotal-cloud-foundry), and previous [18F research on different approaches for use of Sysdig and Falco](https://youtu.be/wFQOXMcZnQg?t=1485) inspired this approach.

## Architecture

Below is the current system architecture.

![Vuls Architecture Diagram](./architecture.svg)

(NOTE: This architecture diagram is derived from [updating this PlantUML file](./architecture.puml).)

Currently, we deploy [all vuls component micro-services](https://vuls.io/docs/en/architecture-remote-scan.html) in separate docker containers on a single EC2 host that communicate through HTTP APIs. Where applicable, they share filesystem directories of the underlying EC2 instance to store scan results, logs, and SQLite databases with relevant vulnerability data. Configuration of the docker containers on the report server, and optionally a bastion server and test application server (not in CloudFoundry), is all managed by [Terraform modules provided with this prototype](./terraform). This approach has been chosen for easy of prototyping and debugging, while also allowing for adaptation to scale services on multiple custom-built EC2 instances or more favorable, alternative deployment strategies as use cases arise: AWS Lambda, ECS Fargate, or CloudFoundry itself.

## Data Flow and Sequence Diagrams

Below is a high-level overview of how scans examine vulnerabilities in an
application's dependencies once deployed into test applications in the cloud.gov
sandbox environment.

![Vuls Scan Sequence Diagram](./scan_sequence_diagram.svg)

(NOTE: This sequence diagram is derived from [updating this PlantUML file](./scan_sequence_diagram.puml).)

## Appendix
