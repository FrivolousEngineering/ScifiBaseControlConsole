from PySide2.QtCore import Signal, Qt, QRectF, Property
from PySide2.QtGui import QColor, QFont, QPainter
from PySide2.QtQuick import QQuickPaintedItem


class RadialBar(QQuickPaintedItem):

    class DialType:
        FullDial = 0
        MinToMax = 1
        NoDial = 2

    sizeChanged = Signal()
    startAngleChanged = Signal()
    spanAngleChanged = Signal()
    minValueChanged = Signal()
    maxValueChanged = Signal()
    valueChanged = Signal()
    dialWidthChanged = Signal()
    backgroundColorChanged = Signal()
    foregroundColorChanged = Signal()
    progressColorChanged = Signal()
    textColorChanged = Signal()
    suffixTextChanged = Signal()
    showTextChanged = Signal()
    penStyleChanged = Signal()
    dialTypeChanged = Signal()
    textFontChanged = Signal()

    def __init__(self, parent=None):
        super(RadialBar, self).__init__(parent)

        self.setWidth(200)
        self.setHeight(200)
        self.setSmooth(True)
        self.setAntialiasing(True)

        self._size = 200
        self._start_angle = 40
        self._span_angle = 280
        self._min_value = 0
        self._max_value = 100
        self._value = 50
        self._dial_width = 25
        self._background_color = Qt.transparent
        self._dial_color = QColor(80, 80, 80)
        self._progress_color = QColor(135, 26, 50)
        self._text_color = QColor(0, 0, 0)
        self._suffix_text = ""
        self._show_text = True
        self._pen_style = Qt.FlatCap
        self._dial_type = RadialBar.DialType.MinToMax
        self._text_font = QFont()

    def paint(self, painter):
        painter.save()
        size = min(self.width(), self.height())
        self.setWidth(size)
        self.setHeight(size)
        rect = QRectF(0, 0, self.width(), self.height())
        painter.setRenderHint(QPainter.Antialiasing)
        pen = painter.pen()
        pen.setCapStyle(self._pen_style)

        startAngle = -90 - self._start_angle
        if RadialBar.DialType.FullDial != self._dial_type:
            spanAngle = 0 - self._span_angle
        else:
            spanAngle = -360

        # Draw outer dial
        painter.save()
        pen.setWidth(self._dial_width)
        pen.setColor(self._dial_color)
        painter.setPen(pen)
        offset = self._dial_width / 2
        if self._dial_type == RadialBar.DialType.MinToMax:
            painter.drawArc(rect.adjusted(offset, offset, -offset, -offset), startAngle * 16, spanAngle * 16)
        elif self._dial_type == RadialBar.DialType.FullDial:
            painter.drawArc(rect.adjusted(offset, offset, -offset, -offset), -90 * 16, -360 * 16)

        painter.restore()

        # Draw background
        painter.save()
        painter.setBrush(self._background_color)
        painter.setPen(self._background_color)
        inner = offset * 2
        painter.drawEllipse(rect.adjusted(inner, inner, -inner, -inner))
        painter.restore()

        # Draw progress text with suffix
        painter.save()
        painter.setFont(self._text_font)
        pen.setColor(self._text_color)
        painter.setPen(pen)
        if self._show_text:
            painter.drawText(rect.adjusted(offset, offset, -offset, -offset), Qt.AlignCenter, str(self._value) + self._suffix_text)
        else:
            painter.drawText(rect.adjusted(offset, offset, -offset, -offset), Qt.AlignCenter, self._suffix_text)
        painter.restore()

        # Draw progress bar
        painter.save()
        pen.setWidth(self._dial_width)
        pen.setColor(self._progress_color)
        valueAngle = float(float(self._value - self._min_value) / float(self._max_value - self._min_value)) * float(spanAngle)  # Map value to angle range
        painter.setPen(pen)
        painter.drawArc(rect.adjusted(offset, offset, -offset, -offset), startAngle * 16, valueAngle * 16)
        painter.restore()
        painter.restore()

    @Property(str, notify=sizeChanged)
    def size(self):
        return self._size

    @size.setter
    def size(self, size):
        if self._size == size:
            return
        self._size = size
        self.sizeChanged.emit()

    @Property(int, notify=startAngleChanged)
    def startAngle(self):
        return self._start_angle

    @startAngle.setter
    def startAngle(self, angle):
        if self._start_angle == angle:
            return
        self._start_angle = angle
        self.startAngleChanged.emit()

    @Property(int, notify=spanAngleChanged)
    def spanAngle(self):
        return self._span_angle

    @spanAngle.setter
    def spanAngle(self, angle):
        if self._span_angle == angle:
            return
        self._span_angle = angle
        self.spanAngleChanged.emit()

    @Property(int, notify=minValueChanged)
    def minValue(self):
        return self._min_value

    @minValue.setter
    def minValue(self, value):
        if self._min_value == value:
            return
        self._min_value = value
        self.minValueChanged.emit()

    @Property(int, notify=maxValueChanged)
    def maxValue(self):
        return self._max_value

    @maxValue.setter
    def maxValue(self, value):
        if self._max_value == value:
            return
        self._max_value = value
        self.maxValueChanged.emit()

    @Property(float, notify=valueChanged)
    def value(self):
        return self._value

    @value.setter
    def value(self, value):
        if self._value == value:
            return
        self._value = value
        self.valueChanged.emit()

    @Property(float, notify=dialWidthChanged)
    def dialWidth(self):
        return self._dial_width

    @dialWidth.setter
    def dialWidth(self, width):
        if self._dial_width == width:
            return
        self._dial_width = width
        self.dialWidthChanged.emit()

    @Property(QColor, notify=backgroundColorChanged)
    def backgroundColor(self):
        return self._background_color

    @backgroundColor.setter
    def backgroundColor(self, color):
        if self._background_color == color:
            return
        self._background_color = color
        self.backgroundColorChanged.emit()

    @Property(QColor, notify=foregroundColorChanged)
    def foregroundColor(self):
        return self._ForegrounColor

    @foregroundColor.setter
    def foregroundColor(self, color):
        if self._dial_color == color:
            return
        self._dial_color = color
        self.foregroundColorChanged.emit()

    @Property(QColor, notify=progressColorChanged)
    def progressColor(self):
        return self._progress_color

    @progressColor.setter
    def progressColor(self, color):
        if self._progress_color == color:
            return
        self._progress_color = color
        self.progressColorChanged.emit()

    @Property(QColor, notify=textColorChanged)
    def textColor(self):
        return self._text_color

    @textColor.setter
    def textColor(self, color):
        if self._text_color == color:
            return
        self._text_color = color
        self.textColorChanged.emit()

    @Property(str, notify=suffixTextChanged)
    def suffixText(self):
        return self._suffix_text

    @suffixText.setter
    def suffixText(self, text):
        if self._suffix_text == text:
            return
        self._suffix_text = text
        self.suffixTextChanged.emit()

    @Property(str, notify=showTextChanged)
    def showText(self):
        return self._show_text

    @showText.setter
    def showText(self, show):
        if self._show_text == show:
            return
        self._show_text = show

    @Property(Qt.PenCapStyle, notify=penStyleChanged)
    def penStyle(self):
        return self._pen_style

    @penStyle.setter
    def penStyle(self, style):
        if self._pen_style == style:
            return
        self._pen_style = style
        self.penStyleChanged.emit()

    @Property(int, notify=dialTypeChanged)
    def dialType(self):
        return self._dial_type

    @dialType.setter
    def dialType(self, type):
        if self._dial_type == type:
            return
        self._dial_type = type
        self.dialTypeChanged.emit()

    @Property(QFont, notify=textFontChanged)
    def textFont(self):
        return self._text_font

    @textFont.setter
    def textFont(self, font):
        if self._text_font == font:
            return
        self._text_font = font
        self.textFontChanged.emit()