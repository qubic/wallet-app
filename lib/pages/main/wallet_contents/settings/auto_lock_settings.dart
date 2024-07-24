import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/textStyles.dart';

class AutoLockSettings extends StatelessWidget {
  final SettingsStore settingsStore = getIt<SettingsStore>();

  final List<int> _minuteList = [1, 3, 5, 10, 15, 20, 30, 45, 60];

  AutoLockSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auto-Lock Settings', style: TextStyles.pageTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Observer(
          builder: (context) {
            return ListView(
              children: [
                ListTile(
                  title: Text('Immediately', style: TextStyles.textNormal),
                  onTap: () {
                    settingsStore.setAutoLockTimeout(0);
                  },
                  trailing: settingsStore.settings.autoLockTimeout == 0
                      ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                      : null,
                ),
                for (int i = 0; i < _minuteList.length; i++)
                  ListTile(
                    title: Text('${_minuteList[i]} minutes',
                        style: TextStyles.textNormal),
                    onTap: () {
                      settingsStore.setAutoLockTimeout(_minuteList[i]);
                    },
                    trailing:
                        settingsStore.settings.autoLockTimeout == _minuteList[i]
                            ? Icon(Icons.check,
                                color: Theme.of(context).primaryColor)
                            : null,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
