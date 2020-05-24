# distutils: language = c
# cython: language_level=3
from typing import Any, Callable, Dict, Union

from cpython.object cimport PyObject
from cpython.pylifecycle cimport Py_IsInitialized
from cpython.pystate cimport PyGILState_STATE, PyGILState_Ensure, PyGILState_Release
from cpython.ref cimport Py_INCREF, Py_DECREF
from libc.stdint cimport uint32_t
from libc.stdlib cimport malloc, free
from posix.dlfcn cimport dlopen, RTLD_NOW, RTLD_GLOBAL, dlsym

from .constants import Props, Errors

cdef extern from 'canberra.h':
    ctypedef struct ca_context:
        pass

    ctypedef struct ca_proplist:
        pass

cdef:
    enum:
        CA_SUCCESS = 0
        CA_ERROR_NOTSUPPORTED = -1
        CA_ERROR_INVALID = -2
        CA_ERROR_STATE = -3
        CA_ERROR_OOM = -4
        CA_ERROR_NODRIVER = -5
        CA_ERROR_SYSTEM = -6
        CA_ERROR_CORRUPT = -7
        CA_ERROR_TOOBIG = -8
        CA_ERROR_NOTFOUND = -9
        CA_ERROR_DESTROYED = -10
        CA_ERROR_CANCELED = -11
        CA_ERROR_NOTAVAILABLE = -12
        CA_ERROR_ACCESS = -13
        CA_ERROR_IO = -14
        CA_ERROR_INTERNAL = -15
        CA_ERROR_DISABLED = -16
        CA_ERROR_FORKED = -17
        CA_ERROR_DISCONNECTED = -18

    ctypedef void (*ca_finish_callback_t)(ca_context *c, uint32_t id, int error_code, void *userdata);

    ctypedef int (*ca_proplist_create_t)(ca_proplist **p);
    ctypedef int (*ca_proplist_destroy_t)(ca_proplist *p);
    ctypedef int (*ca_proplist_sets_t)(ca_proplist *p, const char *key, const char *value);
    ctypedef int (*ca_proplist_setf_t)(ca_proplist *p, const char *key, const char *format, ...);
    ctypedef int (*ca_proplist_set_t)(ca_proplist *p, const char *key, const void *data, size_t nbytes);

    ctypedef int (*ca_context_create_t)(ca_context **c);
    ctypedef int (*ca_context_set_driver_t)(ca_context *c, const char *driver);
    ctypedef int (*ca_context_change_device_t)(ca_context *c, const char *device);
    ctypedef int (*ca_context_open_t)(ca_context *c);
    ctypedef int (*ca_context_destroy_t)(ca_context *c);
    ctypedef int (*ca_context_change_props_t)(ca_context *c, ...);
    ctypedef int (*ca_context_change_props_full_t)(ca_context *c, ca_proplist *p);
    ctypedef int (*ca_context_play_full_t)(ca_context *c, uint32_t id, ca_proplist *p, ca_finish_callback_t cb, void *userdata);
    ctypedef int (*ca_context_play_t)(ca_context *c, uint32_t id, ...);
    ctypedef int (*ca_context_cache_full_t)(ca_context *c, ca_proplist *p);
    ctypedef int (*ca_context_cache_t)(ca_context *c, ...);
    ctypedef int (*ca_context_cancel_t)(ca_context *c, uint32_t id);
    ctypedef int (*ca_context_playing_t)(ca_context *c, uint32_t id, int *playing);

    ctypedef const char *(*ca_strerror_t)(int code);

