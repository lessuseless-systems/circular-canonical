# Python pytest.ini Generator
# Generates pytest configuration file

let config = import "../../../src/config.ncl" in

{
  pytest_ini_content = m%"
# pytest configuration for circular-protocol-api
# Generated from Nickel specifications

[pytest]
# Test discovery
testpaths = tests
python_files = test_*.py *_test.py
python_classes = Test*
python_functions = test_*

# Test execution options
addopts =
    # Strict configuration
    --strict-markers
    --strict-config

    # Coverage reporting
    --cov=circular_protocol_api
    --cov-report=term-missing
    --cov-report=html
    --cov-report=xml

    # Output options
    --verbose
    --showlocals
    --tb=short

    # Warnings
    --disable-warnings

# Custom test markers
markers =
    unit: Unit tests (fast, isolated)
    integration: Integration tests (require API access)
    asyncio: Async tests (require asyncio)
    slow: Slow-running tests
    network: Tests requiring network access

# Asyncio configuration
asyncio_mode = auto

# Minimum Python version
minversion = 7.0

# Console output options
console_output_style = progress

# Logging
log_cli = false
log_cli_level = INFO
log_cli_format = %%(asctime)s [%%(levelname)8s] %%(message)s
log_cli_date_format = %%Y-%%m-%%d %%H:%%M:%%S

# Timeout (prevent hanging tests)
timeout = 300
timeout_method = thread

# Coverage options
[coverage:run]
source = src
branch = True
omit =
    */tests/*
    */test_*.py
    */__pycache__/*
    */site-packages/*

[coverage:report]
precision = 2
show_missing = True
skip_covered = False

# Exclude lines from coverage
exclude_lines =
    pragma: no cover
    def __repr__
    raise AssertionError
    raise NotImplementedError
    if __name__ == .__main__.:
    if TYPE_CHECKING:
    @abstractmethod
    @abc.abstractmethod
"%,
}
