import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '_image_painter.dart';
import '_ported_interactive_viewer.dart';
import 'widgets/_color_widget.dart';
import 'widgets/_mode_widget.dart';
import 'widgets/_range_slider.dart';
import 'widgets/_text_dialog.dart';

export '_image_painter.dart';

enum ControlsPosition {
  top, // Defines the controls position to the top
  bottom, // Defines the controls position to the bottom
  both, // Defines the controls position to both top and bottom
  none, // Defines the controls position to none (no controls)
}

///[ImagePainter] widget.
@immutable
class ImagePainter extends StatefulWidget {
  const ImagePainter._({
    Key? key,
    this.assetPath,
    this.networkUrl,
    this.byteArray,
    this.file,
    this.height,
    this.width,
    this.placeHolder,
    this.isScalable,
    this.brushIcon,
    this.clearAllIcon,
    this.colorIcon,
    this.undoIcon,
    this.isSignature = false,
    this.controlsPosition = ControlsPosition.top,
    this.signatureBackgroundColor,
    this.colors,
    this.initialPaintMode,
    this.initialColor,
    this.initialStrokeWidth,
    this.onChanged,
  }) : super(key: key);

  ///Constructor for loading image from network url.
  factory ImagePainter.network(
    String url, {
    required Key key,
    double? height,
    double? width,
    Widget? placeholderWidget,
    bool? scalable,
    List<Color>? colors,
    Widget? brushIcon,
    Widget? undoIcon,
    Widget? clearAllIcon,
    Widget? colorIcon,
    PaintMode? initialPaintMode,
    ControlsPosition? controlsPosition,
    Color? initialColor,
    double? initialStrokeWidth,
    ValueChanged<Uint8List?>? onChanged,
  }) {
    return ImagePainter._(
      key: key,
      networkUrl: url,
      height: height,
      width: width,
      placeHolder: placeholderWidget,
      colors: colors,
      brushIcon: brushIcon,
      undoIcon: undoIcon,
      colorIcon: colorIcon,
      clearAllIcon: clearAllIcon,
      initialPaintMode: initialPaintMode,
      controlsPosition: controlsPosition ?? ControlsPosition.top,
      initialColor: initialColor,
      onChanged: onChanged,
    );
  }

  ///Constructor for loading image from assetPath.
  factory ImagePainter.asset(
    String path, {
    required Key key,
    double? height,
    double? width,
    bool? scalable,
    Widget? placeholderWidget,
    List<Color>? colors,
    Widget? brushIcon,
    Widget? undoIcon,
    Widget? clearAllIcon,
    Widget? colorIcon,
    ControlsPosition? controlsPosition,
    PaintMode? initialPaintMode,
    Color? initialColor,
    double? initialStrokeWidth,
    ValueChanged<Uint8List?>? onChanged,
  }) {
    return ImagePainter._(
      key: key,
      assetPath: path,
      height: height,
      width: width,
      isScalable: scalable ?? false,
      placeHolder: placeholderWidget,
      colors: colors,
      brushIcon: brushIcon,
      undoIcon: undoIcon,
      colorIcon: colorIcon,
      clearAllIcon: clearAllIcon,
      initialPaintMode: initialPaintMode,
      controlsPosition: controlsPosition ?? ControlsPosition.top,
      initialColor: initialColor,
      initialStrokeWidth: initialStrokeWidth,
      onChanged: onChanged,
    );
  }

  ///Constructor for loading image from [File].
  factory ImagePainter.file(
    File file, {
    required Key key,
    double? height,
    double? width,
    bool? scalable,
    Widget? placeholderWidget,
    List<Color>? colors,
    Widget? brushIcon,
    Widget? undoIcon,
    Widget? clearAllIcon,
    Widget? colorIcon,
    ControlsPosition? controlsPosition,
    PaintMode? initialPaintMode,
    Color? initialColor,
    double? initialStrokeWidth,
    ValueChanged<Uint8List?>? onChanged,
  }) {
    return ImagePainter._(
      key: key,
      file: file,
      height: height,
      width: width,
      placeHolder: placeholderWidget,
      colors: colors,
      isScalable: scalable ?? false,
      brushIcon: brushIcon,
      undoIcon: undoIcon,
      colorIcon: colorIcon,
      clearAllIcon: clearAllIcon,
      initialPaintMode: initialPaintMode,
      controlsPosition: controlsPosition ?? ControlsPosition.top,
      initialColor: initialColor,
      initialStrokeWidth: initialStrokeWidth,
      onChanged: onChanged,
    );
  }

