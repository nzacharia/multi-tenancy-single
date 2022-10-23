# CECG Reference Application - Java 

## P2P Interface

The P2P interface is how the generated pipelines interact with the repo.
For the CECG reference this follows the [3 musketeers pattern](https://3musketeers.io/) of using:

* Make
* Docker
* Compose

These all need to be installed.

## Structure

### Service

Service source code, using Java with Sprint Boot.

### NFT

Load tests using [K6](https://k6.io/).

### Functional

Stubbed Functional Tests using [Cucumber JVM](https://cucumber.io/docs/installation/java/)

## Running the application locally

### Application

```
make run-local
```

This application is exposed locally on port 8080 as well as being available to the functional tests when run with make.
This is as they are in the same docker network.

### Functional Tests

```
make stubbed-functional
```

You should see:

```
io.cecg.reference.Tests.hello world returns ok PASSED
```
