from typing import Optional

from PyQt5.QtCore import QObject, pyqtSlot
from lxml import etree


from PyQt5.QtCore import pyqtProperty as Property


class NodeGraphic(QObject):
    def __init__(self, id, x, y, width, height, parent = None):
        super().__init__(parent)
        self._id = id
        self._x = float(x)
        self._y = float(y)
        self._width = float(width)
        self._height = float(height)

    @Property(str, constant = True)
    def id(self):
        return self._id

    @Property(float, constant = True)
    def x(self):
        return self._x

    @Property(float, constant = True)
    def y(self):
        return self._y

    @Property(float, constant = True)
    def width(self):
        return self._width

    @Property(float, constant = True)
    def height(self):
        return self._height


class ConnectionGraphic(QObject):
    def __init__(self, source, target, points, color, parent = None):
        super().__init__(parent)
        self._source = source
        self._target = target
        self._points = points
        self._color = color

    @Property(str)
    def source(self):
        return self._source

    @Property(str)
    def target(self):
        return self._target

    @Property("QVariantList")
    def points(self):
        return self._points

    @Property(str)
    def color(self):
        return self._color


class Point(QObject):
    def __init__(self, x, y, parent = None):
        super().__init__(parent)
        self._x = float(x)
        self._y = float(y)

    @Property(float, constant=True)
    def x(self):
        return self._x

    @Property(float, constant=True)
    def y(self):
        return self._y


class GraphMLParser(QObject):
    def __init__(self, file_path, parent=None) -> None:
        super().__init__(parent)
        d_s = "{http://graphml.graphdrawing.org/xmlns}"
        y_s = "{http://www.yworks.com/xml/graphml}"
        tree = etree.parse(file_path)
        root = tree.getroot()
        scale = 1
        graph = root.find(d_s+"graph")
        self._nodes = []
        self._nodes_by_id = {}
        self._connections = []
        self._xml_id_to_our = {}
        for node in graph.findall(d_s + "node"):
            for data in node.findall(d_s + "data"):
                if data.attrib["key"] != "d5":
                    continue
                shape_node = data.find(y_s + "ShapeNode")
                node_id = shape_node.find(y_s + "NodeLabel").text
                geometry = shape_node.find(y_s + "Geometry")
                node_graphic = NodeGraphic(node_id,
                                           scale * float(geometry.attrib["x"]),
                                           scale * float(geometry.attrib["y"]),
                                           scale * float(geometry.attrib["width"]),
                                           scale * float(geometry.attrib["height"]))
                self._nodes.append(node_graphic)
                self._nodes_by_id[node_id] = node_graphic
                # Create a mapping to translate between ID's
                self._xml_id_to_our[node.attrib["id"]] = node_id

        for edge in graph.findall(d_s + "edge"):
            source = self._xml_id_to_our[edge.attrib["source"]]
            target = self._xml_id_to_our[edge.attrib["target"]]
            source_node = self._nodes_by_id[source]
            target_node = self._nodes_by_id[target]
            points = []
            color = "#000000"
            for data in edge.findall(d_s + "data"):
                if data.attrib["key"] != "d9":
                    continue
                poly_line = data.find(y_s + "PolyLineEdge")
                path = poly_line.find(y_s + "Path")
                points.append(Point(scale * float(path.attrib["sx"]) + source_node.x + 0.5 * source_node.width,
                                    scale * float(path.attrib["sy"]) + source_node.y + 0.5 * source_node.height))

                for point in path:
                    points.append(Point(scale * float(point.attrib["x"]), scale * float(point.attrib["y"])))
                points.append(Point(scale * float(path.attrib["tx"]) + target_node.x + 0.5 * target_node.width,
                                    scale * float(path.attrib["ty"]) + target_node.y + 0.5 * target_node.height))
                line_style = poly_line.find(y_s + "LineStyle")
                color = line_style.attrib["color"]
            self._connections.append(ConnectionGraphic(source, target, points, color))

    @Property("QVariantList", constant=True)
    def nodes(self):
        return self._nodes

    @pyqtSlot(str, result = "QVariant")
    def getNodeById(self, node_id: str) -> Optional[NodeGraphic]:
        return self._nodes_by_id.get(node_id)

    @Property("QVariantList", constant=True)
    def connections(self):
        return self._connections


