import importlib
import inspect
from inspect import Signature
from pathlib import Path
from types import ModuleType
from typing import Any, Dict, Optional

from sphinx.application import Sphinx


def setup(app: Sphinx):
    """Register Sphinx extension"""
    app.connect('autodoc-process-signature', process_signature)


def process_signature(app: Sphinx, what: str, name: str, obj, options,
                      signature, return_annotation):
    if what == 'method':
        sig = get_stub_signature(obj)
        if sig:
            signature = str(sig)
            return_annotation = None

    return signature, return_annotation


def get_stub_declarations(modname: str) -> Optional[ModuleType]:
    """Given a dotted modname, return any stub declarations in matching pyi file
    """
    mod = importlib.import_module(modname)
    mod_path = Path(mod.__file__)

    stem = modname.rsplit('.', maxsplit=1)[-1]
    stem_path = mod_path.parent / stem
    stub_path = stem_path.with_suffix('.pyi')

    if not stub_path.exists():
        return None

    stub_mod = ModuleType(modname)
    exec(stub_path.read_text(), vars(stub_mod))
    return stub_mod


_stub_mods = {}


def get_stub_signature(obj) -> Optional[Signature]:
    try:
        modname = obj.__module__
    except AttributeError:
        try:
            modname = obj.__objclass__.__module__
        except AttributeError:
            return None

    if modname not in _stub_mods:
        _stub_mods[modname] = get_stub_declarations(modname)

    stub_mod = _stub_mods[modname]
    if not stub_mod:
        return None

    obj_path = obj.__qualname__.split('.')
    if obj_path[-1] == '__init__':
        obj_path = obj_path[:-1]

    root = stub_mod
    for attr in obj_path:
        try:
            root = getattr(root, attr)
        except AttributeError:
            return None

    try:
        return inspect.signature(root)
    except TypeError:
        return None
