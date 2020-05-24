import re
from setuptools import Extension, setup

from Cython.Build import cythonize


def get_readme():
    with open('README.rst') as fp:
        return fp.read()


def get_version():
    with open('canberra/__init__.py') as fp:
        match = re.search(r"__version__ = '([^']+)'", fp.read())
        return match.group(1)


setup(
    long_description=get_readme(),
    long_description_content_type='text/x-rst',
    name='py-canberra',
    version=get_version(),
    description='Wrappers for the libcanberra sound-playing interface',
    url='https://github.com/theY4Kman/py-canberra',
    python_requires='==3.*,>=3.6.0',
    project_urls={
        'homepage': 'https://github.com/theY4Kman/py-canberra',
        'repository': 'https://github.com/theY4Kman/py-canberra',
    },
    author='Zach "theY4Kman" Kanzler',
    author_email='they4kman@gmail.com',
    license='MIT',
    packages=['canberra'],
    extras_require={"dev": ["cython==0.*,>=0.29.19"]},
    ext_modules=cythonize([
        Extension(
            name='canberra._canberra',
            sources=['canberra/_canberra.pyx'],
        ),
    ]),
)
