drop table custbalance cascade CONSTRAINTS purge;

create table custbalance
(
    cust_id number(3) not null,
    cust_bal number(3) not null
);

alter table custbalance add CONSTRAINT custbalance_pk PRIMARY key (cust_id);

INSERT into custbalance VALUES(1, 100);
INSERT into custbalance VALUES(2, 200);
COMMIT;
select * from CUSTBALANCE;

--Task 3
update CUSTBALANCE set CUST_BAL = 110 where CUST_ID = 1;
select * from CUSTBALANCE;

COMMIT;