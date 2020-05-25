from pathlib import Path
from typing import Dict, Union

from . import Context, Props


def play(props: Dict[Union[str, Props], str] = None, **other_props: str) -> Context:
    """Play a sound with the specified props

    :param props:
        A mapping of :class:`Props` to values.

    :param other_props:
        :class:`Props` may also be passed as kwargs, where ``{Props.EVENT_ID: 'bell'}``
        is passed as ``event_id='bell'``.

    :return:
        The canberra.Context used to play the sound. `cancel()` may be called
        on this context to stop the playing sound.

    """
    ctx = Context()
    ctx.play(props, **other_props)
    return ctx


def play_file(filename: Union[str, Path], **other_props: str) -> Context:
    """Play the specified sound file

    :param filename:
        Path to the sound file to be played

    :param other_props:
        :class:`Props` passed as kwargs, where ``{Props.EVENT_ID: 'bell'}`` is
        passed as ``event_id='bell'``.

    :return:
        The :class:`canberra.Context` used to play the sound. `cancel()` may be
        called on this context to stop the playing sound.

    """
    filename = str(filename)
    return play(**other_props, media_filename=filename)
