import argparse


class Customer(object):
    """Customerアプリケーション"""

    def add(self, args: argparse.Namespace) -> None:
        print(args)
