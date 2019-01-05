class Geo(object):
    """位置情報"""

    def __init__(self, lat: float, lng: float, geo_hash: str) -> None:
        self.lat = lat
        self.lng = lng
        self.geo_hash = geo_hash


class Port(object):
    """港エンティティ

    Attributes:
        geo (Geo): 位置情報
        name (str): 港名
    """

    def __init__(self, geo: Geo) -> None:
        self.geo = geo
