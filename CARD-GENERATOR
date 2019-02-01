create or replace PROCEDURE                       "CARD_GENERATOR" (ID_PRODUCT IN VARCHAR2, ID_ISSUER IN VARCHAR2, ID_CUSTOMER IN VARCHAR2, CARD2 OUT SYS_REFCURSOR) AS 

    ID_ACCOUNT VARCHAR2(19);                                                    --Variable que guardara los primeros 14 números del PAN
    PAN2 VARCHAR2(19);                                                          --Variable que guarda el PAN completo de la tarjeta luego de procesar
    EXP_FEC DATE;                                                               --Variable que guarda la fecha de expiración de la tarjeta
    IA VARCHAR (20);                                                            --Variable que guarda la INITIAL_ACCOUNT
    FA VARCHAR (20);                                                            --Variable que guarda la FINAL_ACCOUNT
    MA VARCHAR (20);                                                            --Variable que guarda la MAX ACCOUNT
    CARD VARCHAR (20);                                                          --Variable que guarda el número de cuenta ó número de tarjeta
    FLAG VARCHAR2 (1);                                                          --Variable que guarda indica que camino se tomo durante los IF's iniciales
    CT NUMBER;                                                                  --Variable que guarda el total de cuentas
    CA NUMBER;                                                                  --Variable que guarda el total de cuentas temporales
    
    BEGIN
        FLAG:=0;                                                                --Se asigna por defecto el flujo en el que no hay tarjetas bloqueadas en TEMP
        DELETE FROM VIEW;                                                       --View se limpia al inicio de cada corrida
        
        SELECT  INITIAL_ACCOUNT                                                 --Se obtiene el valor de la INITIAL_ACCOUNT del producto enviado
        INTO    IA
        FROM    PRODUCTS
        WHERE   PRODUCT_ID=ID_PRODUCT;

        SELECT  FINAL_ACCOUNT                                                   --Se obtiene el valor de la FINAL_ACCOUNT del producto enviado
        INTO    FA
        FROM    PRODUCTS
        WHERE   PRODUCT_ID=ID_PRODUCT;
        
        SELECT  COUNT (*)                                                       --Se cuenta el total de cuentas en ACCOUNTS 
        INTO    CT 
        FROM    ACCOUNTS 
        WHERE   ACCOUNT_ID 
        BETWEEN IA
        AND     FA;
        
        SELECT  COUNT (*)                                                       --Se cuenta el total de cuentas en TEMP_ACCOUNTS
        INTO    CA 
        FROM    TEMP_ACCOUNTS 
        WHERE   ACCOUNT_ID 
        BETWEEN IA
        AND     FA;
        
        IF CA=0 AND CT=0 THEN                                                   --Verificamos si hay cuentas en ACCOUNTS o TEMP_ACCOUNTS
        
            SELECT  SUBSTR (INITIAL_ACCOUNT,0,14)                               --Si no hay cuentas buscamos la primera cuenta del producto que nos pasaron y tomamos los primeros 14 digitos del mismo
            INTO    ID_ACCOUNT
            FROM    PRODUCTS
            WHERE   PRODUCT_ID=ID_PRODUCT;
            
        ELSE
        
            SELECT  SUBSTR(MIN(ACCOUNT_ID),0,14)
            INTO    ID_ACCOUNT
            FROM    TEMP_ACCOUNTS
            WHERE   EXTENDED_FIELDS='1';
            
            IF ID_ACCOUNT IS NOT NULL THEN
            
                UPDATE  TEMP_ACCOUNTS 
                SET     EXTENDED_FIELDS='0' 
                WHERE   ACCOUNT_ID=(ID_ACCOUNT||'00');
                FLAG:='1';
                
            ELSE
                
                SELECT  SUBSTR(MAX(ACCOUNT_ID),0,14)
                INTO    ID_ACCOUNT
                FROM    TEMP_ACCOUNTS
                WHERE   ACCOUNT_ID
                BETWEEN IA
                AND     FA;
                
                SELECT  MAX(ACCOUNT_ID)
                INTO    MA
                FROM    ACCOUNTS
                WHERE   ACCOUNT_ID
                BETWEEN IA
                AND     FA;
                   
                    IF ID_ACCOUNT<MA OR ID_ACCOUNT IS NULL THEN
                    
                        SELECT  SUBSTR(MAX(ACCOUNT_ID),0,14)
                        INTO    ID_ACCOUNT
                        FROM    ACCOUNTS
                        WHERE   ACCOUNT_ID 
                        BETWEEN IA
                        AND     FA;
                                
                    END IF;  
                
            END IF;
            
        END IF;
        
        ID_ACCOUNT:=ID_ACCOUNT+1;                                               --Se incrementa el account_id para generar la siguiente cuenta
        ID_ACCOUNT:=ID_ACCOUNT||'0'||'0';                                       --Se genera el número de cuenta
        
        IF FLAG='0' THEN
            INSERT INTO TEMP_ACCOUNTS                                           --Se inserta en la temporal el número de cuenta generado
            VALUES  ('U',
                    ID_ACCOUNT,
                    '30',
                    (SELECT 
                        CURRENCY_CODE 
                    FROM 
                        PRODUCTS 
                    WHERE 
                        PRODUCT_ID=ID_PRODUCT),
                    '',
                    '0',
                    '');
        END IF;
        
        SELECT  MAX(ACCOUNT_ID)
        INTO    CARD
        FROM    TEMP_ACCOUNTS                      
        WHERE   ACCOUNT_ID 
        BETWEEN IA
        AND     FA;
                            
        INSERT INTO VIEW 
        VALUES      (CARD,'','');
            
        ID_ACCOUNT:=SUBSTR(ID_ACCOUNT,0,14)||'1'||'0';                          --Se adjunta 1 que es por emisión y 0 que es requerido por la función PANGEN para hacer el calculo del ultimo digito
        
        SELECT  MIN(PAN)
        INTO    PAN2
        FROM    TEMP_CARDS
        WHERE   FLAG='1';
        
        IF PAN2 IS NULL THEN
        
            SELECT  PANGEN (ID_ACCOUNT)                                         --Se llama al algoritmo de generación del último dígito
            INTO    MA
            FROM    DUAL; 
                
            UPDATE  VIEW 
            SET     PAN=MA 
            WHERE   ACCOUNT_ID=CARD;
            
            INSERT INTO TEMP_CARDS 
            VALUES      (MA,'0');
        
        ELSE
        
            UPDATE  VIEW 
            SET     PAN=PAN2 
            WHERE   ACCOUNT_ID=CARD;
            UPDATE  TEMP_CARDS 
            SET     FLAG='0' 
            WHERE   PAN=PAN2;
            
        END IF;
        
        SELECT  FEC_EXP
        INTO    MA
        FROM    PRODUCTS
        WHERE   PRODUCT_ID=ID_PRODUCT;
        
        SELECT  TO_CHAR((ADD_MONTHS(SYSDATE,MA)),'YYMM')
        INTO    MA
        FROM    DUAL;
        
        UPDATE  VIEW 
        SET     FEC_EXP=MA 
        WHERE   ACCOUNT_ID=CARD;
        
        OPEN    CARD2
        FOR
            SELECT  ACCOUNT_ID,PAN,FEC_EXP
            FROM    VIEW;

END CARD_GENERATOR;
