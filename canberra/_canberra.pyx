# distutils: language = c
# cython: language_level=3

from queue import Queue
from threading import Event, Thread
from typing import Any, Callable, Dict, Union

from cpython.object cimport PyObject
from cpython.pystate cimport PyGILState_STATE, PyGILState_Ensure, PyGILState_Release
from cpython.ref cimport Py_INCREF, Py_DECREF
from libc.stdint cimport uint32_t
from libc.stdlib cimport malloc, free
from posix.dlfcn cimport dlopen, RTLD_NOW, RTLD_GLOBAL, dlsym

from .constants import Props, Errors, NOTSET


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


class CanberraError(Exception):
    """Exception raised when a libcanberra API call returns an error"""

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

    error = Errors(error_code)
    if error != Errors.SUCCESS:
        error = CanberraError(code=error)

    gilstate = PyGILState_Ensure()
    try:
        #
        # ca_finish_callbacks are not allowed to call libcanberra API functions,
        # as they may cause deadlocks (or fatal errors).
        #
        # We must be especially careful with DECREFing in the ca_finish_callback,
        # as well, for if the Context gets GC'd during this callback,
        # ca_context_destroy will be called on it, undoubtedly causing a fatal
        # error.
        #
        # So, instead of invoking user callbacks or DECREFing our context
        # directly from the ca_finish_callback, we queue these to be run in a
        # separate callback thread.
        #
        callback_queue.put_nowait((callback, context, id, error, callback_arg))
    finally:
        PyGILState_Release(gilstate)


cdef callback_processor():
    cdef object callback
    cdef object context
    cdef uint32_t id
    cdef object error
    cdef object callback_arg

    while True:
        callback, context, id, error, callback_arg = callback_queue.get()

        try:
            if callback is not None:
                if callback_arg is NOTSET:
                    args = (context, id, error)
                else:
                    args = (context, id, error, callback_arg)

                callback(*args)
        finally:
            Py_DECREF(context)
            Py_DECREF(callback)
            Py_DECREF(callback_arg)

            del context
            del callback
            del callback_arg
            del error


cdef callback_queue = Queue()
cdef callback_thread_canceled = Event()
cdef callback_thread = Thread(name='py-canberra callback thread', target=callback_processor, daemon=True)
callback_thread.start()


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
        #
        # libcanberra property names need to be in 7bit ASCII, string
        # property values UTF8.
        #
        b_prop = str(prop).encode('ascii')
        c_prop = b_prop

        b_value = str(value).encode('utf-8')
        c_value = b_value

        error = ca_proplist_sets(proplist, c_prop, c_value)
        raise_if_error(error)


