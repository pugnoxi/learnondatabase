SELECT 
    l.Name AS Lehrername,
    l.Kuerzel AS Kuerzel,
    COUNT(u.StundeID) AS Anzahl_Stunden,
    CASE 
        WHEN COUNT(u.StundeID) >= 20 THEN 'Hoch'
        WHEN COUNT(u.StundeID) >= 15 THEN 'Mittel' 
        WHEN COUNT(u.StundeID) >= 10 THEN 'Normal'
        ELSE 'Niedrig'
    END AS Auslastung
FROM Lehrer l
    LEFT JOIN Unterrichtsstunde u ON l.LehrerID = u.LehrerID AND u.Typ = 'Regel'
GROUP BY l.LehrerID, l.Name, l.Kuerzel
ORDER BY COUNT(u.StundeID) DESC, l.Name;