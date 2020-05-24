from enum import Enum, IntEnum
from typing import Dict, Union


class StrEnum(str, Enum):
    def __str__(self):
        return self.value


class Props(StrEnum):

    ###
    # A name describing the media being played. Localized if possible and applicable.
    #
    MEDIA_NAME = 'media.name'

    ###
    # A (song) title describing the media being played. Localized if possible and applicable.
    #
    MEDIA_TITLE = 'media.title'

    ###
    # The artist of this media. Localized if possible and applicable.
    #
    MEDIA_ARTIST = 'media.artist'

    ###
    # The language this media is in, in some standard POSIX locale string, such as "de_DE".
    #
    MEDIA_LANGUAGE = 'media.language'

    ###
    # The file name this media was or can be loaded from.
    #
    MEDIA_FILENAME = 'media.filename'

    ###
    # An icon for this media in binary PNG format.
    #
    MEDIA_ICON = 'media.icon'

    ###
    # An icon name as defined in the XDG icon naming specifcation.
    #
    MEDIA_ICON_NAME = 'media.icon_name'

    ###
    # The "role" this media is played in. For event sounds the string
    # "event". For other cases strings like "music", "video", "game", ...
    #
    MEDIA_ROLE = 'media.role'

    ###
    # A textual id for an event sound, as mandated by the XDG sound naming specification.
    #
    EVENT_ID = 'event.id'

    ###
    # A descriptive string for the sound event. Localized if possible and applicable.
    #
    EVENT_DESCRIPTION = 'event.description'

    ###
    # If this sound event was triggered by a mouse input event, the X
    # position of the mouse cursor on the screen, formatted as string.
    #
    EVENT_MOUSE_X = 'event.mouse.x'

    ###
    # If this sound event was triggered by a mouse input event, the Y
    # position of the mouse cursor on the screen, formatted as string.
    #
    EVENT_MOUSE_Y = 'event.mouse.y'

    ###
    # If this sound event was triggered by a mouse input event, the X
    # position of the mouse cursor as fractional value between 0 and 1,
    # formatted as string, 0 reflecting the left side of the screen, 1
    # the right side.
    #
    EVENT_MOUSE_HPOS = 'event.mouse.hpos'

    ###
    # If this sound event was triggered by a mouse input event, the Y
    # position of the mouse cursor as fractional value between 0 and 1,
    # formatted as string, 0 reflecting the top end of the screen, 1
    # the bottom end.
    #
    EVENT_MOUSE_VPOS = 'event.mouse.vpos'

    ###
    # If this sound event was triggered by a mouse input event, the
    # number of the mouse button that triggered it, formatted as string. 1
    # for left mouse button, 3 for right, 2 for middle.
    #
    EVENT_MOUSE_BUTTON = 'event.mouse.button'

    ###
    # If this sound event was triggered by a window on the screen, the
    # name of this window as human readable string.
    #
    WINDOW_NAME = 'window.name'

    ###
    # If this sound event was triggered by a window on the screen, some
    # identification string for this window, so that the sound system can
    # recognize specific windows.
    #
    WINDOW_ID = 'window.id'

    ###
    # If this sound event was triggered by a window on the screen, binary
    # icon data in PNG format for this window.
    #
    WINDOW_ICON = 'window.icon'

    ###
    # If this sound event was triggered by a window on the screen, an
    # icon name for this window, as defined in the XDG icon naming
    # specification.
    #
    WINDOW_ICON_NAME = 'window.icon_name'

    ###
    # If this sound event was triggered by a window on the screen, the X
    # position of the window measured from the top left corner of the
    # screen to the top left corner of the window.
    #
    # Since: 0.17
    #
    WINDOW_X = 'window.x'

    ###
    # If this sound event was triggered by a window on the screen, the y
    # position of the window measured from the top left corner of the
    # screen to the top left corner of the window.
    #
    # Since: 0.17
    #
    WINDOW_Y = 'window.y'

    ###
    # If this sound event was triggered by a window on the screen, the
    # pixel width of the window.
    #
    # Since: 0.17
    #
    WINDOW_WIDTH = 'window.width'

    ###
    # If this sound event was triggered by a window on the screen, the
    # pixel height of the window.
    #
    # Since: 0.17
    #
    WINDOW_HEIGHT = 'window.height'

    ###
    # If this sound event was triggered by a window on the screen, the X
    # position of the center of the window as fractional value between 0
    # and 1, formatted as string, 0 reflecting the left side of the
    # screen, 1 the right side.
    #
    # Since: 0.17
    #
    WINDOW_HPOS = 'window.hpos'

    ###
    # If this sound event was triggered by a window on the screen, the Y
    # position of the center of the window as fractional value between 0
    # and 1, formatted as string, 0 reflecting the top side of the
    # screen, 1 the bottom side.
    #
    # Since: 0.17
    #
    WINDOW_VPOS = 'window.vpos'

    ###
    # If this sound event was triggered by a window on the screen and the
    # windowing system supports multiple desktops, a comma seperated list
    # of indexes of the desktops this window is visible on. If this
    # property is an empty string, it is visible on all desktops
    # (i.e. 'sticky'). The first desktop is 0. (e.g. "0,2,3")
    #
    # Since: 0.18
    #
    WINDOW_DESKTOP = 'window.desktop'

    ###
    # If this sound event was triggered by a window on the screen and the
    # windowing system is X11, the X display name of the window (e.g. ":0").
    #
    WINDOW_X11_DISPLAY = 'window.x11.display'

    ###
    # If this sound event was triggered by a window on the screen and the
    # windowing system is X11, the X screen id of the window formatted as
    # string (e.g. "0").
    #
    WINDOW_X11_SCREEN = 'window.x11.screen'

    ###
    # If this sound event was triggered by a window on the screen and the
    # windowing system is X11, the X monitor id of the window formatted as
    # string (e.g. "0").
    #
    WINDOW_X11_MONITOR = 'window.x11.monitor'

    ###
    # If this sound event was triggered by a window on the screen and the
    # windowing system is X11, the XID of the window formatted as string.
    #
    WINDOW_X11_XID = 'window.x11.xid'

    ###
    # The name of the application this sound event was triggered by as
    # human readable string. (e.g. "GNU Emacs") Localized if possible and
    # applicable.
    #
    APPLICATION_NAME = 'application.name'

    ###
    # An identifier for the program this sound event was triggered
    # by. (e.g. "org.gnu.emacs").
    #
    APPLICATION_ID = 'application.id'

    ###
    # A version number for the program this sound event was triggered
    # by. (e.g. "22.2")
    #
    APPLICATION_VERSION = 'application.version'

    ###
    # Binary icon data in PNG format for the application this sound event
    # is triggered by.
    #
    APPLICATION_ICON = 'application.icon'

    ###
    # An icon name for the application this sound event is triggered by,
    # as defined in the XDG icon naming specification.
    #
    APPLICATION_ICON_NAME = 'application.icon_name'

    ###
    # The locale string the application that is triggering this sound
    # event is running in. A POSIX locale string such as de_DE@euro.
    #
    APPLICATION_LANGUAGE = 'application.language'

    ###
    # The unix PID of the process that is triggering this sound event, formatted as string.
    #
    APPLICATION_PROCESS_ID = 'application.process.id'

    ###
    # The path to the process binary of the process that is triggering this sound event.
    #
    APPLICATION_PROCESS_BINARY = 'application.process.binary'

    ###
    # The user that owns the process that is triggering this sound event.
    #
    APPLICATION_PROCESS_USER = 'application.process.user'

    ###
    # The host name of the host the process that is triggering this sound event runs on.
    #
    APPLICATION_PROCESS_HOST = 'application.process.host'

    ###
    # A special property that can be used to control the automatic sound
    # caching of sounds in the sound server. One of "permanent",
    # "volatile", "never". "permanent" will cause this sample to be
    # cached in the server permanently. This is useful for very
    # frequently used sound events such as those used for input
    # feedback. "volatile" may be used for cacheing sounds in the sound
    # server temporarily. They will expire after some time or on cache
    # pressure. Finally, "never" may be used for sounds that should never
    # be cached, because they are only generated very seldomly or even
    # only once at most (such as desktop login sounds).
    #
    # If this property is not explicitly passed to ca_context_play() it
    # will default to "never". If it is not explicitly passed to
    # If the list of properties is handed on to the sound server this
    # property is stripped from it.
    #
    CANBERRA_CACHE_CONTROL = 'canberra.cache-control'

    ###
    # A special property that can be used to control the volume this
    # sound event is played in if the backend supports it. A floating
    # point value for the decibel multiplier for the sound. 0 dB relates
    # to zero gain, and is the default volume these sounds are played in.
    #
    # If the list of properties is handed on to the sound server this
    # property is stripped from it.
    #
    CANBERRA_VOLUME = 'canberra.volume'

    ###
    # A special property that can be used to control the XDG sound theme that
    # is used for this sample.
    #
    # If the list of properties is handed on to the sound server this
    # property is stripped from it.
    #
    CANBERRA_XDG_THEME_NAME = 'canberra.xdg-theme.name'

    ###
    # A special property that can be used to control the XDG sound theme
    # output profile that is used for this sample.
    #
    # If the list of properties is handed on to the sound server this
    # property is stripped from it.
    #
    CANBERRA_XDG_THEME_OUTPUT_PROFILE = 'canberra.xdg-theme.output-profile'

    ###
    # A special property that can be used to control whether any sounds
    # are played at all. If this property is "1" or unset sounds are
    # played as normal. However, if it is "0" all calls to
    # If the list of properties is handed on to the sound server this
    # property is stripped from it.
    #
    CANBERRA_ENABLE = 'canberra.enable'

    ###
    # A special property that can be used to control on which channel a
    # sound is played. The value should be one of mono, front-left,
    # front-right, front-center, rear-left, rear-right, rear-center, lfe,
    # front-left-of-center, front-right-of-center, side-left, side-right,
    # top-center, top-front-left, top-front-right, top-front-center,
    # top-rear-left, top-rear-right, top-rear-center. This property is
    # only honoured by some backends, other backends may choose to ignore
    # it completely.
    #
    # If the list of properties is handed on to the sound server this
    # property is stripped from it.
    #
    # Since: 0.13
    #
    CANBERRA_FORCE_CHANNEL = 'canberra.force_channel'

    ###
    # A mapping of kwarg names to the Props enum values they represent.
    # This mapping is used to power canberra.Context().play(media_id='...'), etc
    #
    kwarg_names: Dict[str, 'Props']

    @classmethod
    def from_kwargs(cls,
                    props: Dict[Union[str, 'Props'], str] = None,
                    **kwargs: str,
                    ) -> Dict['Props', str]:
        """Translate kwarg names to Props for a Props->value mapping
        """
        inputs = {}
        if props:
            inputs.update(props)
        inputs.update(kwargs)

        prop_values: Dict['Props', str] = {}
        for key, value in inputs.items():
            if isinstance(key, str):
                if key in cls.kwarg_names:
                    key = cls.kwarg_names[key]
                else:
                    key = cls(key)

            if not isinstance(key, cls):
                raise TypeError(f'Expected a valid {type(key)}. Found {type(key)} {key!r}')

            prop_values[key] = value

        return prop_values


Props.kwarg_names = {
    **Props.__members__,
    **{k.lower(): v for k, v in Props.__members__.items()}
}


class Errors(IntEnum):
    SUCCESS = 0

    NOTSUPPORTED = -1
    INVALID = -2
    STATE = -3
    OOM = -4
    NODRIVER = -5
    SYSTEM = -6
    CORRUPT = -7
    TOOBIG = -8
    NOTFOUND = -9
    DESTROYED = -10
    CANCELED = -11
    NOTAVAILABLE = -12
    ACCESS = -13
    IO = -14
    INTERNAL = -15
    DISABLED = -16
    FORKED = -17
    DISCONNECTED = -18
