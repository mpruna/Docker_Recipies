### Running Unit Tests inside Docker

In computer programming, [unit testing](https://en.wikipedia.org/wiki/Unit_testing) is a software testing method by which individual units of source code, sets of one or more computer program modules together with associated control data, usage procedures, and operating procedures, are tested to determine whether they are fit for use.

  - Unit tests should test some basic functionality of our docker app code,
with no reliance on external services.
  - Unit tests should run as quickly as possible so that developers can iterate
much faster without being blocked by waiting for the tests results.
  - Docker containers can spin up in seconds and can create a clean and
isolated environment which is great tool to run unit tests with.

For this section we sill use python unit testing framework

References:
  - [The Python unit testing framework](https://docs.python.org/2/library/unittest.html), sometimes referred to as “PyUnit,” is a Python language version of JUnit, by Kent Beck and Erich Gamma. JUnit is, in turn, a Java version of Kent’s Smalltalk testing framework. Each is the de facto standard unit testing framework for its respective language.
  - [The Hitchhiker's Guide](https://docs.python-guide.org/writing/tests/) to unity testing
