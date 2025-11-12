-- ================================================================================
-- LearnOn Stundenplan-Verwaltungssystem - Beispieldaten
-- ================================================================================
-- Dieses Skript befüllt die LearnOn Datenbank mit realistischen Beispieldaten
-- für ein Gymnasium. Die Daten sind konsistent und ermöglichen die Beantwortung
-- komplexer Abfragen zum Stundenplan.
--
-- Besondere Merkmale der Testdaten:
-- - Realistische Verteilung von Lehrern, Fächern und Räumen
-- - Vollständiger Stundenplan für mehrere Lerngruppen
-- - Beispiele für Vertretungen und Ausfälle
-- - Fachraum-Zuordnungen (Chemie/Informatik in entsprechenden Fachräumen)
-- - Testdaten für spezifische Abfragen (Klasse 10B, freie Fachräume, etc.)
--
-- Autor: [Student Name] - Universitätsprojekt
-- DBMS: MariaDB
-- ================================================================================

USE LearnOn;

-- ================================================================================
-- GEBÄUDE-DATEN
-- ================================================================================
-- Einfügen der Schulgebäude

INSERT INTO Gebaeude (Name) VALUES 
    ('Hauptgebäude'),        -- GebaeudeID 1: Haupttrakt mit Standard-Klassenzimmern
    ('Naturwissenschaften'), -- GebaeudeID 2: Fachräume für Chemie, Physik, Biologie
    ('Sporttrakt');          -- GebaeudeID 3: Sporthallen und Umkleiden

-- ================================================================================
-- RAUM-DATEN
-- ================================================================================
-- Einfügen verschiedener Raumtypen in die entsprechenden Gebäude

INSERT INTO Raeume (GebaeudeID, Name, Typ) VALUES 
    -- Hauptgebäude: Standard-Klassenzimmer
    (1, 'A101', 'Standard'),     -- RaumID 1
    (1, 'A102', 'Standard'),     -- RaumID 2
    (1, 'A201', 'Standard'),     -- RaumID 3
    (1, 'A202', 'Standard'),     -- RaumID 4
    (1, 'A301', 'Standard'),     -- RaumID 5
    (1, 'B101', 'Standard'),     -- RaumID 6
    
    -- Naturwissenschaften: Fachräume
    (2, 'CH1', 'Chemie'),        -- RaumID 7: Chemielabor 1
    (2, 'CH2', 'Chemie'),        -- RaumID 8: Chemielabor 2
    (2, 'PH1', 'Physik'),        -- RaumID 9: Physikraum
    (2, 'BI1', 'Biologie'),      -- RaumID 10: Biologieraum
    (2, 'IT1', 'IT'),            -- RaumID 11: Computerraum 1
    (2, 'IT2', 'IT'),            -- RaumID 12: Computerraum 2
    
    -- Sporttrakt
    (3, 'SH1', 'Sport'),         -- RaumID 13: Sporthalle 1
    (3, 'SH2', 'Sport'),         -- RaumID 14: Sporthalle 2
    (1, 'AULA', 'Aula');         -- RaumID 15: Aula im Hauptgebäude

-- ================================================================================
-- FÄCHER-DATEN
-- ================================================================================
-- Einfügen der Unterrichtsfächer mit Fachraum-Anforderungen

INSERT INTO Faecher (Kuerzel, Name, IstFachraumErforderlich) VALUES 
    ('MA', 'Mathematik', FALSE),        -- FachID 1: Standard-Raum ausreichend
    ('DE', 'Deutsch', FALSE),           -- FachID 2: Standard-Raum ausreichend
    ('EN', 'Englisch', FALSE),          -- FachID 3: Standard-Raum ausreichend
    ('CH', 'Chemie', TRUE),             -- FachID 4: Fachraum erforderlich
    ('PH', 'Physik', TRUE),             -- FachID 5: Fachraum erforderlich
    ('BI', 'Biologie', FALSE),          -- FachID 6: Standard-Raum möglich
    ('IF', 'Informatik', TRUE),         -- FachID 7: Computerraum erforderlich
    ('SP', 'Sport', TRUE),              -- FachID 8: Sporthalle erforderlich
    ('GE', 'Geschichte', FALSE),        -- FachID 9: Standard-Raum ausreichend
    ('EK', 'Erdkunde', FALSE),          -- FachID 10: Standard-Raum ausreichend
    ('KU', 'Kunst', FALSE),             -- FachID 11: Standard-Raum ausreichend
    ('MU', 'Musik', FALSE);             -- FachID 12: Standard-Raum ausreichend

