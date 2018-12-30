import argparse
import json

from entity import cargo
from entity import schedule


class OrderingManagementService(object):
    """OrderingManagementServiceサービス"""

    def __init__(self) -> None:
        pass

    def create(self, args: argparse.Namespace):
        input_file_path = args.input
        with open(input_file_path, 'r') as f:
            data = json.loads(f.read())

        new_schedule = schedule.Factory().create(data)
        created_schecdule = schedule.Repository().create(new_schedule)

        new_cargo = cargo.Facotry().create()
        created_cargo = cargo.Repository().create(new_cargo)
        return (created_schecdule, created_cargo)
