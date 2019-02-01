create or replace FUNCTION PANGEN (AUX VARCHAR2) RETURN VARCHAR2 AS             --Función que simula la ejecución del algoritmo de Lunh para obtener el último dígito de una tarjeta

AUX2 VARCHAR2(19);                                                              --Auxiliar que retorna el número de tarjeta procesado
FIN NUMBER:=0;                                                                  --Variable usada para la sumatoria total de los numeros
Y NUMBER;                                                                       --Variable que almacena cada número de la tarjeta por itereaciones

BEGIN

FOR X IN 0..15 LOOP                                                             --Recorremos los 16 caracteres de la tarjeta
    Y := TO_NUMBER(SUBSTR(AUX, -X, 1));                                         --Asignamos el digito de la tarjeta a la variable Y
    IF MOD(X,2) = 0 THEN                                                        --Revisamos si el digito esta en una posición par
        Y := Y * 2;                                                             --Al estar en una posición par se multiplica por 2
            IF Y > 9 THEN                                                       --Si al multiplicarlo es mayor que 10 o más, le restamos 9
                Y := Y - 9;
            END IF;
    END IF;
    FIN := FIN + y;                                                             --Sumamos el nuevo digito con la sumatoria total que llevamos en FIN
END LOOP;

FIN:= MOD (FIN,10);                                                             --Sacamos el digito más a la derecha de nuestra sumatoria
FIN:=10-FIN;                                                                    --Restamos 10 menos nuestra sumatoria, para completar el algoritmo de Luhn

IF FIN=10 THEN                                                                  --Si el número resultante es 10 debemos llevarlo a 0 para que sea solo un dígito
    FIN:=0;
END IF;

AUX2:=SUBSTR(AUX,0,15)||FIN;                                                    --Asignamos nuestro digito resultante a AUX2 que serian los 15 primeros números de nuestra tarjeta más el nuevo que generamos

RETURN 
    AUX2;                                                                       --Retornamos el nuevo número generado
END PANGEN;

----@Author GVELASQUEZ