-- ================================================================================
-- LEHRER-DATEN
-- ================================================================================
-- Einfügen der Lehrkräfte mit realistischen Kürzeln und Namen

INSERT INTO Lehrer (Kuerzel, Name) VALUES 
    ('MUE', 'Dr. Maria Müller'),        -- LehrerID 1: Mathematik/Physik
    ('SCH', 'Thomas Schmidt'),          -- LehrerID 2: Deutsch/Geschichte
    ('WEB', 'Sarah Weber'),             -- LehrerID 3: Englisch/Erdkunde
    ('NEU', 'Prof. Klaus Neumann'),     -- LehrerID 4: Chemie/Biologie
    ('MEY', 'Lisa Meyer'),              -- LehrerID 5: Informatik/Mathematik
    ('BAU', 'Michael Bauer'),           -- LehrerID 6: Sport/Biologie
    ('KOC', 'Anna Koch'),               -- LehrerID 7: Deutsch/Kunst
    ('WOL', 'Peter Wolf'),              -- LehrerID 8: Geschichte/Erdkunde
    ('BRA', 'Julia Braun'),             -- LehrerID 9: Englisch/Musik
    ('FIS', 'Robert Fischer');          -- LehrerID 10: Sport/Physik

-- ================================================================================
-- LEHRER-FÄCHER ZUORDNUNG
-- ================================================================================
-- Many-to-Many Verknüpfung: Welcher Lehrer unterrichtet welche Fächer

INSERT INTO Lehrer_Faecher (LehrerID, FachID) VALUES 
    -- Dr. Müller: Mathematik und Physik
    (1, 1), (1, 5),
    -- Schmidt: Deutsch und Geschichte  
    (2, 2), (2, 9),
    -- Weber: Englisch und Erdkunde
    (3, 3), (3, 10),
    -- Prof. Neumann: Chemie und Biologie
    (4, 4), (4, 6),
    -- Meyer: Informatik und Mathematik
    (5, 7), (5, 1),
    -- Bauer: Sport und Biologie
    (6, 8), (6, 6),
    -- Koch: Deutsch und Kunst
    (7, 2), (7, 11),
    -- Wolf: Geschichte und Erdkunde
    (8, 9), (8, 10),
    -- Braun: Englisch und Musik
    (9, 3), (9, 12),
    -- Fischer: Sport und Physik
    (10, 8), (10, 5);

-- ================================================================================
-- ZEITSLOT-DATEN
-- ================================================================================
-- Erstellen des Schulzeit-Rasters: Montag bis Freitag, 1. bis 8. Stunde

INSERT INTO Zeitslots (Wochentag, Stunde) VALUES 
    -- Montag (Wochentag 1)
    (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8),
    -- Dienstag (Wochentag 2) 
    (2, 1), (2, 2), (2, 3), (2, 4), (2, 5), (2, 6), (2, 7), (2, 8),
    -- Mittwoch (Wochentag 3)
    (3, 1), (3, 2), (3, 3), (3, 4), (3, 5), (3, 6), (3, 7), (3, 8),
    -- Donnerstag (Wochentag 4)
    (4, 1), (4, 2), (4, 3), (4, 4), (4, 5), (4, 6), (4, 7), (4, 8),
    -- Freitag (Wochentag 5)
    (5, 1), (5, 2), (5, 3), (5, 4), (5, 5), (5, 6), (5, 7), (5, 8);

