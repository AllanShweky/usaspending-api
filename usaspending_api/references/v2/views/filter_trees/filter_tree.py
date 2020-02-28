from abc import ABCMeta, abstractmethod
from dataclasses import dataclass


@dataclass
class Node:
    name: str
    ancestors: list
    description: str
    count: int
    children: list

    def toJSON(self):
        return {
            "name": self.name,
            "ancestors": self.ancestors,
            "description": self.description,
            "count": self.count,
            "children": self.children,
        }


class FilterTree(metaclass=ABCMeta):
    def basic_search(self, tier1, tier2, tier3) -> list:
        if tier3:
            return [self.construct_node_from_raw(3, data) for data in self.tier_three_search(tier3)]
        elif tier2:
            return [self.construct_node_from_raw(2, data) for data in self.tier_two_search(tier2)]
        elif tier1:
            return [self.construct_node_from_raw(1, data) for data in self.tier_one_search(tier1)]
        else:
            return [self.construct_node_from_raw(1, data) for data in self.toptier_search()]

    @abstractmethod
    def toptier_search(self):
        pass

    @abstractmethod
    def tier_one_search(self, key):
        pass

    @abstractmethod
    def tier_two_search(self, key):
        pass

    @abstractmethod
    def tier_three_search(self, key):
        pass

    @abstractmethod
    def construct_node_from_raw(self, tier: int, data) -> Node:
        pass
