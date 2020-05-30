--------------------------------------------------------
--  DDL for Function F_CCC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CCC" (
   pncuenta IN VARCHAR2,
   pctipban IN NUMBER,
   pncontrol IN OUT NUMBER,
   pnsalida IN OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
/**************************************************************************
    F_CCC        Valida una cuenta bancaria y devuelve como parámetros
            el número incluyendo los dígitos de control.
            Devuelve como valor el código del error. 0 si está bien.
    JFD - 28-09-2007 Se cambia la función para adaptarla a los diferentes
    formatos de cuentas.
        Se añade el parámetro  de entrada pctipban (tipo de cuenta,
        tipos_cuenta). En función del valor de este parámetro se llama a una
        función u otra:
                5 - Angola  => f_ccc_ang
                4 - Bélgica => f_ccc_bel
                3 - Andorra => f_ccc_and
                2 - Iban    => f_valida_iban
                1 - España  => f_ccc_esp (es la antigua f_ccc).
 Ver        Fecha        Autor           Descripción
 ---------  ----------  ---------------  ------------------------------------
 1.0        XX/XX/XXXX   XXX             Creació de la funció
 2.0        13/05/2010   AVT             14502 13-05-2010 funcions passen a estar
                                         dins del package PAC_CCC
 3.0        14/01/2011   ICV             0017242: ENSA101 - Compte bancari
 4.0        25/01/2011   DRA             0017286: GRC003 - PAC_TRANSFERENCIAS y modelo nuevo siniestros
 5.0        27/10/2011   JGR             0019793: LCOL_A001-Formato de cuentas bancarias y tarjetas de credito
 6.0        19/08/2014   XBA             Añadimos el ctipban = 215. Validación de 31 para IBAN de Malta
**************************************************************************/
   vctipcc        NUMBER;
   vlongitud      NUMBER;
   verror         NUMBER;
   vobjectname    tab_error.tobjeto%TYPE := 'F_CCC';   --> 0019793 - AXIS3181 - Ver 2.0
   vpasexec       tab_error.ntraza%TYPE;   --> 0019793 - AXIS3181 - Ver 2.0
   vparam         tab_error.tdescrip%TYPE
                         := 'parámetros - pncuenta: ' || pncuenta || ' pctipban: ' || pctipban;   --> 0019793 - AXIS3181 - Ver 2.0
BEGIN
   IF pctipban = 1
      OR pctipban IS NULL THEN
      verror := pac_ccc.f_ccc_esp(TO_NUMBER(pncuenta), pncontrol, pnsalida);
      vpasexec := 1;
      RETURN verror;
   ELSIF pctipban IN(2, 215) THEN
      vpasexec := 2;
      verror := pac_ccc.f_valida_iban(pncuenta);
      pnsalida := pncuenta;
      pncontrol := NULL;
      RETURN verror;
   ELSIF pctipban = 3 THEN
      vpasexec := 3;
      verror := pac_ccc.f_ccc_and(pncuenta, pnsalida);
      pncontrol := NULL;
      RETURN verror;
   --XVILA: Bug 5553
   ELSIF pctipban = 4 THEN
      vpasexec := 4;
      verror := pac_ccc.f_ccc_bel(pncuenta, pnsalida);
      pncontrol := NULL;
      RETURN verror;
   -- Bug 14502 12-05-2010 AVT
   ELSIF pctipban = 5 THEN
      vpasexec := 5;
      --Bug 17242 - 14-01-2011 - ICV
      --BUG 18312 - 27/04/2011 - JRB - Se permite cualquier número y letra mientras no supere la longitud de 20
      verror := pac_ccc.f_ccc_ang(pncuenta, pnsalida);
      --Fi bug
      --pnsalida := pncuenta;
      pncontrol := NULL;
      RETURN NVL(verror, 0);
   -- Bug 14502 fi
   --> 0019793 - AXIS3181 - Ver 2.0 - INICI
   ELSE
      vpasexec := 6;

      SELECT ctipcc, longitud
        INTO vctipcc, vlongitud
        FROM tipos_cuenta
       WHERE ctipban = pctipban;

      IF vctipcc IN(1,   -- Cuenta bancaria corriente
                      3)   -- Cuenta bancaria ahorro
                        THEN
         vpasexec := 7;

         IF vlongitud IS NOT NULL THEN   -- Si la longitud es nula, no se aplican validaciones de formato
            verror := pac_ccc.f_ccc_col_bco(pctipban, pncuenta, pnsalida);
         ELSE
            pnsalida := pncuenta;
         END IF;

         pncontrol := NULL;
         RETURN NVL(verror, 0);
      ELSE
         vpasexec := 8;
         verror := pac_ccc.f_ccc_col_tar(pctipban, pncuenta, pnsalida);
         pncontrol := NULL;
      END IF;

      RETURN NVL(verror, 0);
--   ELSE
--      RETURN 180928;   -- Error al buscar la descripción de tipo o formato de cuenta ccc

   --> 0019793 - AXIS3181 - Ver 2.0 - FI
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,   --> 0019793 - AXIS3181 - Ver 2.0
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);   --> 0019793 - AXIS3181 - Ver 2.0
      RETURN 102494;   -- El código de cuenta es erróneo
END;

/

  GRANT EXECUTE ON "AXIS"."F_CCC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CCC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CCC" TO "PROGRAMADORESCSI";
