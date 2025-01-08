CREATE TABLE test_int (
    int_5 INT(5),
    int_11 INT(11)
);

-- Grenzen für INT (max. 32 Bit) einfügen:
-- MAX: 2^(32-1)-1 = 2147483647
-- MIN: -2^(32-1) = -2147483648
INSERT INTO test_int (int_5, int_11) VALUES (2147483647, 2147483647);
INSERT INTO test_int (int_5, int_11) VALUES (-2147483648, -2147483648);

SELECT * FROM test_int;