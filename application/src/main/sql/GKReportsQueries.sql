----This file contains queries that are used by GK for reports.

---Branch Cash Confirmation report--
--1)GETTING OVER DUE,DUE,TOTAL AMOUNTS FOR LOAN PRODUCTS--

SELECT 
	PRD.PRD_OFFERING_ID,PRD.PRD_OFFERING_NAME,OVER_DUE.TOTAL OVERDUE,DUE.TOTAL DUE,
	SUM(COALESCE(DUE.TOTAL,0)+COALESCE(OVER_DUE.TOTAL,0)) TOTAL
FROM
	PRD_OFFERING PRD 
LEFT OUTER JOIN
	(SELECT OVERDUE.PRD_OFFERING_ID,PRD.PRD_OFFERING_NAME,SUM(COALESCE(TOT_AMOUNT,0)) TOTAL FROM (
		SELECT LA.PRD_OFFERING_ID,
		SUM(COALESCE(LS.PRINCIPAL,0) - COALESCE(LS.PRINCIPAL_PAID,0) +
		COALESCE(LS.INTEREST,0) - COALESCE(LS.INTEREST_PAID,0) +
		COALESCE(LS.PENALTY,0) - COALESCE(LS.PENALTY_PAID,0) +
		COALESCE(LS.MISC_PENALTY,0)- COALESCE(LS.MISC_PENALTY_PAID,0) +
		COALESCE(LS.MISC_FEES,0) - COALESCE(LS.MISC_FEES_PAID,0)) TOT_AMOUNT
		FROM LOAN_ACCOUNT LA, LOAN_SCHEDULE LS,ACCOUNT AC
		WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.ACCOUNT_ID = LS.ACCOUNT_ID
		AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0
		AND LS.ACTION_DATE < CURRENT_DATE AND AC.OFFICE_ID=12
		GROUP BY LA.PRD_OFFERING_ID
	UNION ALL
		SELECT LA.PRD_OFFERING_ID,SUM(COALESCE(LFS.AMOUNT,0) - COALESCE(LFS.AMOUNT_PAID,0)) TOT_AMOUNT
		FROM LOAN_ACCOUNT LA, LOAN_SCHEDULE LS,ACCOUNT AC,LOAN_FEE_SCHEDULE LFS
		WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.ACCOUNT_ID = LS.ACCOUNT_ID AND LS.ID = LFS.ID
		AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0 AND LS.ACTION_DATE < CURRENT_DATE
		AND AC.OFFICE_ID=12
		GROUP BY LA.PRD_OFFERING_ID
	) OVERDUE,PRD_OFFERING PRD WHERE PRD.PRD_OFFERING_ID = OVERDUE.PRD_OFFERING_ID
	GROUP BY OVERDUE.PRD_OFFERING_ID ORDER BY OVERDUE.PRD_OFFERING_ID) OVER_DUE
ON PRD.PRD_OFFERING_ID = OVER_DUE.PRD_OFFERING_ID
LEFT OUTER JOIN
	(SELECT DUE.PRD_OFFERING_ID,PRD.PRD_OFFERING_NAME,SUM(COALESCE(TOT_AMOUNT,0)) TOTAL FROM (
		SELECT LA.PRD_OFFERING_ID,
		SUM(COALESCE(LS.PRINCIPAL,0) - COALESCE(LS.PRINCIPAL_PAID,0) +
		COALESCE(LS.INTEREST,0) - COALESCE(LS.INTEREST_PAID,0) +
		COALESCE(LS.PENALTY,0) - COALESCE(LS.PENALTY_PAID,0) +
		COALESCE(LS.MISC_PENALTY,0)- COALESCE(LS.MISC_PENALTY_PAID,0) +
		COALESCE(LS.MISC_FEES,0) - COALESCE(LS.MISC_FEES_PAID,0)) TOT_AMOUNT
		FROM LOAN_ACCOUNT LA, LOAN_SCHEDULE LS,ACCOUNT AC
		WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.ACCOUNT_ID = LS.ACCOUNT_ID
		AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0 AND LS.INSTALLMENT_ID =
		     (SELECT MIN(LS1.INSTALLMENT_ID) FROM LOAN_SCHEDULE LS1
		      WHERE LS1.ACTION_DATE >= CURRENT_DATE AND LS1.ACCOUNT_ID=LS.ACCOUNT_ID)
		AND LA.PRD_OFFERING_ID IN (SELECT PRD_OFFERING_ID FROM LOAN_OFFERING) AND AC.OFFICE_ID=12
		GROUP BY LA.PRD_OFFERING_ID
	UNION ALL
		SELECT LA.PRD_OFFERING_ID,SUM(COALESCE(LFS.AMOUNT,0) - COALESCE(LFS.AMOUNT_PAID,0)) TOT_AMOUNT
		FROM LOAN_ACCOUNT LA, LOAN_SCHEDULE LS,ACCOUNT AC,LOAN_FEE_SCHEDULE LFS
		WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.ACCOUNT_ID = LS.ACCOUNT_ID AND LS.ID = LFS.ID
		AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0 AND LS.INSTALLMENT_ID =
		     (SELECT MIN(LS1.INSTALLMENT_ID) FROM LOAN_SCHEDULE LS1
		      WHERE LS1.ACTION_DATE >= CURRENT_DATE AND LS1.ACCOUNT_ID=LS.ACCOUNT_ID)
		AND LA.PRD_OFFERING_ID IN (SELECT PRD_OFFERING_ID FROM LOAN_OFFERING) AND AC.OFFICE_ID=12
		GROUP BY LA.PRD_OFFERING_ID
	) DUE,PRD_OFFERING PRD WHERE PRD.PRD_OFFERING_ID = DUE.PRD_OFFERING_ID
	GROUP BY DUE.PRD_OFFERING_ID ORDER BY DUE.PRD_OFFERING_ID) DUE
ON  DUE.PRD_OFFERING_ID =PRD.PRD_OFFERING_ID
WHERE PRD.PRD_TYPE_ID=1
GROUP BY PRD.PRD_OFFERING_ID
ORDER BY PRD.PRD_OFFERING_ID

----2)GETTING OVER DUE,DUE,TOTAL AMOUNTS FOR SAVINGS VOLUNTORY PRODUCTS

SELECT 
	SA.PRD_OFFERING_ID,PRD.PRD_OFFERING_NAME,0 OVERDUE,
	SUM(COALESCE(SS.DEPOSIT,0) - COALESCE(SS.DEPOSIT_PAID,0)) DUE,
	SUM(COALESCE(SS.DEPOSIT,0) - COALESCE(SS.DEPOSIT_PAID,0)) TOTAL
FROM 
	SAVINGS_ACCOUNT SA, SAVING_SCHEDULE SS,ACCOUNT AC,PRD_OFFERING PRD
WHERE AC.ACCOUNT_ID = SA.ACCOUNT_ID AND SA.ACCOUNT_ID = SS.ACCOUNT_ID
AND SA.PRD_OFFERING_ID = PRD.PRD_OFFERING_ID
AND AC.ACCOUNT_STATE_ID IN (16,18) AND SS.PAYMENT_STATUS=0 AND  SS.INSTALLMENT_ID =
	(SELECT MIN(SS1.INSTALLMENT_ID) FROM SAVING_SCHEDULE SS1
	WHERE SS1.ACTION_DATE >= CURRENT_DATE AND SS1.ACCOUNT_ID=SS.ACCOUNT_ID)
	AND SA.PRD_OFFERING_ID IN (SELECT PRD_OFFERING_ID FROM SAVINGS_OFFERING WHERE SAVINGS_TYPE_ID=2)
	AND AC.OFFICE_ID=12
	GROUP BY SA.PRD_OFFERING_ID ORDER BY SA.PRD_OFFERING_ID


----3)GETTING OVER DUE,DUE,TOTAL AMOUNTS FOR SAVINGS MANDATORY PRODUCTS

SELECT 
	PRD.PRD_OFFERING_ID,OVER_DUE.TOTAL OVERDUE,DUE.TOTAL DUE,
	SUM(COALESCE(DUE.TOTAL,0)+COALESCE(OVER_DUE.TOTAL,0)) TOTAL
FROM
	PRD_OFFERING PRD 
