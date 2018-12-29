from typing import NewType

import location

ScheduleID = NewType("ScheduleID", str)


class CarrierMovement(object):
    """輸送機器移動Entity

    Args:
        schedule_id (ScheduleID): スケジュールID
        departure_point (location.Location): 出発地点
        arrival_point (location.Location): 到着地点

    Attributes:
        schedule_id (ScheduleID): スケジュールID
        departure_point (location.Location): 出発地点
        arrival_point (location.Location): 到着地点
    """

    def __init__(self, schedule_id: ScheduleID, departure_point: location.Location, arrival_point: location.Location) -> None:
        self.schedule_id = schedule_id