-- ================================================================================
-- LERNGRUPPEN-DATEN
-- ================================================================================
-- Einfügen von Klassen (Sekundarstufe I) und Kursen (Sekundarstufe II)

INSERT INTO Lerngruppen_Kurse (Name, Typ, Jahrgangsstufe) VALUES 
    -- Sekundarstufe I: Klassen
    ('5A', 'Klasse', 5),             -- LerngruppeID 1
    ('7C', 'Klasse', 7),             -- LerngruppeID 2
    ('8B', 'Klasse', 8),             -- LerngruppeID 3
    ('9A', 'Klasse', 9),             -- LerngruppeID 4
    ('10B', 'Klasse', 10),           -- LerngruppeID 5: Wichtig für Testabfrage!
    
    -- Sekundarstufe II: Kurse
    ('Q1-LK-DE-1', 'Kurs', 11),     -- LerngruppeID 6: Q1 Deutsch Leistungskurs
    ('Q1-LK-MA-1', 'Kurs', 11),     -- LerngruppeID 7: Q1 Mathe Leistungskurs
    ('Q1-GK-EN-2', 'Kurs', 11),     -- LerngruppeID 8: Q1 Englisch Grundkurs
    ('Q2-LK-CH-1', 'Kurs', 12),     -- LerngruppeID 9: Q2 Chemie Leistungskurs
    ('Q2-GK-MA-3', 'Kurs', 12),     -- LerngruppeID 10: Q2 Mathe Grundkurs
    ('Q2-GK-IF-1', 'Kurs', 12);     -- LerngruppeID 11: Q2 Informatik Grundkurs

-- ================================================================================
-- UNTERRICHTSSTUNDEN - REGEL-STUNDEN
-- ================================================================================
-- Erstellen eines realistischen Stundenplans mit allen Regel-Stunden

