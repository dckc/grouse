# Stubs for sqlalchemy.engine.result (Python 3.5)
#
# NOTE: This dynamically typed stub was automatically generated by stubgen.

from typing import Any, List, Optional
from ..sql import expression as expression, sqltypes as sqltypes
# from ..sql import util as sql_util
# from sqlalchemy.cresultproxy import BaseRowProxy

def rowproxy_reconstructor(cls, state): ...

class BaseRowProxy:
    def __init__(self, parent, row, processors, keymap) -> None: ...
    def __reduce__(self): ...
    def values(self): ...
    def __iter__(self): ...
    def __len__(self): ...
    def __getitem__(self, key): ...
    def __getattr__(self, name): ...

class RowProxy(BaseRowProxy):
    def __contains__(self, key): ...
    __hash__ = ...  # type: Any
    def __lt__(self, other): ...
    def __le__(self, other): ...
    def __ge__(self, other): ...
    def __gt__(self, other): ...
    def __eq__(self, other): ...
    def __ne__(self, other): ...
    def has_key(self, key): ...
    def items(self): ...
    def keys(self) -> List[str]: ...
    def iterkeys(self): ...
    def itervalues(self): ...

class ResultMetaData:
    case_sensitive = ...  # type: Any
    matched_on_name = ...  # type: bool
    def __init__(self, parent, cursor_description) -> None: ...

class ResultProxy:
    out_parameters = ...  # type: Any
    closed = ...  # type: bool
    context = ...  # type: Any
    dialect = ...  # type: Any
    cursor = ...  # type: Any
    connection = ...  # type: Any
    def __init__(self, context) -> None: ...
    def keys(self) -> List[str]: ...
    def rowcount(self): ...
    @property
    def lastrowid(self): ...
    @property
    def returns_rows(self): ...
    @property
    def is_insert(self): ...
    def close(self): ...
    def __iter__(self): ...
    def inserted_primary_key(self): ...
    def last_updated_params(self): ...
    def last_inserted_params(self): ...
    @property
    def returned_defaults(self): ...
    def lastrow_has_defaults(self): ...
    def postfetch_cols(self): ...
    def prefetch_cols(self): ...
    def supports_sane_rowcount(self): ...
    def supports_sane_multi_rowcount(self): ...
    def process_rows(self, rows): ...
    def fetchall(self) -> List[RowProxy]: ...
    def fetchmany(self, size: Optional[Any] = ...): ...
    def fetchone(self): ...
    def first(self): ...
    def scalar(self): ...

class BufferedRowResultProxy(ResultProxy):
    size_growth = ...  # type: Any

class FullyBufferedResultProxy(ResultProxy): ...

class BufferedColumnRow(RowProxy):
    def __init__(self, parent, row, processors, keymap) -> None: ...

class BufferedColumnResultProxy(ResultProxy):
    def fetchall(self) -> List[RowProxy]: ...
    def fetchmany(self, size: Optional[Any] = ...) -> List[RowProxy]: ...
