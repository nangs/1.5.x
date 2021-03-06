ALTER TABLE BATCH_STAFF_SUMMARY DROP COLUMN NEW_GROUP_COUNT;

ALTER TABLE BATCH_STAFF_SUMMARY ADD COLUMN TOTAL_CLIENTS_ENROLLED INTEGER NOT NULL;
ALTER TABLE BATCH_STAFF_SUMMARY ADD COLUMN CLIENTS_ENROLLED_THIS_MONTH INTEGER NOT NULL;
ALTER TABLE BATCH_STAFF_SUMMARY ADD COLUMN LOAN_ARREARS_AMOUNT DECIMAL(20,3) NOT  NULL;
ALTER TABLE BATCH_STAFF_SUMMARY ADD COLUMN LOAN_ARREARS_AMOUNT_CURRENCY_ID SMALLINT NOT NULL;

UPDATE DATABASE_VERsION SET DATABASE_VERSION = 194 WHERE DATABASE_VERSION=193;
