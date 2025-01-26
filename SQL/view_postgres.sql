-- Create tables
CREATE TABLE KUNDEN
(
    KUNDEN_ID     SERIAL PRIMARY KEY,
    NAME          VARCHAR(255),
    GEBURTSTAG    DATE,
    ADRESSE       VARCHAR(255),
    STADT         VARCHAR(100),
    POSTLEITZAHL  VARCHAR(10),
    LAND          VARCHAR(100),
    EMAIL         VARCHAR(255) UNIQUE,
    TELEFONNUMMER VARCHAR(20)
);

CREATE TABLE BESTELLUNG
(
    BESTELLUNG_ID SERIAL PRIMARY KEY,
    BESTELLDATUM  DATE,
    ARTIKEL_ID    INT,
    UMSATZ        INT,
    FK_KUNDEN     INT NOT NULL,
    FOREIGN KEY (FK_KUNDEN) REFERENCES KUNDEN (KUNDEN_ID)
);

-- Insert sample data
INSERT INTO KUNDEN (NAME, GEBURTSTAG, ADRESSE, STADT, POSTLEITZAHL, LAND, EMAIL, TELEFONNUMMER)
VALUES ('Max Mustermann', '1985-06-15', 'Musterstraße 1', 'Berlin', '10115', 'Deutschland', 'max.mustermann@email.com',
        '0301234567'),
       ('Anna Schmidt', '1990-03-22', 'Beispielweg 3', 'München', '80331', 'Deutschland', 'anna.schmidt@email.com',
        '0892345678'),
       ('Peter Müller', '1980-11-30', 'Hauptstraße 12', 'Hamburg', '20095', 'Deutschland', 'peter.mueller@email.com',
        '0402345678'),
       ('Maria Wagner', '1995-08-10', 'Nebenstraße 5', 'Köln', '50667', 'Deutschland', 'maria.wagner@email.com',
        '0221987654');

INSERT INTO BESTELLUNG (BESTELLDATUM, ARTIKEL_ID, UMSATZ, FK_KUNDEN)
VALUES ('2024-01-01', 101, 100, 1),
       ('2024-02-15', 102, 200, 1),
       ('2024-01-05', 103, 150, 2),
       ('2024-02-20', 104, 250, 2),
       ('2024-01-10', 105, 300, 3),
       ('2024-03-05', 106, 400, 3),
       ('2024-02-01', 107, 500, 4),
       ('2024-03-12', 108, 600, 4);

-- Create view
CREATE VIEW UmsatzProJahrStadt AS
SELECT EXTRACT(YEAR FROM B.BESTELLDATUM) AS Jahr,
       K.STADT                           AS Stadt,
       SUM(B.UMSATZ)                     AS Gesamtumsatz
FROM KUNDEN K
         JOIN BESTELLUNG B ON K.KUNDEN_ID = B.FK_KUNDEN
GROUP BY EXTRACT(YEAR FROM B.BESTELLDATUM), K.STADT;

-- Create Rule to simulate INSTEAD OF trigger for INSERT
CREATE RULE instead_of_insert AS
    ON INSERT TO UmsatzProJahrStadt
    DO INSTEAD
    INSERT INTO BESTELLUNG (BESTELLDATUM, FK_KUNDEN, UMSATZ)
    VALUES (TO_DATE(NEW.Jahr || '-01-01', 'YYYY-MM-DD'),
            (SELECT K.KUNDEN_ID FROM KUNDEN K WHERE K.STADT = NEW.STADT LIMIT 1),
            NEW.Gesamtumsatz);

-- Test the insert
INSERT INTO UmsatzProJahrStadt (Jahr, Stadt, Gesamtumsatz)
VALUES (2025, 'Berlin', 5000);

-- Check results
SELECT *
FROM UmsatzProJahrStadt;
SELECT *
FROM BESTELLUNG;
