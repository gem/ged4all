# ged4all
Database schema and prototype code for GED4ALL, a project to construct a 
Global Exposure Database for Multi-Hazard Risk Analysis 

Please note that the contents of this repository should be considered 
experimental.

Note also that Python code requires an installation of the OpenQuake
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