LEFT OUTER JOIN
	(SELECT SA.PRD_OFFERING_ID,PRD.PRD_OFFERING_NAME,
	SUM(COALESCE(SS.DEPOSIT,0) - COALESCE(SS.DEPOSIT_PAID,0)) TOTAL
	FROM SAVINGS_ACCOUNT SA, SAVING_SCHEDULE SS,ACCOUNT AC,PRD_OFFERING PRD
	WHERE AC.ACCOUNT_ID = SA.ACCOUNT_ID AND SA.ACCOUNT_ID = SS.ACCOUNT_ID 
	AND SA.PRD_OFFERING_ID = PRD.PRD_OFFERING_ID
	AND AC.ACCOUNT_STATE_ID IN (16,18) AND SS.PAYMENT_STATUS=0 AND SS.ACTION_DATE < CURRENT_DATE
	AND SA.PRD_OFFERING_ID IN (SELECT PRD_OFFERING_ID FROM SAVINGS_OFFERING WHERE SAVINGS_TYPE_ID=1) 
	AND AC.OFFICE_ID=12
	GROUP BY SA.PRD_OFFERING_ID ORDER BY SA.PRD_OFFERING_ID
) OVER_DUE
ON PRD.PRD_OFFERING_ID = OVER_DUE.PRD_OFFERING_ID
LEFT OUTER JOIN
	(SELECT SA.PRD_OFFERING_ID,PRD.PRD_OFFERING_NAME,
	SUM(COALESCE(SS.DEPOSIT,0) - COALESCE(SS.DEPOSIT_PAID,0))  TOTAL
	FROM SAVINGS_ACCOUNT SA, SAVING_SCHEDULE SS,ACCOUNT AC,PRD_OFFERING PRD
	WHERE AC.ACCOUNT_ID = SA.ACCOUNT_ID AND SA.ACCOUNT_ID = SS.ACCOUNT_ID 
	AND SA.PRD_OFFERING_ID = PRD.PRD_OFFERING_ID
	AND AC.ACCOUNT_STATE_ID IN (16,18) AND SS.PAYMENT_STATUS=0 AND  SS.INSTALLMENT_ID =
	     (SELECT MIN(SS1.INSTALLMENT_ID) FROM SAVING_SCHEDULE SS1
	      WHERE SS1.ACTION_DATE >= CURRENT_DATE AND SS1.ACCOUNT_ID=SS.ACCOUNT_ID)
	AND SA.PRD_OFFERING_ID IN (SELECT PRD_OFFERING_ID FROM SAVINGS_OFFERING WHERE SAVINGS_TYPE_ID=1) 
	AND AC.OFFICE_ID=12
	GROUP BY SA.PRD_OFFERING_ID ORDER BY SA.PRD_OFFERING_ID) DUE
ON  DUE.PRD_OFFERING_ID =PRD.PRD_OFFERING_ID
WHERE PRD.PRD_TYPE_ID=2
GROUP BY PRD.PRD_OFFERING_ID
ORDER BY PRD.PRD_OFFERING_ID



----4)GETTING OVER DUE,DUE,TOTAL AMOUNTS FOR CUSTOMER ACCOUNTS FEES

SELECT
	FEE.FEE_ID,FEE.FEE_NAME,OVER_DUE.TOT_AMOUNT OVERDUE,
	DUE.TOT_AMOUNT DUE,SUM(COALESCE(OVER_DUE.TOT_AMOUNT,0)+COALESCE(DUE.TOT_AMOUNT,0)) TOTAL
FROM
	FEES FEE
LEFT OUTER JOIN
	(SELECT CFS.FEE_ID,SUM(COALESCE(CFS.AMOUNT,0)-COALESCE(CFS.AMOUNT_PAID,0)) TOT_AMOUNT
	FROM CUSTOMER_ACCOUNT CA, CUSTOMER_SCHEDULE CS,ACCOUNT AC,CUSTOMER_FEE_SCHEDULE CFS
	WHERE AC.ACCOUNT_ID = CA.ACCOUNT_ID AND CA.ACCOUNT_ID = CS.ACCOUNT_ID AND CS.ID = CFS.ID
	AND AC.ACCOUNT_STATE_ID IN (11,12) AND CS.PAYMENT_STATUS=0 AND CS.ACTION_DATE < CURRENT_DATE
	AND AC.OFFICE_ID=12
	GROUP BY CFS.FEE_ID ) OVER_DUE
ON OVER_DUE.FEE_ID=FEE.FEE_ID
LEFT OUTER JOIN
	(SELECT CFS.FEE_ID,SUM(COALESCE(CFS.AMOUNT,0)-COALESCE(CFS.AMOUNT_PAID,0)) TOT_AMOUNT
	FROM CUSTOMER_ACCOUNT CA, CUSTOMER_SCHEDULE CS,ACCOUNT AC,CUSTOMER_FEE_SCHEDULE CFS
	WHERE AC.ACCOUNT_ID = CA.ACCOUNT_ID AND CA.ACCOUNT_ID = CS.ACCOUNT_ID AND CS.ID = CFS.ID
	AND AC.ACCOUNT_STATE_ID IN (11,12) AND CS.PAYMENT_STATUS=0 AND CS.INSTALLMENT_ID =
		(SELECT MIN(CS1.INSTALLMENT_ID) FROM CUSTOMER_SCHEDULE CS1
		WHERE CS1.ACTION_DATE >= CURRENT_DATE AND CS1.ACCOUNT_ID=CS.ACCOUNT_ID)
	AND AC.OFFICE_ID=2
	GROUP BY CFS.FEE_ID ) DUE
ON DUE.FEE_ID=FEE.FEE_ID
WHERE FEE.CATEGORY_ID !=5
GROUP BY FEE.FEE_ID ORDER BY FEE.FEE_ID


----5)GETTING OVER DUE,DUE,TOTAL AMOUNTS FOR CUSTOMER ACCOUNTS FEES

SELECT 
	'MISC INCOME',OVER_DUE.TOTAL OVERDUE,DUE.TOTAL DUE,SUM(
	COALESCE(OVER_DUE.TOTAL,0) + COALESCE(DUE.TOTAL,0)) TOTAL 
FROM
	(SELECT 'MISC INCOME',SUM(COALESCE(MISC_FEES,0) - COALESCE(MISC_FEES_PAID,0)+
	COALESCE(MISC_PENALTY,0) - COALESCE(MISC_PENALTY_PAID,0)) TOTAL
	FROM CUSTOMER_ACCOUNT CA,ACCOUNT AC,CUSTOMER_SCHEDULE CS
	WHERE CA.ACCOUNT_ID = AC.ACCOUNT_ID AND CA.ACCOUNT_ID=CS.ACCOUNT_ID
	AND AC.ACCOUNT_STATE_ID IN (11,12) AND CS.PAYMENT_STATUS=0
	AND CS.ACTION_DATE < CURRENT_DATE AND AC.OFFICE_ID=12) OVER_DUE,
	(SELECT 'MISC INCOME',SUM(COALESCE(MISC_FEES,0) - COALESCE(MISC_FEES_PAID,0)+
	COALESCE(MISC_PENALTY,0) - COALESCE(MISC_PENALTY_PAID,0)) TOTAL
	FROM CUSTOMER_ACCOUNT CA,ACCOUNT AC,CUSTOMER_SCHEDULE CS
	WHERE CA.ACCOUNT_ID = AC.ACCOUNT_ID AND CA.ACCOUNT_ID=CS.ACCOUNT_ID
	AND AC.ACCOUNT_STATE_ID IN (11,12) AND CS.PAYMENT_STATUS=0 AND CS.INSTALLMENT_ID =
	     (SELECT MIN(CS1.INSTALLMENT_ID) FROM CUSTOMER_SCHEDULE CS1
	      WHERE CS1.ACTION_DATE >= CURRENT_DATE AND CS1.ACCOUNT_ID=CS.ACCOUNT_ID)
	AND AC.OFFICE_ID=12) DUE
GROUP BY 'MISC INCOME'


----6) GETTING BRANCH NAME

SELECT DISPLAY_NAME FROM OFFICE WHERE OFFICE_ID=2

----7)GETTING TOTAL DISBURSAL AMOUNTS FOR LOANS IN DATE RANGE FOR EACH PRODUCT

SELECT 
	PRD.PRD_OFFERING_ID,PRD.PRD_OFFERING_NAME,LOAN.LOAN_DISBURSED
FROM 
	PRD_OFFERING PRD 
LEFT OUTER JOIN
	(SELECT LA.PRD_OFFERING_ID,SUM(COALESCE(LOAN_AMOUNT,0)) LOAN_DISBURSED
	FROM LOAN_ACCOUNT LA,ACCOUNT AC
	WHERE LA.ACCOUNT_ID= AC.ACCOUNT_ID AND AC.ACCOUNT_STATE_ID IN (5,9)
	AND (LA.DISBURSEMENT_DATE>='2006-01-09' AND LA.DISBURSEMENT_DATE<='2006-08-16')
	AND AC.OFFICE_ID=12
	GROUP BY LA.PRD_OFFERING_ID) LOAN
