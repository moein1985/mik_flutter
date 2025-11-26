import 'dart:convert';

/// RouterOS API protocol encoder/decoder
/// Based on: https://wiki.mikrotik.com/wiki/Manual:API
class RouterOSProtocol {
  /// Encode a word length according to RouterOS protocol
  /// - If length < 0x80: 1 byte
  /// - If length < 0x4000: 2 bytes (0x80 | (length >> 8), length & 0xFF)
  /// - If length < 0x200000: 3 bytes
  /// - If length < 0x10000000: 4 bytes
  /// - Otherwise: 5 bytes
  static List<int> encodeLength(int length) {
    if (length < 0x80) {
      return [length];
    } else if (length < 0x4000) {
      return [
        0x80 | (length >> 8),
        length & 0xFF,
      ];
    } else if (length < 0x200000) {
      return [
        0xC0 | (length >> 16),
        (length >> 8) & 0xFF,
        length & 0xFF,
      ];
    } else if (length < 0x10000000) {
      return [
        0xE0 | (length >> 24),
        (length >> 16) & 0xFF,
        (length >> 8) & 0xFF,
        length & 0xFF,
      ];
    } else {
      return [
        0xF0,
        (length >> 24) & 0xFF,
        (length >> 16) & 0xFF,
        (length >> 8) & 0xFF,
        length & 0xFF,
      ];
    }
  }

  /// Decode a word length from bytes
  /// Returns the length and how many bytes were consumed
  static (int length, int bytesRead) decodeLength(List<int> bytes) {
    if (bytes.isEmpty) {
      throw Exception('Cannot decode length from empty bytes');
    }

    final firstByte = bytes[0];

    if ((firstByte & 0x80) == 0x00) {
      // 1 byte: 0xxxxxxx
      return (firstByte, 1);
    } else if ((firstByte & 0xC0) == 0x80) {
      // 2 bytes: 10xxxxxx xxxxxxxx
      if (bytes.length < 2) throw Exception('Not enough bytes for 2-byte length');
      final length = ((firstByte & 0x3F) << 8) | bytes[1];
      return (length, 2);
    } else if ((firstByte & 0xE0) == 0xC0) {
      // 3 bytes: 110xxxxx xxxxxxxx xxxxxxxx
      if (bytes.length < 3) throw Exception('Not enough bytes for 3-byte length');
      final length = ((firstByte & 0x1F) << 16) | (bytes[1] << 8) | bytes[2];
      return (length, 3);
    } else if ((firstByte & 0xF0) == 0xE0) {
      // 4 bytes: 1110xxxx xxxxxxxx xxxxxxxx xxxxxxxx
      if (bytes.length < 4) throw Exception('Not enough bytes for 4-byte length');
      final length = ((firstByte & 0x0F) << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
      return (length, 4);
    } else if ((firstByte & 0xF8) == 0xF0) {
      // 5 bytes: 11110xxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx
      if (bytes.length < 5) throw Exception('Not enough bytes for 5-byte length');
      final length = (bytes[1] << 24) | (bytes[2] << 16) | (bytes[3] << 8) | bytes[4];
      return (length, 5);
    }

    throw Exception('Invalid length encoding: 0x${firstByte.toRadixString(16)}');
  }

  /// Encode a word (string) to bytes
  static List<int> encodeWord(String word) {
    final wordBytes = utf8.encode(word);
    final lengthBytes = encodeLength(wordBytes.length);
    return [...lengthBytes, ...wordBytes];
  }

  /// Encode a sentence (list of words) to bytes
  /// A sentence is a list of words terminated by an empty word (length 0)
  static List<int> encodeSentence(List<String> words) {
    final List<int> result = [];
    for (final word in words) {
      result.addAll(encodeWord(word));
    }
    // Terminate with empty word (length 0)
    result.add(0);
    return result;
  }

  /// Decode words from a stream of bytes
  /// Returns list of decoded words
  static List<String> decodeWords(List<int> bytes) {
    final List<String> words = [];
    int offset = 0;

    while (offset < bytes.length) {
      // Decode length
      final (length, bytesRead) = decodeLength(bytes.sublist(offset));
      offset += bytesRead;

      // If length is 0, it's the end of sentence
      if (length == 0) {
        break;
      }

      // Read word bytes
      if (offset + length > bytes.length) {
        throw Exception('Not enough bytes for word of length $length');
      }

      final wordBytes = bytes.sublist(offset, offset + length);
      offset += length;

      // Decode to string
      final word = utf8.decode(wordBytes);
      words.add(word);
    }

    return words;
  }
}
