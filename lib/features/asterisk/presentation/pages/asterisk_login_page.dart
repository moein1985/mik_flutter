import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/router/app_router.dart';

/// Asterisk PBX Login/Setup Page
///
/// Allows users to configure AMI and SSH connection settings
/// before accessing the Asterisk dashboard.
class AsteriskLoginPage extends StatefulWidget {
  const AsteriskLoginPage({super.key});

  @override
  State<AsteriskLoginPage> createState() => _AsteriskLoginPageState();
}

class _AsteriskLoginPageState extends State<AsteriskLoginPage> {
  final _formKey = GlobalKey<FormState>();
  
  // AMI Settings
  final _amiHostController = TextEditingController();
  final _amiPortController = TextEditingController();
  final _amiUsernameController = TextEditingController();
  final _amiPasswordController = TextEditingController();
  
  // SSH Settings
  final _sshHostController = TextEditingController();
  final _sshPortController = TextEditingController();
  final _sshUsernameController = TextEditingController();
  final _sshPasswordController = TextEditingController();
  
  bool _obscureAmiPassword = true;
  bool _obscureSshPassword = true;
  bool _isLoading = false;
  bool _useSameHost = true;
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      const secureStorage = FlutterSecureStorage();
      
      // Load AMI settings
      _amiHostController.text = prefs.getString('asterisk_ami_host') ?? AppConfig.defaultAmiHost;
      _amiPortController.text = (prefs.getInt('asterisk_ami_port') ?? AppConfig.defaultAmiPort).toString();
      _amiUsernameController.text = prefs.getString('asterisk_ami_username') ?? AppConfig.defaultAmiUsername;
      _amiPasswordController.text = await secureStorage.read(key: 'asterisk_ami_password') ?? AppConfig.defaultAmiSecret;
      
      // Load SSH settings
      _sshHostController.text = prefs.getString('asterisk_ssh_host') ?? AppConfig.defaultSshHost;
      _sshPortController.text = (prefs.getInt('asterisk_ssh_port') ?? AppConfig.defaultSshPort).toString();
      _sshUsernameController.text = prefs.getString('asterisk_ssh_username') ?? AppConfig.defaultSshUsername;
      _sshPasswordController.text = await secureStorage.read(key: 'asterisk_ssh_password') ?? '';
      