cdef:
    void *libcanberra = dlopen('libcanberra.so', RTLD_NOW | RTLD_GLOBAL)

    ca_proplist_create_t ca_proplist_create                     = <ca_proplist_create_t>dlsym(libcanberra, 'ca_proplist_create')
    ca_proplist_destroy_t ca_proplist_destroy                   = <ca_proplist_destroy_t>dlsym(libcanberra, 'ca_proplist_destroy')
    ca_proplist_sets_t ca_proplist_sets                         = <ca_proplist_sets_t>dlsym(libcanberra, 'ca_proplist_sets')
    ca_proplist_setf_t ca_proplist_setf                         = <ca_proplist_setf_t>dlsym(libcanberra, 'ca_proplist_setf')
    ca_proplist_set_t ca_proplist_set                           = <ca_proplist_set_t>dlsym(libcanberra, 'ca_proplist_set')
    ca_context_create_t ca_context_create                       = <ca_context_create_t>dlsym(libcanberra, 'ca_context_create')
    ca_context_set_driver_t ca_context_set_driver               = <ca_context_set_driver_t>dlsym(libcanberra, 'ca_context_set_driver')
    ca_context_change_device_t ca_context_change_device         = <ca_context_change_device_t>dlsym(libcanberra, 'ca_context_change_device')
    ca_context_open_t ca_context_open                           = <ca_context_open_t>dlsym(libcanberra, 'ca_context_open')
    ca_context_destroy_t ca_context_destroy                     = <ca_context_destroy_t>dlsym(libcanberra, 'ca_context_destroy')
    ca_context_change_props_t ca_context_change_props           = <ca_context_change_props_t>dlsym(libcanberra, 'ca_context_change_props')
    ca_context_change_props_full_t ca_context_change_props_full = <ca_context_change_props_full_t>dlsym(libcanberra, 'ca_context_change_props_full')
    ca_context_play_full_t ca_context_play_full                 = <ca_context_play_full_t>dlsym(libcanberra, 'ca_context_play_full')
    ca_context_play_t ca_context_play                           = <ca_context_play_t>dlsym(libcanberra, 'ca_context_play')
    ca_context_cache_full_t ca_context_cache_full               = <ca_context_cache_full_t>dlsym(libcanberra, 'ca_context_cache_full')
    ca_context_cache_t ca_context_cache                         = <ca_context_cache_t>dlsym(libcanberra, 'ca_context_cache')
    ca_context_cancel_t ca_context_cancel                       = <ca_context_cancel_t>dlsym(libcanberra, 'ca_context_cancel')
    ca_context_playing_t ca_context_playing                     = <ca_context_playing_t>dlsym(libcanberra, 'ca_context_playing')
    ca_strerror_t ca_strerror                                   = <ca_strerror_t>dlsym(libcanberra, 'ca_strerror')


NOTSET = object()


class CanberraError(Exception):
    def __init__(self, code: Union[int, Errors], msg: str = None):
        self.code = Errors(code)

        if msg is None:
            msg = ca_strerror(code).decode('utf-8')
        self.msg = msg

    def __str__(self):
        return f'{self.code!r}: {self.msg}'


cdef raise_if_error(int error):
    if error == CA_ERROR_OOM:
        raise MemoryError()

    if error != CA_SUCCESS:
        raise CanberraError(code=error)


cdef void ca_finish_callback(ca_context *ca, uint32_t id, int error_code, void *userdata) with gil:
    cdef PyGILState_STATE gilstate

    cdef PyObject **py_data = <PyObject **> userdata
    cdef object context = <object>py_data[0]
    cdef object callback = <object>py_data[1]
    cdef object callback_arg = <object>py_data[2]

    free(userdata)

    try:
        # If the Python runtime has finished, calling a Python function
        # will result in a fatal error
        if not Py_IsInitialized():
            return

        if callback is not None:
            error = Errors(error_code)
            if error != Errors.SUCCESS:
                error = CanberraError(code=error)

            gilstate = PyGILState_Ensure()
            try:
                if callback_arg is not NOTSET:
                    callback(context, id, error, callback_arg)
                else:
                    callback(context, id, error)
            finally:
                PyGILState_Release(gilstate)
    finally:
        Py_DECREF(context)
        Py_DECREF(callback)
        Py_DECREF(callback_arg)


OnFinishedCallbackWithoutArg = Callable[['Context', int, Union[Errors, CanberraError]], Any]
OnFinishedCallbackWithArg = Callable[['Context', int, Union[Errors, CanberraError], Any], Any]
OnFinishedCallback = Union[OnFinishedCallbackWithArg, OnFinishedCallbackWithoutArg]


