import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/precheck_result.dart';
import '../bloc/letsencrypt_bloc.dart';
import '../bloc/letsencrypt_event.dart';
import 'letsencrypt_domain_sections.dart';
import 'letsencrypt_helpers.dart';

class LetsEncryptPreChecksView extends StatefulWidget {
  final PreCheckResult result;
  final TextEditingController dnsNameController;

  const LetsEncryptPreChecksView({
    super.key,
    required this.result,
    required this.dnsNameController,
  });

  @override
  State<LetsEncryptPreChecksView> createState() => _LetsEncryptPreChecksViewState();
}

class _LetsEncryptPreChecksViewState extends State<LetsEncryptPreChecksView> {
  bool _useCloudDdns = true;
  bool _showTechnicalDetails = false;

  @override
  void initState() {
    super.initState();
    // For x86/CHR routers, force custom domain mode
    if (!widget.result.cloudSupported) {
      _useCloudDdns = false;
    }
    // Initialize domain from Cloud if available
    if (widget.dnsNameController.text.isEmpty && widget.result.dnsName != null) {
      widget.dnsNameController.text = widget.result.dnsName!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasValidDomain = widget.dnsNameController.text.trim().isNotEmpty;

    // Get only technical checks (not Cloud-related)
    final technicalChecks = widget.result.checks
        .where((c) =>
            c.type != PreCheckType.cloudEnabled &&
            c.type != PreCheckType.dnsAvailable)
        .toList();
    final technicalIssues = technicalChecks.where((c) => !c.passed).toList();
    final allTechnicalPassed = technicalIssues.isEmpty;
    final canRequest = hasValidDomain && allTechnicalPassed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(l10n, theme),
          const SizedBox(height: 24),
          _buildDomainSection(context, l10n, theme),
          const SizedBox(height: 16),
          _buildTechnicalPrereqsSection(context, l10n, theme, technicalChecks, technicalIssues),
          const SizedBox(height: 24),
          _buildActionButtons(context, l10n, canRequest, hasValidDomain, technicalIssues),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.letsEncryptPreChecks,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.letsEncryptPreChecksDesc,
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDomainSection(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    if (widget.result.cloudSupported) {
      return HardwareRouterDomainSection(
        result: widget.result,
        dnsNameController: widget.dnsNameController,
        useCloudDdns: _useCloudDdns,
        onUseCloudDdnsChanged: (value) => setState(() => _useCloudDdns = value),
      );
    } else {
      return VirtualRouterDomainSection(
        result: widget.result,
        dnsNameController: widget.dnsNameController,
        onDomainChanged: () => setState(() {}),
      );
    }
  }

  Widget _buildTechnicalPrereqsSection(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    List<PreCheckItem> technicalChecks,
    List<PreCheckItem> technicalIssues,
  ) {
    final allPassed = technicalIssues.isEmpty;

    return Card(
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _showTechnicalDetails = !_showTechnicalDetails),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: allPassed ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.letsEncryptTechnicalPrereqs,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: allPassed ? Colors.green.shade100 : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      allPassed
                          ? l10n.letsEncryptAllPrereqsMet
                          : l10n.letsEncryptPrereqsIssues(technicalIssues.length),
                      style: TextStyle(
                        color: allPassed ? Colors.green.shade800 : Colors.orange.shade800,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _showTechnicalDetails ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (_showTechnicalDetails) ...[
            const Divider(height: 1),
            ...technicalChecks.map((check) => _buildCheckItem(context, l10n, check)),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckItem(BuildContext context, AppLocalizations l10n, PreCheckItem check) {
    final passed = check.passed;
    final canFix = check.canAutoFix && !passed;

    return ListTile(
      leading: Icon(
        passed ? Icons.check_circle : Icons.error,
        color: passed ? Colors.green : Colors.red,
      ),
      title: Text(LetsEncryptHelpers.getCheckTitle(l10n, check.type)),
      subtitle: !passed && check.errorMessage != null
          ? Text(
              LetsEncryptHelpers.getLocalizedError(l10n, check.errorMessage!),
              style: const TextStyle(color: Colors.red, fontSize: 12),
            )
          : null,
      trailing: canFix
          ? TextButton(
              onPressed: () {
                context.read<LetsEncryptBloc>().add(AutoFixIssue(check.type));
              },
              child: Text(l10n.letsEncryptFix),
            )
          : null,
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppLocalizations l10n,
    bool canRequest,
    bool hasValidDomain,
    List<PreCheckItem> technicalIssues,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canRequest)
          ElevatedButton.icon(
            onPressed: () {
              final dnsName = widget.dnsNameController.text.trim();
              context.read<LetsEncryptBloc>().add(RequestCertificate(dnsName: dnsName));
            },
            icon: const Icon(Icons.lock, color: Colors.white),
            label: Text(l10n.letsEncryptGetFreeSslCertificate),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          )
        else if (!hasValidDomain)
          ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.lock),
            label: Text(l10n.letsEncryptEnterDomainToContinue),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          )
        else if (technicalIssues.isNotEmpty)
          ElevatedButton.icon(
            onPressed: technicalIssues.any((c) => c.canAutoFix)
                ? () {
                    final fixableTypes =
                        technicalIssues.where((c) => c.canAutoFix).map((c) => c.type).toList();
                    context.read<LetsEncryptBloc>().add(AutoFixAll(fixableTypes));
                  }
                : null,
            icon: const Icon(Icons.auto_fix_high),
            label: Text(l10n.letsEncryptFixIssuesFirst),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            context.read<LetsEncryptBloc>().add(const RunPreChecks());
          },
          icon: const Icon(Icons.refresh),
          label: Text(l10n.letsEncryptRecheck),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            context.read<LetsEncryptBloc>().add(const LoadLetsEncryptStatus());
          },
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
