# RouterOS API Test Program

Test program for connecting to MikroTik RouterOS using the binary API protocol.

## Configuration

- **Host:** 192.168.85.1
- **Port:** 8788
- **Protocol:** RouterOS API (binary)

## Features

- ✅ Direct TCP connection to RouterOS API
- ✅ Protocol encoding/decoding (word-based format)
- ✅ Authentication (username/password)
- ✅ Command execution
- ✅ Response parsing

## Usage

```bash
# Get dependencies (if needed)
dart pub get

# Run the test program
dart run bin/main.dart
```

You will be prompted for:
- Username (default: admin)
- Password

## Test Commands

The program tests these RouterOS commands:
1. `/system/resource/print` - System resources (CPU, memory, uptime)
2. `/interface/print` - Network interfaces
3. `/ip/address/print` - IP addresses

## Protocol Details

### Word Length Encoding
- `< 0x80`: 1 byte
- `< 0x4000`: 2 bytes (0x80 prefix)
- `< 0x200000`: 3 bytes (0xC0 prefix)
- `< 0x10000000`: 4 bytes (0xE0 prefix)
- Otherwise: 5 bytes (0xF0 prefix)

### Sentence Structure
- Sentences are lists of words
- Each sentence ends with an empty word (length 0)
- Commands start with `/command`
- Attributes use `=key=value` format

### Response Types
- `!re`: Reply with data
- `!done`: Command completed successfully
- `!trap`: Error occurred
- `!fatal`: Fatal error

## Troubleshooting

### Connection Issues
- Verify IP address and port (check if API is enabled on router)
- Check firewall rules on RouterOS
- Ensure network connectivity

### Authentication Issues
- Verify username and password
- Check user permissions in RouterOS
- Try with admin user first

### Port Issues
- Default API port: 8728
- API-SSL port: 8729
- **Your router uses: 8788** (non-standard)

## Next Steps

Once this POC works:
1. Refactor into clean classes (Connection, Protocol, Client)
2. Add error handling and recovery
3. Implement connection pooling
4. Add SSL/TLS support
5. Integrate into Flutter app with Clean Architecture
