drop table agent cascade constraints purge; 
select * from cat; 
purge recyclebin; 

CREATE TABLE agent (
    agent_code      NUMBER(3) NOT NULL,
    agent_areacode  NUMBER(3) NOT NULL,
    agent_phone     CHAR(8) NOT NULL,
    agent_lname     VARCHAR2(50) NOT NULL,
    agent_ytd_sls   NUMBER(8, 2) NOT NULL
);

COMMENT ON COLUMN agent.agent_code IS
    'agent code (unique for each agent)';

COMMENT ON COLUMN agent.agent_areacode IS
    'area code of agent';

COMMENT ON COLUMN agent.agent_phone IS
    'agent phone number';

COMMENT ON COLUMN agent.agent_lname IS
    'agent last name';

COMMENT ON COLUMN agent.agent_ytd_sls IS
    'year to date sales made by agent';

ALTER TABLE agent ADD CONSTRAINT agent_pk PRIMARY KEY ( agent_code );

CREATE TABLE customer (
    cus_code        NUMBER(5) NOT NULL,
    cus_lname       VARCHAR2(50) NOT NULL,
    cus_fname       VARCHAR2(50) NOT NULL,
    cus_initial     CHAR(1),
    cus_renew_date  DATE NOT NULL,
    agent_code      NUMBER(3)
);

COMMENT ON COLUMN customer.cus_code IS
    'customer code (unique for each customer)';

COMMENT ON COLUMN customer.cus_lname IS
    'customer last name';

COMMENT ON COLUMN customer.cus_fname IS
    'customer first name';

COMMENT ON COLUMN customer.cus_initial IS
    'customer initial (not mandatory)';

COMMENT ON COLUMN customer.cus_renew_date IS
    'customer insurance renewal date';

COMMENT ON COLUMN customer.agent_code IS
    'agent code (unique for each agent)';

ALTER TABLE customer ADD CONSTRAINT customer_pk PRIMARY KEY ( cus_code );

ALTER TABLE customer
    ADD CONSTRAINT agent_customer_fk FOREIGN KEY ( agent_code )
        REFERENCES agent ( agent_code )
            ON DELETE SET NULL;