  ///Constructor for loading image from memory.
  factory ImagePainter.memory(
    Uint8List byteArray, {
    required Key key,
    double? height,
    double? width,
    bool? scalable,
    Widget? placeholderWidget,
    List<Color>? colors,
    Widget? brushIcon,
    Widget? undoIcon,
    Widget? clearAllIcon,
    Widget? colorIcon,
    PaintMode? initialPaintMode,
    ControlsPosition? controlsPosition,
    Color? initialColor,
    double? initialStrokeWidth,
    ValueChanged<Uint8List?>? onChanged,
  }) {
    return ImagePainter._(
      key: key,
      byteArray: byteArray,
      height: height,
      width: width,
      placeHolder: placeholderWidget,
      isScalable: scalable ?? false,
      colors: colors,
      brushIcon: brushIcon,
      undoIcon: undoIcon,
      colorIcon: colorIcon,
      clearAllIcon: clearAllIcon,
      initialPaintMode: initialPaintMode,
      controlsPosition: controlsPosition ?? ControlsPosition.top,
      initialColor: initialColor,
      initialStrokeWidth: initialStrokeWidth,
      onChanged: onChanged,
    );
  }

  ///Constructor for signature painting.
  factory ImagePainter.signature({
    required Key key,
    Color? signatureBgColor,
    double? height,
    double? width,
    List<Color>? colors,
    Widget? brushIcon,
    Widget? undoIcon,
    Widget? clearAllIcon,
    Widget? colorIcon,
    ValueChanged<Uint8List?>? onChanged,
  }) {
    return ImagePainter._(
      key: key,
      height: height,
      width: width,
      isSignature: true,
      isScalable: false,
      colors: colors,
      signatureBackgroundColor: signatureBgColor ?? Colors.white,
      brushIcon: brushIcon,
      undoIcon: undoIcon,
      colorIcon: colorIcon,
      clearAllIcon: clearAllIcon,
      controlsPosition: ControlsPosition.none,
      onChanged: onChanged,
    );
  }

  ///Only accessible through [ImagePainter.network] constructor.
  final String? networkUrl;

  ///Only accessible through [ImagePainter.memory] constructor.
  final Uint8List? byteArray;

  ///Only accessible through [ImagePainter.file] constructor.
  final File? file;

  ///Only accessible through [ImagePainter.asset] constructor.
  final String? assetPath;

  ///Height of the Widget. Image is subjected to fit within the given height.
  final double? height;

  ///Width of the widget. Image is subjected to fit within the given width.
  final double? width;

  ///Widget to be shown during the conversion of provided image to [ui.Image].
  final Widget? placeHolder;

  ///Defines whether the widget should be scaled or not. Defaults to [false].
  final bool? isScalable;

  ///Flag to determine signature or image;
  final bool isSignature;

  ///Signature mode background color
  final Color? signatureBackgroundColor;

  ///List of colors for color selection
  ///If not provided, default colors are used.
  final List<Color>? colors;

  ///Icon Widget of strokeWidth.
  final Widget? brushIcon;

  ///Widget of Color Icon in control bar.
  final Widget? colorIcon;

  ///Widget for Undo last action on control bar.
  final Widget? undoIcon;

  ///Widget for clearing all actions on control bar.
  final Widget? clearAllIcon;

  ///Define where the controls position
  /// defaults to top
  final ControlsPosition controlsPosition;

  ///Initial PaintMode.
  final PaintMode? initialPaintMode;

  ///Initial Color
  final Color? initialColor;

  ///Initial brush stroke width
  final double? initialStrokeWidth;

  ///Listener for image changes
  final ValueChanged<Uint8List?>? onChanged;

  @override
  ImagePainterState createState() => ImagePainterState();
}

///
class ImagePainterState extends State<ImagePainter> {
  final _repaintKey = GlobalKey();
  ui.Image? _image;
  bool _inDrag = false;
  final _paintHistory = <PaintInfo>[];
  final _points = <Offset?>[];
  late final ValueNotifier<Controller> _controller;
  late final ValueNotifier<bool> _isLoaded;
  late final TextEditingController _textController;
  Offset? _start, _end;
  int _strokeMultiplier = 1;

  Timer? _changeNotifier;

  @override
  void initState() {
    super.initState();
    _resolveAndConvertImage();
    if (widget.isSignature) {
      _controller = ValueNotifier(
          const Controller(mode: PaintMode.freeStyle, color: Colors.black));
    } else {
      _controller = ValueNotifier(const Controller().copyWith(
        mode: widget.initialPaintMode,
        color: widget.initialColor,
        strokeWidth: widget.initialStrokeWidth,
      ));
    }
    _textController = TextEditingController();
    _isLoaded = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _isLoaded.dispose();
    _textController.dispose();
    super.dispose();
  }

