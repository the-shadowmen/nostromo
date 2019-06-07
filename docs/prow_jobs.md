# Prow Jobs

## Core Components

- `hook` is the most important piece. It is a stateless server that listens for GitHub webhooks and dispatches them to the appropriate plugins. Hook's plugins are used to trigger jobs, implement 'slash' commands, post to Slack, and more. See the [`prow/plugins`](/prow/plugins/) directory for more information on plugins.
- `plank` is the controller that manages the job execution and lifecycle for jobs that run in k8s pods.
- `deck` presents a nice view of [recent jobs](https://prow.k8s.io/), [command](https://prow.k8s.io/command-help) and [plugin](https://prow.k8s.io/plugins) help information, the [current status](https://prow.k8s.io/tide) and (history)[https://prow.k8s.io/tide-history] of merge automation, and a [dashboard for PR authors](https://prow.k8s.io/pr).
- `horologium` triggers periodic jobs when necessary.
- `sinker` cleans up old jobs and pods.<Paste>
- `tide` manages retesting and merging PRs once they meet the configured merge criteria. See [its README](./tide/README.md) for more information.

Reference: https://raw.githubusercontent.com/kubernetes/test-infra/master/prow/cmd/README.md

## Tide

Works as a separated component of Prow and needs some things to make them done before use it.

### Pre-reqs for Tide

- [You need to register a GH OAUTH app which will monitor the PRs statuses](https://github.com/kubernetes/test-infra/blob/master/prow/docs/pr_status_setup.md)

