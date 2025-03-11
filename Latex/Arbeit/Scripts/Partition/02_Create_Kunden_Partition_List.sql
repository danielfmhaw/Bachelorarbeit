CREATE TABLE IF NOT EXISTS KUNDEN (
    KUNDEN_ID     INT NOT NULL,
    LAND          VARCHAR(100) NOT NULL,
    -- other attributes
    PRIMARY KEY (KUNDEN_ID, LAND)
) PARTITION BY LIST COLUMNS(LAND) (
    PARTITION p_china VALUES IN ('China'),
    PARTITION p_india VALUES IN ('India'),
    PARTITION p_united_states VALUES IN ('United States'),
    -- other partitions
    PARTITION p_thailand VALUES IN ('Thailand'),
    PARTITION p_other VALUES IN ('Other')
);