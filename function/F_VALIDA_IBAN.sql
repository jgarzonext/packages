--------------------------------------------------------
--  DDL for Function F_VALIDA_IBAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_VALIDA_IBAN" (pcodigo IN VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
    02/2007  MCA
    F_VALIDA_IBAN: Valida el código IBAN entrado por parámetro
    Devuelve 1 si es correcto.

    JFD 27/09/2007 para igualar salida de datos con f_ccc si no hay error
    devuelve 0 en caso contrario devuelve un literal.

    JFD 08/10/2007  Mofificamos la función para que valide la procedencia
    del código y la longitud.
***********************************************************************/
    vresto      NUMBER;     vpos        VARCHAR2(2);    vcodigo     VARCHAR2(100);
    vcodi       NUMBER;     vinicio     VARCHAR2(4);    vresultado  VARCHAR2(100);
    vlong       NUMBER;     vfinal      VARCHAR2(30);
    v_detccc		NUMBER;


BEGIN

    SELECT LENGTH(pcodigo) INTO vlong FROM DUAL;
    SELECT SUBSTR(pcodigo,1,4) INTO vinicio FROM DUAL;
    SELECT SUBSTR(pcodigo,5) INTO vfinal FROM DUAL;
    vcodigo:= TRIM(vfinal) || TRIM(vinicio);

   -- JFD 08/10/2007 -------------------------------------------------------
   --XVILA: Bug 5553
   /*
   if vlong <> f_parinstalacion_n('IBAN') then
        RETURN 180755; -- no coincideixen les longituds
   end if;

   SELECT SUBSTR(pcodigo,1,2) INTO vpos FROM DUAL;

   if vpos <> f_parinstalacion_t('IBAN') then
       RETURN 102494; -- El código de cuenta es erróneo
   end if;

   vpos := null;
   */

   SELECT LONGITUD
   INTO v_detccc
   FROM DETTIPOS_CUENTA
   WHERE IDPAIS = UPPER(SUBSTR(pcodigo,1,2))
         AND CTIPBAN = 2;

   if vlong <> v_detccc then
        RETURN 180755; -- no coincideixen les longituds
   end if;
   --XVILA: Bug 5553
   -------------------------------------------------------------------------


    FOR i IN 1..vlong LOOP
        vpos := RTRIM(UPPER(SUBSTR(vcodigo,i,1)));
        IF vpos IS NOT NULL THEN
            IF ASCII(vpos)>=65 AND ASCII(vpos)<=90 THEN /*LETRA*/
                SELECT ASCII(UPPER(vpos))-55 INTO vpos
                FROM DUAL;
            END IF;
            vresultado:=vresultado||vpos;
        END IF;
    END LOOP;
    SELECT MOD(vresultado,97) INTO vresto
    FROM DUAL;
    IF vresto = 1 THEN
        RETURN 0;
    ELSE
        RETURN 102494; -- El código de cuenta es erróneo
    END IF;
EXCEPTION
    WHEN others THEN
        RETURN 102494; -- El código de cuenta es erróneo
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_VALIDA_IBAN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_VALIDA_IBAN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_VALIDA_IBAN" TO "PROGRAMADORESCSI";
