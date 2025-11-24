# LearnOn - Stundenplan-Verwaltungssystem

## Produktbeschreibung

**LearnOn** ist ein relationales Datenbanksystem zur Verwaltung von Stundenplänen eines Gymnasiums (Jahrgangsstufen 5-12). Das System wurde speziell für die Anforderungen einer modernen Schule entwickelt und bietet umfassende Funktionalitäten zur Stundenplanverwaltung.

### Kernfunktionalitäten

- **Zentrale Verwaltung von Unterrichtsstunden**: Verwaltet alle Aspekte einer Unterrichtsstunde (Wer, Was, Wann, Wo)
- **Konfliktprävention**: Automatische Verhinderung von Überschneidungen durch Unique Constraints
- **Vertretungs- und Ausfalllogik**: Vollständige Nachverfolgung von Vertretungsstunden mit Verweis auf ursprüngliche Regel-Stunden
- **Flexible Raumverwaltung**: Unterstützung für Standard- und Fachräume mit spezifischen Anforderungen
- **Lerngruppenverwaltung**: Verwaltung von Klassen und Kursen mit individuellen Stundenplänen

## Datenbankstruktur

### Haupttabellen

#### Gebäude und Räume
- **Gebaeude**: Verwaltung aller Schulgebäude
- **Raeume**: Detaillierte Raumverwaltung mit Typisierung (Standard, IT, Chemie, Physik, etc.)

#### Personal und Fächer
- **Lehrer**: Lehrkraftverwaltung mit eindeutigen Kürzeln
- **Faecher**: Fachverwaltung mit Fachraum-Anforderungen
- **Lehrer_Faecher**: Many-to-Many Verknüpfung zwischen Lehrern und ihren Unterrichtsfächern

#### Lerngruppen und Zeitmanagement
- **Lerngruppen_Kurse**: Verwaltung von Klassen und Kursen
- **Zeitslots**: Definierte Unterrichtszeiten (1.-11. Stunde)

#### Kernfunktionalität
- **Unterrichtsstunde**: Zentrale Tabelle für alle Unterrichtsstunden mit Typ-Differenzierung:
  - `Regel`: Reguläre Unterrichtsstunden
  - `Vertretung`: Vertretungsstunden
  - `Ausfall`: Ausfallstunden

### Views und Abfragen
- **LearnOn_OeffentlicherStundenplan**: Öffentliche Sicht auf den Stundenplan
- Vorgefertigte Testabfragen für häufige Anwendungsfälle

## Installation

### Voraussetzungen

**Alle Betriebssysteme:**
- MariaDB Server 10.3 oder höher

### Installation unter Linux (Ubuntu/Debian)

```bash
# 1. Als root-User anmelden
sudo mysql -u root -p

# 2. Datenbankstruktur erstellen
mysql -u root -p < setup.sql

# 3. Beispieldaten einfügen
mysql -u root -p < dummy_data.sql
```

### Installation unter macOS

```bash
# 1. Als root-User anmelden
mysql -u root -p

# 2. Datenbankstruktur erstellen
mysql -u root -p < path/to/setup.sql

# 3. Beispieldaten einfügen
mysql -u root -p < path/to/dummy_data.sql
```

### Installation unter Windows

**Command Prompt als Administrator öffnen**
   ```cmd
   # Zu MariaDB-Verzeichnis navigieren
   cd "C:\Program Files\MariaDB 10.x\bin"
   
   # Mit MariaDB verbinden
   mysql -u root -p
   
   # Datenbankstruktur erstellen
   mysql -u root -p < C:\Pfad\zum\setup.sql
   
   # Beispieldaten einfügen
   mysql -u root -p < C:\Pfad\zum\dummy_data.sql
   ```

## Beispieldaten

Die Datenbank wird mit realistischen Beispieldaten befüllt, die folgende Bereiche abdecken:

### Schulstruktur
- **3 Gebäude**: Hauptgebäude, Naturwissenschaften, Sporttrakt
- **15 Räume**: Standard-Klassenzimmer und Fachräume
- **12 Unterrichtsfächer**: Von Deutsch bis Informatik
- **15 Lehrkräfte**: Mit realistischen Namen und Kürzeln

