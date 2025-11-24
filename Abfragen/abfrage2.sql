SELECT 
    r.Name AS Fachraum,
    r.Typ AS Raumtyp,
    g.Name AS Gebaeude,
    'FREI' AS Status
FROM Raeume r
    INNER JOIN Gebaeude g ON r.GebaeudeID = g.GebaeudeID
WHERE r.Typ IN ('Chemie', 'IT', 'Physik', 'Biologie')
    AND r.RaumID NOT IN (
        SELECT u.RaumID 
        FROM Unterrichtsstunde u
        INNER JOIN Zeitslots z ON u.ZeitSlotID = z.ZeitSlotID
        WHERE z.Wochentag = 2 AND z.Stunde = 3 AND u.Typ = 'Regel'
    )
ORDER BY r.Typ, r.Name;