ON LOAN.PRD_OFFERING_ID=PRD.PRD_OFFERING_ID
WHERE PRD.PRD_TYPE_ID=1
ORDER BY PRD.PRD_OFFERING_ID

----8) GETTING TOTAL DISBURSAL AMOUNTS FOR LOANS IN DATE RANGE

SELECT SUM(COALESCE(LOAN_AMOUNT,0)) TOTAL
FROM LOAN_ACCOUNT LA,ACCOUNT AC
WHERE LA.ACCOUNT_ID= AC.ACCOUNT_ID AND AC.ACCOUNT_STATE_ID IN (5,9)
AND (LA.DISBURSEMENT_DATE>='2006-01-09' AND LA.DISBURSEMENT_DATE<='2006-08-16')
AND AC.OFFICE_ID=12

---9) TOTAL OF ALL 

SELECT SUM(COALESCE(TOT_AMOUNT,0)) TOTAL FROM (
	SELECT SUM(COALESCE(LS.PRINCIPAL,0) - COALESCE(LS.PRINCIPAL_PAID,0) +
	COALESCE(LS.INTEREST,0) - COALESCE(LS.INTEREST_PAID,0) +
	COALESCE(LS.PENALTY,0) - COALESCE(LS.PENALTY_PAID,0) +
	COALESCE(LS.MISC_PENALTY,0)- COALESCE(LS.MISC_PENALTY_PAID,0) +
	COALESCE(LS.MISC_FEES,0) - COALESCE(LS.MISC_FEES_PAID,0)) TOT_AMOUNT
	FROM LOAN_ACCOUNT LA, LOAN_SCHEDULE LS,ACCOUNT AC
	WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.ACCOUNT_ID = LS.ACCOUNT_ID
	AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0
	AND LS.ACTION_DATE < CURRENT_DATE AND AC.OFFICE_ID=12
UNION ALL
	SELECT SUM(COALESCE(LFS.AMOUNT,0) - COALESCE(LFS.AMOUNT_PAID,0)) TOT_AMOUNT
	FROM LOAN_ACCOUNT LA, LOAN_SCHEDULE LS,ACCOUNT AC,LOAN_FEE_SCHEDULE LFS
	WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.ACCOUNT_ID = LS.ACCOUNT_ID AND LS.ID = LFS.ID
	AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0 AND LS.ACTION_DATE < CURRENT_DATE
	AND AC.OFFICE_ID=12
UNION ALL
	 SELECT SUM(COALESCE(LS.PRINCIPAL,0) - COALESCE(LS.PRINCIPAL_PAID,0) +
	COALESCE(LS.INTEREST,0) - COALESCE(LS.INTEREST_PAID,0) +
	COALESCE(LS.PENALTY,0) - COALESCE(LS.PENALTY_PAID,0) +
	COALESCE(LS.MISC_PENALTY,0)- COALESCE(LS.MISC_PENALTY_PAID,0) +
	COALESCE(LS.MISC_FEES,0) - COALESCE(LS.MISC_FEES_PAID,0)) TOT_AMOUNT
	FROM LOAN_ACCOUNT LA, LOAN_SCHEDULE LS,ACCOUNT AC
	WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.ACCOUNT_ID = LS.ACCOUNT_ID
	AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0 AND LS.INSTALLMENT_ID =
	     (SELECT MIN(LS1.INSTALLMENT_ID) FROM LOAN_SCHEDULE LS1
	      WHERE LS1.ACTION_DATE >= CURRENT_DATE AND LS1.ACCOUNT_ID=LS.ACCOUNT_ID)
	AND LA.PRD_OFFERING_ID IN (SELECT PRD_OFFERING_ID FROM LOAN_OFFERING) AND AC.OFFICE_ID=12
UNION ALL
	SELECT SUM(COALESCE(LFS.AMOUNT,0) - COALESCE(LFS.AMOUNT_PAID,0)) TOT_AMOUNT
	FROM LOAN_ACCOUNT LA, LOAN_SCHEDULE LS,ACCOUNT AC,LOAN_FEE_SCHEDULE LFS
	WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.ACCOUNT_ID = LS.ACCOUNT_ID AND LS.ID = LFS.ID
	AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0 AND LS.INSTALLMENT_ID =
	     (SELECT MIN(LS1.INSTALLMENT_ID) FROM LOAN_SCHEDULE LS1
	      WHERE LS1.ACTION_DATE >= CURRENT_DATE AND LS1.ACCOUNT_ID=LS.ACCOUNT_ID)
	AND LA.PRD_OFFERING_ID IN (SELECT PRD_OFFERING_ID FROM LOAN_OFFERING) AND AC.OFFICE_ID=12
UNION ALL
	SELECT SUM(COALESCE(SS.DEPOSIT,0) - COALESCE(SS.DEPOSIT_PAID,0)) TOT_AMOUNT
	FROM SAVINGS_ACCOUNT SA, SAVING_SCHEDULE SS,ACCOUNT AC,PRD_OFFERING PRD
	WHERE AC.ACCOUNT_ID = SA.ACCOUNT_ID AND SA.ACCOUNT_ID = SS.ACCOUNT_ID
	AND SA.PRD_OFFERING_ID = PRD.PRD_OFFERING_ID
	AND AC.ACCOUNT_STATE_ID IN (16,18) AND SS.PAYMENT_STATUS=0 AND  SS.INSTALLMENT_ID =
		(SELECT MIN(SS1.INSTALLMENT_ID) FROM SAVING_SCHEDULE SS1
		WHERE SS1.ACTION_DATE >= CURRENT_DATE AND SS1.ACCOUNT_ID=SS.ACCOUNT_ID)
		AND SA.PRD_OFFERING_ID IN (SELECT PRD_OFFERING_ID FROM SAVINGS_OFFERING)
		AND AC.OFFICE_ID=12
UNION ALL
	SELECT SUM(COALESCE(SS.DEPOSIT,0) - COALESCE(SS.DEPOSIT_PAID,0)) TOT_AMOUNT
	FROM SAVINGS_ACCOUNT SA, SAVING_SCHEDULE SS,ACCOUNT AC,PRD_OFFERING PRD
	WHERE AC.ACCOUNT_ID = SA.ACCOUNT_ID AND SA.ACCOUNT_ID = SS.ACCOUNT_ID
	AND SA.PRD_OFFERING_ID = PRD.PRD_OFFERING_ID
	AND AC.ACCOUNT_STATE_ID IN (16,18) AND SS.PAYMENT_STATUS=0 AND SS.ACTION_DATE < CURRENT_DATE
	AND SA.PRD_OFFERING_ID IN (SELECT PRD_OFFERING_ID FROM SAVINGS_OFFERING WHERE SAVINGS_TYPE_ID=1)
	AND AC.OFFICE_ID=12
UNION ALL
	SELECT SUM(COALESCE(CFS.AMOUNT,0)-COALESCE(CFS.AMOUNT_PAID,0)) TOT_AMOUNT
	FROM CUSTOMER_ACCOUNT CA, CUSTOMER_SCHEDULE CS,ACCOUNT AC,CUSTOMER_FEE_SCHEDULE CFS
	WHERE AC.ACCOUNT_ID = CA.ACCOUNT_ID AND CA.ACCOUNT_ID = CS.ACCOUNT_ID AND CS.ID = CFS.ID
	AND AC.ACCOUNT_STATE_ID IN (11,12) AND CS.PAYMENT_STATUS=0 AND CS.ACTION_DATE < CURRENT_DATE
	AND AC.OFFICE_ID=12
UNION ALL
	SELECT SUM(COALESCE(CFS.AMOUNT,0)-COALESCE(CFS.AMOUNT_PAID,0)) TOT_AMOUNT
	FROM CUSTOMER_ACCOUNT CA, CUSTOMER_SCHEDULE CS,ACCOUNT AC,CUSTOMER_FEE_SCHEDULE CFS
	WHERE AC.ACCOUNT_ID = CA.ACCOUNT_ID AND CA.ACCOUNT_ID = CS.ACCOUNT_ID AND CS.ID = CFS.ID
	AND AC.ACCOUNT_STATE_ID IN (11,12) AND CS.PAYMENT_STATUS=0 AND CS.INSTALLMENT_ID =
		(SELECT MIN(CS1.INSTALLMENT_ID) FROM CUSTOMER_SCHEDULE CS1
		WHERE CS1.ACTION_DATE >= CURRENT_DATE AND CS1.ACCOUNT_ID=CS.ACCOUNT_ID)
	AND AC.OFFICE_ID=12
UNION ALL
	  SELECT SUM(COALESCE(MISC_FEES,0) - COALESCE(MISC_FEES_PAID,0)+
	COALESCE(MISC_PENALTY,0) - COALESCE(MISC_PENALTY_PAID,0)) TOT_AMOUNT
	FROM CUSTOMER_ACCOUNT CA,ACCOUNT AC,CUSTOMER_SCHEDULE CS
	WHERE CA.ACCOUNT_ID = AC.ACCOUNT_ID AND CA.ACCOUNT_ID=CS.ACCOUNT_ID
	AND AC.ACCOUNT_STATE_ID IN (11,12) AND CS.PAYMENT_STATUS=0
	AND CS.ACTION_DATE < CURRENT_DATE AND AC.OFFICE_ID=12

UNION ALL
	SELECT SUM(COALESCE(MISC_FEES,0) - COALESCE(MISC_FEES_PAID,0)+
	COALESCE(MISC_PENALTY,0) - COALESCE(MISC_PENALTY_PAID,0)) TOT_AMOUNT
	FROM CUSTOMER_ACCOUNT CA,ACCOUNT AC,CUSTOMER_SCHEDULE CS
	WHERE CA.ACCOUNT_ID = AC.ACCOUNT_ID AND CA.ACCOUNT_ID=CS.ACCOUNT_ID
	AND AC.ACCOUNT_STATE_ID IN (11,12) AND CS.PAYMENT_STATUS=0 AND CS.INSTALLMENT_ID =
	     (SELECT MIN(CS1.INSTALLMENT_ID) FROM CUSTOMER_SCHEDULE CS1
	      WHERE CS1.ACTION_DATE >= CURRENT_DATE AND CS1.ACCOUNT_ID=CS.ACCOUNT_ID)
	AND AC.OFFICE_ID=12
) TT