      // Check if hosts are same
      _useSameHost = _amiHostController.text == _sshHostController.text;
    } catch (e) {
      // Use defaults on error
      _amiHostController.text = AppConfig.defaultAmiHost;
      _amiPortController.text = AppConfig.defaultAmiPort.toString();
      _amiUsernameController.text = AppConfig.defaultAmiUsername;
      _amiPasswordController.text = AppConfig.defaultAmiSecret;
      _sshHostController.text = AppConfig.defaultSshHost;
      _sshPortController.text = AppConfig.defaultSshPort.toString();
      _sshUsernameController.text = AppConfig.defaultSshUsername;
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _saveAndConnect() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      const secureStorage = FlutterSecureStorage();
      
      // Save AMI settings
      await prefs.setString('asterisk_ami_host', _amiHostController.text.trim());
      await prefs.setInt('asterisk_ami_port', int.parse(_amiPortController.text.trim()));
      await prefs.setString('asterisk_ami_username', _amiUsernameController.text.trim());
      await secureStorage.write(key: 'asterisk_ami_password', value: _amiPasswordController.text);
      
      // Save SSH settings
      final sshHost = _useSameHost ? _amiHostController.text.trim() : _sshHostController.text.trim();
      await prefs.setString('asterisk_ssh_host', sshHost);
      await prefs.setInt('asterisk_ssh_port', int.parse(_sshPortController.text.trim()));
      await prefs.setString('asterisk_ssh_username', _sshUsernameController.text.trim());
      await secureStorage.write(key: 'asterisk_ssh_password', value: _sshPasswordController.text);
      
      // Mark as configured
      await prefs.setBool('asterisk_configured', true);
      
      // Navigate to Asterisk dashboard
      if (mounted) {
        context.go(AppRoutes.asterisk);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در ذخیره تنظیمات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _amiHostController.dispose();
    _amiPortController.dispose();
    _amiUsernameController.dispose();
    _amiPasswordController.dispose();
    _sshHostController.dispose();
    _sshPortController.dispose();
    _sshUsernameController.dispose();
    _sshPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asterisk PBX'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6600).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.phone_in_talk,
                                color: Color(0xFFFF6600),
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'اتصال به Asterisk PBX',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                  Text(
                                    'تنظیمات AMI و SSH را وارد کنید',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // AMI Settings Section
                    Text(
                      'تنظیمات AMI (Asterisk Manager Interface)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _amiHostController,
                              decoration: const InputDecoration(
                                labelText: 'آدرس سرور',
                                hintText: '192.168.1.100',
                                prefixIcon: Icon(Icons.dns),
                              ),
                              validator: (v) => v?.isEmpty == true ? 'آدرس سرور الزامی است' : null,
                              textDirection: TextDirection.ltr,
                              keyboardType: TextInputType.url,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _amiPortController,
                              decoration: const InputDecoration(
                                labelText: 'پورت AMI',
                                hintText: '5038',
                                prefixIcon: Icon(Icons.numbers),
                              ),
                              validator: (v) {
                                if (v?.isEmpty == true) return 'پورت الزامی است';
                                final port = int.tryParse(v!);
                                if (port == null || port < 1 || port > 65535) {
                                  return 'پورت نامعتبر است';
                                }
                                return null;
                              },
                              textDirection: TextDirection.ltr,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _amiUsernameController,
                              decoration: const InputDecoration(
                                labelText: 'نام کاربری AMI',
                                hintText: 'admin',
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (v) => v?.isEmpty == true ? 'نام کاربری الزامی است' : null,
                              textDirection: TextDirection.ltr,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _amiPasswordController,
                              decoration: InputDecoration(
                                labelText: 'رمز عبور AMI',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureAmiPassword ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => _obscureAmiPassword = !_obscureAmiPassword),
                                ),
                              ),
                              obscureText: _obscureAmiPassword,
                              validator: (v) => v?.isEmpty == true ? 'رمز عبور الزامی است' : null,
                              textDirection: TextDirection.ltr,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // SSH Settings Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'تنظیمات SSH',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() => _showAdvanced = !_showAdvanced),
                          icon: Icon(_showAdvanced ? Icons.expand_less : Icons.expand_more),
                          label: Text(_showAdvanced ? 'بستن' : 'نمایش'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Same host checkbox
                    Card(
                      child: CheckboxListTile(
                        title: const Text('استفاده از همان آدرس AMI'),
                        subtitle: const Text('SSH روی همان سرور Asterisk'),
                        value: _useSameHost,
                        onChanged: (v) => setState(() => _useSameHost = v ?? true),
                      ),
                    ),
                    
                    if (_showAdvanced || !_useSameHost) ...[
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              if (!_useSameHost)
                                TextFormField(
                                  controller: _sshHostController,
                                  decoration: const InputDecoration(
                                    labelText: 'آدرس SSH',
                                    hintText: '192.168.1.100',
                                    prefixIcon: Icon(Icons.terminal),
                                  ),
                                  validator: (v) {
                                    if (!_useSameHost && v?.isEmpty == true) {
                                      return 'آدرس SSH الزامی است';
                                    }
                                    return null;
                                  },
                                  textDirection: TextDirection.ltr,
                                  keyboardType: TextInputType.url,
                                ),
                              if (!_useSameHost) const SizedBox(height: 16),
                              TextFormField(
                                controller: _sshPortController,
                                decoration: const InputDecoration(
                                  labelText: 'پورت SSH',
                                  hintText: '22',
                                  prefixIcon: Icon(Icons.numbers),
                                ),
                                validator: (v) {
                                  if (v?.isEmpty == true) return 'پورت الزامی است';
                                  final port = int.tryParse(v!);
                                  if (port == null || port < 1 || port > 65535) {
                                    return 'پورت نامعتبر است';
                                  }
                                  return null;
                                },
                                textDirection: TextDirection.ltr,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _sshUsernameController,
                                decoration: const InputDecoration(
                                  labelText: 'نام کاربری SSH',
                                  hintText: 'root',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (v) => v?.isEmpty == true ? 'نام کاربری الزامی است' : null,
                                textDirection: TextDirection.ltr,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _sshPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'رمز عبور SSH',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureSshPassword ? Icons.visibility : Icons.visibility_off),
                                    onPressed: () => setState(() => _obscureSshPassword = !_obscureSshPassword),
                                  ),
                                ),
                                obscureText: _obscureSshPassword,
                                textDirection: TextDirection.ltr,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                    
                    // Connect Button
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _saveAndConnect,
                      icon: const Icon(Icons.login),
                      label: const Text('ذخیره و اتصال'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFFF6600),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Info Card
                    Card(
                      color: theme.colorScheme.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'برای دسترسی به CDR و ضبط مکالمات، دسترسی SSH لازم است.',
                                style: TextStyle(
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Helper function to check if Asterisk is configured
Future<bool> isAsteriskConfigured() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('asterisk_configured') ?? false;
  } catch (e) {
    return false;
  }
}
