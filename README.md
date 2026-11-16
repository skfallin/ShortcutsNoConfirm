# ShortcutsNoConfirm

Rootless tweak for **iOS 16.5.1** (Dopamine) that lets Shortcuts automations run without the confirmation prompts iOS still shows when **Ask Before Running** is off. The typical case is an automation ending in **Shut Down**: the condition is met, but the phone waits on *Continue?* instead of turning off.

**With the switch on, the tweak accepts these prompts on your behalf. Destructive actions (shutting down, deleting data, opening a secure Home accessory) run with no chance to cancel, and for Shut Down and secure accessories the unlock request shown while the phone is locked is skipped too.** Check your automation conditions before enabling it.

[Download the beta](https://github.com/skfallin/ShortcutsNoConfirm/releases/tag/v0.1.0-beta.1) · [Italiano](#italiano) · [Build instructions](BUILDING.md)

## Compatibility and validation

| Configuration | Status |
| --- | --- |
| iOS 16.5.1 (20F75), arm64e | Every hooked class, selector, block signature and response code checked against the dyld shared cache of this build |
| Dopamine, rootless, ElleKit | Target configuration; package built and contents checked locally |
| Shut Down from a personal automation, without prompt | Not device-tested |
| Settings switch read by the shortcut runner | Not device-tested |
| Other iOS versions, rootful or roothide | Not supported; the package depends on `firmware (= 16.5.1)` |

This beta has not been installed on a device yet. Reports from a real 16.5.1 setup are welcome, see [Limits and bug reports](#limits-and-bug-reports).

## What it skips

| Prompt | Without the tweak | With the switch on |
| --- | --- | --- |
| Shut Down / Restart | *Continue?* and, when locked, an unlock request | Runs immediately |
| Secure Home accessories (locks, gates, garage doors) | Confirmation and unlock request | Runs immediately |
| App Intents confirmations | *Yes / No* | Answered *Yes* |
| SiriKit intent confirmations | *Confirm / Cancel* | Confirmed |
| Deleting photos, files and other items | Confirmation | Allowed |
| Deleting or sharing large amounts of data | Confirmation | Allowed |

It does not touch:

- **Ask Before Running**, the notification shown when an automation starts. Turn it off in the automation itself.
- Privacy prompts such as *Allow "…" to access …?*. Tap **Always Allow** once.
- Prompts your shortcut asks on purpose: **Show Alert**, **Ask for Input**, **Choose from Menu**.

The hooks act on the process that runs automations. Shortcuts started by hand from the app may still show some confirmations.

## Example: scheduled shutdown

1. Create a personal automation *At 11:00 PM* with a single **Shut Down** action and turn **Ask Before Running** off.
2. At 11:00 PM Shortcuts runs the action and iOS builds the *Continue?* alert.
3. The tweak intercepts the alert and calls the same handler as the **Continue** button.
4. The phone shuts down. No alert, no notification, also when locked.

With the switch off the alert appears as on stock iOS.

## Install and configure

1. Make sure **ElleKit** (tweak injection) and **PreferenceLoader** are installed. Both are part of a standard Dopamine setup.
2. Download `com.skfallin.shortcutsnoconfirm_0.1.0~beta1_iphoneos-arm64.deb` from the [beta release](https://github.com/skfallin/ShortcutsNoConfirm/releases/tag/v0.1.0-beta.1) and check it against `SHA256SUMS`.
3. Install it with Sileo, Filza or another local Debian-package installer. The shortcut runner loads the tweak the next time it starts; respring once to be sure.
4. Open **Settings → ShortcutsNoConfirm**. The switch is on by default and changes apply immediately.
5. Test with an automation you can trigger right away before relying on a scheduled one.

Over SSH, after uploading the `.deb` to the phone, run **on the iPhone**:

```sh
sudo dpkg -i ./com.skfallin.shortcutsnoconfirm_0.1.0~beta1_iphoneos-arm64.deb
```

## Remove or recover

Turn the switch off in Settings to get stock behaviour back without uninstalling. To remove it, uninstall **ShortcutsNoConfirm** in Sileo.

If an automation keeps shutting the phone down at the wrong time, disable or delete that automation in Shortcuts first. Over SSH, run on the iPhone:

```sh
sudo dpkg --remove com.skfallin.shortcutsnoconfirm
sudo killall -9 BackgroundShortcutRunner
```

Tweak injection is inactive in Safe Mode and while the jailbreak is hidden or not running: in those states every prompt is back.

## How it works

All hooks are in [Tweak.x](Tweak.x) and load into processes that use `WorkflowKit`, the Shortcuts engine. During an automation the alerts go through `WFDialogTransformer`, the runner's user interface host.

| Hook | What it does |
| --- | --- |
| `-[WFDialogTransformer presentAlert:]` | If the alert is a `WFSecureConfirmationAlert`, built by `-[WFAction(RequestUnlock) requestUnlock:]`, calls its `successHandler` instead of presenting it |
| `-[WFDialogTransformer showLinkActionConfirmationWithActionMetadata:…completionHandler:]` | Replies `1`, the code of the Yes button in `WFLinkConfirmationDialogViewController` |
| `-[WFDialogTransformer showConfirmInteraction:prompt:requireAuthentication:completionHandler:]` | Replies `1`, the confirmed code in `WFInteractionDialogViewController` |
| `+[WFShortcutsSecuritySettings allowsDeletingWithoutConfirmation]`, `allowsDeletingLargeAmountsOfData`, `allowsSharingLargeAmountsOfData` | Return `YES`, the same as the matching switches in Settings → Shortcuts → Advanced |

The switch is stored in the `com.skfallin.shortcutsnoconfirm` preferences domain and reloaded through a Darwin notification when it changes.

## Limits and bug reports

The response codes and handlers were read from the iOS 16.5.1 binaries, not from public API. A different iOS build can change them, which is why the package refuses other firmware versions.

Open an [issue](https://github.com/skfallin/ShortcutsNoConfirm/issues) with the model, iOS version, jailbreak and version, package version, the automation's trigger and actions, and what appeared on screen. Redact identifiers from logs; do not post serial numbers, ECID or UDID.

## License

[MIT license](LICENSE). Theos and the iOS SDK are separate build dependencies and are not included in this repository or release.

## Italiano

Tweak rootless per **iOS 16.5.1** (Dopamine) che permette alle automazioni di Comandi di partire senza le richieste di conferma che iOS mostra anche con **Chiedi prima di eseguire** disattivato. Il caso tipico è un'automazione che finisce con **Spegni**: la condizione si verifica, ma il telefono resta fermo su *Vuoi continuare?* invece di spegnersi.

**Con l'interruttore attivo il tweak accetta queste richieste al posto tuo. Le azioni distruttive (spegnimento, eliminazione di dati, apertura di un accessorio Casa protetto) partono senza possibilità di annullarle e, per lo spegnimento e gli accessori protetti, viene saltata anche la richiesta di sblocco che compare a telefono bloccato.** Controlla le condizioni delle automazioni prima di attivarlo.

### Compatibilità e verifiche

| Configurazione | Stato |
| --- | --- |
| iOS 16.5.1 (20F75), arm64e | Classi, selettori, firme dei blocchi e codici di risposta verificati sulla dyld shared cache di questa build |
| Dopamine, rootless, ElleKit | Configurazione prevista; pacchetto compilato e contenuto controllato in locale |
| Spegnimento da automazione personale, senza conferma | Non testato sul dispositivo |
| Lettura dell'interruttore da parte del runner dei comandi | Non testato sul dispositivo |
| Altre versioni di iOS, rootful o roothide | Non supportate; il pacchetto dipende da `firmware (= 16.5.1)` |

### Cosa salta

| Richiesta | Senza tweak | Con l'interruttore attivo |
| --- | --- | --- |
| Spegni / Riavvia | *Vuoi continuare?* e, se bloccato, richiesta di sblocco | Eseguito subito |
| Accessori Casa protetti (serrature, cancelli, garage) | Conferma e richiesta di sblocco | Eseguito subito |
| Conferme App Intents | *Sì / No* | Risposto *Sì* |
| Conferme degli intent SiriKit | *Conferma / Annulla* | Confermato |
| Eliminazione di foto, file e altri elementi | Conferma | Consentita |
| Eliminazione o condivisione di grandi quantità di dati | Conferma | Consentita |

Non tocca **Chiedi prima di eseguire** (da disattivare nell'automazione), gli avvisi di privacy (*Consentire a "…" di accedere a …?*, basta **Consenti sempre** una volta) e le domande che il comando fa apposta: **Mostra avviso**, **Richiedi input**, **Scegli dal menu**. Gli hook agiscono sul processo che esegue le automazioni: lanciando un comando a mano dall'app alcune conferme potrebbero comparire ancora.

### Esempio: spegnimento programmato

1. Crea un'automazione personale *Alle 23:00* con la sola azione **Spegni** e disattiva **Chiedi prima di eseguire**.
2. Alle 23:00 Comandi esegue l'azione e iOS prepara l'avviso *Vuoi continuare?*.
3. Il tweak intercetta l'avviso e chiama lo stesso gestore del pulsante **Continua**.
4. Il telefono si spegne. Nessun avviso, nessuna notifica, anche se è bloccato.

Con l'interruttore spento l'avviso compare come su iOS originale.

### Installazione e configurazione

1. Verifica di avere **ElleKit** (iniezione dei tweak) e **PreferenceLoader**, presenti in una normale installazione di Dopamine.
2. Scarica `com.skfallin.shortcutsnoconfirm_0.1.0~beta1_iphoneos-arm64.deb` dalla [release beta](https://github.com/skfallin/ShortcutsNoConfirm/releases/tag/v0.1.0-beta.1) e controllalo con `SHA256SUMS`.
3. Installalo con Sileo, Filza o un altro installer di pacchetti Debian. Il runner dei comandi carica il tweak al prossimo avvio; per sicurezza fai un respring.
4. Apri **Impostazioni → ShortcutsNoConfirm**. L'interruttore è attivo di default e le modifiche valgono subito.
5. Prova con un'automazione che puoi avviare subito prima di affidarti a una programmata.

Via SSH, dopo aver caricato il `.deb` sul telefono, esegui **sull'iPhone**:

```sh
sudo dpkg -i ./com.skfallin.shortcutsnoconfirm_0.1.0~beta1_iphoneos-arm64.deb
```

### Rimozione e ripristino

Spegni l'interruttore nelle Impostazioni per tornare al comportamento originale senza disinstallare. Per rimuoverlo, disinstalla **ShortcutsNoConfirm** da Sileo.

Se un'automazione continua a spegnere il telefono nel momento sbagliato, disattivala o eliminala prima in Comandi. Via SSH, esegui sull'iPhone:

```sh
sudo dpkg --remove com.skfallin.shortcutsnoconfirm
sudo killall -9 BackgroundShortcutRunner
```

In modalità sicura e quando il jailbreak è nascosto o non attivo l'iniezione è disattivata: in quei casi tutte le conferme tornano.

### Limiti e segnalazioni

Codici di risposta e gestori sono stati letti dai binari di iOS 16.5.1, non da API pubbliche. Un'altra build di iOS può cambiarli, per questo il pacchetto rifiuta le altre versioni del firmware.

Apri una [issue](https://github.com/skfallin/ShortcutsNoConfirm/issues) indicando modello, versione di iOS, jailbreak e versione, versione del pacchetto, attivazione e azioni dell'automazione e cosa è comparso a schermo. Togli gli identificativi dai log; non pubblicare numero di serie, ECID o UDID.

### Licenza

[Licenza MIT](LICENSE). Theos e l'SDK di iOS sono dipendenze di build separate e non sono inclusi in questo repository né nella release.
