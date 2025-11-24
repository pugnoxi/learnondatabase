# LearnOn Stundenplan-Verwaltungssystem
## Data Dictionary 

---

## Tabelle: Gebaeude

**Zweck:** Speichert alle Gebäude der Schule als Container für Räume.

| Attributsname | Datentyp | Länge | Format | Defaultwert | NULL? | Schlüssel | Beschreibung |
|---------------|----------|-------|---------|-------------|-------|-----------|--------------|
| GebaeudeID | INT | - | - | AUTO_INCREMENT | N | PK | Eindeutiger Primärschlüssel des Gebäudes |
| Name | VARCHAR | 50 | 'Hauptgebäude' | - | N | Unique | Eindeutiger Name des Gebäudes (z.B. 'Hauptgebäude', 'Sporttrakt') |

---

## Tabelle: Raeume

**Zweck:** Speichert alle Räume der Schule mit ihrer Zuordnung zu Gebäuden und Raumtyp.

| Attributsname | Datentyp | Länge | Format | Defaultwert | NULL? | Schlüssel | Beschreibung |
|---------------|----------|-------|---------|-------------|-------|-----------|--------------|
| RaumID | INT | - | - | AUTO_INCREMENT | N | PK | Eindeutiger Primärschlüssel des Raums |
| GebaeudeID | INT | - | - | - | N | FK | Verweis auf das Gebäude, in dem sich der Raum befindet |
| Name | VARCHAR | 20 | 'A101' | - | N | - | Raumbezeichnung (z.B. 'A101', 'Chemielabor') |
| Typ | VARCHAR | 30 | 'Standard' | NULL | J | - | Raumtyp zur Klassifizierung (z.B. 'Standard', 'IT', 'Chemie', 'Physik', 'Sport') |

**Foreign Keys:**
- GebaeudeID → Gebaeude(GebaeudeID) ON DELETE RESTRICT ON UPDATE CASCADE

---

## Tabelle: Lehrer

**Zweck:** Speichert alle Lehrkräfte der Schule mit eindeutigem Kürzel für die Stundenplanung.

| Attributsname | Datentyp | Länge | Format | Defaultwert | NULL? | Schlüssel | Beschreibung |
|---------------|----------|-------|---------|-------------|-------|-----------|--------------|
| LehrerID | INT | - | - | AUTO_INCREMENT | N | PK | Eindeutiger Primärschlüssel der Lehrkraft |
| Kuerzel | VARCHAR | 5 | 'MUE' | - | N | Unique | Einzigartiges Kürzel des Lehrers für Stundenplan (z.B. 'MUE', 'SCH') |
| Name | VARCHAR | 100 | 'Dr. Maria Müller' | - | N | - | Vollständiger Name der Lehrkraft |

---

## Tabelle: Faecher

**Zweck:** Speichert alle Unterrichtsfächer mit Information über Fachraum-Anforderungen.

| Attributsname | Datentyp | Länge | Format | Defaultwert | NULL? | Schlüssel | Beschreibung |
|---------------|----------|-------|---------|-------------|-------|-----------|--------------|
| FachID | INT | - | - | AUTO_INCREMENT | N | PK | Eindeutiger Primärschlüssel des Fachs |
| Kuerzel | VARCHAR | 5 | 'MA' | - | N | Unique | Fachkürzel für Stundenplan (z.B. 'MA', 'CH', 'IF') |
| Name | VARCHAR | 50 | 'Mathematik' | - | N | - | Vollständiger Fachname |
| IstFachraumErforderlich | BOOLEAN | - | TRUE/FALSE | FALSE | N | - | Gibt an, ob für das Fach ein spezieller Fachraum benötigt wird |

---

## Tabelle: Lehrer_Faecher

**Zweck:** Many-to-Many Verknüpfung zwischen Lehrern und Fächern. Definiert Unterrichtsberechtigung.

| Attributsname | Datentyp | Länge | Format | Defaultwert | NULL? | Schlüssel | Beschreibung |
|---------------|----------|-------|---------|-------------|-------|-----------|--------------|
| LehrerID | INT | - | - | - | N | PK, FK | Verweis auf die Lehrkraft |
| FachID | INT | - | - | - | N | PK, FK | Verweis auf das Fach |

**Primary Key:** (LehrerID, FachID)  
**Foreign Keys:**
- LehrerID → Lehrer(LehrerID) ON DELETE RESTRICT ON UPDATE CASCADE
- FachID → Faecher(FachID) ON DELETE RESTRICT ON UPDATE CASCADE

---

## Tabelle: Zeitslots

**Zweck:** Definiert das Zeitraster der Schule. Jeder Zeitslot ist eine eindeutige Kombination aus Wochentag und Stunde.

| Attributsname | Datentyp | Länge | Format | Defaultwert | NULL? | Schlüssel | Beschreibung |
|---------------|----------|-------|---------|-------------|-------|-----------|--------------|
| ZeitSlotID | INT | - | - | AUTO_INCREMENT | N | PK | Eindeutiger Primärschlüssel des Zeitslots |
| Wochentag | INT | - | 1-5 | - | N | Unique | Wochentag (1=Montag, 2=Dienstag, 3=Mittwoch, 4=Donnerstag, 5=Freitag) |
| Stunde | INT | - | 1-8 | - | N | Unique | Stundennummer (1=1. Stunde, 2=2. Stunde, etc.) |

**Unique Constraints:**
- uk_wochentag_stunde (Wochentag, Stunde) - Pro Wochentag und Stunde nur ein Zeitslot

---

