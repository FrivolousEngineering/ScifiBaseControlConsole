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
        self.valueChanged.connect(self.update)
        self.progressColorChanged.connect(self.update)
        self.foregroundColorChanged.connect(self.update)

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

    def setSize(self, size):
        if self._size == size:
            return
        self._size = size
        self.sizeChanged.emit()

    @Property(str, notify=sizeChanged, fset=setSize)
    def size(self):
        return self._size

    def setStartAngle(self, angle):
        if self._start_angle == angle:
            return
        self._start_angle = angle
        self.startAngleChanged.emit()

    @Property(int, notify=startAngleChanged, fset=setStartAngle)
    def startAngle(self):
        return self._start_angle

    def setSpanAngle(self, angle):
        if self._span_angle == angle:
            return
        self._span_angle = angle
        self.spanAngleChanged.emit()

    @Property(int, notify=spanAngleChanged, fset=setSpanAngle)
    def spanAngle(self):
        return self._span_angle

    def setMinValue(self, value):
        if self._min_value == value:
            return
        self._min_value = value
        self.minValueChanged.emit()

    @Property(int, notify=minValueChanged, fset=setMinValue)
    def minValue(self):
        return self._min_value

    def setMaxValue(self, value):
        if self._max_value == value:
            return
        self._max_value = value
        self.maxValueChanged.emit()

    @Property(int, notify=maxValueChanged, fset=setMaxValue)
    def maxValue(self):
        return self._max_value

    def setValue(self, value):
        if self._value == value:
            return
        self._value = value
        self.valueChanged.emit()

    @Property(float, notify=valueChanged, fset=setValue)
    def value(self):
        return self._value

    def setDialWidth(self, width):
        if self._dial_width == width:
            return
        self._dial_width = width
        self.dialWidthChanged.emit()

    @Property(float, notify=dialWidthChanged, fset=setDialWidth)
    def dialWidth(self):
        return self._dial_width

    def setBackgroundColor(self, color):
        if self._background_color == color:
            return
        self._background_color = color
        self.backgroundColorChanged.emit()

    @Property(QColor, notify=backgroundColorChanged, fset=setBackgroundColor)
    def backgroundColor(self):
        return self._background_color

    def setForegroundColor(self, color):
        if self._dial_color == color:
            return
        self._dial_color = color
        self.foregroundColorChanged.emit()

    @Property(QColor, notify=foregroundColorChanged, fset=setForegroundColor)
    def foregroundColor(self):
        return self._dial_color

    def setProgressColor(self, color):
        if self._progress_color == color:
            return
        self._progress_color = color
        self.progressColorChanged.emit()

    @Property(QColor, notify=progressColorChanged, fset=setProgressColor)
    def progressColor(self):
        return self._progress_color

    def setTextColor(self, color):
        if self._text_color == color:
            return
        self._text_color = color
        self.textColorChanged.emit()

    @Property(QColor, notify=textColorChanged, fset=setTextColor)
    def textColor(self):
        return self._text_color

    def setSuffixText(self, text):
        if self._suffix_text == text:
            return
        self._suffix_text = text
        self.suffixTextChanged.emit()

    @Property(str, notify=suffixTextChanged, fset=setSuffixText)
    def suffixText(self):
        return self._suffix_text

    def setShowText(self, show):
        if self._show_text == show:
            return
        self._show_text = show

    @Property(bool, notify=showTextChanged, fset=setShowText)
    def showText(self):
        return self._show_text

    def setPenStyle(self, style):
        if self._pen_style == style:
            return
        self._pen_style = style
        self.penStyleChanged.emit()

    @Property(Qt.PenCapStyle, notify=penStyleChanged, fset=setPenStyle)
    def penStyle(self):
        return self._pen_style

    def setDialType(self, type):
        if self._dial_type == type:
            return
        self._dial_type = type
        self.dialTypeChanged.emit()

    @Property(int, notify=dialTypeChanged, fset=setDialType)
    def dialType(self):
        return self._dial_type

    def setTextFont(self, font):
        if self._text_font == font:
            return
        self._text_font = font
        self.textFontChanged.emit()

    @Property(QFont, notify=textFontChanged)
    def textFont(self):
        return self._text_font