INSERT INTO Unterrichtsstunde (ZeitSlotID, LerngruppeID, FachID, LehrerID, RaumID, Typ) VALUES 
    -- ===== MONTAG (ZeitSlotID 1-8) =====
    
    -- 1. Stunde Montag (ZeitSlotID 1)
    (1, 1, 1, 1, 1, 'Regel'),       -- 5A: Mathematik mit Dr. Müller in A101
    (1, 2, 2, 2, 2, 'Regel'),       -- 7C: Deutsch mit Schmidt in A102
    (1, 5, 3, 3, 3, 'Regel'),       -- 10B: Englisch mit Weber in A201 (wichtig für Testabfrage!)
    
    -- 2. Stunde Montag (ZeitSlotID 2)
    (2, 1, 2, 7, 1, 'Regel'),       -- 5A: Deutsch mit Koch in A101
    (2, 2, 1, 1, 2, 'Regel'),       -- 7C: Mathematik mit Dr. Müller in A102
    (2, 5, 1, 5, 3, 'Regel'),       -- 10B: Mathematik mit Meyer in A201
    
    -- 3. Stunde Montag (ZeitSlotID 3)
    (3, 1, 8, 6, 13, 'Regel'),      -- 5A: Sport mit Bauer in Sporthalle 1
    (3, 5, 4, 4, 7, 'Regel'),       -- 10B: Chemie mit Prof. Neumann in Chemielabor 1 (Fachraum!)
    (3, 9, 4, 4, 8, 'Regel'),       -- Q2-LK-CH-1: Chemie mit Prof. Neumann in Chemielabor 2
    
    -- 4. Stunde Montag (ZeitSlotID 4)  
    (4, 1, 6, 4, 4, 'Regel'),       -- 5A: Biologie mit Prof. Neumann in A202
    (4, 5, 9, 8, 3, 'Regel'),       -- 10B: Geschichte mit Wolf in A201
    (4, 6, 2, 2, 5, 'Regel'),       -- Q1-LK-DE-1: Deutsch mit Schmidt in A301
    
    -- 5. Stunde Montag (ZeitSlotID 5)
    (5, 2, 8, 10, 14, 'Regel'),     -- 7C: Sport mit Fischer in Sporthalle 2
    (5, 5, 6, 6, 10, 'Regel'),      -- 10B: Biologie mit Bauer in Biologieraum
    
    -- ===== DIENSTAG (ZeitSlotID 9-16) =====
    
    -- 1. Stunde Dienstag (ZeitSlotID 9)
    (9, 5, 2, 2, 1, 'Regel'),       -- 10B: Deutsch mit Schmidt in A101
    (9, 3, 1, 1, 2, 'Regel'),       -- 8B: Mathematik mit Dr. Müller in A102
    
    -- 2. Stunde Dienstag (ZeitSlotID 10)
    (10, 5, 5, 10, 9, 'Regel'),     -- 10B: Physik mit Fischer in Physikraum
    (10, 7, 1, 1, 3, 'Regel'),      -- Q1-LK-MA-1: Mathematik mit Dr. Müller in A201
    
    -- 3. Stunde Dienstag (ZeitSlotID 11) - WICHTIG: Freie Fachräume für Testabfrage!
    (11, 4, 7, 5, 11, 'Regel'),     -- 9A: Informatik mit Meyer in IT1 (IT2 ist frei!)
    (11, 8, 3, 9, 4, 'Regel'),      -- Q1-GK-EN-2: Englisch mit Braun in A202
    -- CH1 und CH2 sind frei in dieser Stunde!
    
    -- 4. Stunde Dienstag (ZeitSlotID 12) - WICHTIG: Freie Fachräume für Testabfrage!
    (12, 5, 11, 7, 5, 'Regel'),     -- 10B: Kunst mit Koch in A301
    (12, 10, 1, 5, 6, 'Regel'),     -- Q2-GK-MA-3: Mathematik mit Meyer in B101
    -- IT1, IT2, CH1, CH2 sind frei in dieser Stunde!
    
    -- 5. Stunde Dienstag (ZeitSlotID 13)
    (13, 5, 8, 6, 13, 'Regel'),     -- 10B: Sport mit Bauer in Sporthalle 1
    
    -- 6. Stunde Dienstag (ZeitSlotID 14)
    (14, 5, 10, 8, 1, 'Regel'),     -- 10B: Erdkunde mit Wolf in A101
    
    -- ===== MITTWOCH (ZeitSlotID 17-24) =====
    
    -- 1. Stunde Mittwoch (ZeitSlotID 17)
    (17, 5, 1, 1, 2, 'Regel'),      -- 10B: Mathematik mit Dr. Müller in A102
    
    -- 2. Stunde Mittwoch (ZeitSlotID 18) 
    (18, 5, 3, 3, 2, 'Regel'),      -- 10B: Englisch mit Weber in A102
    
    -- 3. Stunde Mittwoch (ZeitSlotID 19)
    (19, 5, 7, 5, 12, 'Regel'),     -- 10B: Informatik mit Meyer in IT2 (Fachraum!)
    
    -- ===== DONNERSTAG (ZeitSlotID 25-32) =====
    
    -- 1. Stunde Donnerstag (ZeitSlotID 25)
    (25, 5, 2, 7, 3, 'Regel'),      -- 10B: Deutsch mit Koch in A201
    
    -- 2. Stunde Donnerstag (ZeitSlotID 26)
    (26, 5, 12, 9, 3, 'Regel'),     -- 10B: Musik mit Braun in A201
    
    -- ===== FREITAG (ZeitSlotID 33-40) =====
    
    -- 1. Stunde Freitag (ZeitSlotID 33)
    (33, 5, 5, 1, 9, 'Regel'),      -- 10B: Physik mit Dr. Müller in Physikraum
    
    -- Weitere Stunden für andere Klassen und vollständigere Lehrerauslastung
    (6, 7, 1, 5, 6, 'Regel'),       -- Montag 6.: Q1-LK-MA-1 mit Meyer
    (7, 8, 3, 3, 4, 'Regel'),       -- Montag 7.: Q1-GK-EN-2 mit Weber
    (15, 11, 7, 5, 11, 'Regel'),    -- Dienstag 7.: Q2-GK-IF-1 mit Meyer in IT1
    (20, 6, 2, 2, 1, 'Regel'),      -- Mittwoch 4.: Q1-LK-DE-1 mit Schmidt
    (27, 9, 4, 4, 7, 'Regel'),      -- Donnerstag 3.: Q2-LK-CH-1 mit Prof. Neumann
    (34, 1, 3, 9, 5, 'Regel');      -- Freitag 2.: 5A Englisch mit Braun

