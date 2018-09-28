Schema validation for Rubikloud Dataplatform Metafiles

This repository holds the metafile-schema.json file that can be used to validate that a metafile contains all of the required fields for the Rubikloud data platform metafile format.

:warning: PLEASE NOTE: :warning: This does not validate that the values are correct, just that the fields are present.

Usage
-----

Python
======

First install the python `jsonschema` package;

```
$ pip install jsonschema
```

Then you can use this package to validate that a metafile has the correct format;

```
$ jsonschema metafile-schema.json -i metafile-2018.json
```

Testing
-------

There are a number of incorrectly formatted metafiles in the tests/error folder.
There are a couple of correctly formatted metafiles in the tests/pass folder.

To check that the metafile-schema.json detects the faults correctly you can use the pytest program;

```
$ pipenv install
$ pipenv shell
$ pytest
================================================= test session starts =================================================
platform linux -- Python 3.5.3, pytest-3.8.1, py-1.6.0, pluggy-0.7.1
rootdir: /home/duncward/src/github.com/rubikloud/metafile-json-schema, inifile:
collected 10 items

tests/test_schema.py ..........                                                                                 [100%]

============================================== 10 passed in 0.04 seconds ==============================================```