### Unterrichtsorganisation
- **55 Zeitslots**: Montag bis Freitag, 1.-11. Stunde
- **8 Lerngruppen**: Klassen 5a bis 13 (Leistungskurse)
- **200+ Unterrichtsstunden**: Regel-, Vertretungs- und Ausfallstunden

## Berechtigungskonzept

### Rollen

1. **LearnOn_Admin**: Vollzugriff für Systemadministratoren
   - Alle Rechte auf LearnOn-Datenbank
   - Benutzerverwaltungsrechte (CREATE USER, RELOAD)

2. **LearnOn_Stundenplan_Verwalter**: Schreibzugriff für Schulleitung/Sekretariat  
   - Vollzugriff (SELECT, INSERT, UPDATE, DELETE) auf alle Tabellen
   - Für Stundenplanerstellung und -verwaltung

3. **LearnOn_Lehrer**: Lesezugriff für Lehrkräfte
   - Lesezugriff auf alle Tabellen
   - UPDATE-Recht für eigene Kontaktdaten (Name)
   - Zugriff auf View "LearnOn_MeineStunden"

4. **LearnOn_Schueler**: Eingeschränkter Lesezugriff für Schüler/Eltern
   - Lesezugriff auf Raeume, Faecher, Zeitslots, Lerngruppen_Kurse, Unterrichtsstunde
   - Nur Lehrerkürzel (LehrerID, Kuerzel), keine vollständigen Namen
   - Zugriff auf View "LearnOn_OeffentlicherStundenplan"

5. **LearnOn_Vertretungs_Verwalter**: Spezialrechte für Vertretungsplanung
   - Lesezugriff auf alle Stammdaten
   - Vollzugriff auf Unterrichtsstunde (für Vertretungsmanagement)

### Beispiel-Benutzerkonten

**Administrative Benutzer:**
- `admin_system@localhost` (LearnOn_Admin)
- `schulleitung_mueller@localhost` (LearnOn_Stundenplan_Verwalter)
- `sekretariat_weber@localhost` (LearnOn_Stundenplan_Verwalter)
- `vertretung_schmidt@localhost` (LearnOn_Vertretungs_Verwalter)

**Lehrkräfte:**
- `lehrer_mue@localhost` (Dr. Maria Müller - Mathematik/Physik)
- `lehrer_sch@localhost` (Thomas Schmidt - Deutsch/Geschichte)
- `lehrer_web@localhost` (Sarah Weber - Englisch/Erdkunde)
- `lehrer_neu@localhost` (Prof. Klaus Neumann - Chemie/Biologie)

**Schüler/Eltern:**
- `schueler_sv@localhost` (Schülervertreter)
- `eltern_beirat@localhost` (Elternvertreter)
- `web_portal@localhost` (Öffentlicher Lesezugriff für Web-Portal)

---

## Technische Details

### Engine und Konfiguration
- **Storage Engine:** InnoDB (für alle Tabellen)
- **Zeichensatz:** Standard MariaDB
- **Transaktionale Integrität:** Vollständig unterstützt durch InnoDB

### Naming Conventions
- **Tabellennamen:** PascalCase mit deutschen Begriffen (z.B. `Unterrichtsstunde`)
- **Spaltennamen:** PascalCase mit ID-Suffix für Primärschlüssel (z.B. `LehrerID`)
- **Rollen:** Prefix `LearnOn_` mit beschreibendem Namen
- **Benutzer:** Format `rolle_kuerzel@localhost` (z.B. `lehrer_mue@localhost`)
- **Views:** Prefix `LearnOn_` mit beschreibendem Namen

---

## Beispiel-Abfragen ausführen

Das System enthält vorgefertigte Beispiel-Abfragen im Ordner `Abfragen/`, die häufige Anwendungsfälle demonstrieren. Diese können direkt ausgeführt werden, um die Funktionalität zu testen.

### Verfügbare Abfragen

#### 1. **Stundenplan einer Klasse** (`abfrage1.sql`)
**Zweck:** Zeigt den kompletten Stundenplan für eine bestimmte Klasse/Lerngruppe an.  
**Beispiel:** Stundenplan der Klasse 10B mit allen Details (Wochentag, Stunde, Fach, Lehrer, Raum, Stundentyp)

