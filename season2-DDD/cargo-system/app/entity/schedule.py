from datetime import datetime

from . import port


class Schedule(object):
    """スケジュールエンティティ

    Attributes:
        foo (str): attributes comment.
    """

    def __init__(self) -> None:
        pass


class Factory(object):
    def __init__(self) -> None:
        pass

    def create(self, start_port: port.Port, end_port: port.Port, start_date: datetime.datetime, end_date: datetime.datetime) -> Schedule:
        sch = Schedule()
        sch.start_port = start_port
        sch.end_port = end_port
        sch.start_date = start_date
        sch.end_date = end_date
        return sch


class Repository(object):
    def __init__(self) -> None:
        pass

    def create(self) -> Schedule:
        pass
