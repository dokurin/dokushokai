class Location(object):
    """位置

    Args:
        port_code (str): 港湾コード

    Attributes:
        port_code (str): 港湾コード
    """

    def __init__(self, port_code: str) -> None:
        self.port_code = port_code
