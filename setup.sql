-- ================================================================================
-- LearnOn Stundenplan-Verwaltungssystem - Datenbankstruktur
-- ================================================================================
-- Dieses Skript erstellt die gesamte Datenbankstruktur für das LearnOn System,
-- ein relationales Datenbanksystem zur Verwaltung von Stundenplänen eines 
-- Gymnasiums (Jahrgangsstufen 5-13).
--
-- Kernfunktionalitäten:
-- - Zentrale Verwaltung von Unterrichtsstunden (Wer, Was, Wann, Wo)
-- - Konfliktprävention durch Unique Constraints (Lehrer/Raum/Lerngruppe zur gleichen Zeit)
-- - Vertretungs- und Ausfalllogik mit Verweis auf ursprüngliche Regel-Stunden
--
-- Autor: [Student Name] - Universitätsprojekt
-- Datum: [Aktuelles Datum]
-- DBMS: MariaDB
-- ================================================================================

-- Datenbank neu erstellen (falls vorhanden, löschen)
DROP DATABASE IF EXISTS LearnOn;
CREATE DATABASE LearnOn;
USE LearnOn;

-- ================================================================================
-- TABELLE: Gebaeude
-- ================================================================================
/*
 * Speichert alle Gebäude der Schule.
 * Jedes Gebäude hat einen eindeutigen Namen und dient als Container für Räume.
 */
CREATE TABLE Gebaeude (
    GebaeudeID INT AUTO_INCREMENT PRIMARY KEY, -- Eindeutige ID des Gebäudes
    Name VARCHAR(50) NOT NULL UNIQUE           -- Name des Gebäudes (z.B. 'Hauptgebäude', 'Sporttrakt')
) ENGINE=InnoDB;

-- ================================================================================
-- TABELLE: Raeume
-- ================================================================================
/*
 * Speichert alle Räume der Schule mit ihrer Zuordnung zu Gebäuden.
 * Jeder Raum hat einen Typ, der angibt, für welche Art von Unterricht er geeignet ist.
 */
