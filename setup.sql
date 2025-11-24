-- LearnOn Stundenplan-Verwaltungssystem - Datenbankstruktur
-- Dieses Skript erstellt die gesamte Datenbankstruktur für ein relationales Datenbanksystem zur Verwaltung von Stundenplänen eines Gymnasiums (Jahrgangsstufen 5-12).
--
-- Kernfunktionalitäten:
-- - Zentrale Verwaltung von Unterrichtsstunden (Wer, Was, Wann, Wo)
-- - Konfliktprävention durch Unique Constraints (Lehrer/Raum/Lerngruppe zur gleichen Zeit)
-- - Vertretungs- und Ausfalllogik mit Verweis auf ursprüngliche Regel-Stunden
--
-- DBMS: MariaDB


-- Datenbank neu erstellen (falls vorhanden, verherige Datenbank löschen)
DROP DATABASE IF EXISTS LearnOn;
CREATE DATABASE LearnOn;
USE LearnOn;

/*
 * Beinhält alle Gebäude der Schule.
 * Jedes Gebäude hat eindeutigen Namen und dient als übergeordneter Standort für Räume.
 */
CREATE TABLE Gebaeude (
    GebaeudeID INT AUTO_INCREMENT PRIMARY KEY, -- Eindeutige ID des Gebäudes
    Name VARCHAR(50) NOT NULL UNIQUE           -- Name des Gebäudes
) ENGINE=InnoDB;

/*
 * Beinhält alle Räume der Schule mit ihrer Zuordnung zu Gebäuden.
 * Jeder Raum hat einen Typ, der angibt, für welche Art von Unterricht er geeignet ist.
 */