-----10) NET

SELECT SUM(TOTAL.TOTAL-DISB.TOTAL) NET FROM
	(SELECT SUM(COALESCE(TOT_AMOUNT,0)) TOTAL FROM (
		SELECT SUM(COALESCE(LS.PRINCIPAL,0) - COALESCE(LS.PRINCIPAL_PAID,0) +
		COALESCE(LS.INTEREST,0) - COALESCE(LS.INTEREST_PAID,0) +
		COALESCE(LS.PENALTY,0) - COALESCE(LS.PENALTY_PAID,0) +
		COALESCE(LS.MISC_PENALTY,0)- COALESCE(LS.MISC_PENALTY_PAID,0) +
		COALESCE(LS.MISC_FEES,0) - COALESCE(LS.MISC_FEES_PAID,0)) TOT_AMOUNT
		FROM LOAN_ACCOUNT LA, LOAN_SCHEDULE LS,ACCOUNT AC
		WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.ACCOUNT_ID = LS.ACCOUNT_ID
		AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0
		AND LS.ACTION_DATE < CURRENT_DATE AND AC.OFFICE_ID=12
	UNION ALL
		SELECT SUM(COALESCE(LFS.AMOUNT,0) - COALESCE(LFS.AMOUNT_PAID,0)) TOT_AMOUNT
		FROM LOAN_ACCOUNT LA, LOAN_SCHEDULE LS,ACCOUNT AC,LOAN_FEE_SCHEDULE LFS
		WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.ACCOUNT_ID = LS.ACCOUNT_ID AND LS.ID = LFS.ID
		AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0 AND LS.ACTION_DATE < CURRENT_DATE
		AND AC.OFFICE_ID=12
	UNION ALL
		SELECT SUM(COALESCE(LS.PRINCIPAL,0) - COALESCE(LS.PRINCIPAL_PAID,0) +
		COALESCE(LS.INTEREST,0) - COALESCE(LS.INTEREST_PAID,0) +
		COALESCE(LS.PENALTY,0) - COALESCE(LS.PENALTY_PAID,0) +
		COALESCE(LS.MISC_PENALTY,0)- COALESCE(LS.MISC_PENALTY_PAID,0) +
		COALESCE(LS.MISC_FEES,0) - COALESCE(LS.MISC_FEES_PAID,0)) TOT_AMOUNT
		FROM LOAN_ACCOUNT LA, LOAN_SCHEDULE LS,ACCOUNT AC
		WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.ACCOUNT_ID = LS.ACCOUNT_ID
		AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0 AND LS.INSTALLMENT_ID =
		     (SELECT MIN(LS1.INSTALLMENT_ID) FROM LOAN_SCHEDULE LS1
		      WHERE LS1.ACTION_DATE >= CURRENT_DATE AND LS1.ACCOUNT_ID=LS.ACCOUNT_ID)
		AND LA.PRD_OFFERING_ID IN (SELECT PRD_OFFERING_ID FROM LOAN_OFFERING) AND AC.OFFICE_ID=12
	UNION ALL
		SELECT SUM(COALESCE(LFS.AMOUNT,0) - COALESCE(LFS.AMOUNT_PAID,0)) TOT_AMOUNT
		FROM LOAN_ACCOUNT LA, LOAN_SCHEDULE LS,ACCOUNT AC,LOAN_FEE_SCHEDULE LFS
		WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.ACCOUNT_ID = LS.ACCOUNT_ID AND LS.ID = LFS.ID
		AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0 AND LS.INSTALLMENT_ID =
		     (SELECT MIN(LS1.INSTALLMENT_ID) FROM LOAN_SCHEDULE LS1
		      WHERE LS1.ACTION_DATE >= CURRENT_DATE AND LS1.ACCOUNT_ID=LS.ACCOUNT_ID)
		AND LA.PRD_OFFERING_ID IN (SELECT PRD_OFFERING_ID FROM LOAN_OFFERING) AND AC.OFFICE_ID=12
	UNION ALL
		SELECT SUM(COALESCE(SS.DEPOSIT,0) - COALESCE(SS.DEPOSIT_PAID,0)) TOT_AMOUNT
		FROM SAVINGS_ACCOUNT SA, SAVING_SCHEDULE SS,ACCOUNT AC,PRD_OFFERING PRD
		WHERE AC.ACCOUNT_ID = SA.ACCOUNT_ID AND SA.ACCOUNT_ID = SS.ACCOUNT_ID
		AND SA.PRD_OFFERING_ID = PRD.PRD_OFFERING_ID
		AND AC.ACCOUNT_STATE_ID IN (16,18) AND SS.PAYMENT_STATUS=0 AND  SS.INSTALLMENT_ID =
			(SELECT MIN(SS1.INSTALLMENT_ID) FROM SAVING_SCHEDULE SS1
			WHERE SS1.ACTION_DATE >= CURRENT_DATE AND SS1.ACCOUNT_ID=SS.ACCOUNT_ID)
		AND SA.PRD_OFFERING_ID IN (SELECT PRD_OFFERING_ID FROM SAVINGS_OFFERING)
		AND AC.OFFICE_ID=12
	UNION ALL
		 SELECT SUM(COALESCE(SS.DEPOSIT,0) - COALESCE(SS.DEPOSIT_PAID,0)) TOT_AMOUNT
		FROM SAVINGS_ACCOUNT SA, SAVING_SCHEDULE SS,ACCOUNT AC,PRD_OFFERING PRD
		WHERE AC.ACCOUNT_ID = SA.ACCOUNT_ID AND SA.ACCOUNT_ID = SS.ACCOUNT_ID
		AND SA.PRD_OFFERING_ID = PRD.PRD_OFFERING_ID
		AND AC.ACCOUNT_STATE_ID IN (16,18) AND SS.PAYMENT_STATUS=0 AND SS.ACTION_DATE < CURRENT_DATE
		AND SA.PRD_OFFERING_ID IN (SELECT PRD_OFFERING_ID FROM SAVINGS_OFFERING WHERE SAVINGS_TYPE_ID=1)
		AND AC.OFFICE_ID=12
	UNION ALL
		SELECT SUM(COALESCE(CFS.AMOUNT,0)-COALESCE(CFS.AMOUNT_PAID,0)) TOT_AMOUNT
		FROM CUSTOMER_ACCOUNT CA, CUSTOMER_SCHEDULE CS,ACCOUNT AC,CUSTOMER_FEE_SCHEDULE CFS
		WHERE AC.ACCOUNT_ID = CA.ACCOUNT_ID AND CA.ACCOUNT_ID = CS.ACCOUNT_ID AND CS.ID = CFS.ID
		AND AC.ACCOUNT_STATE_ID IN (11,12) AND CS.PAYMENT_STATUS=0 AND CS.ACTION_DATE < CURRENT_DATE
		AND AC.OFFICE_ID=12
	UNION ALL
		SELECT SUM(COALESCE(CFS.AMOUNT,0)-COALESCE(CFS.AMOUNT_PAID,0)) TOT_AMOUNT
		FROM CUSTOMER_ACCOUNT CA, CUSTOMER_SCHEDULE CS,ACCOUNT AC,CUSTOMER_FEE_SCHEDULE CFS
		WHERE AC.ACCOUNT_ID = CA.ACCOUNT_ID AND CA.ACCOUNT_ID = CS.ACCOUNT_ID AND CS.ID = CFS.ID
		AND AC.ACCOUNT_STATE_ID IN (11,12) AND CS.PAYMENT_STATUS=0 AND CS.INSTALLMENT_ID =
			(SELECT MIN(CS1.INSTALLMENT_ID) FROM CUSTOMER_SCHEDULE CS1
			WHERE CS1.ACTION_DATE >= CURRENT_DATE AND CS1.ACCOUNT_ID=CS.ACCOUNT_ID)
		AND AC.OFFICE_ID=12
	UNION ALL
		SELECT SUM(COALESCE(MISC_FEES,0) - COALESCE(MISC_FEES_PAID,0)+
		COALESCE(MISC_PENALTY,0) - COALESCE(MISC_PENALTY_PAID,0)) TOT_AMOUNT
		FROM CUSTOMER_ACCOUNT CA,ACCOUNT AC,CUSTOMER_SCHEDULE CS
		WHERE CA.ACCOUNT_ID = AC.ACCOUNT_ID AND CA.ACCOUNT_ID=CS.ACCOUNT_ID
		AND AC.ACCOUNT_STATE_ID IN (11,12) AND CS.PAYMENT_STATUS=0
		AND CS.ACTION_DATE < CURRENT_DATE AND AC.OFFICE_ID=12
	UNION ALL
		SELECT SUM(COALESCE(MISC_FEES,0) - COALESCE(MISC_FEES_PAID,0)+
		COALESCE(MISC_PENALTY,0) - COALESCE(MISC_PENALTY_PAID,0)) TOT_AMOUNT
		FROM CUSTOMER_ACCOUNT CA,ACCOUNT AC,CUSTOMER_SCHEDULE CS
		WHERE CA.ACCOUNT_ID = AC.ACCOUNT_ID AND CA.ACCOUNT_ID=CS.ACCOUNT_ID
		AND AC.ACCOUNT_STATE_ID IN (11,12) AND CS.PAYMENT_STATUS=0 AND CS.INSTALLMENT_ID =
		     (SELECT MIN(CS1.INSTALLMENT_ID) FROM CUSTOMER_SCHEDULE CS1
		      WHERE CS1.ACTION_DATE >= CURRENT_DATE AND CS1.ACCOUNT_ID=CS.ACCOUNT_ID)
		AND AC.OFFICE_ID=12
	) TT) TOTAL,
	(SELECT SUM(COALESCE(LOAN_AMOUNT,0)) TOTAL
	FROM LOAN_ACCOUNT LA,ACCOUNT AC
	WHERE LA.ACCOUNT_ID= AC.ACCOUNT_ID AND AC.ACCOUNT_STATE_ID IN (5,9)
	AND (LA.DISBURSEMENT_DATE>='2006-01-09' AND LA.DISBURSEMENT_DATE<='2006-08-16')
	AND AC.OFFICE_ID=12 ) DISB

