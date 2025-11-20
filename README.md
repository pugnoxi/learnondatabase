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

