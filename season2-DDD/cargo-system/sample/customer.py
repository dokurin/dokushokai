from typing import NewType

ID = NewType("CustomerID", str)


class Customer(object):
    """顧客Entity

    Args:
        id (ID): 顧客ID
        name (str): 氏名

    Attrubutes:
        id (ID): 顧客ID
        name (str): 氏名
    """

    def __init__(self, id: str, name: ID) -> None:
        self.id = id
        self.name = name