cdef populate_propslist(ca_proplist *proplist,
                        props: Dict[Union[str, Props], str],
                        other_props: Dict[Union[str, Props], str]):
    cdef bytes b_prop
    cdef char *c_prop
    cdef bytes b_value
    cdef char *c_value

    prop_values = Props.from_kwargs(props, **other_props)

    for prop, value in prop_values.items():
        b_prop = str(prop).encode('ascii')
        c_prop = b_prop

        b_value = str(value).encode('ascii')
        c_value = b_value

        error = ca_proplist_sets(proplist, c_prop, c_value)
        raise_if_error(error)


cdef class Context:
    cdef ca_context *_ca_ctx

    def __cinit__(self):
        self._ca_ctx = NULL

        error = ca_context_create(&self._ca_ctx)
        if self._ca_ctx is NULL:
            raise MemoryError()

        raise_if_error(error)

    def __dealloc__(self):
        if self._ca_ctx is not NULL:
            ca_context_destroy(self._ca_ctx)

    def __init__(self, props: Dict[Union[str, Props], str] = None, **other_props: str):
        if props or other_props:
            self.change_props(props, **other_props)

    def set_driver(self, driver: Union[str, bytes]):
        driver_bytes = driver if isinstance(driver, bytes) else driver.encode('utf-8')
        cdef char *c_driver = driver_bytes

        cdef int error = ca_context_set_driver(self._ca_ctx, c_driver)
        raise_if_error(error)

    def change_device(self, device: Union[str, bytes]):
        device_bytes = device if isinstance(device, bytes) else device.encode('utf-8')
        cdef char *c_device = device_bytes

        cdef int error = ca_context_change_device(self._ca_ctx, c_device)
        raise_if_error(error)

    def open(self):
        cdef int error = ca_context_open(self._ca_ctx)
        raise_if_error(error)

    def change_props(self, props: Dict[Union[str, Props], str] = None, **other_props: str):
        cdef int error
        cdef ca_proplist *proplist

        error = ca_proplist_create(&proplist)
        raise_if_error(error)

        try:
            populate_propslist(proplist, props, other_props)

            error = ca_context_change_props_full(self._ca_ctx, proplist)
            raise_if_error(error)

        finally:
            ca_proplist_destroy(proplist)

    def play(
        self,
        props: Dict[Union[str, Props], str] = None,
        uint32_t id = 0,
        on_finished: OnFinishedCallback = None,
        user_data = NOTSET,
        **other_props: str,
    ):
        cdef int error
        cdef ca_proplist *proplist
        cdef PyObject **ca_userdata

        error = ca_proplist_create(&proplist)
        raise_if_error(error)

        try:
            populate_propslist(proplist, props, other_props)

            ca_userdata = <PyObject **>malloc(sizeof(PyObject *) * 3)
            ca_userdata[0] = <PyObject *>self
            ca_userdata[1] = <PyObject *>on_finished
            ca_userdata[2] = <PyObject *>user_data

            Py_INCREF(self)
            Py_INCREF(self)
            Py_INCREF(on_finished)
            Py_INCREF(user_data)

            error = ca_context_play_full(self._ca_ctx, id, proplist, ca_finish_callback, <void *>ca_userdata)
            if error != CA_SUCCESS:
                free(ca_userdata)

                Py_DECREF(self)
                Py_DECREF(on_finished)
                Py_DECREF(user_data)

            raise_if_error(error)

        finally:
            ca_proplist_destroy(proplist)

    def cache(self, props: Dict[Union[str, Props], str] = None, **other_props: str):
        cdef int error
        cdef ca_proplist *proplist

        error = ca_proplist_create(&proplist)
        raise_if_error(error)

        try:
            populate_propslist(proplist, props, other_props)

            error = ca_context_cache_full(self._ca_ctx, proplist)
            raise_if_error(error)

        finally:
            ca_proplist_destroy(proplist)

    def cancel(self, uint32_t id = 0):
        cdef int error

        error = ca_context_cancel(self._ca_ctx, id)
        raise_if_error(error)

    def playing(self, uint32_t id = 0) -> bool:
        cdef int error
        cdef int playing

        error = ca_context_playing(self._ca_ctx, id, &playing)
        raise_if_error(error)

        return bool(playing)
