# getsonar

A script to download the latest [Project Sonar](https://www.rapid7.com/research/project-sonar/) dataset. Some configuration required.

## Dependencies

Installing dependencies with `apt`.

```D
apt install -y ca-certificates curl jq lftp
```

## Configuration

Configure the `API_KEY` and `OUTPUT_DIR` variables as desired.

* `API_KEY` is a free key [granted by Project Sonar](https://opendata.rapid7.com/apihelp/) in a uuid format (example: `a3f2a134-901f-4d55-a674-298324773933`).
* `OUTPUT_DIR` is a filesystem directory where you'd like results saved.

## References

Parse Project Sonar datasets with [inetdata-parsers](https://github.com/hdm/inetdata-parsers) by [HD Moore](https://github.com/hdm).
