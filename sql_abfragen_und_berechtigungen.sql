-- ================================================================================
-- LearnOn Stundenplan-Verwaltungssystem - SQL-Abfragen für typische Fragestellungen
-- ================================================================================
-- Inhalte:
-- 1. Stundenplan für Klasse '10B'
-- 2. Lehrerauslastung pro Woche
-- 3. Freie Fachräume zu bestimmten Zeiten
-- ================================================================================

USE LearnOn;

-- ================================================================================
-- TEIL 1: SQL-ABFRAGEN FÜR TYPISCHE FRAGESTELLUNGEN
-- ================================================================================

-- ********************************************************************************
-- ABFRAGE 1: Filter & Join
-- Fragestellung: "Zeige mir den kompletten Stundenplan (Wochentag, Stunde, Fach, 
-- Lehrer, Raum) für die Klasse '10B'."
-- ********************************************************************************


SELECT 
    -- Wochentag als lesbare Bezeichnung
    CASE z.Wochentag 
        WHEN 1 THEN 'Montag'
        WHEN 2 THEN 'Dienstag'
        WHEN 3 THEN 'Mittwoch'
        WHEN 4 THEN 'Donnerstag'
        WHEN 5 THEN 'Freitag'
    END AS Wochentag,
    
    -- Stundennummer
    z.Stunde,
    
    -- Fachbezeichnung
    f.Name AS Fach,
    
    -- Lehrkraft (Kürzel und Name)
    CONCAT(l.Kuerzel, ' (', l.Name, ')') AS Lehrer,
    
    -- Raum mit Gebäude-Information
    CONCAT(g.Name, ' - ', r.Name) AS Raum,
    
    -- Stundentyp zur Unterscheidung Regel/Vertretung/Ausfall
    u.Typ AS Stundentyp

FROM Unterrichtsstunde u
    -- Verknüpfung aller relevanten Stammdaten
    INNER JOIN Zeitslots z ON u.ZeitSlotID = z.ZeitSlotID
    INNER JOIN Lerngruppen_Kurse lg ON u.LerngruppeID = lg.LerngruppeID
    INNER JOIN Faecher f ON u.FachID = f.FachID
    INNER JOIN Lehrer l ON u.LehrerID = l.LehrerID
    INNER JOIN Raeume r ON u.RaumID = r.RaumID
    INNER JOIN Gebaeude g ON r.GebaeudeID = g.GebaeudeID

WHERE 
    -- Filter auf Klasse '10B'
    lg.Name = '10B'
    -- Nur aktive Stunden anzeigen (keine Ausfälle)
    AND u.Typ IN ('Regel', 'Vertretung')

ORDER BY 
    z.Wochentag,    -- Chronologisch: Montag bis Freitag
    z.Stunde;       -- Chronologisch: 1. bis 8. Stunde

-- Erwartetes Ergebnis: Vollständiger Wochenplan der Klasse 10B mit allen Details


-- ********************************************************************************
-- ABFRAGE 2: Aggregation & Group By
-- Fragestellung: "Wie viele Unterrichtsstunden hält jeder Lehrer (Kürzel) in der 
-- aktuellen Woche (inkl. Vertretungen)?"
-- ********************************************************************************

SELECT 
    l.Kuerzel AS Lehrer_Kuerzel,
    l.Name AS Lehrer_Name,
    
    -- Gesamtanzahl Unterrichtsstunden (Regel + Vertretung)
    COUNT(*) AS Anzahl_Stunden,
    
    -- Aufschlüsselung nach Stundentyp für bessere Übersicht
    COUNT(CASE WHEN u.Typ = 'Regel' THEN 1 END) AS Regel_Stunden,
    COUNT(CASE WHEN u.Typ = 'Vertretung' THEN 1 END) AS Vertretungs_Stunden

FROM Unterrichtsstunde u
    INNER JOIN Lehrer l ON u.LehrerID = l.LehrerID

WHERE 
    -- Nur gehaltene Stunden zählen (keine Ausfälle)
    u.Typ IN ('Regel', 'Vertretung')

