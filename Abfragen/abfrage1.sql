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