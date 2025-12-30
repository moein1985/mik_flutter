# Network Assistant Documentation

Welcome to the Network Assistant documentation! This directory contains comprehensive documentation for the application architecture, modules, and development guidelines.

## 📚 Documentation Structure

```
docs/
├── README.md                           ← You are here
├── architecture/                       ← Architecture guidelines
│   ├── MODULE_GUIDELINES.md           ← How to create new modules
│   └── SDK_DEVELOPMENT.md             ← How to create reusable SDKs
└── modules/                            ← Per-module documentation
    ├── mikrotik/
    │   └── README.md                   ← MikroTik Assist module
    ├── snmp/
    │   └── README.md                   ← SNMP Assist module
    ├── cisco/
    │   └── README.md                   ← Cisco module (future)
    ├── asterisk/
    │   └── README.md                   ← Asterisk PBX module (future)
    ├── microsoft/
    │   └── README.md                   ← Microsoft Server module (future)
    └── esxi/
        └── README.md                   ← VMware ESXi module (future)
```

## 🎯 Quick Links

### For Developers

**Getting Started:**
- [Project Setup](../README.md) - Main project README
- [Architecture Guidelines](architecture/MODULE_GUIDELINES.md) - How to create modules
- [SDK Development](architecture/SDK_DEVELOPMENT.md) - How to create SDKs

**Module Documentation:**
- [MikroTik Assist](modules/mikrotik/README.md) - RouterOS management
- [SNMP Assist](modules/snmp/README.md) - SNMP device monitoring

**Refactoring:**
- [Refactoring Proposal](../REFACTORING_PROPOSAL.md) - Multi-module architecture plan

### For Users

