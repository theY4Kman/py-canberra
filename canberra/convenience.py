from pathlib import Path
from typing import Dict, Union

from .constants import Props
from ._canberra import Context


def play(props: Dict[Union[str, Props], str] = None, **other_props: str) -> Context:
    """Play a sound with the specified props

    :param props:
        A mapping of Props to string values to pass to libcanberra

    :param other_props:
        The Props.XYZ members may be passed as XYZ='val' or xyz='val'
        (i.e. uppercase or lowercase) in the kwargs.

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
        Additional props (e.g. Props.XYZ), passed as XYZ='val' or xyz='val'
        in the kwargs.

    :return:
        The canberra.Context used to play the sound. `cancel()` may be called
        on this context to stop the playing sound.

    """
    filename = str(filename)
    return play(**other_props, media_filename=filename)
