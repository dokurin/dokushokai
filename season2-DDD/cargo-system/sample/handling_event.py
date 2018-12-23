from datetime import datetime
from enum import Enum, auto

import cargo

import carrier_movement


class Kind(Enum):
    """荷役タイプ"""

    Something = auto()


class HandlingEvent(object):
    """荷役イベントEntity

    Args:
        cargo (cargo.Cargo): 貨物
        completed_at (datetime): 完了時刻
        kind (Kind): タイプ
        carrier_movement (carrier_movement.CarrierMovement): 輸送機器移動 default: None

    Attributes:
        cargo (cargo.Cargo): 貨物
        completed_at (datetime): 完了時刻
        kind (Kind): タイプ
        carrier_movement (carrier_movement.CarrierMovement): 輸送機器移動
    """

    def __init__(self, cargo: cargo.Cargo, completed_at: datetime, kind: Kind, carrier_movement: carrier_movement.CarrierMovement = None) -> None:
        self.cargo = cargo
        self.completed_at = completed_at
        self.kind = kind
        self.carrier_movement = carrier_movement
