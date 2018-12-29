from datetime import datetime
from typing import List, NewType

import customer

import handling_event

import location

ID = NewType("CargoID", str)


class DeriveryHistory(object):
    """配送記録Entity

    Args:
        cargo_id (ID): 貨物ID
        events (List[handling_event.HandlingEvent]): 荷役イベント

    Attributes:
        cargo_id (ID): 貨物ID
        events (List[handling_event.HandlingEvent]): 荷役イベント
    """

    def __init__(self, cargo_id: ID, events: List[handling_event.HandlingEvent]) -> None:
        self.cargo_id = cargo_id
        self.events = events


class DeliverySpecification(object):
    """配送仕様VO

    Args:
        arrived_at (datetime): 到着時刻
        derivery_point (location.Location): 荷出し地

    Attributes:
        arrived_at (datetime): 到着時刻
        derivery_point (location.Location): 荷出し地
    """

    def __init__(self, arrived_at: datetime, derivery_point: location.Location) -> None:
        self.arrived_at = arrived_at
        self.derivery_point = derivery_point


class Role(object):
    """役割VO

    Args:
        customer (customer.Customer): 顧客

    Attributes:
        customer (customer.Customer): 顧客
    """

    def __init__(self, customer: customer.Customer) -> None:
        self.customer = customer


class Cargo(object):
    """貨物Entity

    Args:
        id (ID): 貨物ID
        derivery_history (DeriveryHistory): 配送記録
        target (DeliverySpecification): 目標
        roles (List[Role]): 役割 # TODO: 役割って何だろ??

    Attrubutes:
        id (ID): 貨物ID
        derivery_history (DeriveryHistory): 配送記録
        target (DeliverySpecification): 目標
        roles (List[Role]): 役割 # TODO: 役割って何だろ??
    """

    def __init__(self, id: ID, derivery_history: DeriveryHistory, target: DeliverySpecification, roles: List[Role]) -> None:
        self.id = id
        self.derivery_history = derivery_history
        self.target = target
        self.roles = roles