---Branch Progress Report--
----1) BRANCH ID,BLOCK,CREATED DATE,CITY

SELECT OFF.GLOBAL_OFFICE_NUM,OFF_ADD.CITY,OFF.CREATED_DATE,PARENT_OFFICE.DISPLAY_NAME
FROM OFFICE OFF LEFT OUTER JOIN OFFICE PARENT_OFFICE ON OFF.PARENT_OFFICE_ID=PARENT_OFFICE.OFFICE_ID,
OFFICE_ADDRESS OFF_ADD
WHERE OFF.OFFICE_ID = OFF_ADD.OFFICE_ID AND OFF.DISPLAY_NAME='BRANCH OFFICE1'

----2) BRANCH MANAGER

SELECT DISPLAY_NAME FROM PERSONNEL WHERE TITLE=59 AND OFFICE_ID=2

----3) NO OF ACTIVE KENDRAS IN BRANCH

SELECT COUNT(*) FROM CUSTOMER WHERE CUSTOMER_LEVEL_ID=3 AND BRANCH_ID=2 AND STATUS_ID=13

---4) NO OF ACTIVE GROUPS IN BRANCH

SELECT COUNT(*) FROM CUSTOMER WHERE CUSTOMER_LEVEL_ID=2 AND BRANCH_ID=2 AND STATUS_ID IN (9,10)

----5) NO OF ACTIVE BORROWERS

SELECT COUNT(DISTINCT  AC.CUSTOMER_ID)
FROM CUSTOMER CUST,ACCOUNT AC
WHERE AC.CUSTOMER_ID = CUST.CUSTOMER_ID
AND AC.ACCOUNT_STATE_ID IN (5,9) AND AC.ACCOUNT_TYPE_ID=1
AND CUSTOMER_LEVEL_ID=1 AND BRANCH_ID=2 AND STATUS_ID IN (3,4)

---6) NO OF SAVERS

SELECT COUNT(DISTINCT  AC.CUSTOMER_ID)
FROM CUSTOMER CUST,ACCOUNT AC
WHERE AC.CUSTOMER_ID = CUST.CUSTOMER_ID
AND AC.ACCOUNT_STATE_ID = 16 AND AC.ACCOUNT_TYPE_ID=2
AND CUSTOMER_LEVEL_ID=1 AND BRANCH_ID=2 AND STATUS_ID =3

----7)NO OF DROPUTS

SELECT COUNT(*) FROM CUSTOMER WHERE CUSTOMER_LEVEL_ID=1 AND BRANCH_ID=2 AND STATUS_ID=6

----8)NO OF DORMANTS

SELECT COUNT(CUSTOMER_ID) FROM CUSTOMER WHERE CUSTOMER_ID NOT IN (
SELECT DISTINCT AC.CUSTOMER_ID
FROM CUSTOMER CUST LEFT OUTER JOIN ACCOUNT AC ON AC.CUSTOMER_ID = CUST.CUSTOMER_ID
WHERE CUSTOMER_LEVEL_ID=1 AND BRANCH_ID=2 AND STATUS_ID =3 AND AC.ACCOUNT_TYPE_ID=1
AND (DATE_SUB(CURDATE(),INTERVAL 84 DAY) <=AC.CREATED_DATE)) AND
CUSTOMER_LEVEL_ID=1 AND BRANCH_ID=2 AND STATUS_ID =3


---9)NO. OF TARGETS

SELECT COUNT(*) FROM CUSTOMER WHERE CUSTOMER_LEVEL_ID=1 AND BRANCH_ID=2 AND STATUS_ID IN (1,2)

----10) NO. OF LOAN OUTSTANDING

SELECT COUNT(ACCOUNT_ID)
FROM ACCOUNT AC
WHERE AC.ACCOUNT_STATE_ID IN (5,9)
AND AC.ACCOUNT_TYPE_ID=1 AND AC.OFFICE_ID=2


---11) AMOUNT OUTSTANDING

