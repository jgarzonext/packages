--------------------------------------------------------
--  DDL for Function F_NIF_TMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_NIF_TMP" (w_nif IN OUT VARCHAR2)
RETURN NUMBER authid current_user IS
--*********************************************************
--   Llibreria: allibmfm
--   F_NIF  : Obte el nif o el cif amb la lletra correcta.
--            Si hi ha
--            problema retorna un numero de error, si no 0.
--   Retorna:
--   0 - nif correcta.
--   101249 - nif/cif null.
--   101250 - longitud nif/cif incorrecta.
--   101251 - lletra nif/cif incorrecta.
--   101506 - digit cif incorrecta.
--   101657 - nif sense lletra.
--*********************************************************
num_err     NUMBER;
i           NUMBER;
w_lletra_act  VARCHAR2(1):=NULL;
w_lletra_ant  VARCHAR2(1):=NULL;
w_lletra_ant1 VARCHAR2(1):=NULL;
w_caracter    VARCHAR2(1):=NULL;
w_long      NUMBER;
w_num_nif   VARCHAR2(20);
w_numer_nif VARCHAR2(7):=' ';
r           NUMBER:=0;
r1          NUMBER:=0;
r2          NUMBER:=0;
resto       NUMBER:=0;
dif         NUMBER:=0;
w_impar     VARCHAR2(2):=' ';
g           VARCHAR2(1):=' ';
w_ultim_digit NUMBER:=0;
w_nif_ant   VARCHAR2(12);
w_num       NUMBER:=0;
sw_nif      NUMBER:=2;
w_oper      NUMBER(2);
w_nou       NUMBER:=0;
BEGIN
W_nif_ant := w_nif;
IF w_nif IS NULL OR w_nif = ' ' THEN
num_err := 101249; -- nif null
RETURN num_err;
END IF;
w_long := LENGTH(w_nif);
IF w_long <8 OR w_long >12 THEN
num_err:= 101250;  -- longitud nif incorrecta
RETURN num_err;
END IF;
FOR i IN 1..w_long
LOOP
w_caracter := UPPER(SUBSTR(w_nif,i,1));
IF ASCII(w_caracter)>=48 AND ASCII(w_caracter)<=57 THEN /*NUMEROS*/
w_nou := w_nou + 1;
w_num := w_num + 1;
w_num_nif := LTRIM(RTRIM(w_num_nif))||w_caracter;
IF i = w_long THEN
w_ultim_digit := w_caracter;
END IF;
END IF;
IF (i=1 OR i=w_long) AND
ASCII(w_caracter)>=65 AND ASCII(w_caracter)<=90 THEN /*LLETRES*/
w_nou := w_nou + 1;
IF i=1 THEN
sw_nif := 1;        -- CIF
w_lletra_ant1 := w_caracter;
END IF;
IF i = w_long THEN
IF sw_nif <> 1 THEN
sw_nif := 2;        -- NIF
ELSE
sw_nif := 3;     -- EXTRANJER
END IF;
w_lletra_ant := w_caracter;
END IF;
END IF;
END LOOP;
IF sw_nif = 3 THEN
num_err := 0;
RETURN num_err;
END IF;
IF w_num > 8 THEN
num_err:= 101250;  -- longitud nif incorrecta
RETURN num_err;
END IF;
IF sw_nif = 2 THEN         -- NIF
w_oper := MOD(TO_NUMBER(w_num_nif),23);
IF w_oper = 0 THEN
w_lletra_act := 'T';
END IF;
IF w_oper = 1 THEN
w_lletra_act := 'R';
END IF;
IF w_oper = 2 THEN
w_lletra_act := 'W';
END IF;
IF w_oper = 3 THEN
w_lletra_act := 'A';
END IF;
IF w_oper = 4 THEN
w_lletra_act := 'G';
END IF;
IF w_oper = 5 THEN
w_lletra_act := 'M';
END IF;
IF w_oper = 6 THEN
w_lletra_act := 'Y';
END IF;
IF w_oper = 7 THEN
w_lletra_act := 'F';
END IF;
IF w_oper = 8 THEN
w_lletra_act := 'P';
END IF;
IF w_oper = 9 THEN
w_lletra_act := 'D';
END IF;
IF w_oper = 10 THEN
w_lletra_act := 'X';
END IF;
IF w_oper = 11 THEN
w_lletra_act := 'B';
END IF;
IF w_oper = 12 THEN
w_lletra_act := 'N';
END IF;
IF w_oper = 13 THEN
w_lletra_act := 'J';
END IF;
IF w_oper = 14 THEN
w_lletra_act := 'Z';
END IF;
IF w_oper = 15 THEN
w_lletra_act := 'S';
END IF;
IF w_oper = 16 THEN
w_lletra_act := 'Q';
END IF;
IF w_oper = 17 THEN
w_lletra_act := 'V';
END IF;
IF w_oper = 18 THEN
w_lletra_act := 'H';
END IF;
IF w_oper = 19 THEN
w_lletra_act := 'L';
END IF;
IF w_oper = 20 THEN
w_lletra_act := 'C';
END IF;
IF w_oper = 21 THEN
w_lletra_act := 'K';
END IF;
IF w_oper = 22 THEN
w_lletra_act := 'E';
END IF;
IF w_oper = 23 THEN
w_lletra_act := 'T';
END IF;
IF NVL(w_lletra_ant,' ') <>' ' THEN
IF w_lletra_act <> w_lletra_ant THEN
w_nif := LTRIM(RTRIM(w_num_nif))||LTRIM(RTRIM(w_lletra_act));
num_err:= 101251; -- lletra nif Incorrecta.
ELSE
num_err:= 0;
END IF;
ELSE
IF LENGTH(w_num_nif)>8 THEN
num_err:= 101250;  -- longitud nif incorrecta
ELSE
w_nif:=LTRIM(RTRIM(w_num_nif))||LTRIM(RTRIM(w_lletra_act));
num_err:= 101657;
END IF;
END IF;
END IF;
IF sw_nif = 1 THEN  -- CIF
IF w_lletra_ant1 <> 'A' AND
w_lletra_ant1 <> 'B' AND
w_lletra_ant1 <> 'C' AND
w_lletra_ant1 <> 'D' AND
w_lletra_ant1 <> 'E' AND
w_lletra_ant1 <> 'F' AND
w_lletra_ant1 <> 'G' AND
w_lletra_ant1 <> 'H' AND
w_lletra_ant1 <> 'S' AND
w_lletra_ant1 <> 'P' AND
w_lletra_ant1 <> 'N' AND
w_lletra_ant1 <> 'Q' THEN
num_err := 101507;
RETURN num_err;
END IF;
w_numer_nif := SUBSTR(w_num_nif,1,7);
IF LENGTH(w_numer_nif) = 7 THEN
FOR i IN 1..7
LOOP
IF MOD(i,2) = 0 THEN  -- posicio par
r1 := r1 + TO_NUMBER(SUBSTR(w_numer_nif,i,1));
ELSE
w_impar :=TO_CHAR(TO_NUMBER(SUBSTR(w_numer_nif,i,1)) * 2);
IF LENGTH(w_impar) = 1 THEN
r2 := r2 + TO_NUMBER(w_impar);
ELSE
r2 := r2 + TO_NUMBER(SUBSTR(w_impar,1,1)) +
TO_NUMBER(SUBSTR(w_impar,2,1));
END IF;
END IF;
END LOOP;
r := r1 + r2;
resto := MOD(r,10);
dif := 10 - resto;
IF dif = 10 THEN
dif := 0;
END IF;
IF LENGTH(w_lletra_ant1)<>0 AND NVL(LENGTH(w_lletra_ant),0)=0 THEN
-- es nacional
w_nif :=LTRIM(RTRIM(w_lletra_ant1))||LTRIM(RTRIM(w_numer_nif))||
TO_CHAR(dif);
IF w_ultim_digit <> dif THEN
w_nif   := w_nif_ant;
num_err := 101506;
ELSE
num_err :=0;
END IF;
ELSE -- resto
IF dif = 1 THEN
g := 'A';
END IF;
IF dif = 2 THEN
g := 'B';
END IF;
IF dif = 3 THEN
g := 'C';
END IF;
IF dif = 4 THEN
g := 'D';
END IF;
IF dif = 5 THEN
g := 'E';
END IF;
IF dif = 6 THEN
g := 'F';
END IF;
IF dif = 7 THEN
g := 'G';
END IF;
IF dif = 8 THEN
g := 'H';
END IF;
IF dif = 9 THEN
g := 'I';
END IF;
IF dif = 0 THEN
g := 'J';
END IF;
w_nif :=LTRIM(RTRIM(w_lletra_ant1))||LTRIM(RTRIM(w_numer_nif))||
g;
IF w_lletra_ant <> g THEN
w_nif := w_nif_ant;
num_err:= 101251; -- lletra cif Incorrecta.
ELSE
num_err:= 0;
END IF;
END IF;
ELSE
w_nif   := w_nif_ant;
num_err := 101250;
END IF;
END IF;
RETURN num_err;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_NIF_TMP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_NIF_TMP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_NIF_TMP" TO "PROGRAMADORESCSI";
