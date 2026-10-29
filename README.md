# EverAfter: gemeinsame Hochzeitsplanung

Private Daten, auch wenn der Code in einem öffentlichen GitHub-Repository liegt.

## Einrichtung
1. Kostenloses Supabase-Projekt anlegen (EU-Region).
2. Unter Authentication -> Providers -> Email öffentliche Registrierung ausschalten.
3. Unter Authentication -> Users sechs Benutzer per E-Mail einladen oder anlegen. Öffentliche Registrierung deaktiviert lassen; bei jedem Benutzer die UUID notieren.
4. `database.sql` im SQL Editor ausführen. Anschließend die kommentierte INSERT-Anweisung für `public.members` mit den freigegebenen UUIDs (bis zu sechs) ausführen.
5. In `config.js` die öffentliche Supabase Project URL und den publishable (oder anon) key eintragen. **Keine geheimen API-Schlüssel committen!**
6. Dieses Repository per Cloudflare Pages mit Produktionsbranch und Ausgabeordner `/` bereitstellen (statische HTML-Site ohne Build-Schritt).
7. Die HTTPS-Adresse öffnen und mit den eingerichteten Konten anmelden.

## Schutz
Row Level Security und `save_workspace`-RPC erlauben ausschließlich Mitgliederzugriff. In Supabase öffentliche Registrierungen deaktivieren und nur die sechs gewünschten Nutzer hinzufügen. Passwörter, private Gästedaten und geheime Schlüssel niemals in dieses GitHub-Repository eintragen.

## Betrieb
Die App enthält Dashboard, Veranstaltungen, Aufgaben, Gäste, Budget und Kosten. Regelmäßig JSON-Backups exportieren. Kostenlose Anbieter können Limits, Pausen bei Inaktivität oder Tarifänderungen haben.

Aktueller Status: Ohne Supabase-Konfiguration und Hosting **noch nicht live nutzbar**.

## Sechs Nutzer freischalten
In Supabase unter **Authentication → Users** die sechs gewünschten Personen einladen oder anlegen. Jeder verwendet seine persönliche E-Mail und sein eigenes Passwort. Danach freigegebene UUIDs in `public.members` hinterlegen, beispielsweise:
```sql
insert into public.members(user_id)
select id from auth.users
where email in ('person1@example.com', 'person2@example.com');
```
Die Beispieladressen durch die gewünschten E-Mails ersetzen, weitere Zeilen ergänzen. **Keine Registrierung für beliebige Besucher aktivieren.** Mitgliedschaft wird durch `public.members` kontrolliert. Aktuelle Datenbank erlaubt mehr als sechs Accounts; sechs sind die geplante Teamgröße, kein hartes Limit.