CREATE TABLE Raeume (
    RaumID INT AUTO_INCREMENT PRIMARY KEY,     -- Eindeutige ID des Raums
    GebaeudeID INT NOT NULL,                   -- Verweis auf das Gebäude
    Name VARCHAR(20) NOT NULL,                 -- Raumbezeichnung (z.B. 'A101', 'Chemielabor')
    Typ VARCHAR(30),                           -- Raumtyp (z.B. 'Standard', 'IT', 'Chemie', 'Physik')
    
    -- Foreign Key Constraints
    FOREIGN KEY (GebaeudeID) REFERENCES Gebaeude(GebaeudeID) 
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ================================================================================
-- TABELLE: Lehrer
-- ================================================================================
/*
 * Speichert alle Lehrkräfte der Schule.
 * Jede Lehrkraft hat ein eindeutiges Kürzel für die Stundenplanung.
 */
CREATE TABLE Lehrer (
    LehrerID INT AUTO_INCREMENT PRIMARY KEY,   -- Eindeutige ID der Lehrkraft
    Kuerzel VARCHAR(5) NOT NULL UNIQUE,        -- Einzigartiges Kürzel des Lehrers (z.B. 'MUE', 'SCH')
    Name VARCHAR(100) NOT NULL                 -- Vollständiger Name der Lehrkraft
) ENGINE=InnoDB;

-- ================================================================================
-- TABELLE: Faecher
-- ================================================================================
/*
 * Speichert alle Unterrichtsfächer der Schule.
 * Das Flag 'IstFachraumErforderlich' gibt an, ob für das Fach ein spezieller
 * Fachraum benötigt wird (z.B. Chemielabor für Chemie).
 */
CREATE TABLE Faecher (
    FachID INT AUTO_INCREMENT PRIMARY KEY,     -- Eindeutige ID des Fachs
    Kuerzel VARCHAR(5) NOT NULL UNIQUE,        -- Fachkürzel (z.B. 'MA', 'CH', 'IF')
    Name VARCHAR(50) NOT NULL,                 -- Vollständiger Fachname
    IstFachraumErforderlich BOOLEAN NOT NULL DEFAULT FALSE -- TRUE wenn Fachraum erforderlich
) ENGINE=InnoDB;

-- ================================================================================
-- TABELLE: Lehrer_Faecher (M:N Verknüpfung)
-- ================================================================================
/*
 * Many-to-Many Verknüpfung zwischen Lehrern und Fächern.
 * Definiert, welche Lehrkraft welche Fächer unterrichten darf/kann.
 */
CREATE TABLE Lehrer_Faecher (
    LehrerID INT NOT NULL,                     -- Verweis auf Lehrkraft
    FachID INT NOT NULL,                       -- Verweis auf Fach
    
    -- Kombinierter Primärschlüssel
    PRIMARY KEY (LehrerID, FachID),
    
    -- Foreign Key Constraints
    FOREIGN KEY (LehrerID) REFERENCES Lehrer(LehrerID) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (FachID) REFERENCES Faecher(FachID) 
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ================================================================================
-- TABELLE: Zeitslots
-- ================================================================================
/*
 * Definiert das Zeitraster der Schule.
 * Jeder Zeitslot ist eine eindeutige Kombination aus Wochentag und Stunde.
 * Wochentag: 1=Montag, 2=Dienstag, 3=Mittwoch, 4=Donnerstag, 5=Freitag
 * Stunde: 1=1. Stunde, 2=2. Stunde, etc.
 */
CREATE TABLE Zeitslots (
    ZeitSlotID INT AUTO_INCREMENT PRIMARY KEY, -- Eindeutige ID des Zeitslots
    Wochentag INT NOT NULL,                    -- Wochentag (1-5 für Mo-Fr)
    Stunde INT NOT NULL,                       -- Stundennummer (1-8 für 1.-8. Stunde)
    
    -- Unique Constraint: Pro Wochentag und Stunde nur ein Zeitslot
    UNIQUE KEY uk_wochentag_stunde (Wochentag, Stunde)
) ENGINE=InnoDB;

-- ================================================================================
-- TABELLE: Lerngruppen_Kurse
-- ================================================================================
/*
 * Speichert alle Lerngruppen der Schule (Klassen und Kurse).
 * Unterscheidet zwischen festen Klassen (z.B. '10B') und 
 * Kursen der Oberstufe (z.B. 'Q1-LK-DE-1').
 */
CREATE TABLE Lerngruppen_Kurse (
    LerngruppeID INT AUTO_INCREMENT PRIMARY KEY, -- Eindeutige ID der Lerngruppe
    Name VARCHAR(20) NOT NULL UNIQUE,           -- Name der Lerngruppe (z.B. '10B', 'Q1-LK-DE-1')
    Typ ENUM('Klasse', 'Kurs') NOT NULL,        -- Art der Lerngruppe
    Jahrgangsstufe INT                          -- Jahrgangsstufe (5-13)
) ENGINE=InnoDB;

-- ================================================================================
-- TABELLE: Unterrichtsstunde (KERNTABELLE)
-- ================================================================================
/*
 * Die zentrale Tabelle des Systems. Speichert alle Unterrichtsstunden mit
 * vollständiger Information: Wer unterrichtet was, wann und wo.
 * 
 * Unterstützt drei Arten von Stunden:
 * - 'Regel': Normale, regelmäßige Unterrichtsstunden
 * - 'Vertretung': Vertretungsstunden (verweisen auf ursprüngliche Regel-Stunde)
 * - 'Ausfall': Ausgefallene Stunden (verweisen auf ursprüngliche Regel-Stunde)
 * 
 * WICHTIGE CONSTRAINTS:
 * - Verhindert Doppelbuchungen von Lehrern, Räumen und Lerngruppen
 * - Stellt referenzielle Integrität über alle Dimensionen sicher
 */
CREATE TABLE Unterrichtsstunde (
    StundeID INT AUTO_INCREMENT PRIMARY KEY,   -- Eindeutige ID der Unterrichtsstunde
    ZeitSlotID INT NOT NULL,                   -- Wann findet die Stunde statt?
    LerngruppeID INT NOT NULL,                 -- Welche Lerngruppe wird unterrichtet?
    FachID INT NOT NULL,                       -- Welches Fach wird unterrichtet?
    LehrerID INT NOT NULL,                     -- Welche Lehrkraft unterrichtet?
    RaumID INT NOT NULL,                       -- In welchem Raum findet es statt?
    Typ ENUM('Regel', 'Vertretung', 'Ausfall') NOT NULL DEFAULT 'Regel', -- Art der Stunde
    VerweisAufStundeID INT NULL,               -- Verweis auf ursprüngliche Stunde (bei Vertretung/Ausfall)
    
    -- Foreign Key Constraints
    FOREIGN KEY (ZeitSlotID) REFERENCES Zeitslots(ZeitSlotID) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (LerngruppeID) REFERENCES Lerngruppen_Kurse(LerngruppeID) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (FachID) REFERENCES Faecher(FachID) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (LehrerID) REFERENCES Lehrer(LehrerID) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (RaumID) REFERENCES Raeume(RaumID) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (VerweisAufStundeID) REFERENCES Unterrichtsstunde(StundeID) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- ============================================================================
    -- KONFLIKTPRÄVENTIONS-CONSTRAINTS
    -- ============================================================================
    -- Diese Unique Constraints verhindern Doppelbuchungen zur gleichen Zeit:
    -- 
    -- HINWEIS: Diese Constraints gelten für alle Stundentypen. In der Praxis 
    -- sollten Ausfälle ('Ausfall') diese Constraints nicht blockieren, da sie
    -- keine echten Belegungen darstellen. MariaDB unterstützt jedoch keine 
    -- partiellen Unique Constraints mit WHERE-Bedingungen. Eine vollständige
    -- Lösung würde Check-Constraints oder Trigger erfordern.
    
    UNIQUE KEY uk_lehrer_zeitslot (LehrerID, ZeitSlotID),     -- Ein Lehrer kann nicht zur gleichen Zeit mehrere Stunden haben
    UNIQUE KEY uk_raum_zeitslot (RaumID, ZeitSlotID),         -- Ein Raum kann nicht zur gleichen Zeit mehrfach belegt sein
    UNIQUE KEY uk_lerngruppe_zeitslot (LerngruppeID, ZeitSlotID) -- Eine Lerngruppe kann nicht zur gleichen Zeit mehrere Stunden haben
) ENGINE=InnoDB;

-- ================================================================================
-- SCHEMA-ERSTELLUNG ABGESCHLOSSEN
-- ================================================================================
-- Die Datenbankstruktur für das LearnOn Stundenplan-Verwaltungssystem ist 
-- vollständig erstellt. Das Schema unterstützt:
-- 
-- ✓ Vollständige Stundenplanung mit allen Dimensionen (Wer, Was, Wann, Wo)
-- ✓ Konfliktprävention durch Unique Constraints
-- ✓ Vertretungs- und Ausfalllogik mit Referenzen
-- ✓ Flexible Raum- und Fachzuordnungen
-- ✓ Referenzielle Integrität durch Foreign Keys
-- 
-- Das System ist bereit für die Befüllung mit Beispieldaten.
-- ================================================================================