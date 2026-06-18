ALTER TABLE unit ADD (
    unit_credit_points NUMBER(2,0) DEFAULT 6 NOT NULL,
CONSTRAINT chk_unitcreditpoints CHECK (unit_credit_points in (3, 6, 12))
);

COMMENT on COLUMN unit.unit_credit_points IS 'unit credit point';
DESC unit;