  Paint get _painter => Paint()
    ..color = _controller.value.color
    ..strokeWidth = _controller.value.strokeWidth * _strokeMultiplier
    ..style = _controller.value.mode == PaintMode.dashLine
        ? PaintingStyle.stroke
        : _controller.value.paintStyle;

  ///Converts the incoming image type from constructor to [ui.Image]
  Future<void> _resolveAndConvertImage() async {
    if (widget.networkUrl != null) {
      _image = await _loadNetworkImage(widget.networkUrl!);
      if (_image == null) {
        throw ("${widget.networkUrl} couldn't be resolved.");
      } else {
        _setStrokeMultiplier();
      }
    } else if (widget.assetPath != null) {
      final img = await rootBundle.load(widget.assetPath!);
      _image = await _convertImage(Uint8List.view(img.buffer));
      if (_image == null) {
        throw ("${widget.assetPath} couldn't be resolved.");
      } else {
        _setStrokeMultiplier();
      }
    } else if (widget.file != null) {
      final img = await widget.file!.readAsBytes();
      _image = await _convertImage(img);
      if (_image == null) {
        throw ("Image couldn't be resolved from provided file.");
      } else {
        _setStrokeMultiplier();
      }
    } else if (widget.byteArray != null) {
      _image = await _convertImage(widget.byteArray!);
      if (_image == null) {
        throw ("Image couldn't be resolved from provided byteArray.");
      } else {
        _setStrokeMultiplier();
      }
    } else {
      _isLoaded.value = true;
    }
  }

  ///Dynamically sets stroke multiplier on the basis of widget size.
  ///Implemented to avoid thin stroke on high res images.
  _setStrokeMultiplier() {
    if ((_image!.height + _image!.width) > 1000) {
      _strokeMultiplier = (_image!.height + _image!.width) ~/ 1000;
    }
  }