GROUP BY 
    l.LehrerID,     -- Gruppierung nach Lehrer (ID für Eindeutigkeit)
    l.Kuerzel,      -- Für SELECT-Auswahl
    l.Name          -- Für SELECT-Auswahl

ORDER BY 
    Anzahl_Stunden DESC,    -- Absteigende Sortierung nach Gesamtstunden
    l.Kuerzel;              -- Sekundär alphabetisch nach Kürzel

-- Erwartetes Ergebnis: Rangliste aller Lehrkräfte mit ihrer Unterrichtsbelastung


-- ********************************************************************************
-- ABFRAGE 3: Filter & Subquery/CTE
-- Fragestellung: "Welche Fachräume (z.B. 'Chemie', 'IT') sind am Dienstag in der 
-- 3. und 4. Stunde noch frei (nicht belegt)?"
-- ********************************************************************************


-- CTE: Alle Fachräume des gewünschten Typs ermitteln
WITH Fachräume AS (
    SELECT 
        r.RaumID,
        r.Name AS Raum_Name,
        r.Typ AS Raum_Typ,
        g.Name AS Gebäude_Name
    FROM Raeume r
        INNER JOIN Gebaeude g ON r.GebaeudeID = g.GebaeudeID
    WHERE 
        -- Nur Fachräume für Chemie und IT
        r.Typ IN ('Chemie', 'IT')
),

-- CTE: Zeitslots für Dienstag 3. und 4. Stunde
Gesuchte_Zeitslots AS (
    SELECT 
        z.ZeitSlotID,
        z.Wochentag,
        z.Stunde
    FROM Zeitslots z
    WHERE 
        z.Wochentag = 2         -- Dienstag
        AND z.Stunde IN (3, 4)  -- 3. und 4. Stunde
)

-- Hauptabfrage: Freie Fachräume ermitteln
SELECT 
    f.Raum_Typ,
    f.Gebäude_Name,
    f.Raum_Name,
    gzs.Wochentag,
    gzs.Stunde,
    'Frei verfügbar' AS Status

FROM Fachräume f
    CROSS JOIN Gesuchte_Zeitslots gzs  -- Kartesisches Produkt: Alle Raum-Zeit-Kombinationen

WHERE 
    -- Subquery: Raum ist NICHT belegt zur angegebenen Zeit
    NOT EXISTS (
        SELECT 1
        FROM Unterrichtsstunde u
        WHERE 
            u.RaumID = f.RaumID 
            AND u.ZeitSlotID = gzs.ZeitSlotID
            AND u.Typ IN ('Regel', 'Vertretung')  -- Ausfälle blockieren nicht
    )

ORDER BY 
    f.Raum_Typ,        -- Gruppierung nach Fachbereich
    gzs.Stunde,        -- Chronologisch nach Stunde
    f.Raum_Name;       -- Alphabetisch nach Raum

-- Erwartetes Ergebnis: Liste aller freien Fachräume mit Zeit-Details

-- Alternative Lösung ohne CTE (reine Subquery-Variante):
-- Diese Variante zeigt eine kompaktere Lösung für dasselbe Problem

/*
SELECT 
    r.Typ AS Raum_Typ,
    g.Name AS Gebäude_Name,
    r.Name AS Raum_Name,
    z.Wochentag,
    z.Stunde,
    'Frei verfügbar' AS Status

FROM Raeume r
    INNER JOIN Gebaeude g ON r.GebaeudeID = g.GebaeudeID
    CROSS JOIN Zeitslots z

WHERE 
    -- Nur Fachräume
    r.Typ IN ('Chemie', 'IT')
    -- Nur Dienstag, 3. und 4. Stunde
    AND z.Wochentag = 2 
    AND z.Stunde IN (3, 4)
    -- Raum ist nicht belegt
    AND NOT EXISTS (
        SELECT 1
        FROM Unterrichtsstunde u
        WHERE 
            u.RaumID = r.RaumID 
            AND u.ZeitSlotID = z.ZeitSlotID
            AND u.Typ IN ('Regel', 'Vertretung')
    )

ORDER BY 
    r.Typ, z.Stunde, r.Name;
*/