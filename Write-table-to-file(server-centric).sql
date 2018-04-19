DECLARE
    
    V_DIRECTORY        		VARCHAR2(256) := 'C:\';
    V_FILE_NAME            	VARCHAR2(256) := 'Filename.csv';
    V_FILE_HANDLER          UTL_FILE.FILE_TYPE;
    V_FILE_ROW              VARCHAR2(20000);
    V_FILE_DATA_FIELD     	VARCHAR2(4000);
    V_TABLE_NAME            VARCHAR2(30);
    V_TABLE_OWNER         	VARCHAR2(30);
    V_DATE_FORMAT         	VARCHAR2(30) := 'YYYY-MM-DD';
    V_DYNAMIC_SQL          	VARCHAR(32767);

BEGIN
    
    V_FILE_HANDLER := UTL_FILE.FOPEN(V_DIRECTORY,V_FILE_NAME,'W');
    
    FOR CUR_REC IN         (SELECT * FROM {schema}.{table})
    LOOP
        
        FOR CUR_COL IN     (SELECT 
							 OWNER
							 ,TABLE_NAME
							 ,COLUMN_NAME
							 ,DATA_TYPE
							 ,DATA_TYPE_MOD
							 ,DATA_TYPE_OWNER
							 ,DATA_LENGTH
							 ,DATA_PRECISION
							 ,DATA_SCALE
							 ,NULLABLE
							 ,COLUMN_ID
							FROM DBA_TAB_COLUMNS
						   	WHERE 
						   	     OWNER = 'schema'
							 AND TABLE_NAME = 'table'
						   ORDER BY 
						    COLUMN_ID)
        LOOP
            
        	V_DYNAMIC_SQL := 
				CASE
				WHEN CUR_COL.data_type = 'DATE'
				THEN  'TO_CHAR(CUR_REC.'|| CUR_COL.column_name ||',''' ||V_DATE_FORMAT||''')'
				ELSE  'CUR_REC.'|| CUR_COL.column_name
				END;
            
            EXECUTE IMMEDIATE V_DYNAMIC_SQL INTO V_FILE_DATA_FIELD;
            
            V_FILE_ROW :=       
				CASE
				WHEN CUR_COL.COLUMN_ID = 1
				THEN V_FILE_DATA_FIELD
				ELSE V_FILE_ROW || ','|| V_FILE_DATA_FIELD
				END;
            
            V_FILE_DATA_FIELD := NULL;
            
        END LOOP;
        
        UTL_FILE.PUT_LINE (V_FILE_HANDLER, V_FILE_ROW);
        V_FILE_ROW := NULL;
        
    END LOOP;
    
    UTL_FILE.FCLOSE(V_FILE_HANDLER);

END;
/