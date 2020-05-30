--------------------------------------------------------
--  DDL for Function F_FORMATOCCC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_FORMATOCCC" (
   ptcuenta IN VARCHAR2,
   ptsalida OUT VARCHAR2,
   pctipban IN NUMBER DEFAULT 1,
   pquitarformato IN NUMBER DEFAULT 0)
   RETURN NUMBER AUTHID CURRENT_USER IS
/*****************************************************************
F_FORMATOCCC: Retorna el compte bancari sense formatejar en un
string formatejat
LCF - 0023894: MDP - PER - Validación de la cuenta bancaria.
JFD - 20080212 - Modificación temporal para que la función formatee
las cuentas IBAN de Andorra tal y como quiere el cliente (6 grupos
de 4 dígitos)
JTS - 12-02-2008 - Es remodela la funció per a que tingui
                   en compte la longitud i la màscara informades
                   a la taula tipos_cuenta.

 Ver        Fecha       Autor           Descripción
 -----  ----------  ---------  ------------------------------------
 1.0    XX/XX/XXXX  XXX        Creació de la funció
 2.0    27/10/2011  JGR        0019793: LCOL_A001-Formato de cuentas bancarias y tarjetas de credito
 3.0    07/02/2014  CML        Poner UPPER cuando sea IBAN (ctipban = 2)
******************************************************************/
   v_coderr       NUMBER := 0;
   v_longcuen     NUMBER;
   v_longtipban   NUMBER;
   v_mascara      VARCHAR2(50);
   v_indcuen      NUMBER;
   v_indmasc      NUMBER;
   v_mascact      CHAR;
   v_cuenact      CHAR;
   v_tcuenta      seguros.cbancar%TYPE;
   e_param_error  EXCEPTION;
   vobjectname    tab_error.tobjeto%TYPE := 'f_formatoccc';
   vparam         tab_error.tdescrip%TYPE
                         := 'parámetros - ptcuenta: ' || ptcuenta || ' pctipban: ' || pctipban;
   vpasexec       NUMBER(5) := 1;
   vbanco         VARCHAR2(20);
BEGIN
   IF pctipban = 2 THEN   -- Para IBAN trataremos en mayúsculas
      v_tcuenta := UPPER(ptcuenta);
   ELSE
      v_tcuenta := ptcuenta;
   END IF;

   --JTS Comprovem els paràmetres d'entrada
   IF v_tcuenta IS NULL THEN
      v_coderr := 1;
      RAISE e_param_error;
   END IF;

   --Bug.: 0017242 - 14/01/2011 - ICV
   IF pctipban = 5 THEN
      IF pquitarformato = 0 THEN
         ptsalida := v_tcuenta;
      ELSE
         ptsalida :=(REPLACE(v_tcuenta, '-', ''));
      END IF;

      RETURN v_coderr;
   END IF;

   --Fin bug.
   SELECT LENGTH(v_tcuenta)
     INTO v_longcuen
     FROM DUAL;

   --XVILA: Bug 5553
   /*
   SELECT longitud, formato
     INTO v_longtipban, v_mascara
     FROM tipos_cuenta
    WHERE ctipban = pctipban;
   */
   IF pctipban = 2 THEN   --es IBAN
      SELECT longitud, formato
        INTO v_longtipban, v_mascara
        FROM dettipos_cuenta
       WHERE idpais = SUBSTR(v_tcuenta, 1, 2)
         AND ctipban = pctipban;
   ELSIF pctipban = 1
         OR pctipban = 3
         OR pctipban = 4   --es compte lliure (AD,ESP,BEL)
         OR pctipban = 5 THEN   -- 14502 13-05-2010 AVT S'afegeix el format d'Angola
      SELECT longitud, formato
        INTO v_longtipban, v_mascara
        FROM dettipos_cuenta
       WHERE ctipban = pctipban;
   --> 0019793 - AXIS3181 - Ver 2.0 - INICI
   ELSE
      SELECT longitud, formato
        INTO v_longtipban, v_mascara
        FROM tipos_cuenta
       WHERE ctipban = pctipban;
--   ELSE
--      v_coderr := 1;
--      RAISE e_param_error;
  --> 0019793 - AXIS3181 - Ver 2.0 - FI
   END IF;

   vpasexec := 2;

   --JTS Si no coincideixen les longituds no continua
   IF v_longcuen != v_longtipban
      AND v_longtipban IS NOT NULL THEN
      v_coderr := 180755;
      RAISE e_param_error;
   END IF;

   --JTS Si no está informada la màscara o la longitud, no formateja
   IF v_longtipban IS NULL
      AND v_mascara IS NULL THEN
      --v_coderr := 180756;
      ptsalida := v_tcuenta;
      RETURN v_coderr;
   END IF;

   v_indcuen := 1;
   ptsalida := '';
   vpasexec := 3;

   --JTS Formatejem el compte
   IF pquitarformato = 0 THEN   --JRH 04/2008 hace lo de hasta ahora
      IF v_mascara IS NOT NULL THEN   --> 0019793 - AXIS3181 - Ver 2.0
         FOR v_indmasc IN 1 .. LENGTH(v_mascara) LOOP
            v_mascact := SUBSTR(v_mascara, v_indmasc, 1);
            v_cuenact := SUBSTR(v_tcuenta, v_indcuen, 1);

            IF v_mascact = 'X' THEN
               v_indcuen := v_indcuen + 1;
               ptsalida := ptsalida || v_cuenact;
            ELSE
               ptsalida := ptsalida || v_mascact;
            END IF;
         END LOOP;
      ELSE   --> 0019793 - AXIS3181 - Ver 2.0
         ptsalida := v_tcuenta;   --> 0019793 - AXIS3181 - Ver 2.0
      END IF;   --> 0019793 - AXIS3181 - Ver 2.0
   ELSE
          --Le quitamos el formato
      /*
      begin --JRH 04/2008
      ptsalida:=to_number(v_tcuenta);

      exception
      WHEN OTHERS THEN
        begin
          ptsalida:=TO_NUMBER(REPLACE(v_tcuenta,'-',''));
        exception
        when others then
          ptsalida:=(REPLACE(v_tcuenta,'-',''));
        end;
      end;
      */
      ptsalida :=(REPLACE(v_tcuenta, '-', ''));
   END IF;

   /* Bug : 23894  */

   -- Si es cuenta española Y le parametro por empresa indica que tenemos que validar el banco, comprobamos que no sea 0000
   IF (pctipban = 1
       AND NVL(pac_parametros.f_parempresa_n(f_empres, 'PER_BANCO_0000'), 0) = 1) THEN
      -- Coger los 4 digitos primeros
      SELECT SUBSTR(v_tcuenta, 0, 4)
        INTO vbanco
        FROM DUAL;

      IF vbanco = '0000' THEN
         RETURN 9904308;   --'No existe el banco '
         RAISE e_param_error;
      /*ELSE
         ptsalida :=(REPLACE(v_tcuenta, '-', ''));
       */
      END IF;
   END IF;

   vpasexec := 4;
   RETURN v_coderr;
EXCEPTION
   WHEN e_param_error THEN
      p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                  'Objeto invocado con parámetros erroneos');
      RETURN v_coderr;
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1;
END;

/

  GRANT EXECUTE ON "AXIS"."F_FORMATOCCC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FORMATOCCC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FORMATOCCC" TO "PROGRAMADORESCSI";
