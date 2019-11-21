from jsonschema import validate, ValidationError
import pytest
import os
import json


@pytest.fixture(scope="session")
def schema():
    with open(
        os.path.join(os.path.dirname(__file__), "..", "metafile-schema.json"),
        "r",
    ) as fh:
        yield json.load(fh)


def files(path):
    mypath = os.path.join(os.path.dirname(__file__), path)
    return [
        os.path.join(mypath, f)
        for f in os.listdir(mypath)
        if os.path.isfile(os.path.join(mypath, f))
    ]


@pytest.mark.parametrize("file", files("error"))
def test_error(file, schema):
    with open(file, "r") as fh:
        with pytest.raises(ValidationError):
            validate(json.load(fh), schema)


@pytest.mark.parametrize("file", files("pass"))
def test_pass(file, schema):
    with open(file, "r") as fh:
        validate(json.load(fh), schema)