SELECT SUM(COALESCE(TOT_AMOUNT,0)) TOTAL FROM (
	SELECT SUM(COALESCE(LS.PRINCIPAL,0) - COALESCE(LS.PRINCIPAL_PAID,0) +
  COALESCE(LS.INTEREST,0) - COALESCE(LS.INTEREST_PAID,0) +
  COALESCE(LS.PENALTY,0) - COALESCE(LS.PENALTY_PAID,0) +
	COALESCE(LS.MISC_PENALTY,0)- COALESCE(LS.MISC_PENALTY_PAID,0) +
  COALESCE(LS.MISC_FEES,0) - COALESCE(LS.MISC_FEES_PAID,0)) TOT_AMOUNT
	FROM LOAN_SCHEDULE LS,ACCOUNT AC
	WHERE  AC.ACCOUNT_ID = LS.ACCOUNT_ID
	AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0
	AND LS.ACTION_DATE < CURRENT_DATE AND AC.OFFICE_ID=2
UNION ALL
	SELECT SUM(COALESCE(LFS.AMOUNT,0)-COALESCE(LFS.AMOUNT_PAID,0)) TOT_AMOUNT
	FROM LOAN_SCHEDULE LS,ACCOUNT AC,LOAN_FEE_SCHEDULE LFS
	WHERE AC.ACCOUNT_ID = LS.ACCOUNT_ID AND LS.ID = LFS.ID
	AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0 AND
	LS.ACTION_DATE < CURRENT_DATE AND AC.OFFICE_ID=12
UNION ALL
	SELECT SUM(COALESCE(LS.PRINCIPAL,0)) TOT_AMOUNT
	FROM LOAN_SCHEDULE LS,ACCOUNT AC
	WHERE AC.ACCOUNT_ID = LS.ACCOUNT_ID AND AC.ACCOUNT_STATE_ID IN (5,9)
  AND AC.OFFICE_ID=12 AND LS.ACTION_DATE>=CURRENT_DATE	
) TOT

----12)TOTAL BALANCE FOR EACH SAVINGS INSTANCE

SELECT PRD.PRD_OFFERING_ID,PRD.PRD_OFFERING_NAME, COALESCE(TOT_AMOUNT,0) SAVINGS_BALANCE
FROM
PRD_OFFERING PRD
LEFT OUTER JOIN (
SELECT SA.PRD_OFFERING_ID,SUM(COALESCE(SA.SAVINGS_BALANCE,0)) TOT_AMOUNT
FROM SAVINGS_ACCOUNT SA, ACCOUNT AC,PRD_OFFERING PRD
WHERE AC.ACCOUNT_ID = SA.ACCOUNT_ID AND SA.PRD_OFFERING_ID = PRD.PRD_OFFERING_ID
AND AC.ACCOUNT_STATE_ID IN (16,18) AND AC.OFFICE_ID=2
GROUP BY SA.PRD_OFFERING_ID ORDER BY SA.PRD_OFFERING_ID
) VALUE

ON VALUE.PRD_OFFERING_ID = PRD.PRD_OFFERING_ID
WHERE PRD.PRD_TYPE_ID=2
GROUP BY PRD.PRD_OFFERING_ID ORDER BY PRD.PRD_OFFERING_ID

---13)TOTAL LOAN AMOUNT OUTSTANDING FOR EACH LOAN INSTANCE

SELECT PRD.PRD_OFFERING_ID,PRD.PRD_OFFERING_NAME, COALESCE(TOTAL_AMOUNT,0) AMOUNT
FROM
PRD_OFFERING PRD
LEFT OUTER JOIN (
SELECT TOTAL.PRD_OFFERING_ID,SUM(COALESCE(TOTAL,0)) TOTAL_AMOUNT FROM (
	SELECT PRD_OFFERING_ID,SUM(TOT_AMOUNT) TOTAL FROM (
		SELECT LA.PRD_OFFERING_ID,
		SUM(COALESCE(LS.PRINCIPAL,0) - COALESCE(LS.PRINCIPAL_PAID,0) +
  COALESCE(LS.INTEREST,0) - COALESCE(LS.INTEREST_PAID,0) +
  COALESCE(LS.PENALTY,0) - COALESCE(LS.PENALTY_PAID,0) +
	COALESCE(LS.MISC_PENALTY,0)- COALESCE(LS.MISC_PENALTY_PAID,0) +
  COALESCE(LS.MISC_FEES,0) - COALESCE(LS.MISC_FEES_PAID,0)) TOT_AMOUNT
		FROM LOAN_ACCOUNT LA, LOAN_SCHEDULE LS,ACCOUNT AC
		WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.ACCOUNT_ID = LS.ACCOUNT_ID
		AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0
		AND LS.ACTION_DATE < CURRENT_DATE AND AC.OFFICE_ID=12
		GROUP BY LA.PRD_OFFERING_ID
	UNION ALL
		SELECT LA.PRD_OFFERING_ID,SUM(COALESCE(LFS.AMOUNT,0)-COALESCE(LFS.AMOUNT_PAID,0)) TOT_AMOUNT
		FROM LOAN_ACCOUNT LA, LOAN_SCHEDULE LS,ACCOUNT AC,LOAN_FEE_SCHEDULE LFS
		WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.ACCOUNT_ID = LS.ACCOUNT_ID AND LS.ID = LFS.ID
		AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0
		AND LS.ACTION_DATE < CURRENT_DATE AND AC.OFFICE_ID=12
		GROUP BY LA.PRD_OFFERING_ID
	) OVERDUE
	GROUP BY PRD_OFFERING_ID
UNION ALL
	SELECT LA.PRD_OFFERING_ID,SUM(COALESCE(LS.PRINCIPAL,0)) TOTAL
	FROM LOAN_ACCOUNT LA, LOAN_SCHEDULE LS,ACCOUNT AC
	WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.ACCOUNT_ID = LS.ACCOUNT_ID
	AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0
	AND LS.ACTION_DATE >= CURRENT_DATE AND AC.OFFICE_ID=12
	GROUP BY LA.PRD_OFFERING_ID
) TOTAL,PRD_OFFERING PRD WHERE PRD.PRD_OFFERING_ID = TOTAL.PRD_OFFERING_ID
GROUP BY TOTAL.PRD_OFFERING_ID ORDER BY TOTAL.PRD_OFFERING_ID
) VALUE
ON VALUE.PRD_OFFERING_ID = PRD.PRD_OFFERING_ID
WHERE PRD.PRD_TYPE_ID=1
GROUP BY PRD.PRD_OFFERING_ID ORDER BY PRD.PRD_OFFERING_ID

----14)NO OF LOANS DISBURSED

SELECT COUNT(AC.ACCOUNT_ID),SUM(LA.LOAN_AMOUNT) "AMOUNT DISBURSED"
FROM ACCOUNT AC,LOAN_ACCOUNT LA
WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.PRD_OFFERING_ID !=2
AND AC.ACCOUNT_TYPE_ID=1 AND AC.ACCOUNT_STATE_ID IN (5,6,7,8,9)
AND AC.OFFICE_ID=2

---15)BRANCH STAFFING LEVEL- SECTION

SELECT 
	LOOK.LOOKUP_VALUE TITLE,COALESCE(TOTAL,0) TOTAL 
FROM
	LOOKUP_VALUE_LOCALE LOOK
LEFT OUTER JOIN (
	SELECT LC.LOOKUP_VALUE_ID,LC.LOOKUP_VALUE TITLE, COUNT(PERS.TITLE) TOTAL
	FROM PERSONNEL PERS,LOOKUP_VALUE_LOCALE LC
	WHERE LC.LOOKUP_ID = PERS.TITLE AND OFFICE_ID=12
	AND LC.LOOKUP_ID IN (57,58,59,540,541,542,543,544,545)
	GROUP BY LC.LOOKUP_ID
	) VALUE
ON VALUE.LOOKUP_VALUE_ID  = LOOK.LOOKUP_VALUE_ID
WHERE LOOK.LOOKUP_ID IN (57,58,59,540,541,542,543,544,545)

----16)NAME OF LO,AVG GROUPS,TOTAL NO OF ACTIVE + ON HOLD CLIENTS IN BRANCH / NO OF ACTIVE KENDRAS IN BRANCH,
---NO OF KENDRAS,NO OF CLIENTS,NO OF ACCOUNTS,NO OF ACT LOANS,TMG FOR EACH LOAN OFFICER

SELECT
	PERS.PERSONNEL_ID,PERS.DISPLAY_NAME,GROUPS.GROUPS,
	ROUND(CLIENTS.CLIENTS /CENTER.CENTERS) CLIENTDIVCENTER,
	CLIENTS.CLIENTS,CENTER.CENTERS,BORROWERS.BORROWERS,
	ACT_LOANS.ACT_LOANS,TMG.TMG
FROM 
	PERSONNEL PERS
LEFT JOIN
	(SELECT PERS1.PERSONNEL_ID PI,COUNT(CUST.CUSTOMER_ID) GROUPS
	FROM PERSONNEL PERS1,CUSTOMER CUST
	WHERE PERS1.PERSONNEL_ID = CUST.LOAN_OFFICER_ID
	AND CUST.CUSTOMER_LEVEL_ID=2 AND CUST.STATUS_ID IN (9,10)
	GROUP BY PERS1.PERSONNEL_ID) GROUPS