#### 2. **Freie Fachräume finden** (`abfrage2.sql`)  
**Zweck:** Findet alle freien Fachräume zu einer bestimmten Zeit.  
**Beispiel:** Alle verfügbaren Fachräume (Chemie, IT, Physik, Biologie) am Dienstag in der 3. Stunde

#### 3. **Lehrerauslastung analysieren** (`abfrage3.sql`)  
**Zweck:** Berechnet die Stundenanzahl und Auslastung aller Lehrkräfte.  
**Beispiel:** Übersicht aller Lehrer mit Stundenzahl und Auslastungskategorien (Hoch/Mittel/Normal/Niedrig)

### Ausführung der Abfragen

#### Methode 1: Direkte Datei-Ausführung

**Linux/macOS:**
```bash
# Mit Administrator-Rechten anmelden
mysql -u root -p LearnOn

# Abfrage direkt aus Datei ausführen
mysql -u root -p LearnOn < Abfragen/abfrage1.sql
mysql -u root -p LearnOn < Abfragen/abfrage2.sql  
mysql -u root -p LearnOn < Abfragen/abfrage3.sql
```

**Windows (Command Prompt als Administrator):**
```cmd
# Zu MariaDB-Verzeichnis navigieren
cd "C:\Program Files\MariaDB 10.x\bin"

# Mit Datenbank verbinden
mysql -u root -p LearnOn

# Abfragen ausführen
mysql -u root -p LearnOn < C:\Pfad\zu\Abfragen\abfrage1.sql
mysql -u root -p LearnOn < C:\Pfad\zu\Abfragen\abfrage2.sql
mysql -u root -p LearnOn < C:\Pfad\zu\Abfragen\abfrage3.sql
```

#### Methode 2: Interaktive MySQL-Session

```sql
-- 1. Mit Datenbank verbinden
mysql -u root -p

-- 2. Datenbank auswählen
USE LearnOn;

-- 3. Abfrage-Inhalte kopieren und einfügen
-- (Inhalt von abfrage1.sql, abfrage2.sql, oder abfrage3.sql)

-- Beispiel: Stundenplan für Klasse 10B anzeigen
SELECT 
    CASE z.Wochentag 
        WHEN 1 THEN 'Montag'
        WHEN 2 THEN 'Dienstag'
        WHEN 3 THEN 'Mittwoch'
        WHEN 4 THEN 'Donnerstag'
        WHEN 5 THEN 'Freitag'
    END AS Wochentag,
    z.Stunde AS Stunde,
    f.Name AS Fach,
    l.Kuerzel AS Lehrer,
    CONCAT(g.Name, ' - ', r.Name) AS Raum,
    u.Typ AS Stundentyp
FROM Unterrichtsstunde u
    INNER JOIN Zeitslots z ON u.ZeitSlotID = z.ZeitSlotID
    INNER JOIN Lerngruppen_Kurse lg ON u.LerngruppeID = lg.LerngruppeID  
    INNER JOIN Faecher f ON u.FachID = f.FachID
    INNER JOIN Lehrer l ON u.LehrerID = l.LehrerID
    INNER JOIN Raeume r ON u.RaumID = r.RaumID
    INNER JOIN Gebaeude g ON r.GebaeudeID = g.GebaeudeID
WHERE lg.Name = '10B'
ORDER BY z.Wochentag, z.Stunde;
```

#### Methode 3: Mit Benutzerrechten testen

```sql
-- Als Lehrer anmelden (nur Lesezugriff)
mysql -u lehrer_mue@localhost LearnOn

-- Eigene Stunden anzeigen (automatisch gefiltert)
SELECT * FROM LearnOn_MeineStunden;

-- Als Schüler/Eltern anmelden (eingeschränkter Zugriff)  
mysql -u schueler_sv@localhost LearnOn

-- Öffentlichen Stundenplan anzeigen
SELECT * FROM LearnOn_OeffentlicherStundenplan 
WHERE Lerngruppe = '10B'
ORDER BY Wochentag, Stunde;
```
