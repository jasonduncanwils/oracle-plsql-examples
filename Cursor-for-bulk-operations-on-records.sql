SET SERVEROUTPUT ON;

DECLARE

    CURSOR  CUR1 IS {query};

    TYPE CUR1_TABLE IS TABLE OF CUR1%ROWTYPE;
    CUR1_RECS    CUR1_TABLE;
    
    --************************************************************************* 
    
    V_REC_CNT               NUMBER(20);
    V_ERROR_CNT				NUMBER(20);
    V_COMMIT_LIMIT CONSTANT NUMBER := 100;  -- bulk collect x records into table type 
    V_COMMIT_ITER  CONSTANT NUMBER := 10;
    V_COMMIT_CNT            NUMBER := 0;
    
BEGIN

V_REC_CNT := 0;
V_ERROR_CNT := 0;

OPEN CUR1;
LOOP
	
    V_COMMIT_CNT := V_COMMIT_CNT + 1;
    
    FETCH CUR1 BULK COLLECT INTO CUR1_RECS LIMIT V_COMMIT_LIMIT;
    
    FOR I IN 1..CUR1_RECS.COUNT LOOP
      	
      	BEGIN
            
            -- add SQL for INSERTS, UPDATES, or DELETES
            
            V_REC_CNT := V_REC_CNT + 1;
            
        EXCEPTION
            WHEN OTHERS THEN
            V_EXC_CNT := V_EXC_CNT + 1;
        END;

    END LOOP;
  	 
  	IF (V_COMMIT_CNT = V_COMMIT_ITER) THEN 
          COMMIT;
  	  V_COMMIT_CNT := 0;
  	END IF;
    
    EXIT WHEN CUR1%NOTFOUND;
    
END LOOP;
CLOSE CUR1;
COMMIT;
V_COMMIT_CNT:=0;

-- add another cursor if needed that repeats the prior structure

DBMS_OUTPUT.PUT_LINE('Number of affected records: ' || V_REC_CNT);
DBMS_OUTPUT.PUT_LINE('Number of errors: ' || V_ERROR_CNT);

END;
/