ON GROUPS.PI = PERS.PERSONNEL_ID
LEFT JOIN
	(SELECT PERS1.PERSONNEL_ID PI,COUNT(CUST.CUSTOMER_ID) CENTERS
	FROM PERSONNEL PERS1,CUSTOMER CUST
	WHERE PERS1.PERSONNEL_ID = CUST.LOAN_OFFICER_ID
	AND CUST.CUSTOMER_LEVEL_ID=3 AND CUST.STATUS_ID=13
	GROUP BY PERS1.PERSONNEL_ID) CENTER
ON CENTER.PI =PERS.PERSONNEL_ID
LEFT JOIN
	(SELECT PERS1.PERSONNEL_ID PI,COUNT(CUST.CUSTOMER_ID) CLIENTS
	FROM PERSONNEL PERS1,CUSTOMER CUST
	WHERE PERS1.PERSONNEL_ID = CUST.LOAN_OFFICER_ID
	AND CUST.CUSTOMER_LEVEL_ID=1 AND CUST.STATUS_ID IN (3,4)
	GROUP BY PERS1.PERSONNEL_ID ) CLIENTS
ON CLIENTS.PI =PERS.PERSONNEL_ID
LEFT JOIN
	(SELECT PERS1.PERSONNEL_ID PI,COUNT(DISTINCT  AC.CUSTOMER_ID) BORROWERS
	FROM CUSTOMER CUST,ACCOUNT AC,LOAN_ACCOUNT LA,PERSONNEL PERS1
	WHERE AC.ACCOUNT_ID=LA.ACCOUNT_ID AND AC.CUSTOMER_ID = CUST.CUSTOMER_ID
	AND AC.ACCOUNT_STATE_ID = 5 AND PERS1.PERSONNEL_ID = CUST.LOAN_OFFICER_ID
	AND CUSTOMER_LEVEL_ID=1 AND STATUS_ID IN (3,4)
	GROUP BY PERS1.PERSONNEL_ID) BORROWERS
ON BORROWERS.PI =PERS.PERSONNEL_ID
LEFT JOIN
	(SELECT PERS1.PERSONNEL_ID PI,COUNT(AC.ACCOUNT_ID) ACT_LOANS
	FROM ACCOUNT AC,LOAN_ACCOUNT LA,PERSONNEL PERS1
	WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND AC.PERSONNEL_ID=PERS1.PERSONNEL_ID
	AND LA.PRD_OFFERING_ID !=20 AND AC.ACCOUNT_STATE_ID IN (5,9)
	GROUP BY PERS1.PERSONNEL_ID) ACT_LOANS
ON ACT_LOANS.PI =PERS.PERSONNEL_ID
LEFT JOIN
	(SELECT PERS1.PERSONNEL_ID PI,COUNT(CUST.CUSTOMER_ID) TMG
	FROM PERSONNEL PERS1,CUSTOMER CUST
	WHERE PERS1.PERSONNEL_ID = CUST.LOAN_OFFICER_ID
	AND CUST.CUSTOMER_LEVEL_ID=2 AND MONTH(CUST.CREATED_DATE)=MONTH(CURRENT_DATE)
	GROUP BY PERS1.PERSONNEL_ID) TMG
ON TMG.PI =PERS.PERSONNEL_ID
WHERE PERS.LEVEL_ID=1 AND PERS.OFFICE_ID=12
GROUP BY PERS.PERSONNEL_ID

---17)NUMBER OF LOANS DISBURSED,AMOUNT OF LOAN DISBURSED FOR EACH LOAN OFFICER

SELECT
	PERS.PERSONNEL_ID,LOAN_DISBUSRED.NO_LOAN_DISBURSED,LOAN_DISBUSRED.AMOUNT_DISBURSED
FROM
	PERSONNEL PERS
LEFT JOIN
	(SELECT PERS1.PERSONNEL_ID PI,COUNT(AC.ACCOUNT_ID) NO_LOAN_DISBURSED,
	SUM(COALESCE(LA.LOAN_AMOUNT,0)) AMOUNT_DISBURSED
	FROM ACCOUNT AC,LOAN_ACCOUNT LA,PERSONNEL PERS1
	WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND AC.PERSONNEL_ID=PERS1.PERSONNEL_ID
	AND LA.PRD_OFFERING_ID !=20 AND AC.ACCOUNT_STATE_ID IN (5,6,7,8,9)
	GROUP BY PERS1.PERSONNEL_ID) LOAN_DISBUSRED
ON LOAN_DISBUSRED.PI = PERS.PERSONNEL_ID
WHERE PERS.LEVEL_ID=1 AND PERS.OFFICE_ID=12
GROUP BY PERS.PERSONNEL_ID

---18)SAVINGS BALANCE FOR EACH INSTANCE,LOAN OUSTANDING FOR EACH LOAN INSTANCE FOR EACH LOAN OFFICER

SELECT PERSONNEL_ID,PRD_OFFERING_ID,PRD_OFFERING_NAME, TOT_AMOUNT FROM(
	SELECT PERS.PERSONNEL_ID,SA.PRD_OFFERING_ID,PRD.PRD_OFFERING_NAME,SUM(COALESCE(SA.SAVINGS_BALANCE,0)) TOT_AMOUNT
	FROM SAVINGS_ACCOUNT SA, ACCOUNT AC,PRD_OFFERING PRD,PERSONNEL PERS
	WHERE AC.ACCOUNT_ID = SA.ACCOUNT_ID AND SA.PRD_OFFERING_ID = PRD.PRD_OFFERING_ID
	AND AC.PERSONNEL_ID=PERS.PERSONNEL_ID AND PERS.LEVEL_ID=1
	AND AC.ACCOUNT_STATE_ID IN (16,18)AND AC.OFFICE_ID=12
	GROUP BY PERS.PERSONNEL_ID,SA.PRD_OFFERING_ID
UNION ALL
	SELECT TOTAL.PERSONNEL_ID,TOTAL.PRD_OFFERING_ID,PRD.PRD_OFFERING_NAME,SUM(COALESCE(TOTAL,0)) TOT_AMOUNT FROM (
		SELECT PERSONNEL_ID,PRD_OFFERING_ID,SUM(COALESCE(TOT_AMOUNT,0)) TOTAL FROM (
			SELECT PERS.PERSONNEL_ID,LA.PRD_OFFERING_ID,
			SUM(COALESCE(LS.PRINCIPAL,0) - COALESCE(LS.PRINCIPAL_PAID,0) +
  COALESCE(LS.INTEREST,0) - COALESCE(LS.INTEREST_PAID,0) +
  COALESCE(LS.PENALTY,0) - COALESCE(LS.PENALTY_PAID,0) +
	COALESCE(LS.MISC_PENALTY,0)- COALESCE(LS.MISC_PENALTY_PAID,0) +
  COALESCE(LS.MISC_FEES,0) - COALESCE(LS.MISC_FEES_PAID,0)) TOT_AMOUNT
			FROM LOAN_ACCOUNT LA, LOAN_SCHEDULE LS,ACCOUNT AC,PERSONNEL PERS
			WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.ACCOUNT_ID = LS.ACCOUNT_ID
			AND AC.PERSONNEL_ID=PERS.PERSONNEL_ID	
			AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0 AND LS.ACTION_DATE < CURRENT_DATE
			AND LA.PRD_OFFERING_ID !=20 AND AC.OFFICE_ID=12
			GROUP BY PERS.PERSONNEL_ID,LA.PRD_OFFERING_ID
		UNION ALL
			SELECT PERS.PERSONNEL_ID,LA.PRD_OFFERING_ID,SUM(COALESCE(LFS.AMOUNT,0)-COALESCE(LFS.AMOUNT_PAID,0)) TOT_AMOUNT
			FROM LOAN_ACCOUNT LA, LOAN_SCHEDULE LS,ACCOUNT AC,LOAN_FEE_SCHEDULE LFS,PERSONNEL PERS
			WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.ACCOUNT_ID = LS.ACCOUNT_ID AND LS.ID = LFS.ID
			AND AC.PERSONNEL_ID=PERS.PERSONNEL_ID	
			AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0 AND LS.ACTION_DATE < CURRENT_DATE
			AND LA.PRD_OFFERING_ID !=20 AND AC.OFFICE_ID=12
			GROUP BY PERS.PERSONNEL_ID,LA.PRD_OFFERING_ID
		) OVERDUE
		GROUP BY PERSONNEL_ID,PRD_OFFERING_ID
	UNION ALL
		SELECT PERS.PERSONNEL_ID,LA.PRD_OFFERING_ID,SUM(COALESCE(LS.PRINCIPAL,0)) TOTAL
		FROM LOAN_ACCOUNT LA, LOAN_SCHEDULE LS,ACCOUNT AC,PERSONNEL PERS
		WHERE AC.ACCOUNT_ID = LA.ACCOUNT_ID AND LA.ACCOUNT_ID = LS.ACCOUNT_ID
		AND AC.PERSONNEL_ID=PERS.PERSONNEL_ID	
		AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0 AND LS.ACTION_DATE >= CURRENT_DATE
		AND LA.PRD_OFFERING_ID !=20 AND AC.OFFICE_ID=12
		GROUP BY PERS.PERSONNEL_ID,LA.PRD_OFFERING_ID
	) TOTAL,PRD_OFFERING PRD WHERE PRD.PRD_OFFERING_ID = TOTAL.PRD_OFFERING_ID
	GROUP BY TOTAL.PERSONNEL_ID,TOTAL.PRD_OFFERING_ID
) TOT
GROUP BY TOT.PERSONNEL_ID,TOT.PRD_OFFERING_ID
ORDER BY TOT.PERSONNEL_ID,TOT.PRD_OFFERING_ID

