import sqlite3

def get_teacher_schedule_unsafe(teacher_name):
    """❌ DON'T DO THIS - Anfällig für SQL Injection"""
    conn = sqlite3.connect('learnon.db')
    cursor = conn.cursor()
    
    # Das hier ist der Grund, warum wir nachts nicht schlafen können
    query = f"SELECT fach, raum, wochentag FROM stundenplan WHERE lehrer = '{teacher_name}'"
    cursor.execute(query)
    
    return cursor.fetchall()

def get_teacher_schedule_safe(teacher_name):
    """✅ SO geht's richtig - Parameterized Queries"""
    conn = sqlite3.connect('learnon.db')
    cursor = conn.cursor()
    
    # Der Platzhalter ? ist dein bester Freund. SQLite escapet automatisch.
    query = "SELECT fach, raum, wochentag FROM stundenplan WHERE lehrer = ?"
    cursor.execute(query, (teacher_name,))
    
    return cursor.fetchall()

# Warum das wichtig ist? Stell dir vor, jemand gibt das hier als teacher_name ein:
# "Schmidt'; DROP TABLE stundenplan; --"
# Die unsafe Version würde deinen ganzen Stundenplan löschen. Die safe Version treated es als harmlosen String.