## Tabelle: Lerngruppen_Kurse

**Zweck:** Speichert alle Lerngruppen der Schule (Klassen und Kurse der Oberstufe).

| Attributsname | Datentyp | Länge | Format | Defaultwert | NULL? | Schlüssel | Beschreibung |
|---------------|----------|-------|---------|-------------|-------|-----------|--------------|
| LerngruppeID | INT | - | - | AUTO_INCREMENT | N | PK | Eindeutiger Primärschlüssel der Lerngruppe |
| Name | VARCHAR | 20 | '10B' | - | N | Unique | Name der Lerngruppe (z.B. '10B', 'Q1-LK-DE-1') |
| Typ | ENUM | - | 'Klasse', 'Kurs' | - | N | - | Art der Lerngruppe zur Unterscheidung zwischen festen Klassen und Oberstufenkursen |
| Jahrgangsstufe | INT | - | 5-13 | NULL | J | - | Jahrgangsstufe der Lerngruppe (5-13) |

---

## Tabelle: Unterrichtsstunde

**Zweck:** Die zentrale Tabelle des Systems. Speichert alle Unterrichtsstunden mit vollständiger Information über Wer, Was, Wann und Wo.

| Attributsname | Datentyp | Länge | Format | Defaultwert | NULL? | Schlüssel | Beschreibung |
|---------------|----------|-------|---------|-------------|-------|-----------|--------------|
| StundeID | INT | - | - | AUTO_INCREMENT | N | PK | Eindeutiger Primärschlüssel der Unterrichtsstunde |
| ZeitSlotID | INT | - | - | - | N | FK, Unique | Verweis auf den Zeitpunkt der Stunde (Wann?) |
| LerngruppeID | INT | - | - | - | N | FK, Unique | Verweis auf die unterrichtete Lerngruppe (Wer wird unterrichtet?) |
| FachID | INT | - | - | - | N | FK | Verweis auf das unterrichtete Fach (Was wird unterrichtet?) |
| LehrerID | INT | - | - | - | N | FK, Unique | Verweis auf die unterrichtende Lehrkraft (Wer unterrichtet?) |
| RaumID | INT | - | - | - | N | FK, Unique | Verweis auf den Unterrichtsraum (Wo findet es statt?) |
| Typ | ENUM | - | 'Regel', 'Vertretung', 'Ausfall' | 'Regel' | N | - | Art der Stunde zur Unterscheidung zwischen regulärem Unterricht, Vertretungen und Ausfällen |
| VerweisAufStundeID | INT | - | - | NULL | J | FK | Verweis auf die ursprüngliche Regel-Stunde bei Vertretungen oder Ausfällen |

**Foreign Keys:**
- ZeitSlotID → Zeitslots(ZeitSlotID) ON DELETE RESTRICT ON UPDATE CASCADE
- LerngruppeID → Lerngruppen_Kurse(LerngruppeID) ON DELETE RESTRICT ON UPDATE CASCADE
- FachID → Faecher(FachID) ON DELETE RESTRICT ON UPDATE CASCADE
- LehrerID → Lehrer(LehrerID) ON DELETE RESTRICT ON UPDATE CASCADE
- RaumID → Raeume(RaumID) ON DELETE RESTRICT ON UPDATE CASCADE
- VerweisAufStundeID → Unterrichtsstunde(StundeID) ON DELETE RESTRICT ON UPDATE CASCADE

**Unique Constraints (Konfliktprävention):**
- uk_lehrer_zeitslot (LehrerID, ZeitSlotID) - Ein Lehrer kann nicht zur gleichen Zeit mehrere Stunden haben
- uk_raum_zeitslot (RaumID, ZeitSlotID) - Ein Raum kann nicht zur gleichen Zeit mehrfach belegt sein  
- uk_lerngruppe_zeitslot (LerngruppeID, ZeitSlotID) - Eine Lerngruppe kann nicht zur gleichen Zeit mehrere Stunden haben

---

## Views (Sicherheits-Views)

### View: LearnOn_MeineStunden

**Zweck:** Sicherheits-View für Lehrkräfte zur Einsicht nur der eigenen Unterrichtsstunden.

**Beschreibung:** Diese View filtert automatisch auf den aktuell angemeldeten Benutzer und zeigt nur dessen eigene Stunden an. Wird für Datenschutz und rollenbasierte Zugriffskontrolle verwendet.

### View: LearnOn_OeffentlicherStundenplan

**Zweck:** Anonymisierte Sicht auf Stundenpläne für Schüler und Eltern.

**Beschreibung:** Diese View zeigt Stundenplan-Informationen ohne private Lehrerdaten (nur Kürzel, keine vollständigen Namen). Verwendet für öffentlich zugängliche Stundenplan-Anzeigen.

---

## Datenintegrität und Constraints

### Referenzielle Integrität
Alle Foreign Key Beziehungen sind mit `ON DELETE RESTRICT` und `ON UPDATE CASCADE` definiert, um Dateninkonsistenzen zu vermeiden.

### Eindeutigkeit
- Gebäude haben eindeutige Namen
- Lehrer haben eindeutige Kürzel  
- Fächer haben eindeutige Kürzel
- Lerngruppen haben eindeutige Namen
- Zeitslots sind eindeutig durch Wochentag/Stunde-Kombination

### Konfliktprävention
Das System verhindert durch Unique Constraints:
- Doppelbuchung von Lehrern zur gleichen Zeit
- Doppelbelegung von Räumen zur gleichen Zeit  
- Mehrfachbelegung von Lerngruppen zur gleichen Zeit

---
