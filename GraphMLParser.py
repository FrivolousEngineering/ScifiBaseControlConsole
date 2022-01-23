from lxml import etree



class NodeGraphic:
    def __init__(self, id, x, y, width, height):
        self.id = id
        self.x = x
        self.y = y
        self.width = width
        self.height = height


class ConnectionGraphic:
    def __init__(self, source, target, points):
        self.source = source
        self.target = target
        self.points = points


class GraphMLParser:
    def __init__(self, file_path) -> None:

        d_s = "{http://graphml.graphdrawing.org/xmlns}"
        y_s = "{http://www.yworks.com/xml/graphml}"
        tree = etree.parse(file_path)
        root = tree.getroot()

        graph = root.find(d_s+"graph")
        self._nodes = []
        self._connections = []
        self._our_id_to_xml_id = {}
        self._xml_id_to_our = {}
        for node in graph.findall(d_s + "node"):
            for data in node.findall(d_s + "data"):
                if data.attrib["key"] != "d5":
                    continue
                shape_node = data.find(y_s + "ShapeNode")
                node_id = shape_node.find(y_s + "NodeLabel").text
                geometry = shape_node.find(y_s + "Geometry")

                self._nodes.append(NodeGraphic(node_id, geometry.attrib["x"], geometry.attrib["y"], geometry.attrib["width"], geometry.attrib["height"]))
                # Create a mapping to translate between ID's
                self._our_id_to_xml_id[node_id] = node.attrib["id"]
                self._xml_id_to_our[node.attrib["id"]] = node_id

        for edge in graph.findall(d_s + "edge"):
            source = self._xml_id_to_our[edge.attrib["source"]]
            target = self._xml_id_to_our[edge.attrib["target"]]

            points = []
            for data in edge.findall(d_s + "data"):
                if data.attrib["key"] != "d9":
                    continue
                poly_line = data.find(y_s + "PolyLineEdge")
                path = poly_line.find(y_s + "Path")
                for point in path:
                    points.append((point.attrib["x"], point.attrib["y"]))
            self._connections.append(ConnectionGraphic(source, target, points))


