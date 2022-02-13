# ged4all
Database schema and prototype code for GED4ALL, a project to construct a 
Global Exposure Database for Multi-Hazard Risk Analysis 

Please note that the Python code requires an installation of the OpenQuake
Engine and makes use of the underlying baselib and hazardlib libraries

## Quick setup

### Pre-requisites

Ubuntu
```bash
$ sudo apt install python-virtualenv python-dev
```
CentOS/FEdora
```bash
$ sudo yum install python-virtualenv python-devel
```
### Installation

```bash
$ virtualenv gedenv
$ source gedenv/bin/activate
$ pip -U install pip
$ pip install -r requirements.txt
```

# Background Information
Schema and related tools for a database of natural hazard scenarios.

This work was performed as part of the GFDRR/DFID [Challenge Fund](https://www.gfdrr.org/en/challengefund) and is now part of the [Risk Data Library](http://riskdatalibrary.org/project).

The [D1 - Exposure Database Schema and Complementary Tools report](http://riskdatalibrary.org/assets/docs/technicalReports/challengefund_phase1_exposureSchemaDevelopment_D1%20-%20Exposure%20Data%20Schema%20and%20Tools.pdf) provides a more detailed description of how this schema was developed and is intended to be used.

Please see the [Risk Data Library resources](http://riskdatalibrary.org/resources) section for additioanl technical documentation and background information.
