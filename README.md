# reproduceR
Template for minimal reproducible reporting in R

# requirements

Install the containeRit package from o2r.info github:

```
devtools::install_github("r-hub/sysreqs")
devtools::install_github("o2r-project/containerit")
```

## steps

1. Write and do analyses in ```this_report.Rnw``` 
2. When done, or after important changes, call ```run.sh``` - can set up Rstudio to use run.sh as build script. Run.sh will:
  * Call containeRit on the script
  * build the docker
  * push the docker to (local) docker hub
  * write gorbachev.yaml with latest docker to allow Gorbachev CI system to run report
  * build report in the new docker to test reproducibility
3. Set up Gorbachev CI for report on gorbachev.io