---19)NO OF LOANS IN ARREARS

SELECT COUNT(DISTINCT AC.ACCOUNT_ID)
FROM ACCOUNT AC,LOAN_SCHEDULE LS
WHERE AC.ACCOUNT_ID=LS.ACCOUNT_ID
AND AC.ACCOUNT_STATE_ID IN (5,9)
AND AC.ACCOUNT_TYPE_ID=1 AND AC.OFFICE_ID=2
AND LS.PAYMENT_STATUS=0 AND LS.ACTION_DATE<CURRENT_DATE

---20)NO OF CLIENTS IN ARREARS

SELECT COUNT(DISTINCT AC.CUSTOMER_ID)
FROM CUSTOMER CUST,ACCOUNT AC,LOAN_SCHEDULE LS
WHERE AC.CUSTOMER_ID = CUST.CUSTOMER_ID AND AC.ACCOUNT_ID=LS.ACCOUNT_ID
AND CUSTOMER_LEVEL_ID=1 AND BRANCH_ID=2 AND STATUS_ID =3 AND AC.ACCOUNT_TYPE_ID=1
AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0 AND LS.ACTION_DATE<CURRENT_DATE


---21)AMOUNT IN ARREARS

SELECT SUM(COALESCE(TOT_AMOUNT,0)) TOTAL FROM (
SELECT SUM(COALESCE(LS.PRINCIPAL,0) - COALESCE(LS.PRINCIPAL_PAID,0) +
  COALESCE(LS.INTEREST,0) - COALESCE(LS.INTEREST_PAID,0) +
  COALESCE(LS.PENALTY,0) - COALESCE(LS.PENALTY_PAID,0) +
	COALESCE(LS.MISC_PENALTY,0)- COALESCE(LS.MISC_PENALTY_PAID,0) +
  COALESCE(LS.MISC_FEES,0) - COALESCE(LS.MISC_FEES_PAID,0)) TOT_AMOUNT
	FROM LOAN_SCHEDULE LS,ACCOUNT AC
	WHERE  AC.ACCOUNT_ID = LS.ACCOUNT_ID
	AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0
	AND LS.ACTION_DATE < CURRENT_DATE AND AC.OFFICE_ID=12
UNION ALL
	SELECT SUM(COALESCE(LFS.AMOUNT,0)-COALESCE(LFS.AMOUNT_PAID,0)) TOT_AMOUNT
	FROM LOAN_SCHEDULE LS,ACCOUNT AC,LOAN_FEE_SCHEDULE LFS
	WHERE AC.ACCOUNT_ID = LS.ACCOUNT_ID AND LS.ID = LFS.ID
	AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0 AND
	LS.ACTION_DATE < CURRENT_DATE AND AC.OFFICE_ID=12
  ) TOT

------22)OUTSTANDING AMOUNT IN ARREARS

  SELECT SUM(COALESCE(TOT_AMOUNT,0)) TOTAL FROM (
	SELECT SUM(COALESCE(LS.PRINCIPAL,0) - COALESCE(LS.PRINCIPAL_PAID,0) +
  COALESCE(LS.INTEREST,0) - COALESCE(LS.INTEREST_PAID,0) +
  COALESCE(LS.PENALTY,0) - COALESCE(LS.PENALTY_PAID,0) +
	COALESCE(LS.MISC_PENALTY,0)- COALESCE(LS.MISC_PENALTY_PAID,0) +
  COALESCE(LS.MISC_FEES,0) - COALESCE(LS.MISC_FEES_PAID,0)) TOT_AMOUNT
	FROM LOAN_SCHEDULE LS,ACCOUNT AC
	WHERE  AC.ACCOUNT_ID = LS.ACCOUNT_ID
	AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0
	AND LS.ACTION_DATE < CURRENT_DATE AND AC.OFFICE_ID=12
	AND AC.ACCOUNT_ID IN (
		SELECT DISTINCT AC.ACCOUNT_ID
		FROM ACCOUNT AC,LOAN_SCHEDULE LS
		WHERE AC.ACCOUNT_ID=LS.ACCOUNT_ID
		AND AC.ACCOUNT_STATE_ID IN (5,9)
		AND AC.ACCOUNT_TYPE_ID=1 AND AC.OFFICE_ID=12
		AND LS.PAYMENT_STATUS=0 AND LS.ACTION_DATE<CURRENT_DATE)
  UNION ALL
	SELECT SUM(COALESCE(LFS.AMOUNT,0)-COALESCE(LFS.AMOUNT_PAID,0)) TOT_AMOUNT
	FROM LOAN_SCHEDULE LS,ACCOUNT AC,LOAN_FEE_SCHEDULE LFS
	WHERE AC.ACCOUNT_ID = LS.ACCOUNT_ID AND LS.ID = LFS.ID
	AND AC.ACCOUNT_STATE_ID IN (5,9) AND LS.PAYMENT_STATUS=0 AND
	LS.ACTION_DATE < CURRENT_DATE AND AC.OFFICE_ID=12
	AND AC.ACCOUNT_ID IN (
		SELECT DISTINCT AC.ACCOUNT_ID
		FROM ACCOUNT AC,LOAN_SCHEDULE LS
		WHERE AC.ACCOUNT_ID=LS.ACCOUNT_ID
		AND AC.ACCOUNT_STATE_ID IN (5,9)
		AND AC.ACCOUNT_TYPE_ID=1 AND AC.OFFICE_ID=12
		AND LS.PAYMENT_STATUS=0 AND LS.ACTION_DATE<CURRENT_DATE)
  UNION ALL
	SELECT SUM(COALESCE(LS.PRINCIPAL,0)) TOT_AMOUNT
	FROM LOAN_SCHEDULE LS,ACCOUNT AC
	WHERE AC.ACCOUNT_ID = LS.ACCOUNT_ID AND AC.ACCOUNT_STATE_ID IN (5,9)
	AND AC.OFFICE_ID=12 AND LS.ACTION_DATE>=CURRENT_DATE
	AND AC.ACCOUNT_ID IN (
		SELECT DISTINCT AC.ACCOUNT_ID
		FROM ACCOUNT AC,LOAN_SCHEDULE LS
		WHERE AC.ACCOUNT_ID=LS.ACCOUNT_ID
		AND AC.ACCOUNT_STATE_ID IN (5,9)
		AND AC.ACCOUNT_TYPE_ID=1 AND AC.OFFICE_ID=12
		AND LS.PAYMENT_STATUS=0 AND LS.ACTION_DATE<CURRENT_DATE)
) TOT

---23) TOTAL STAFF

SELECT
	COALESCE(SUM(TOTAL),0) TOTAL
FROM
	LOOKUP_VALUE_LOCALE LOOK
LEFT OUTER JOIN (
	SELECT LC.LOOKUP_VALUE_ID,LC.LOOKUP_VALUE TITLE, COUNT(PERS.TITLE) TOTAL
	FROM PERSONNEL PERS,LOOKUP_VALUE_LOCALE LC
	WHERE LC.LOOKUP_ID = PERS.TITLE AND OFFICE_ID=14
	AND LC.LOOKUP_ID IN (57,58,59,540,541,542,543,544,545)
	GROUP BY LC.LOOKUP_ID
	) VALUE
ON VALUE.LOOKUP_VALUE_ID  = LOOK.LOOKUP_VALUE_ID
WHERE LOOK.LOOKUP_ID IN (57,58,59,540,541,542,543,544,545)