  ///Completer function to convert asset or file image to [ui.Image] before drawing on custompainter.
  Future<ui.Image> _convertImage(Uint8List img) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(img, (image) {
      _isLoaded.value = true;
      return completer.complete(image);
    });
    return completer.future;
  }

  ///Completer function to convert network image to [ui.Image] before drawing on custompainter.
  Future<ui.Image> _loadNetworkImage(String path) async {
    final completer = Completer<ImageInfo>();
    var img = NetworkImage(path);
    img.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completer.complete(info)));
    final imageInfo = await completer.future;
    _isLoaded.value = true;
    return imageInfo.image;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoaded,
      builder: (_, loaded, __) {
        if (loaded) {
          return widget.isSignature ? _paintSignature() : _paintImage();
        } else {
          return Container(
            height: widget.height ?? double.maxFinite,
            width: widget.width ?? double.maxFinite,
            child: Center(
              child: widget.placeHolder ?? const CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  ///paints image on given constrains for drawing if image is not null.
  Widget _paintImage() {
    return Container(
      height: widget.height ?? double.maxFinite,
      width: widget.width ?? double.maxFinite,
      child: Column(
        children: [
          if (widget.controlsPosition == ControlsPosition.top ||
              widget.controlsPosition == ControlsPosition.both)
            _buildControls(),
          Expanded(
            child: FittedBox(
              alignment: FractionalOffset.center,
              child: ClipRect(
                child: ValueListenableBuilder<Controller>(
                  valueListenable: _controller,
                  builder: (_, controller, __) {
                    return ImagePainterTransformer(
                      maxScale: 2.4,
                      minScale: 1,
                      panEnabled: controller.mode == PaintMode.none,
                      scaleEnabled: widget.isScalable!,
                      onInteractionUpdate: (details) =>
                          _scaleUpdateGesture(details, controller),
                      onInteractionEnd: (details) =>
                          _scaleEndGesture(details, controller),
                      child: CustomPaint(
                        size: Size(_image!.width.toDouble(),
                            _image!.height.toDouble()),
                        willChange: true,
                        isComplex: true,
                        painter: DrawImage(
                          image: _image,
                          points: _points,
                          paintHistory: _paintHistory,
                          isDragging: _inDrag,
                          update: UpdatePoints(
                              start: _start,
                              end: _end,
                              painter: _painter,
                              mode: controller.mode),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (widget.controlsPosition == ControlsPosition.bottom ||
              widget.controlsPosition == ControlsPosition.both)
            _buildControls(),
          SizedBox(height: MediaQuery.of(context).padding.bottom)
        ],
      ),
    );
  }

  Widget _paintSignature() {
    return RepaintBoundary(
      key: _repaintKey,
      child: ClipRect(
        child: Container(
          width: widget.width ?? double.maxFinite,
          height: widget.height ?? double.maxFinite,
          child: ValueListenableBuilder<Controller>(
            valueListenable: _controller,
            builder: (_, controller, __) {
              return ImagePainterTransformer(
                panEnabled: false,
                scaleEnabled: false,
                onInteractionStart: _scaleStartGesture,
                onInteractionUpdate: (details) =>
                    _scaleUpdateGesture(details, controller),
                onInteractionEnd: (details) =>
                    _scaleEndGesture(details, controller),
                child: CustomPaint(
                  willChange: true,
                  isComplex: true,
                  painter: DrawImage(
                    isSignature: true,
                    backgroundColor: widget.signatureBackgroundColor,
                    points: _points,
                    paintHistory: _paintHistory,
                    isDragging: _inDrag,
                    update: UpdatePoints(
                        start: _start,
                        end: _end,
                        painter: _painter,
                        mode: controller.mode),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  _scaleStartGesture(ScaleStartDetails onStart) {
    _changeNotifier?.cancel();

    setState(() {
      _start = onStart.focalPoint;
      _points.add(_start);
    });
  }

  ///Fires while user is interacting with the screen to record painting.
  void _scaleUpdateGesture(ScaleUpdateDetails onUpdate, Controller ctrl) {
    _changeNotifier?.cancel();

    setState(
      () {
        _inDrag = true;
        _start ??= onUpdate.focalPoint;
        _end = onUpdate.focalPoint;
        if (ctrl.mode == PaintMode.freeStyle) _points.add(_end);
        if (ctrl.mode == PaintMode.text &&
            _paintHistory
                .where((element) => element.mode == PaintMode.text)
                .isNotEmpty) {
          _paintHistory
              .lastWhere((element) => element.mode == PaintMode.text)
              .offset = [_end];
        }
      },
    );
  }

  ///Fires when user stops interacting with the screen.
  void _scaleEndGesture(ScaleEndDetails onEnd, Controller controller) {
    _changeNotifier?.cancel();

    setState(() {
      _inDrag = false;
      if (_start != null &&
          _end != null &&
          (controller.mode == PaintMode.freeStyle)) {
        _points.add(null);
        _addFreeStylePoints();
        _points.clear();
      } else if (_start != null &&
          _end != null &&
          controller.mode != PaintMode.text) {
        _addEndPoints();
      }
      _start = null;
      _end = null;
    });
  }

  void _addEndPoints() => _addPath(
        PaintInfo(
          offset: <Offset?>[_start, _end],
          painter: _painter,
          mode: _controller.value.mode,
        ),
      );

  void _addFreeStylePoints() => _addPath(
        PaintInfo(
          offset: <Offset?>[..._points],
          painter: _painter,
          mode: PaintMode.freeStyle,
        ),
      );

  ///Provides [ui.Image] of the recorded canvas to perform action.
  Future<ui.Image> _renderImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = DrawImage(image: _image, paintHistory: _paintHistory);
    final size = Size(_image!.width.toDouble(), _image!.height.toDouble());
    painter.paint(canvas, size);
    return recorder
        .endRecording()
        .toImage(size.width.floor(), size.height.floor());
  }

  PopupMenuItem _showOptionsRow(Controller controller) {
    return PopupMenuItem(
      enabled: false,
      child: Center(
        child: SizedBox(
          child: Wrap(
            children: paintModes
                .map(
                  (item) => SelectionItems(
                    data: item,
                    isSelected: controller.mode == item.mode,
                    onTap: () {
                      _controller.value = controller.copyWith(mode: item.mode);
                      Navigator.of(context).pop();
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  PopupMenuItem _showRangeSlider() {
    return PopupMenuItem(
      enabled: false,
      child: SizedBox(
        width: double.maxFinite,
        child: ValueListenableBuilder<Controller>(
          valueListenable: _controller,
          builder: (_, ctrl, __) {
            return RangedSlider(
              value: ctrl.strokeWidth,
              onChanged: (value) =>
                  _controller.value = ctrl.copyWith(strokeWidth: value),
            );
          },
        ),
      ),
    );
  }

  PopupMenuItem _showColorPicker(Controller controller) {
    return PopupMenuItem(
        enabled: false,
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: (widget.colors ?? editorColors).map((color) {
              return ColorItem(
                isSelected: color == controller.color,
                color: color,
                onTap: () {
                  _controller.value = controller.copyWith(color: color);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ));
  }

  ///Generates [Uint8List] of the [ui.Image] generated by the [renderImage()] method.
  ///Can be converted to image file by writing as bytes.
  Future<Uint8List?> exportImage() async {
    late ui.Image _convertedImage;
    if (widget.isSignature) {
      final _boundary = _repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      _convertedImage = await _boundary.toImage(pixelRatio: 3);
    } else if (widget.byteArray != null && _paintHistory.isEmpty) {
      return widget.byteArray;
    } else {
      _convertedImage = await _renderImage();
    }
    final byteData =
        await _convertedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  void _openTextDialog() {
    _controller.value = _controller.value.copyWith(mode: PaintMode.text);
    final fontSize = 6 * _controller.value.strokeWidth;

    TextDialog.show(context, _textController, fontSize, _controller.value.color,
        onFinished: () {
      if (_textController.text != '') {
        setState(() {
          _addPath(
            PaintInfo(
                mode: PaintMode.text,
                text: _textController.text,
                painter: _painter,
                offset: []),
          );
        });
        _textController.clear();
      }
      Navigator.pop(context);
    });
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(4),
      color: Colors.grey[200],
      child: Row(
        children: [
          ValueListenableBuilder<Controller>(
              valueListenable: _controller,
              builder: (_, _ctrl, __) {
                return PopupMenuButton(
                  tooltip: "Change mode",
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  icon: Icon(
                      paintModes
                          .firstWhere((item) => item.mode == _ctrl.mode)
                          .icon,
                      color: Colors.grey[700]),
                  itemBuilder: (_) => [_showOptionsRow(_ctrl)],
                );
              }),
          ValueListenableBuilder<Controller>(
              valueListenable: _controller,
              builder: (_, controller, __) {
                return PopupMenuButton(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  tooltip: "Change color",
                  icon: widget.colorIcon ??
                      Container(
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                          color: controller.color,
                        ),
                      ),
                  itemBuilder: (_) => [_showColorPicker(controller)],
                );
              }),
          PopupMenuButton(
            tooltip: "Change Brush Size",
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            icon:
                widget.brushIcon ?? Icon(Icons.brush, color: Colors.grey[700]),
            itemBuilder: (_) => [_showRangeSlider()],
          ),
          IconButton(
              icon: const Icon(Icons.text_format), onPressed: _openTextDialog),
          const Spacer(),
          IconButton(
              tooltip: "Undo",
              icon:
                  widget.undoIcon ?? Icon(Icons.reply, color: Colors.grey[700]),
              onPressed: () {
                if (_paintHistory.isNotEmpty) {
                  setState(_paintHistory.removeLast);
                }
              }),
          IconButton(
            tooltip: "Clear all progress",
            icon: widget.clearAllIcon ??
                Icon(Icons.clear, color: Colors.grey[700]),
            onPressed: () => setState(_paintHistory.clear),
          ),
        ],
      ),
    );
  }

  _addPath(PaintInfo paintInfo) {
    _paintHistory.add(paintInfo);

    if (widget.onChanged != null) {
      _changeNotifier = Timer(const Duration(milliseconds: 500), () async {
        Uint8List? image = await exportImage();

        widget.onChanged!(image);
      });
    }
  }
}

///Gives access to manipulate the essential components like [strokeWidth], [Color] and [PaintMode].
@immutable
class Controller {
  ///Tracks [strokeWidth] of the [Paint] method.
  final double strokeWidth;

  ///Tracks [Color] of the [Paint] method.
  final Color color;

  ///Tracks [PaintingStyle] of the [Paint] method.
  final PaintingStyle paintStyle;

  ///Tracks [PaintMode] of the current [Paint] method.
  final PaintMode mode;

  ///Any text.
  final String text;

  ///Constructor of the [Controller] class.
  const Controller(
      {this.strokeWidth = 4.0,
      this.color = Colors.red,
      this.mode = PaintMode.line,
      this.paintStyle = PaintingStyle.stroke,
      this.text = ""});

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Controller &&
        o.strokeWidth == strokeWidth &&
        o.color == color &&
        o.paintStyle == paintStyle &&
        o.mode == mode &&
        o.text == text;
  }

  @override
  int get hashCode {
    return strokeWidth.hashCode ^
        color.hashCode ^
        paintStyle.hashCode ^
        mode.hashCode ^
        text.hashCode;
  }

  ///copyWith Method to access immutable controller.
  Controller copyWith(
      {double? strokeWidth,
      Color? color,
      PaintMode? mode,
      PaintingStyle? paintingStyle,
      String? text}) {
    return Controller(
        strokeWidth: strokeWidth ?? this.strokeWidth,
        color: color ?? this.color,
        mode: mode ?? this.mode,
        paintStyle: paintingStyle ?? paintStyle,
        text: text ?? this.text);
  }
}
