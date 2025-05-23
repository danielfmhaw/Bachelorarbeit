-- KUNDEN_MAT_OVERVIEW
SELECT LAND,
       COUNT(*) AS ANZAHL_KUNDEN
FROM KUNDEN
WHERE LAND IS NOT NULL
  AND TIMESTAMPDIFF(YEAR, GEBURTSTAG, CURDATE()) < 50
GROUP BY LAND;

DROP TABLE KUNDEN_MAT_OVERVIEW;
CREATE TABLE IF NOT EXISTS KUNDEN_MAT_OVERVIEW AS
SELECT LAND,
       COUNT(*) AS ANZAHL_KUNDEN
FROM KUNDEN
WHERE LAND IS NOT NULL
  AND TIMESTAMPDIFF(YEAR, GEBURTSTAG, CURDATE()) < 50
GROUP BY LAND;

CREATE TRIGGER UPDATE_KUNDEN_MAT_OVERVIEW_AFTER_INSERT
    AFTER INSERT ON KUNDEN
    FOR EACH ROW
BEGIN
    UPDATE KUNDEN_MAT_OVERVIEW
    SET ANZAHL_KUNDEN = ANZAHL_KUNDEN + 1
    WHERE LAND = NEW.LAND AND LAND IS NOT NULL;

    INSERT INTO KUNDEN_MAT_OVERVIEW (LAND, ANZAHL_KUNDEN)
    SELECT NEW.LAND, 1
    WHERE NOT EXISTS (
        SELECT 1
        FROM KUNDEN_MAT_OVERVIEW
        WHERE LAND = NEW.LAND AND LAND IS NOT NULL
    );
END;

CREATE TRIGGER UPDATE_KUNDEN_MAT_OVERVIEW_AFTER_DELETE
    AFTER DELETE ON KUNDEN
    FOR EACH ROW
BEGIN
    UPDATE KUNDEN_MAT_OVERVIEW
    SET ANZAHL_KUNDEN = ANZAHL_KUNDEN - 1
    WHERE LAND = OLD.LAND AND LAND IS NOT NULL;

    DELETE FROM KUNDEN_MAT_OVERVIEW
    WHERE LAND = OLD.LAND AND ANZAHL_KUNDEN <= 0;
END;

DROP TRIGGER IF EXISTS UPDATE_KUNDEN_MAT_OVERVIEW_AFTER_INSERT;
DROP TRIGGER IF EXISTS UPDATE_KUNDEN_MAT_OVERVIEW_AFTER_DELETE;
SELECT *
FROM KUNDEN_MAT_OVERVIEW;

-- Kunden
DROP TABLE KUNDEN;
CREATE TABLE IF NOT EXISTS KUNDEN
(
    KUNDEN_ID     INT PRIMARY KEY,
    NAME          VARCHAR(255),
    GEBURTSTAG    DATE,
    ADRESSE       VARCHAR(255),
    STADT         VARCHAR(100),
    POSTLEITZAHL  VARCHAR(10),
    LAND          VARCHAR(100),
    EMAIL         VARCHAR(255) UNIQUE,
    TELEFONNUMMER VARCHAR(20)
);

SELECT *
FROM KUNDEN;
DELETE
FROM KUNDEN
WHERE KUNDEN_ID = 10;
INSERT INTO KUNDEN (KUNDEN_ID, NAME, GEBURTSTAG, ADRESSE, STADT, POSTLEITZAHL, LAND, EMAIL, TELEFONNUMMER)
VALUES (10, 'fwfefo5V0pwdwdkAkizbpwvt4pojad82qmekarhk45v0g5u', '1988-10-05', 'Address_10', 'City_77', '20882',
        'Germany', 'customer10@example.com', '+491576399169');

SELECT
    LAND,
    COUNT(*) AS ANZAHL_KUNDEN
FROM KUNDEN
WHERE LAND IS NOT NULL
  AND TIMESTAMPDIFF(YEAR, GEBURTSTAG, CURDATE()) < 50
GROUP BY LAND;

DROP VIEW  KUNDEN_OVERVIEW;
CREATE VIEW KUNDEN_OVERVIEW AS
SELECT
    LAND,
    COUNT(*) AS ANZAHL_KUNDEN
FROM KUNDEN
WHERE LAND IS NOT NULL
  AND TIMESTAMPDIFF(YEAR, GEBURTSTAG, CURDATE()) < 50
GROUP BY LAND;