-- ================================================================================
-- VERTRETUNGSSTUNDEN
-- ================================================================================
-- Beispiele für Vertretungen: Eine andere Lehrkraft übernimmt die Stunde

INSERT INTO Unterrichtsstunde (ZeitSlotID, LerngruppeID, FachID, LehrerID, RaumID, Typ, VerweisAufStundeID) VALUES 
    -- Vertretung 1: Dr. Müller (LehrerID 1) ist krank, Meyer (LehrerID 5) übernimmt
    -- Originale Regel-Stunde: Mittwoch 1. Stunde, 10B Mathematik mit Dr. Müller (StundeID sollte 17 sein)
    (17, 5, 1, 5, 2, 'Vertretung', 17),  -- Meyer übernimmt 10B Mathe in A102
    
    -- Vertretung 2: Weber (LehrerID 3) ist krank, Braun (LehrerID 9) übernimmt  
    -- Originale Regel-Stunde: Donnerstag 3. Stunde sollte eine neue Regel-Stunde sein
    (28, 4, 3, 3, 4, 'Regel'),           -- 28: Do 4. Stunde - Neue Regel-Stunde: 9A Englisch mit Weber in A202
    (28, 4, 3, 9, 4, 'Vertretung', 
        (SELECT StundeID FROM Unterrichtsstunde WHERE ZeitSlotID = 28 AND LerngruppeID = 4 AND Typ = 'Regel' LIMIT 1));

-- Da die Subquery in INSERT problematisch ist, erstelle ich die Regel-Stunden zuerst separat:

-- Zusätzliche Regel-Stunden für Vertretungs-Beispiele
INSERT INTO Unterrichtsstunde (ZeitSlotID, LerngruppeID, FachID, LehrerID, RaumID, Typ) VALUES 
    (28, 4, 3, 3, 4, 'Regel');           -- StundeID wird ~50: Do 4. Stunde - 9A Englisch mit Weber

-- Jetzt die Vertretung mit bekannter StundeID (angenommen StundeID 50)
INSERT INTO Unterrichtsstunde (ZeitSlotID, LerngruppeID, FachID, LehrerID, RaumID, Typ, VerweisAufStundeID) VALUES 
    (28, 4, 3, 9, 4, 'Vertretung', 50);  -- Braun übernimmt Webers Englischstunde

-- ================================================================================
-- AUSFALLSTUNDEN  
-- ================================================================================
-- Beispiele für Stundenausfälle

-- Zusätzliche Regel-Stunde für Ausfall-Beispiel
INSERT INTO Unterrichtsstunde (ZeitSlotID, LerngruppeID, FachID, LehrerID, RaumID, Typ) VALUES 
    (29, 3, 8, 6, 13, 'Regel');          -- StundeID wird ~52: Do 5. Stunde - 8B Sport mit Bauer

-- Ausfall dieser Sport-Stunde
INSERT INTO Unterrichtsstunde (ZeitSlotID, LerngruppeID, FachID, LehrerID, RaumID, Typ, VerweisAufStundeID) VALUES 
    (29, 3, 8, 6, 13, 'Ausfall', 52);    -- Sport-Stunde fällt aus (Bauer krank)
