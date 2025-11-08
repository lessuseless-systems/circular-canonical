# Python setup.py Generator
# Generates legacy setup.py for backwards compatibility
# Note: pyproject.toml is preferred for modern Python packaging

let config = import "../../../src/config.ncl" in

{
  setup_code = m%"
#!/usr/bin/env python3
"""
Setup script for circular-protocol-api

This is a legacy setup.py for backwards compatibility.
Modern builds should use pyproject.toml (PEP 518/621).
"""

from setuptools import setup, find_packages
from pathlib import Path

# Read long description from README
readme_file = Path(__file__).parent / "README.md"
long_description = readme_file.read_text(encoding="utf-8") if readme_file.exists() else ""

# Read version from package
version = "%{config.version}"

# Runtime dependencies
install_requires = [
    "requests>=2.28.0",
    "typing-extensions>=4.5.0;python_version<'3.10'",
]

# Optional dependencies
extras_require = {
    "async": [
        "aiohttp>=3.8.0",
    ],
    "dev": [
        "pytest>=7.0.0",
        "pytest-cov>=4.0.0",
        "pytest-asyncio>=0.21.0",
        "black>=22.0.0",
        "mypy>=1.0.0",
        "ruff>=0.0.270",
        "types-requests>=2.28.0",
    ],
    "docs": [
        "sphinx>=5.0.0",
        "sphinx-rtd-theme>=1.2.0",
    ],
}

# Combined "all" extra
extras_require["all"] = sum(extras_require.values(), [])

setup(
    name="circular-protocol-api",
    version=version,
    description="%{config.description}",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="Danny De Novi",
    author_email="dannydnc@protonmail.com",
    url="https://github.com/circular-protocol/circular-protocol-py",
    project_urls={
        "Documentation": "https://docs.circular.org",
        "Source": "https://github.com/circular-protocol/circular-protocol-py",
        "Issues": "https://github.com/circular-protocol/circular-protocol-py/issues",
        "Changelog": "https://github.com/circular-protocol/circular-protocol-py/blob/main/CHANGELOG.md",
    },
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    python_requires=">=3.8",
    install_requires=install_requires,
    extras_require=extras_require,
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
        "Topic :: Software Development :: Libraries :: Python Modules",
        "Topic :: Internet :: WWW/HTTP",
        "Topic :: System :: Distributed Computing",
    ],
    keywords=[
        "blockchain",
        "circular",
        "protocol",
        "smart-contracts",
        "web3",
        "sdk",
        "api",
        "python",
    ],
    license="MIT",
    include_package_data=True,
    zip_safe=False,
)
"%,
}
