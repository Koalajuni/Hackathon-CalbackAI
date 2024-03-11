import 'package:calendar/l10n/change_language.dart';
import 'package:flutter/material.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/l10n/l10n.dart';




class LanguageSettings extends StatefulWidget {
  const LanguageSettings({ Key? key }) : super(key: key);

  @override
  State<LanguageSettings> createState() => _LanguageSettingsState();
}

class _LanguageSettingsState extends State<LanguageSettings> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
                      color: Colors.black
                    ),
        backgroundColor: Colors.white70,
        elevation: 0,
        title: Text(
            AppLocalizations.of(context)!.languages,
            style:TextStyle(
              color: Colors.black,
            )),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: L10n.all.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              final languageName = L10n.getLanguage(L10n.all[index].languageCode);
              return Column(
                children:<Widget> [
                  ListTile(
                    title: Text(languageName),
                    onTap: () {
                      final provider = Provider.of<ChangeLanguage>(context,listen: false);
                      provider.setLocale(L10n.all[index]);
                      Navigator.of(context).pop();
                  },
                  ),
              Divider(),
                ],
              );
            },
          ),
        ),
      ),
    );

  }

}