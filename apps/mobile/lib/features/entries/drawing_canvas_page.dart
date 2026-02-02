import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DrawingCanvasPage extends StatefulWidget {
  const DrawingCanvasPage({super.key});

  @override
  State<DrawingCanvasPage> createState() => _DrawingCanvasPageState();
}

class _DrawingCanvasPageState extends State<DrawingCanvasPage> {
  final _repaintKey = GlobalKey();
  final List<_Stroke> _strokes = [];
  final List<_CanvasText> _texts = [];
  Color _color = Colors.black;
  double _width = 3;
  bool _drawing = true;

  void _startStroke(Offset p) {
    setState(() {
      _strokes.add(_Stroke(points: [p], color: _color, width: _width));
    });
  }

  void _extendStroke(Offset p) {
    setState(() {
      _strokes.last.points.add(p);
    });
  }

  Future<void> _addText() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add text'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter text'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Add')),
        ],
      ),
    );

    if (text != null && text.isNotEmpty) {
      setState(() {
        _texts.add(_CanvasText(text: text, offset: const Offset(120, 160), color: _color));
      });
    }
  }

  Future<void> _save() async {
    final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final bytes = byteData.buffer.asUint8List();
    if (!mounted) return;
    Navigator.pop(context, bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing'),
        actions: [
          IconButton(onPressed: _addText, icon: const Icon(Icons.text_fields)),
          IconButton(onPressed: () => setState(() => _strokes.clear()), icon: const Icon(Icons.delete_outline)),
          IconButton(onPressed: _save, icon: const Icon(Icons.save)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: RepaintBoundary(
                key: _repaintKey,
                child: GestureDetector(
                  onPanStart: (d) {
                    if (_drawing) _startStroke(d.localPosition);
                  },
                  onPanUpdate: (d) {
                    if (_drawing && _strokes.isNotEmpty) _extendStroke(d.localPosition);
                  },
                  child: CustomPaint(
                    painter: _CanvasPainter(strokes: _strokes, texts: _texts),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Draw',
                    onPressed: () => setState(() => _drawing = true),
                    icon: Icon(Icons.brush, color: _drawing ? Colors.blue : Colors.grey),
                  ),
                  IconButton(
                    tooltip: 'Move text',
                    onPressed: () => setState(() => _drawing = false),
                    icon: Icon(Icons.open_with, color: !_drawing ? Colors.blue : Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<double>(
                    value: _width,
                    items: const [2, 3, 5, 8].map((w) => DropdownMenuItem(value: w.toDouble(), child: Text('${w}px'))).toList(),
                    onChanged: (v) => setState(() => _width = v ?? 3),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<Color>(
                    value: _color,
                    items: const [
                      Colors.black,
                      Colors.red,
                      Colors.green,
                      Colors.blue,
                      Colors.orange,
                    ].map((c) => DropdownMenuItem(value: c, child: Container(width: 20, height: 20, color: c))).toList(),
                    onChanged: (v) => setState(() => _color = v ?? Colors.black),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check),
                    label: const Text('Attach'),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stroke {
  _Stroke({required this.points, required this.color, required this.width});
  final List<Offset> points;
  final Color color;
  final double width;
}

class _CanvasText {
  _CanvasText({required this.text, required this.offset, required this.color});
  final String text;
  final Offset offset;
  final Color color;
}

class _CanvasPainter extends CustomPainter {
  _CanvasPainter({required this.strokes, required this.texts});

  final List<_Stroke> strokes;
  final List<_CanvasText> texts;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
      }
    }

    for (final t in texts) {
      final tp = TextPainter(
        text: TextSpan(text: t.text, style: TextStyle(color: t.color, fontSize: 18)),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);
      tp.paint(canvas, t.offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
