import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/lore_dialogue.dart';
import 'dialogue_avatar.dart';

class DialogueOverlay extends StatefulWidget {
  final List<DialogueNode> dialogueSequence;
  final VoidCallback onComplete;

  const DialogueOverlay({
    super.key,
    required this.dialogueSequence,
    required this.onComplete,
  });

  @override
  State<DialogueOverlay> createState() => _DialogueOverlayState();
}

class _DialogueOverlayState extends State<DialogueOverlay> {
  int _currentIndex = 0;
  String _displayedText = "";
  bool _isTyping = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  void _startTyping() {
    _typingTimer?.cancel();
    _displayedText = "";
    _isTyping = true;

    final targetText = widget.dialogueSequence[_currentIndex].text;
    int charIndex = 0;

    _typingTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (charIndex < targetText.length) {
        setState(() {
          _displayedText += targetText[charIndex];
        });
        charIndex++;
        // Cybernetic typing haptic feedback
        if (charIndex % 3 == 0) {
          HapticFeedback.selectionClick();
        }
      } else {
        timer.cancel();
        setState(() {
          _isTyping = false;
        });
      }
    });
  }

  void _skipTyping() {
    _typingTimer?.cancel();
    setState(() {
      _displayedText = widget.dialogueSequence[_currentIndex].text;
      _isTyping = false;
    });
    HapticFeedback.mediumImpact();
  }

  void _progressDialogue() {
    if (_isTyping) {
      _skipTyping();
      return;
    }

    HapticFeedback.lightImpact();
    if (_currentIndex < widget.dialogueSequence.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startTyping();
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.dialogueSequence[_currentIndex];
    final speakerName = _getSpeakerName(node.speaker);
    final themeColor = _getCharacterColor(node.speaker);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: SafeArea(
          child: Stack(
            children: [
              // Absolute Close/Skip Button on top right
              Positioned(
                top: 16,
                right: 16,
                child: SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      widget.onComplete();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF2E93),
                      side: const BorderSide(color: Color(0xFFFF2E93), width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text(
                      "SKIP DIALOGUE",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

              // Tactical Transmission Active label top center
              Positioned(
                top: 22,
                left: 16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00FFF5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "SECURE FREQUENCY ESTABLISHED // COMLINK HUD",
                      style: TextStyle(
                        color: Color(0xFF00FFF5),
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              // Avatars & Comlink Panel Layout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Dialogue Avatars Row (Floating in mid-lower screen)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Left Speaker (Dax Sterling)
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 250),
                            opacity: node.isLeft ? 1.0 : 0.20,
                            child: Transform.scale(
                              scale: node.isLeft ? 1.05 : 0.95,
                              child: const DialogueAvatar(
                                character: Character.dax,
                                emotion: Emotion.calm, // emotion is computed dynamically in paint if needed, but calm is good default
                              ),
                            ),
                          ),

                          // Right Speaker (Adversaries)
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 250),
                            opacity: !node.isLeft ? 1.0 : 0.20,
                            child: Transform.scale(
                              scale: !node.isLeft ? 1.05 : 0.95,
                              child: DialogueAvatar(
                                character: node.speaker == Character.dax ? Character.vance : node.speaker,
                                emotion: node.emotion,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Main Glassmorphic Comlink Dialogue Card
                    GestureDetector(
                      onTap: _progressDialogue,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 135, maxHeight: 180),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B0E14).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: themeColor.withOpacity(0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: themeColor.withOpacity(0.1),
                              blurRadius: 16,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Dialogue Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  speakerName.toUpperCase(),
                                  style: TextStyle(
                                    color: themeColor,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: themeColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    node.emotion.name.toUpperCase(),
                                    style: TextStyle(
                                      color: themeColor,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 1.0,
                              color: themeColor.withOpacity(0.2),
                            ),
                            const SizedBox(height: 12),

                            // Dialogue Content Body
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  _displayedText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontFamily: 'monospace',
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Bottom Navigation Indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "TRANSMISSION NODE ${_currentIndex + 1}/${widget.dialogueSequence.length}",
                                  style: TextStyle(
                                    color: Colors.grey.withOpacity(0.5),
                                    fontSize: 8,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (_isTyping)
                                      Text(
                                        "TAP TO SKIP TYPING",
                                        style: TextStyle(
                                          color: themeColor.withOpacity(0.4),
                                          fontSize: 8,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    else
                                      Text(
                                        _currentIndex < widget.dialogueSequence.length - 1
                                            ? "TAP TO CONTINUE"
                                            : "TAP TO COMMENCE DECK",
                                        style: TextStyle(
                                          color: themeColor,
                                          fontSize: 8,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_right,
                                      color: themeColor,
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSpeakerName(Character speaker) {
    switch (speaker) {
      case Character.dax:
        return "Capt. Dax Sterling // Rebel Dreadnought";
      case Character.vance:
        return "Grand Moff Vance // Imperial Fleet Cmd";
      case Character.kael:
        return "Commander Kael // Imperial Sector Core";
      case Character.vex:
        return "Syndicate Boss Vex // Black Sun Guild";
      case Character.sol:
        return "Major Sol // Spatial Operations Div";
    }
  }

  Color _getCharacterColor(Character speaker) {
    switch (speaker) {
      case Character.dax:
        return const Color(0xFF00FFF5);
      case Character.vance:
        return const Color(0xFFFF1744);
      case Character.kael:
        return const Color(0xFF69F0AE);
      case Character.vex:
        return const Color(0xFFFF9F1C);
      case Character.sol:
        return const Color(0xFF2979FF);
    }
  }
}
