-- First steps to allow ability to define/edit/view individual amounts for a group loan.

ALTER TABLE LOAN_ACCOUNT ADD COLUMN PARENT_ACCOUNT_ID INTEGER;

ALTER TABLE LOAN_ACCOUNT ADD FOREIGN KEY (PARENT_ACCOUNT_ID)
  REFERENCES ACCOUNT(ACCOUNT_ID) ON DELETE NO ACTION  ON UPDATE NO ACTION;

-- Add an Individual Loan Account Type (to regard as a virtual Loan Account)

INSERT INTO ACCOUNT_TYPE(ACCOUNT_TYPE_ID,LOOKUP_ID,DESCRIPTION)
VALUES(4,126,'Individual Loan Account');   
   
UPDATE DATABASE_VERSION SET DATABASE_VERSION = 153 WHERE DATABASE_VERSION = 152;