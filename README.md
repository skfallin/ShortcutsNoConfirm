# ShortcutsNoConfirm

**Shortcuts automations that actually run without asking.**
A rootless tweak for **iOS 16.5.1** (Dopamine) that removes the confirmation prompts the Shortcuts app shows even when an automation is set to run without asking.

[🇮🇹 Italiano](#-italiano) · [🇬🇧 English](#-english)

![iOS](https://img.shields.io/badge/iOS-16.5.1-blue) ![Jailbreak](https://img.shields.io/badge/jailbreak-Dopamine%20(rootless)-purple) ![Arch](https://img.shields.io/badge/arch-arm64%20%7C%20arm64e-lightgrey)

---

## 🇮🇹 Italiano

### Il problema

In Comandi puoi creare un'automazione con **"Chiedi prima di eseguire" disattivato**, ma alcune azioni chiedono comunque una conferma. L'esempio più comune è **Spegni**: l'automazione parte, la condizione è vera, e invece di spegnersi il telefono ti mostra *"Vuoi continuare?"* con **Annulla / Continua**. L'automazione resta ferma finché non tocchi lo schermo.

### Cosa fa il tweak

Quando l'interruttore è attivo, queste conferme vengono accettate in automatico, come se avessi premuto il pulsante di conferma:

| Situazione | Senza tweak | Con il tweak |
|---|---|---|
| **Spegni / Riavvia** | "Vuoi continuare?" + richiesta di sblocco | Si spegne subito |
| **Accessori Casa protetti** (serrature, cancelli, garage) | Conferma richiesta | Eseguito subito |
| **Conferme delle app** (App Intents, Siri Intents) | "Sì / No" | Risposto "Sì" |
| **Eliminazione** di foto, file, ecc. | Conferma richiesta | Eliminato senza chiedere |
| **Grandi quantità di dati** (eliminazione/condivisione) | Conferma richiesta | Consentito |

### Esempio: spegnimento programmato

1. Automazione: *"Alle 23:00"* → azione **Spegni**, con *"Chiedi prima di eseguire"* **disattivato**.
2. Alle 23:00 Comandi esegue l'azione.
3. iOS prepara la conferma, il tweak la intercetta e preme **Continua**.
4. Il telefono si spegne. Nessun avviso, anche se è bloccato.

> ⚠️ Senza conferma non c'è modo di fermare l'azione. Controlla bene le condizioni delle tue automazioni.

### Impostazioni

In **Impostazioni** compare la voce **"Comandi senza conferma"** con un interruttore:

- **On** (predefinito): le conferme vengono saltate.
- **Off**: tutto torna come iOS originale.

La modifica vale subito, senza respring.

### Requisiti

- iOS **16.5.1** (sviluppato e verificato sulla build 20F75)
- Jailbreak **Dopamine** (rootless, `/var/jb`)
- **ElleKit** e **PreferenceLoader**, già presenti nelle installazioni standard di Dopamine

### Installazione

1. Scarica il `.deb` dall'ultima [release](../../releases/latest).
2. Installalo con **Sileo**, **Filza** o da terminale:
   ```sh
   dpkg -i it.comandi.senzaconferma_1.0.0_iphoneos-arm64.deb
   ```
3. Apri **Impostazioni → Comandi senza conferma** e verifica che l'interruttore sia attivo.

### Note e limiti

- **"Chiedi prima di eseguire"** è una domanda diversa, fatta all'avvio dell'automazione. Il tweak non la tocca: disattivala tu nell'automazione.
- Per spegnimento e accessori protetti viene saltata **anche la richiesta di sblocco** che iOS fa quando il telefono è bloccato.
- Gli avvisi di privacy (*"Consentire a … di accedere a …?"*) non vengono toccati: usa "Consenti sempre" una volta.
- Il tweak agisce sul processo che esegue le automazioni. Se avvii un comando a mano dall'app, alcune conferme potrebbero comparire ancora.

---

## 🇬🇧 English

### The problem

In the Shortcuts app you can create an automation with **"Ask Before Running" turned off**, yet some actions still ask for confirmation. The most common one is **Shut Down**: the automation fires, the condition is met, and instead of shutting down the phone shows *"Do you want to continue?"* with **Cancel / Continue**. The automation sits there until you tap the screen.

### What the tweak does

While the switch is on, these confirmations are accepted automatically, exactly as if you had tapped the confirm button:

| Situation | Without the tweak | With the tweak |
|---|---|---|
| **Shut Down / Restart** | "Continue?" + unlock request | Shuts down right away |
| **Secure Home accessories** (locks, gates, garage doors) | Confirmation required | Runs right away |
| **App confirmations** (App Intents, Siri Intents) | "Yes / No" | Answered "Yes" |
| **Deleting** photos, files, etc. | Confirmation required | Deleted without asking |
| **Large amounts of data** (delete/share) | Confirmation required | Allowed |

### Example: scheduled shutdown

1. Automation: *"At 11:00 PM"* → **Shut Down** action, with *"Ask Before Running"* **off**.
2. At 11:00 PM Shortcuts runs the action.
3. iOS builds the confirmation; the tweak intercepts it and presses **Continue**.
4. The phone shuts down. No prompt, even when locked.

> ⚠️ With no confirmation there is no way to stop the action. Double-check your automation conditions.

### Settings

A **"Comandi senza conferma"** entry with a single switch appears in **Settings**:

- **On** (default): confirmations are skipped.
- **Off**: everything behaves like stock iOS.

Changes apply immediately, no respring needed.

### Requirements

- iOS **16.5.1** (built and verified against build 20F75)
- **Dopamine** jailbreak (rootless, `/var/jb`)
- **ElleKit** and **PreferenceLoader**, already present in a standard Dopamine install

### Installation

1. Download the `.deb` from the latest [release](../../releases/latest).
2. Install it with **Sileo**, **Filza** or from a terminal:
   ```sh
   dpkg -i it.comandi.senzaconferma_1.0.0_iphoneos-arm64.deb
   ```
3. Open **Settings → Comandi senza conferma** and make sure the switch is on.

### Notes and limits

- **"Ask Before Running"** is a different prompt, shown when the automation starts. The tweak doesn't touch it: turn it off in the automation itself.
- For Shut Down and secure accessories the **unlock request** iOS shows while the phone is locked is skipped too.
- Privacy prompts (*"Allow … to access …?"*) are left alone: tap "Always Allow" once.
- The tweak acts on the process that runs automations. Shortcuts started by hand from the app may still show some confirmations.

---

## How it works

All hooks live in `Tweak.x` and are loaded into processes that use `WorkflowKit` (the Shortcuts engine). Every class, selector, block signature and response code was checked against the iOS 16.5.1 (20F75) dyld shared cache.

| Hook | Why |
|---|---|
| `-[WFDialogTransformer presentAlert:]` | When the alert is a `WFSecureConfirmationAlert` (built by `-[WFAction(RequestUnlock) requestUnlock:]`), its `successHandler` is called instead of showing it. |
| `-[WFDialogTransformer showLinkActionConfirmation…completionHandler:]` | Replies `1`, the code of the **Yes** button in `WFLinkConfirmationDialogViewController`. |
| `-[WFDialogTransformer showConfirmInteraction…completionHandler:]` | Replies `1`, the "Confirmed interaction" code in `WFInteractionDialogViewController`. |
| `+[WFShortcutsSecuritySettings allowsDeletingWithoutConfirmation]` and the two "large amounts of data" getters | Return `YES`, like the matching switches in Settings › Shortcuts › Advanced. |

The setting is read from the `it.comandi.senzaconferma` preferences domain and reloaded live through a Darwin notification.

### Building

Requires [Theos](https://theos.dev) with the iOS 16.5 SDK in `$THEOS/sdks`.

```sh
make package FINALPACKAGE=1
# → packages/it.comandi.senzaconferma_1.0.0_iphoneos-arm64.deb
```

## Disclaimer

Use at your own risk. Skipping confirmations means destructive actions (shutting down, deleting data, unlocking doors) run without any chance to cancel.
