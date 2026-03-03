// lib/widgets/search_with_history_inline.dart
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';

// SECCIÓN 2: Declaración del Widget
class SearchWithHistoryInline extends StatefulWidget {
  final ValueChanged<String> onSearchSelected;
  const SearchWithHistoryInline({Key? key, required this.onSearchSelected})
    : super(key: key);

  @override
  _SearchWithHistoryInlineState createState() =>
      _SearchWithHistoryInlineState();
}

// SECCIÓN 3: Estado privado y variables
class _SearchWithHistoryInlineState extends State<SearchWithHistoryInline> {
  // Controladores y nodos
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlayEntry; // Entrada de overlay

  late final String _userId; // ID del usuario actual
  List<String> _historyList = []; // Historial completo
  List<String> _filteredHistory = []; // Historial filtrado
  // NUEVO: para dictado de voz
  late stt.SpeechToText _speech;
  bool _isListening = false;

  // SECCIÓN 4: Inicialización y carga de historial
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    // Obtenemos el userId
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    // Cargamos historial desde Firestore
    _loadHistory();

    // Listener para focus del TextField
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    // Limpiamos overlay y listeners
    _removeOverlay();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  // SECCIÓN 5: Manejador de focus (modificado)
  void _handleFocusChange() {
    if (_focusNode.hasFocus && _historyList.isNotEmpty) {
      // Sólo abre si existe historial
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  // SECCIÓN 6: Cargar historial de Firestore (modificada)
  Future<void> _loadHistory() async {
    if (_userId.isEmpty) return;
    final snap = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(_userId)
        .collection('searchHistory')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();

    _historyList = snap.docs
        .map((d) => (d.data() as Map<String, dynamic>)['text'] as String)
        .toList();

    _filteredHistory = List.from(_historyList);
    setState(() {}); // refresca el TextField, etc.
    _overlayEntry?.markNeedsBuild(); // obliga a rebuild del overlay
  }

  // SECCIÓN 7: Filtrar historial localmente
  void _filterHistory(String q) {
    _filteredHistory = _historyList
        .where((e) => e.toLowerCase().contains(q.toLowerCase()))
        .toList();
    _overlayEntry?.markNeedsBuild();
  }

  // SECCIÓN 8: Agregar término al historial en Firestore
  Future<void> _addToHistory(String text) async {
    if (_userId.isEmpty) return;
    final col = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(_userId)
        .collection('searchHistory');
    await col.add({'text': text, 'timestamp': FieldValue.serverTimestamp()});
    _loadHistory();
  }

  // SECCIÓN 8bis: Borrar todo el historial en Firestore (modificada)
  Future<void> _clearHistory() async {
    if (_userId.isEmpty) return;
    final col = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(_userId)
        .collection('searchHistory');
    final snap = await col.get();
    for (var doc in snap.docs) {
      await doc.reference.delete();
    }
    await _loadHistory(); // recarga y refuerza markNeedsBuild
  }

  // SECCIÓN 9: Enviar la búsqueda
  void _submit(String term) {
    if (term.trim().isEmpty) return;
    widget.onSearchSelected(term);
    _addToHistory(term.trim());
    _controller.clear();
    _focusNode.unfocus();
  }

  // SECCIÓN 9bis: Pedir permiso y luego inicializar SpeechToText
Future<bool> _requestMicPermission() async {
  final status = await Permission.microphone.request();
  return status.isGranted;
}

Future<void> _initSpeech() async {
  final granted = await _requestMicPermission();
  if (!granted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permiso de micrófono denegado')),
    );
    return;
  }
  bool available = await _speech.initialize(
    onStatus: (_) {},
    onError: (_) {},
  );
  if (!available) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reconocimiento de voz no disponible')),
    );
  }
}

// Inicia la escucha
void _startListening() async {
  await _initSpeech();
  if (!_isListening && await _speech.isAvailable) {
    setState(() => _isListening = true);
    _speech.listen(onResult: (result) {
      setState(() {
        _controller.text = result.recognizedWords;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
        _filterHistory(_controller.text);
      });

      // Lanzar búsqueda automáticamente cuando finaliza
      if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
        _stopListening();
        _submit(result.recognizedWords.trim());
      }
    });
  }
}


// SECCIÓN 9bis-ext: Detiene la escucha
void _stopListening() {
  if (_isListening) {
    _speech.stop();
    setState(() => _isListening = false);
  }
}


  // SECCIÓN 10: Mostrar / remover overlay
  void _showOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)!.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // SECCIÓN 11: Construir OverlayEntry (ajustes de redondeo)
  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 5,
        width: size.width, // mismo ancho que el campo
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16), // más redondeado
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              child: _historyList.isNotEmpty
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header con “Historial” y “Borrar”
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Historial',
                                style: TextStyle(
                                  color: Color(0xFFA50302),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: _clearHistory,
                                child: Text(
                                  'Borrar',
                                  style: TextStyle(
                                    color: Color(0xFFA50302),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Lista de historial
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: _filteredHistory.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final term = _filteredHistory[i];
                              return ListTile(
                                leading: const Icon(Icons.history, size: 20),
                                title: Text(term),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Color(0xFFA50302),
                                ),
                                onTap: () => _submit(term),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : // placeholder si no hay historial
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No hay historial',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // SECCIÓN 12: Construir la UI principal (añadido micrófono y redondeo)
  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Buscar productos...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: const Icon(Icons.search, color: Color(0xFFa6a6a6)),
            // Si no hay texto, mostramos micrófono; si hay, el botón de borrar
            suffixIcon: _controller.text.isEmpty 
    ? IconButton(
        icon: Icon(
          _isListening ? Icons.mic_off : Icons.mic,
          color: Color(0xFFA50302),
        ),
        onPressed: () {
          if (_isListening) {
            _stopListening();
          } else {
            _startListening();
          }
        },
      )
    : IconButton(
        icon: const Icon(Icons.clear, color: Color(0xFFA50302)),
        onPressed: () {
          _controller.clear();
          _filterHistory('');
        },
      ),


            filled: true,
            fillColor: Colors.white, // fondo blanco
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Color(0xFFA50302)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Color(0xFFb88917)),
            ),
          ),
          onChanged: (v) => _filterHistory(v),
          onSubmitted: _submit,
        ),
      ),
    );
  }
}
