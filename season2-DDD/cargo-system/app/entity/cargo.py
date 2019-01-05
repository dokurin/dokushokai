from datetime import datetime


class Cargo(object):
    """貨物エンティティ

    Attributes:
        id (str): cargo id.
    """

    def __init__(self) -> None:
        pass


class Facotry(object):
    def create() -> Cargo:
        cargo = Cargo()
        cargo.id = datetime.now().timestamp()
        return cargo


class Repository(object):
    def create(self, cargo: Cargo) -> Cargo:
        # 登録処理が走る
        return cargo
