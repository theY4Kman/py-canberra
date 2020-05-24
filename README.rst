py-canberra
===========

.. image:: https://badge.fury.io/py/py-canberra.svg
    :target: https://badge.fury.io/py/py-canberra

py-canberra is a Python interface to the `libcanberra <http://0pointer.de/lennart/projects/libcanberra/>`_ sound-playing library for Linux.


Dependencies
------------

The only dependency is libcanberra, which can usually be installed from your package repository as ``libcanberra``.

.. code-block:: bash

    # Ubuntu
    apt install libcanberra0

    # RHEL / CentOS
    yum install libcanberra

    # Arch
    pacman -S libcanberra


Installation
------------

py-canberra includes binary distributions for many platforms through `PyPI <https://pypi.org/project/py-canberra/>`_

.. code-block:: bash

    pip install py-canberra


Quickstart
----------

Oftentimes, if libcanberra is installed, some default system sounds will be installed to ``/usr/share/sounds``, including a bell sound

.. code-block:: python

    import canberra
    canberra.play(event_id='bell')

    import time
    time.sleep(0.5)  # wait for the sound to finish playing

This plays ``/usr/share/sounds/freedesktop/stereo/bell.oga`` on the default output device.
