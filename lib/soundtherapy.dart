import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'dart:io';

class SoundTherapyScreen extends StatefulWidget {
  @override
  _SoundTherapyScreenState createState() => _SoundTherapyScreenState();
}

class _SoundTherapyScreenState extends State<SoundTherapyScreen> {
  final Map<String, AudioPlayer> _players = {};
  final Map<String, bool> _playingStatus = {};
  final Map<String, double> _volumes = {};
  final Map<String, String> _audioPaths = {};
  final Map<String, IconData> _icons = {};
  final Map<String, Color> _colors = {};
  final Map<String, bool> _isCustomSound = {}; // Track custom sounds

  final Set<int> _usedRecordingIds = <int>{}; // Track used IDs
  bool _isInitialized = false; // Add initialization flag

  final List<Map<String, dynamic>> _defaultSounds = [
    {
      'name': 'Rain',
      'path': 'assets/audio/rain.mp3',
      'icon': Icons.cloud_rounded,
      'color': Color(0xFF64B5F6),
    },
    {
      'name': 'Water Stream',
      'path': 'assets/audio/water_stream.mp3',
      'icon': Icons.waves_rounded,
      'color': Color.fromARGB(255, 95, 134, 167),
    },
    {
      'name': 'Ocean Waves',
      'path': 'assets/audio/ocean.mp3',
      'icon': Icons.water_rounded,
      'color': Colors.blueGrey,
    },
    {
      'name': 'Birds',
      'path': 'assets/audio/birds.mp3',
      'icon': Icons.flare_rounded,
      'color': Color(0xFF4DB6AC),
    },
    {
      'name': 'Crickets',
      'path': 'assets/audio/cricket.mp3',
      'icon': Icons.grass_rounded,
      'color': Color.fromARGB(255, 76, 139, 83),
    },
    {
      'name': 'Guitar',
      'path': 'assets/audio/guitar.mp3',
      'icon': Icons.music_note_rounded,
      'color': Color(0xFF81C784),
    },
    {
      'name': 'Frog',
      'path': 'assets/audio/frog_sound.mp3',
      'icon': Icons.spa_rounded,
      'color': Color.fromARGB(255, 105, 34, 176),
    },
    {
      'name': 'Thunder',
      'path': 'assets/audio/thunder_beat.mp3',
      'icon': Icons.flash_on_rounded,
      'color': Color.fromARGB(255, 77, 135, 182),
    },
    {
      'name': 'Piano',
      'path': 'assets/audio/soft_piano.mp3',
      'icon': Icons.piano_rounded,
      'color': Color.fromARGB(255, 152, 148, 35),
    },
    {
      'name': 'Binaural',
      'path': 'assets/audio/binaural.mp3',
      'icon': Icons.headphones_rounded,
      'color': Color.fromARGB(255, 220, 122, 242),
    },
    {
      'name': 'Soft Piano',
      'path': 'assets/audio/soft_piano_2.mp3',
      'icon': Icons.piano_outlined,
      'color': Color.fromARGB(255, 180, 20, 137),
    },
    {
      'name': 'Fire Crackling',
      'path': 'assets/audio/fire_crackling.mp3',
      'icon': Icons.local_fire_department_rounded,
      'color': Color.fromARGB(255, 180, 20, 20),
    },
    {
      'name': 'Peaceful',
      'path': 'assets/audio/peaceful.mp3',
      'icon': Icons.self_improvement_rounded,
      'color': Color.fromARGB(255, 156, 163, 242),
    },
  ];

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration.music());

      // Load default sounds
      for (var soundData in _defaultSounds) {
        String soundName = soundData['name'];
        String path = soundData['path'];
        IconData icon = soundData['icon'];
        Color color = soundData['color'];

        final player = AudioPlayer();
        await player.setAsset(path);
        player.setLoopMode(LoopMode.all);
        player.setVolume(0.6);

        _players[soundName] = player;
        _playingStatus[soundName] = false;
        _volumes[soundName] = 0.6;
        _icons[soundName] = icon;
        _colors[soundName] = color;
        _audioPaths[soundName] = path;
        _isCustomSound[soundName] = false;
      }

      // ✅ Load previously saved custom sounds
      await _loadCustomSounds();
    } catch (e) {
      print('Error initializing audio: $e');
    } finally {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _toggleSound(String sound) {
    final player = _players[sound];
    if (player == null) return;

    final isPlaying = _playingStatus[sound] ?? false;

    setState(() {
      _playingStatus[sound] = !isPlaying;
    });

    if (isPlaying) {
      player.stop();
    } else {
      player.play();
    }
  }

  void _updateVolume(String sound, double value) {
    setState(() {
      _volumes[sound] = value;
      _players[sound]?.setVolume(value);
    });
    if (_isCustomSound[sound] == true) {
      _saveCustomSounds(); // persist volume for custom items
    }
  }

  // Get next available recording ID - Fixed logic
  int _getNextRecordingId() {
    // Find the lowest available ID starting from 1
    int id = 1;
    while (_usedRecordingIds.contains(id)) {
      id++;
    }
    return id; // Don't add to set yet - do it when recording is successful
  }

  /// 🎤 Start/Stop Recording
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      if (path != null) {
        final recordingId = _getNextRecordingId();
        // Only add to used IDs when recording is successful
        _usedRecordingIds.add(recordingId);
        await _addCustomSound(
          "Audio $recordingId", // Fixed naming
          path,
          Icons.mic_rounded,
          Color(0xFFFF6B6B),
          isRecording: true,
          recordingId: recordingId,
        );
      }
      setState(() => _isRecording = false);
    } else {
      if (await _recorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final filePath =
            "${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a";

        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
          path: filePath,
        );

        setState(() => _isRecording = true);
      }
    }
  }

  /// ➕ Pick Music from Local Storage
  Future<void> _pickLocalFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      String displayName = result.files.single.name;

      // Remove file extension and truncate if too long
      displayName = displayName.split('.').first;
      if (displayName.length > 20) {
        displayName = displayName.substring(0, 20) + '...';
      }

      // Copy file to app directory to prevent access issues
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'imported_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
      final newFile = File('${dir.path}/$fileName');
      await file.copy(newFile.path);

      await _addCustomSound(
        displayName,
        newFile.path,
        Icons.library_music_rounded,
        Color(0xFF4ECDC4),
      );
    }
  }

  /// Add new custom sound tile
  Future<void> _addCustomSound(
    String name,
    String path,
    IconData icon,
    Color color, {
    bool isRecording = false,
    int? recordingId,
  }) async {
    final player = AudioPlayer();

    try {
      // Use setFilePath for file-based audio to avoid caching issues
      await player.setFilePath(path);
      player.setLoopMode(LoopMode.all);
      player.setVolume(0.6);

      setState(() {
        _players[name] = player;
        _playingStatus[name] = false;
        _volumes[name] = 0.6;
        _icons[name] = icon;
        _colors[name] = color;
        _audioPaths[name] = path;
        _isCustomSound[name] = true; // Mark as custom sound
      });

      await _saveCustomSounds();
    } catch (e) {
      print('Error adding custom sound: $e');
      // Show error to user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading audio file: $e')));
    }
  }

  /// Remove custom sound and delete file - Fixed ID management
  Future<void> _removeCustomSound(String soundName) async {
    try {
      // Stop and dispose player first
      final player = _players[soundName];
      if (player != null) {
        await player.stop();
        await player.dispose();
      }

      // Delete the actual file if it's a custom sound
      final filePath = _audioPaths[soundName];
      if (filePath != null && _isCustomSound[soundName] == true) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }

        // If it's a recording, remove the ID from used set - Fixed regex
        if (soundName.startsWith('Audio ')) {
          final idMatch = RegExp(r'Audio (\d+)').firstMatch(soundName);
          if (idMatch != null) {
            final id = int.parse(idMatch.group(1)!);
            _usedRecordingIds.remove(id); // Free up the number
          }
        }
      }

      // Remove from all maps
      setState(() {
        _playingStatus.remove(soundName);
        _volumes.remove(soundName);
        _icons.remove(soundName);
        _colors.remove(soundName);
        _audioPaths.remove(soundName);
        _isCustomSound.remove(soundName);
        _players.remove(soundName);
      });
      await _saveCustomSounds();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$soundName removed successfully')),
      );
    } catch (e) {
      print('Error removing custom sound: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error removing sound: $e')));
    }
  }

  /// Rename sound
  void _showRenameDialog(String currentName) {
    if (_isCustomSound[currentName] != true) {
      return; // Only allow renaming custom sounds
    }

    final TextEditingController controller = TextEditingController(
      text: currentName,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Rename Sound'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'New name',
                border: OutlineInputBorder(),
              ),
              maxLength: 30,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newName = controller.text.trim();
                  if (newName.isNotEmpty && newName != currentName) {
                    _renameSound(currentName, newName);
                  }
                  Navigator.pop(context);
                },
                child: Text('Rename'),
              ),
            ],
          ),
    );
  }

  /// Rename a custom sound
  void _renameSound(String oldName, String newName) {
    if (_players.containsKey(newName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('A sound with that name already exists')),
      );
      return;
    }

    setState(() {
      // Transfer all properties to new name
      _players[newName] = _players[oldName]!;
      _playingStatus[newName] = _playingStatus[oldName]!;
      _volumes[newName] = _volumes[oldName]!;
      _icons[newName] = _icons[oldName]!;
      _colors[newName] = _colors[oldName]!;
      _audioPaths[newName] = _audioPaths[oldName]!;
      _isCustomSound[newName] = _isCustomSound[oldName]!;

      // Remove old entries
      _players.remove(oldName);
      _playingStatus.remove(oldName);
      _volumes.remove(oldName);
      _icons.remove(oldName);
      _colors.remove(oldName);
      _audioPaths.remove(oldName);
      _isCustomSound.remove(oldName);
    });
    _saveCustomSounds();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Renamed to "$newName"')));
  }

  @override
  void dispose() {
    for (var player in _players.values) {
      player.dispose();
    }
    _recorder.dispose();
    super.dispose();
  }

  Widget _buildSoundCard(String sound, bool isTablet) {
    final isActive = _playingStatus[sound] ?? false;
    final icon = _icons[sound] ?? Icons.music_note_rounded;
    final volume = _volumes[sound] ?? 0.6;
    final soundColor = _colors[sound] ?? Colors.blueAccent;
    final isCustom = _isCustomSound[sound] ?? false;

    return Container(
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.8),
            Colors.white.withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            soundColor.withOpacity(0.3),
                            soundColor.withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(
                          color: soundColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(icon, color: soundColor, size: 28),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: isCustom ? () => _showRenameDialog(sound) : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    sound,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                      letterSpacing: 0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isCustom)
                                  Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              isActive ? "Playing" : "Paused",
                              style: TextStyle(
                                fontSize: 14,
                                color: isActive ? soundColor : Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isCustom)
                      Container(
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.red.withOpacity(0.2),
                              Colors.red.withOpacity(0.1),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: Colors.red[400],
                          ),
                          onPressed: () => _removeCustomSound(sound),
                        ),
                      ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors:
                              isActive
                                  ? [
                                    soundColor.withOpacity(0.3),
                                    soundColor.withOpacity(0.1),
                                  ]
                                  : [
                                    Colors.grey.withOpacity(0.2),
                                    Colors.grey.withOpacity(0.1),
                                  ],
                        ),
                        border: Border.all(
                          color:
                              isActive
                                  ? soundColor.withOpacity(0.4)
                                  : Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          isActive
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 28,
                          color: isActive ? soundColor : Colors.grey[600],
                        ),
                        onPressed: () => _toggleSound(sound),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Volume",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "${(volume * 100).round()}%",
                          style: TextStyle(
                            fontSize: 14,
                            color: soundColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 6,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 12,
                        ),
                        overlayShape: RoundSliderOverlayShape(
                          overlayRadius: 20,
                        ),
                        activeTrackColor: soundColor,
                        inactiveTrackColor: Colors.grey[300],
                        thumbColor: soundColor,
                        overlayColor: soundColor.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: volume,
                        onChanged: (val) => _updateVolume(sound, val),
                        min: 0.0,
                        max: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fixed floating buttons positioning
  Widget _buildFloatingButtons() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        // Changed from Row to Column for vertical stacking
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "addMusicBtn",
            backgroundColor: const Color.fromARGB(255, 178, 149, 227),
            onPressed: _pickLocalFile,
            child: Icon(Icons.library_music),
          ),
          SizedBox(height: 16), // Changed from width to height
          FloatingActionButton(
            heroTag: "recordBtn",
            backgroundColor:
                _isRecording
                    ? Colors.red
                    : const Color.fromARGB(255, 133, 212, 204),
            onPressed: _toggleRecording,
            child: Icon(_isRecording ? Icons.stop : Icons.mic),
          ),
        ],
      ),
    );
  }

  Future<File> _getCustomSoundsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/custom_sounds.json');
  }

  Future<void> _saveCustomSounds() async {
    try {
      final file = await _getCustomSoundsFile();
      final entries =
          _players.keys
              .where((k) => _isCustomSound[k] == true)
              .map(
                (name) => {
                  'name': name,
                  'path': _audioPaths[name],
                  'icon': _icons[name]?.codePoint,
                  'color': _colors[name]?.value,
                  'volume': _volumes[name],
                },
              )
              .toList();
      await file.writeAsString(jsonEncode(entries));
    } catch (e) {
      print('Error saving custom sounds: $e');
    }
  }

  Future<void> _loadCustomSounds() async {
    try {
      final file = await _getCustomSoundsFile();
      if (!await file.exists()) return;

      final jsonStr = await file.readAsString();
      final List list = jsonDecode(jsonStr);

      for (final item in list) {
        final name = item['name'] as String;
        final path = item['path'] as String;
        final icon = IconData(item['icon'] as int, fontFamily: 'MaterialIcons');
        final color = Color(item['color'] as int);
        final volume = (item['volume'] as num?)?.toDouble() ?? 0.6;

        final p = AudioPlayer();
        await p.setFilePath(path);
        await p.setLoopMode(LoopMode.all);
        await p.setVolume(volume);

        _players[name] = p;
        _playingStatus[name] = false;
        _volumes[name] = volume;
        _icons[name] = icon;
        _colors[name] = color;
        _audioPaths[name] = path;
        _isCustomSound[name] = true;

        final m = RegExp(r'^Audio (\d+)$').firstMatch(name);
        if (m != null) {
          _usedRecordingIds.add(int.parse(m.group(1)!));
        }
      }
    } catch (e) {
      print('Error loading custom sounds: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final crossAxisCount = isTablet ? 2 : 1;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F4F8), Color(0xFFE8F3F8), Color(0xFFF5F8FA)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Custom App Bar
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.withOpacity(0.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.grey[700],
                              size: 18,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sound Therapy',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[800],
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'Create your own sound therapy and relax',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sound Cards Grid or Loading Indicator
                  Expanded(
                    child:
                        _isInitialized
                            ? GridView.count(
                              crossAxisCount: crossAxisCount,
                              padding: EdgeInsets.fromLTRB(
                                8,
                                16,
                                8,
                                100,
                              ), // Bottom padding for floating buttons
                              childAspectRatio: isTablet ? 1.3 : 1.2,
                              children:
                                  _players.keys
                                      .map(
                                        (sound) =>
                                            _buildSoundCard(sound, isTablet),
                                      )
                                      .toList(),
                            )
                            : Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF64B5F6),
                                ),
                              ),
                            ),
                  ),
                ],
              ),

              // Floating Action Buttons - Fixed positioning
              _buildFloatingButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
