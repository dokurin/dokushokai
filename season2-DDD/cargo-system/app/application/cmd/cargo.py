import argparse


class Cargo(object):
    """Cargoアプリケーション"""

    def __init__(self) -> None:
        pass

    def add(self, args: argparse.Namespace) -> None:
        print(args)

    def find(self, args: argparse.Namespace) -> None:
        print(args)