CREATE TABLE Raeume (
    RaumID INT AUTO_INCREMENT PRIMARY KEY,     -- Eindeutige ID des Raums
    GebaeudeID INT NOT NULL,                   -- Verweis auf das Gebäude
    Name VARCHAR(20) NOT NULL,                 -- Raumbezeichnung 
    Typ VARCHAR(30),                           -- Raumtyp
    
    -- Foreign Key Constraints
    FOREIGN KEY (GebaeudeID) REFERENCES Gebaeude(GebaeudeID) 
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;


/*
 * Beinhält alle Lehrkräfte der Schule.
 * Jede Lehrkraft hat ein eindeutiges Kürzel für die Stundenplanung.
 */
CREATE TABLE Lehrer (
    LehrerID INT AUTO_INCREMENT PRIMARY KEY,   -- Eindeutige ID der Lehrkraft
    Kuerzel VARCHAR(5) NOT NULL UNIQUE,        -- Einzigartiges Kürzel des Lehrers (z.B. 'MUE', 'SCH')
    Name VARCHAR(100) NOT NULL                 -- Vollständiger Name der Lehrkraft
) ENGINE=InnoDB;


/*
 * Beinhält alle Unterrichtsfächer der Schule.
 * Das Flag 'IstFachraumErforderlich' gibt an, ob das Fach einen speziellen
 * Fachraum benötigt wird (z.B. Chemielabor für Chemie).
 */
CREATE TABLE Faecher (
    FachID INT AUTO_INCREMENT PRIMARY KEY,     -- Eindeutige ID des Fachs
    Kuerzel VARCHAR(5) NOT NULL UNIQUE,        -- Fachkürzel (z.B. 'MA', 'CH', 'IF')
    Name VARCHAR(50) NOT NULL,                 -- Vollständiger Fachname
    IstFachraumErforderlich BOOLEAN NOT NULL DEFAULT FALSE -- TRUE wenn Fachraum erforderlich
) ENGINE=InnoDB;


/*
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


/*
 * Definiert Zeitraster.
 * Jeder Zeitslot ist eine eindeutige Kombination aus Wochentag und Stunde.
 * Wochentag: 1=Montag, 2=Dienstag, 3=Mittwoch, 4=Donnerstag, 5=Freitag
 * Stunde: 1=1. Stunde, 2=2. Stunde, etc.
 */
CREATE TABLE Zeitslots (
    ZeitSlotID INT AUTO_INCREMENT PRIMARY KEY, -- Eindeutige ID des Zeitslots
    Wochentag INT NOT NULL,                    -- Wochentag (1-5 für Mo-Fr)
    Stunde INT NOT NULL,                       -- Stundennummer (1-8 für 1.-8. Stunde)
    
    -- Unique Constraint: Pro Wochentag und Stunde nur ein Zeitslot
    UNIQUE (Wochentag, Stunde)
) ENGINE=InnoDB;


/*
 * Speichert Lerngruppen der Schule (Klassen und Kurse).
 * Unterscheidet zwischen festen Klassen (z.B. '10B') und 
 * Kursen der Oberstufe (z.B. 'Q1-LK-DE-1').
 */
CREATE TABLE Lerngruppen_Kurse (
    LerngruppeID INT AUTO_INCREMENT PRIMARY KEY, -- Eindeutige ID der Lerngruppe
    Name VARCHAR(20) NOT NULL UNIQUE,           -- Name der Lerngruppe (z.B. '10B', 'Q1-LK-DE-1')
    Typ ENUM('Klasse', 'Kurs') NOT NULL,        -- Art Lerngruppe
    Jahrgangsstufe INT                          -- Jahrgangsstufe (5-12)
) ENGINE=InnoDB;


/*
 * zentrale Tabelle des Systems. Speichert alle Unterrichtsstunden mit
 * vollständiger Info: Wer unterrichtet was, wann und wo.
 * 
 * Unterstützt drei Arten von Stunden:
 * - 'Regel': Normale, regelmäßige Unterrichtsstunden
 * - 'Vertretung': Vertretungsstunden (verweisen auf ursprüngliche Regel-Stunde)
 * - 'Ausfall': Ausgefallene Stunden (verweisen auf ursprüngliche Regel-Stunde)
 * 
 * wichtige ConstraintS:
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
    
 
    -- Diese Unique Constraints verhindern Doppelbuchungen zur gleichen Zeit:
    -- 
    -- HINWEIS: Diese Constraints gelten für alle Stundentypen. In der Praxis 
    -- sollten Ausfälle ('Ausfall') diese Constraints nicht blockieren, da sie
    -- keine echten Belegungen darstellen. MariaDB unterstützt jedoch keine 
    -- partiellen Unique Constraints mit WHERE-Bedingungen. Eine vollständige
    -- Lösung würde Check-Constraints oder Trigger erfordern. Funktioniert hier nicht.
    
    UNIQUE (LehrerID, ZeitSlotID),     -- Ein Lehrer kann nicht zur gleichen Zeit mehrere Stunden haben
    UNIQUE (RaumID, ZeitSlotID),         -- Ein Raum kann nicht zur gleichen Zeit mehrfach belegt sein
    UNIQUE (LerngruppeID, ZeitSlotID) -- Eine Lerngruppe kann nicht zur gleichen Zeit mehrere Stunden haben
) ENGINE=InnoDB;


-- SCHRITT 1: ROLLEN ERSTELLEN
-- Administrative Vollzugriffs-Rolle
CREATE ROLE IF NOT EXISTS 'LearnOn_Admin';

-- Stundenplan-Verwaltung (Schulleitung, Sekretariat)
CREATE ROLE IF NOT EXISTS 'LearnOn_Stundenplan_Verwalter';

-- Lehrkräfte (Einsicht in eigene Stunden und Gesamtpläne)
CREATE ROLE IF NOT EXISTS 'LearnOn_Lehrer';

-- Schüler/Eltern (Einsicht in öffentliche Stundenpläne)
CREATE ROLE IF NOT EXISTS 'LearnOn_Schueler';

-- Vertretungsplan-Verwaltung (oft separate Zuständigkeit)
CREATE ROLE IF NOT EXISTS 'LearnOn_Vertretungs_Verwalter';


-- SCHRITT 2: BERECHTIGUNGEN PRO ROLLE DEFINIEREN


-- ADMIN_ROLLE: Vollzugriff auf alles
GRANT ALL PRIVILEGES ON LearnOn.* TO 'LearnOn_Admin';
-- Berechtigung zum Verwalten anderer Benutzer
GRANT CREATE USER ON *.* TO 'LearnOn_Admin';
GRANT RELOAD ON *.* TO 'LearnOn_Admin';



-- STUNDENPLAN_VERWALTER: Vollzugriff auf Schulbetrieb
-- Vollzugriff auf alle fachlichen Tabellen
GRANT SELECT, INSERT, UPDATE, DELETE ON LearnOn.Gebaeude TO 'LearnOn_Stundenplan_Verwalter';
GRANT SELECT, INSERT, UPDATE, DELETE ON LearnOn.Raeume TO 'LearnOn_Stundenplan_Verwalter';
GRANT SELECT, INSERT, UPDATE, DELETE ON LearnOn.Lehrer TO 'LearnOn_Stundenplan_Verwalter';
GRANT SELECT, INSERT, UPDATE, DELETE ON LearnOn.Faecher TO 'LearnOn_Stundenplan_Verwalter';
GRANT SELECT, INSERT, UPDATE, DELETE ON LearnOn.Lehrer_Faecher TO 'LearnOn_Stundenplan_Verwalter';
GRANT SELECT, INSERT, UPDATE, DELETE ON LearnOn.Zeitslots TO 'LearnOn_Stundenplan_Verwalter';
GRANT SELECT, INSERT, UPDATE, DELETE ON LearnOn.Lerngruppen_Kurse TO 'LearnOn_Stundenplan_Verwalter';
GRANT SELECT, INSERT, UPDATE, DELETE ON LearnOn.Unterrichtsstunde TO 'LearnOn_Stundenplan_Verwalter';



-- LEHRER_ROLLE: Lesezugriff + eingeschränkte Änderungen
-- Lesezugriff auf Stammdaten
GRANT SELECT ON LearnOn.Gebaeude TO 'LearnOn_Lehrer';
GRANT SELECT ON LearnOn.Raeume TO 'LearnOn_Lehrer';
GRANT SELECT ON LearnOn.Lehrer TO 'LearnOn_Lehrer';
GRANT SELECT ON LearnOn.Faecher TO 'LearnOn_Lehrer';
GRANT SELECT ON LearnOn.Lehrer_Faecher TO 'LearnOn_Lehrer';
GRANT SELECT ON LearnOn.Zeitslots TO 'LearnOn_Lehrer';
GRANT SELECT ON LearnOn.Lerngruppen_Kurse TO 'LearnOn_Lehrer';
GRANT SELECT ON LearnOn.Unterrichtsstunde TO 'LearnOn_Lehrer';

-- Lehrer können ihre eigenen Kontaktdaten aktualisieren
GRANT UPDATE (Name) ON LearnOn.Lehrer TO 'LearnOn_Lehrer';

-- SCHUELER_ROLLE: Nur Lesezugriff auf öffentliche Daten
-- Nur Lesezugriff auf für Schüler relevante Informationen
GRANT SELECT ON LearnOn.Raeume TO 'LearnOn_Schueler';
GRANT SELECT ON LearnOn.Faecher TO 'LearnOn_Schueler';
GRANT SELECT ON LearnOn.Zeitslots TO 'LearnOn_Schueler';
GRANT SELECT ON LearnOn.Lerngruppen_Kurse TO 'LearnOn_Schueler';
GRANT SELECT ON LearnOn.Unterrichtsstunde TO 'LearnOn_Schueler';
-- Eingeschränkte Lehrerdaten (nur Kürzel, nicht private Daten)
GRANT SELECT (LehrerID, Kuerzel) ON LearnOn.Lehrer TO 'LearnOn_Schueler';



-- VERTRETUNGS_VERWALTER: Spezialzugriff für Vertretungen
-- Lesezugriff auf alle Stammdaten
GRANT SELECT ON LearnOn.Gebaeude TO 'LearnOn_Vertretungs_Verwalter';
GRANT SELECT ON LearnOn.Raeume TO 'LearnOn_Vertretungs_Verwalter';
GRANT SELECT ON LearnOn.Lehrer TO 'LearnOn_Vertretungs_Verwalter';
GRANT SELECT ON LearnOn.Faecher TO 'LearnOn_Vertretungs_Verwalter';
GRANT SELECT ON LearnOn.Lehrer_Faecher TO 'LearnOn_Vertretungs_Verwalter';
GRANT SELECT ON LearnOn.Zeitslots TO 'LearnOn_Vertretungs_Verwalter';
GRANT SELECT ON LearnOn.Lerngruppen_Kurse TO 'LearnOn_Vertretungs_Verwalter';

-- Vollzugriff auf Unterrichtsstunden (für Vertretungsmanagement)
GRANT SELECT, INSERT, UPDATE, DELETE ON LearnOn.Unterrichtsstunde TO 'LearnOn_Vertretungs_Verwalter';


-- SCHRITT 3: SICHERHEITS-VIEWS FÜR DATENSCHUTZ
-- View für Lehrkräfte: Nur eigene Stunden einsehen
CREATE VIEW LearnOn_MeineStunden AS
SELECT 
    CASE z.Wochentag 
        WHEN 1 THEN 'Montag'
        WHEN 2 THEN 'Dienstag'
        WHEN 3 THEN 'Mittwoch'
        WHEN 4 THEN 'Donnerstag'
        WHEN 5 THEN 'Freitag'
    END AS Wochentag,
    z.Stunde,
    f.Name AS Fach,
    lg.Name AS Lerngruppe,
    CONCAT(g.Name, ' - ', r.Name) AS Raum,
    u.Typ AS Stundentyp
FROM Unterrichtsstunde u
    INNER JOIN Zeitslots z ON u.ZeitSlotID = z.ZeitSlotID
    INNER JOIN Lerngruppen_Kurse lg ON u.LerngruppeID = lg.LerngruppeID  
    INNER JOIN Faecher f ON u.FachID = f.FachID
    INNER JOIN Lehrer l ON u.LehrerID = l.LehrerID
    INNER JOIN Raeume r ON u.RaumID = r.RaumID
    INNER JOIN Gebaeude g ON r.GebaeudeID = g.GebaeudeID
WHERE 
    l.Kuerzel = SUBSTRING_INDEX(SUBSTRING_INDEX(USER(), '@', 1), '_', -1) -- Filtert auf aktuellen Benutzer (z.B. lehrer_mue -> mue)
    AND u.Typ IN ('Regel', 'Vertretung');

-- View für Schüler: Anonymisierte Lehrerdaten
CREATE VIEW LearnOn_OeffentlicherStundenplan AS
SELECT 
    CASE z.Wochentag 
        WHEN 1 THEN 'Montag'
        WHEN 2 THEN 'Dienstag'
        WHEN 3 THEN 'Mittwoch'
        WHEN 4 THEN 'Donnerstag'
        WHEN 5 THEN 'Freitag'
    END AS Wochentag,
    z.Stunde,
    f.Name AS Fach,
    lg.Name AS Lerngruppe,
    l.Kuerzel AS Lehrer_Kuerzel,  -- Nur Kürzel, keine Namen
    r.Name AS Raum,
    u.Typ AS Stundentyp
FROM Unterrichtsstunde u
    INNER JOIN Zeitslots z ON u.ZeitSlotID = z.ZeitSlotID
    INNER JOIN Lerngruppen_Kurse lg ON u.LerngruppeID = lg.LerngruppeID
    INNER JOIN Faecher f ON u.FachID = f.FachID
    INNER JOIN Lehrer l ON u.LehrerID = l.LehrerID
    INNER JOIN Raeume r ON u.RaumID = r.RaumID
WHERE 
    u.Typ IN ('Regel', 'Vertretung');

-- SCHRITT 4: BENUTZERKONTEN ERSTELLEN (ohne Passwort)

-- ADMINISTRATIVE BENUTZER
-- Systemadministrator
CREATE USER IF NOT EXISTS 'admin_system'@'localhost';
GRANT 'LearnOn_Admin' TO 'admin_system'@'localhost';
SET DEFAULT ROLE 'LearnOn_Admin' FOR 'admin_system'@'localhost';

-- Schulleitung mit Verwaltungsrechten  
CREATE USER IF NOT EXISTS 'schulleitung_mueller'@'localhost';
GRANT 'LearnOn_Stundenplan_Verwalter' TO 'schulleitung_mueller'@'localhost';
SET DEFAULT ROLE 'LearnOn_Stundenplan_Verwalter' FOR 'schulleitung_mueller'@'localhost';



-- SEKRETARIAT UND VERWALTUNG
-- Sekretariat (Stundenplan-Verwaltung)
CREATE USER IF NOT EXISTS 'sekretariat_weber'@'localhost';
GRANT 'LearnOn_Stundenplan_Verwalter' TO 'sekretariat_weber'@'localhost';
SET DEFAULT ROLE 'LearnOn_Stundenplan_Verwalter' FOR 'sekretariat_weber'@'localhost';

-- Vertretungsplan-Verwaltung
CREATE USER IF NOT EXISTS 'vertretung_schmidt'@'localhost';
GRANT 'LearnOn_Vertretungs_Verwalter' TO 'vertretung_schmidt'@'localhost';
SET DEFAULT ROLE 'LearnOn_Vertretungs_Verwalter' FOR 'vertretung_schmidt'@'localhost';


-- LEHRKRÄFTE (Beispiele aus der Datenbank)
-- Dr. Maria Müller (Mathematik/Physik)
CREATE USER IF NOT EXISTS 'lehrer_mue'@'localhost';
GRANT 'LearnOn_Lehrer' TO 'lehrer_mue'@'localhost';
SET DEFAULT ROLE 'LearnOn_Lehrer' FOR 'lehrer_mue'@'localhost';

-- Thomas Schmidt (Deutsch/Geschichte)
CREATE USER IF NOT EXISTS 'lehrer_sch'@'localhost';
GRANT 'LearnOn_Lehrer' TO 'lehrer_sch'@'localhost';
SET DEFAULT ROLE 'LearnOn_Lehrer' FOR 'lehrer_sch'@'localhost';

-- Sarah Weber (Englisch/Erdkunde)
CREATE USER IF NOT EXISTS 'lehrer_web'@'localhost';
GRANT 'LearnOn_Lehrer' TO 'lehrer_web'@'localhost';
SET DEFAULT ROLE 'LearnOn_Lehrer' FOR 'lehrer_web'@'localhost';

-- Prof. Klaus Neumann (Chemie/Biologie)
CREATE USER IF NOT EXISTS 'lehrer_neu'@'localhost';
GRANT 'LearnOn_Lehrer' TO 'lehrer_neu'@'localhost';
SET DEFAULT ROLE 'LearnOn_Lehrer' FOR 'lehrer_neu'@'localhost';


-- SCHÜLER UND ELTERN (Beispiele)
-- Schülervertreter
CREATE USER IF NOT EXISTS 'schueler_sv'@'localhost';
GRANT 'LearnOn_Schueler' TO 'schueler_sv'@'localhost';
SET DEFAULT ROLE 'LearnOn_Schueler' FOR 'schueler_sv'@'localhost';

-- Elternvertreter
CREATE USER IF NOT EXISTS 'eltern_beirat'@'localhost';
GRANT 'LearnOn_Schueler' TO 'eltern_beirat'@'localhost';
SET DEFAULT ROLE 'LearnOn_Schueler' FOR 'eltern_beirat'@'localhost';

-- Öffentlicher Lesezugriff (für Web-Portal)
CREATE USER IF NOT EXISTS 'web_portal'@'localhost';
GRANT 'LearnOn_Schueler' TO 'web_portal'@'localhost';
SET DEFAULT ROLE 'LearnOn_Schueler' FOR 'web_portal'@'localhost';


-- SCHRITT 5: BERECHTIGUNGEN AUF VIEWS VERGEBEN
-- Lehrkräfte dürfen ihre eigenen Stunden einsehen
GRANT SELECT ON LearnOn.LearnOn_MeineStunden TO 'LearnOn_Lehrer';

-- Schüler/Eltern dürfen öffentlichen Stundenplan einsehen  
GRANT SELECT ON LearnOn.LearnOn_OeffentlicherStundenplan TO 'LearnOn_Schueler';

FLUSH PRIVILEGES;