**Module Guides:**
- [MikroTik Setup](modules/mikrotik/README.md#usage) - How to connect to MikroTik router
- [SNMP Setup](modules/snmp/README.md#configuration) - How to monitor SNMP devices

## 🏗️ Architecture Overview

### Application Structure

```
lib/
├── core/                    ← Core infrastructure
│   ├── network/            ← Network clients (RouterOS, etc.)
│   ├── protocols/          ← Protocol implementations (SNMP, etc.)
│   ├── router/             ← App routing (GoRouter)
│   └── utils/              ← Utilities
│
├── sdks/                    ← Reusable SDKs
│   ├── cisco/              ← Cisco multi-protocol SDK (future)
│   └── snmp_vendor_extensions/  ← Vendor-specific SNMP MIBs
│
├── modules/                 ← Vendor-specific modules
│   ├── _shared/            ← Shared module utilities
│   ├── mikrotik/           ← MikroTik RouterOS module
│   ├── snmp/               ← SNMP monitoring module
│   ├── cisco/              ← Cisco module (future)
│   ├── asterisk/           ← Asterisk PBX module (future)
│   ├── microsoft/          ← Microsoft Server module (future)
│   └── esxi/               ← VMware ESXi module (future)
│
└── features/                ← Cross-cutting features
    ├── app_auth/           ← App-level authentication
    ├── home/               ← Home page with module list
    ├── settings/           ← App settings
    ├── subscription/       ← In-app purchases
    └── about/              ← About page
```

### Clean Architecture Layers

Each module follows Clean Architecture:

```
module_name/
├── core/                   ← Module definition
├── data/                   ← Data layer
│   ├── datasources/       ← External data sources
│   ├── models/            ← Data models
│   └── repositories/      ← Repository implementations
├── domain/                 ← Business logic layer
│   ├── entities/          ← Business entities
│   ├── repositories/      ← Repository interfaces
│   └── usecases/          ← Use cases
└── presentation/           ← UI layer
    ├── bloc/              ← State management
    ├── pages/             ← Screens
    └── widgets/           ← UI components
```

## 📖 Module Documentation

### Available Modules

#### 1. MikroTik Assist
Complete RouterOS management with 13+ features.
- **Protocol**: RouterOS API
- **Status**: ✅ Production
- **Docs**: [modules/mikrotik/README.md](modules/mikrotik/README.md)

#### 2. SNMP Assist
General SNMP device monitoring + Asterisk support.
- **Protocol**: SNMP v1/v2c
- **Status**: ✅ Production
- **Docs**: [modules/snmp/README.md](modules/snmp/README.md)

### Planned Modules

#### 3. Cisco Module
Multi-protocol Cisco device management.
- **Protocols**: SNMP, NETCONF, RESTCONF, SSH/CLI
- **Status**: 📝 Planned
- **Docs**: [modules/cisco/README.md](modules/cisco/README.md) (future)

#### 4. Asterisk PBX
Dedicated Asterisk management (migrated from SNMP).
- **Protocols**: SNMP (ASTERISK-MIB), AMI
- **Status**: 📝 Planned
- **Docs**: [modules/asterisk/README.md](modules/asterisk/README.md) (future)

#### 5. Microsoft Server
Windows Server monitoring.
- **Protocols**: SNMP, WMI
- **Status**: 📝 Planned
- **Docs**: [modules/microsoft/README.md](modules/microsoft/README.md) (future)

#### 6. VMware ESXi
VMware hypervisor management.
- **Protocols**: SNMP, vSphere API
- **Status**: 📝 Planned
- **Docs**: [modules/esxi/README.md](modules/esxi/README.md) (future)

## 🛠️ Development

### Creating a New Module

1. **Read the guidelines:**
   - [Module Guidelines](architecture/MODULE_GUIDELINES.md)
   - [SDK Development](architecture/SDK_DEVELOPMENT.md) (if SDK needed)

2. **Create structure:**
   ```bash
   mkdir -p lib/modules/MODULE_NAME/{core,data,domain,presentation}
   mkdir -p docs/modules/MODULE_NAME
   ```

3. **Implement module:**
   - Follow Clean Architecture
   - Implement `BaseDeviceModule`
   - Register in `injection_container.dart`

4. **Document:**
   - Create `docs/modules/MODULE_NAME/README.md`
   - Add usage examples
   - Document troubleshooting

5. **Test:**
   - Unit tests (>80% coverage)
   - Integration tests
   - Manual testing

### Creating an SDK

1. **Decide if SDK needed:**
   - Multiple protocols? → SDK
   - Shared across modules? → SDK
   - Single protocol? → Module only

2. **Read guidelines:**
   - [SDK Development Guide](architecture/SDK_DEVELOPMENT.md)

3. **Create structure:**
   ```bash
   mkdir -p lib/sdks/VENDOR_NAME/protocols
   ```

4. **Implement:**
   - Protocol clients
   - Shared models
   - Unified interface

## 📝 Contributing

### Documentation Standards

When writing documentation:

- ✅ Use clear, concise language
- ✅ Provide code examples
- ✅ Include troubleshooting sections
- ✅ Keep examples up-to-date
- ✅ Use proper Markdown formatting
- ✅ Add diagrams where helpful

### File Naming

- Module docs: `docs/modules/MODULE_NAME/README.md`
- Architecture: `docs/architecture/TOPIC_NAME.md`
- Use `UPPERCASE_WITH_UNDERSCORES.md` for guides
- Use `lowercase-with-dashes.md` for specific topics

### Markdown Guidelines

```markdown
# Main Title (H1)

## Section (H2)

### Subsection (H3)

**Bold text**
*Italic text*

- Bullet point
- Another point

1. Numbered list
2. Second item

`inline code`

```dart
// Code block with syntax highlighting
class Example {}
```

[Link text](url)
```

## 🔍 Finding Information

### Common Questions

**Q: How do I add a new module?**  
A: See [Module Guidelines](architecture/MODULE_GUIDELINES.md)

**Q: When should I create an SDK?**  
A: See [SDK Development - When to Create](architecture/SDK_DEVELOPMENT.md#when-to-create-an-sdk)

**Q: How does MikroTik authentication work?**  
A: See [MikroTik - Authentication](modules/mikrotik/README.md#authentication)

**Q: How to monitor Asterisk PBX?**  
A: See [SNMP - Asterisk Setup](modules/snmp/README.md#configuration)

**Q: What's the project architecture?**  
A: See [Architecture Overview](#architecture-overview) above

### Search Tips

1. Use your editor's search (Ctrl+Shift+F / Cmd+Shift+F)
2. Search for keywords in this docs/ folder
3. Check module README files first
4. Check architecture guidelines for patterns

## 📊 Documentation Checklist

When creating new documentation:

- [ ] Clear title and overview
- [ ] Table of contents (for long docs)
- [ ] Code examples
- [ ] Usage instructions
- [ ] Configuration details
- [ ] Troubleshooting section
- [ ] References/links to related docs
- [ ] Proper Markdown formatting
- [ ] No broken links
- [ ] Reviewed by another developer

## 🚀 Getting Help

- Read relevant documentation first
- Check existing modules for patterns
- Ask in team chat/discussions
- Create issue for documentation improvements
- Refer to external references:
  - [Flutter Documentation](https://flutter.dev/docs)
  - [Dart Language Guide](https://dart.dev/guides)
  - [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## 📜 License

See [LICENSE](../LICENSE) file in project root.

---

**Last Updated**: 2025-12-30  
**Documentation Version**: 1.0  
**Project Status**: Active Development