cdef class Context:
    """A libcanberra ``ca_context``"""

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
        """Initialize the libcanberra ca_context, optionally with default props all sounds will share

        :param props:
            A mapping of Props to values. These properties and values will be set
            as defaults for all sounds played from this context.

        :param other_props:
            Props may also be passed as kwargs, where ``{Props.EVENT_ID: 'bell'}`` may
            be passed as ``event_id='bell'``. These properties and values will be set
            as defaults for all sounds played from this context.

        """
        if props or other_props:
            self.change_props(props, **other_props)

    def set_driver(self, driver: Union[str, bytes]) -> None:
        """Specify the backend driver used

        This method may not be called again after a successful call to :meth:`open`,
        which occurs implicitly when calling :meth:`.play`.

        This method might succeed even when the specified driver backend is not
        available. Use :meth:`open` to find out whether the backend is available.

        :param driver:
            The backend driver to use (e.g. ``"alsa"``, ``"pulse"``, ``"null"``, ...)

        """
        driver_bytes = driver if isinstance(driver, bytes) else driver.encode('utf-8')
        cdef char *c_driver = driver_bytes

        cdef int error = ca_context_set_driver(self._ca_ctx, c_driver)
        raise_if_error(error)

    def change_device(self, device: Union[str, bytes]) -> None:
        """Specify the backend device to use

        This method may not be called again after a successful call to :meth:`open`,
        which occurs implicitly when calling :meth:`.play`.

        This method might succeed even when the specified driver backend is not
        available. Use :meth:`open` to find out whether the backend is available.

        Depending on the backend used, this might or might not cause all
        currently playing event sounds to be moved to the new device.

        :param device:
            The backend device to use, in a format that is specific to the backend

        """
        device_bytes = device if isinstance(device, bytes) else device.encode('utf-8')
        cdef char *c_device = device_bytes

        cdef int error = ca_context_change_device(self._ca_ctx, c_device)
        raise_if_error(error)

    def open(self) -> None:
        """Connect the context to the sound system.

        This is implicitly called in :meth:`.play` or :meth:`cache` if not called
        explicitly. It is recommended to initialize application properties
        with :meth:`change_props` (or when creating :class:`Context`)
        before calling this function.

        """
        cdef int error = ca_context_open(self._ca_ctx)
        raise_if_error(error)

    def change_props(self, props: Dict[Union[str, Props], str] = None, **other_props: str) -> None:
        """Write one or more string properties to the Context

        Properties set like this will be attached to both the client object of
        the sound server and to all event sounds played or cached. It is
        recommended to call this method at least once before calling :meth:`open`
        (which occurs implicitly when calling :meth:`.play`), so that the
        initial application properties are set properly before the initial
        connection to the sound system.

        This method can be called both before and after the :meth:`open` call.
        Properties that have already been set before will be overwritten.

        :param props:
            A mapping of :class:`Props` to values.

        :param other_props:
            :class:`Props` may also be passed as kwargs, where
            ``{Props.EVENT_ID: 'bell'}`` is passed as ``event_id='bell'``.

        """
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

    def cache(self, props: Dict[Union[str, Props], str] = None, **other_props: str) -> None:
        """Upload the specified sample into the audio server and attach the specified properties to it

        This method will only return after the sample upload was finished.

        The sound to cache is found with the same algorithm that is used to
        find the sounds for :meth:`.play`.

        If the backend doesn't support caching sound samples, this method
        will raise a :exc:`CanberraError` with a ``code`` of :attr:`.NOTSUPPORTED`.

        :param props:
            A mapping of :class:`Props` to values.

        :param other_props:
            :class:`Props` may also be passed as kwargs, where
            ``{Props.EVENT_ID: 'bell'}`` is passed as ``event_id='bell'``.

        """
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

    def play(
        self,
        props: Dict[Union[str, Props], str] = None,
        uint32_t id = 0,
        on_finished: OnFinishedCallback = None,
        user_data = NOTSET,
        **other_props: str,
    ) -> None:
        """Play one event sound

        ``id`` can be any numeric value which later can be used to cancel an
        event sound that is currently being played. You may use the same ``id``
        twice or more times if you want to cancel multiple event sounds with
        a single :meth:`cancel` call. It is recommended to pass ``0`` (the default)
        for the ``id`` if the event sound shall never be canceled.

        If the requested sound is not cached in the server yet, this call might
        result in the sample being uploaded temporarily or permanently
        (this may be controlled with :attr:`.CANBERRA_CACHE_CONTROL`).

        This method will start playback in the background. It will not wait to
        return until playback completed. Depending on the backend used, a sound
        that is started shortly before your application terminates might or
        might not continue to play after your application terminated. If you
        want to make sure that all sounds finish to play, you need to pass an
        :paramref:`on_finished <Context.play.on_finished>` callback and wait
        for it to be called before you terminate your application.

        The sample to play is identified by the :attr:`.EVENT_ID` property.
        If it is already cached in the server the cached version is played.
        The properties passed in this call are merged with the properties
        supplied when the sample was cached (if applicable) and the context
        properties as set with :meth:`change_props`.

        If :attr:`.EVENT_ID` is not defined, the sound file passed in the
        :attr:`.MEDIA_FILENAME` is played.

        On Linux/Unix, the right sound to play is determined according to
        :attr:`.EVENT_ID`, :attr:`.APPLICATION_LANGUAGE`/:attr:`.MEDIA_LANGUAGE`,
        the system locale, :attr:`.CANBERRA_XDG_THEME_NAME` and
        :attr:`.CANBERRA_XDG_THEME_OUTPUT_PROFILE`, following the XDG Sound
        Theming Specification. On non-Unix systems, the native event sound
        that matches the XDG sound name in :attr:`.EVENT_ID` is played.

        :param props:
            A mapping of :class:`Props` to values describing additional
            properties for this sound event.

        :param id:
            An integer id this sound can later be identified with when calling
            :meth:`.cancel`

        :param on_finished:
            An optional callback to be called when the sound finishes playing.
            Depending on whether :paramref:`.user_data` is passed, the prototype
            for this callback will be:

            .. code-block:: python

                # without user_data
                def callback(ctx: Context, id: int, error: Union[CanberraError, Errors])

                # with user_data
                def callback(ctx: Context, id: int, error: Union[CanberraError, Errors], user_data: Any)

        :param user_data:
            An optional argument to be passed to the
            :paramref:`on_finished <Context.play.on_finished>` callback

        :param other_props:
            :class:`Props` may also be passed as kwargs, where ``{Props.EVENT_ID: 'bell'}``
            is passed as ``event_id='bell'``, which describe additional
            properties for this sound event.

        """
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
            Py_INCREF(on_finished)
            Py_INCREF(user_data)

            error = ca_context_play_full(self._ca_ctx, id, proplist, ca_finish_callback, <void *>ca_userdata)
            if error != CA_SUCCESS:
                #
                # If the call is not successful, our ca_finish_callback will not
                # be called, so we must free our memory and decrement our references
                # now.
                #
                free(ca_userdata)

                Py_DECREF(self)
                Py_DECREF(on_finished)
                Py_DECREF(user_data)

            raise_if_error(error)

        finally:
            ca_proplist_destroy(proplist)

    def cancel(self, uint32_t id = 0) -> None:
        """Cancel one or more event sounds that have been started via :meth:`.play`

        If callback function was passed to :meth:`.play` when starting the sound,
        calling :meth:`.cancel` might cause this callback function to be called
        with :attr:`.CANCELED` as the error code (wrapped in :exc:`CanberraError`).

        :param id:
            The ID that identifies the sound(s) to cancel.

        """
        cdef int error

        error = ca_context_cancel(self._ca_ctx, id)
        raise_if_error(error)

    def playing(self, uint32_t id = 0) -> bool:
        """Check if at least one sound with the specified id is still playing

        :param id:
            The ID that identifies the sound(s) to check

        :return:
            ``True`` if at least one sound with the specified ID is still playing,
            and ``False`` if no sounds with the specified ID are still playing

        """
        cdef int error
        cdef int playing

        error = ca_context_playing(self._ca_ctx, id, &playing)
        raise_if_error(error)

        return bool(playing)
