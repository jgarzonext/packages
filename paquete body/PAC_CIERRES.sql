--------------------------------------------------------
--  DDL for Package Body PAC_CIERRES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CIERRES" AS
/******************************************************************************
   NOMBRE:       PAC_MD_CIERRES
   PROPÓSITO: Funciones para cierres contables

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        22/08/2008   JGM                1. Creación del package.
   2.0        12/01/2010   MCA                2. Creación de función para obtener la fecha fin de un tipo de cierre
   3.0        02/01/2012   JMF                3. 0020701 LCOL_F001 - UAT-FIN - La parametrizacion para programacion de cierres no funciono
   4.0        28/01/2013   JLTS               4. 0025023/0136496 LCOL_A001-QT 468 - Campo Estado del cierre obligatorio.
                                                 Se condicionan los campos para que sean obligatorios
******************************************************************************/
   FUNCTION f_set_cierres(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE)
      RETURN NUMBER IS
        /*F_SET_CIERRES
      Función que grabará los datos de un nuevo cierre.

      Parámetros

      1.    CEMPRES: : Entrada y numérico.
      2.    CTIPO: : Entrada y numérico.
      3.    CESTADO: Entrada y numérico.
      4.    FPERINI: Entrada y fecha.
      5.    FPERFIN: Entrada y fecha.
      6.    FCIERRE: Entrada y fecha.

      */
      v_estado       NUMBER(2);
   BEGIN
      IF pcempres IS NULL
         OR pctipo IS NULL
         OR pcestado IS NULL
         OR pfperini IS NULL
         OR pfperfin IS NULL
         OR pfcierre IS NULL THEN
         RETURN 9904873;
      ELSE
         --Esquemáticamente se realizarán las siguientes acciones:

         --Insertar_cierre /insert cierres ...
         BEGIN
            INSERT INTO cierres
                        (fperini, fperfin, fcierre, cempres, ctipo, cestado, sproces,
                         fproces, fcontab)
                 VALUES (pfperini, pfperfin, pfcierre, pcempres, pctipo, pcestado, NULL,
                         f_sysdate, NULL);

            RETURN 0;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               -- control de circuito de estados
               BEGIN
                  SELECT cestado
                    INTO v_estado
                    FROM cierres
                   WHERE fperini = pfperini
                     AND cempres = pcempres
                     AND ctipo = pctipo;

                  IF (v_estado = 0
                      AND pcestado IN(20, 21, 22))
                     OR(v_estado IN(20, 21, 22)
                        AND pcestado = 0)
                     OR(v_estado = pcestado) THEN
                     --Actualizar/update cierres set ...
                     UPDATE cierres
                        SET fperfin = pfperfin,
                            fcierre = pfcierre,
                            cestado = pcestado,
                            sproces = NULL,
                            fproces = f_sysdate,
                            fcontab = NULL
                      WHERE fperini = pfperini
                        AND cempres = pcempres
                        AND ctipo = pctipo;

                     RETURN 0;
                  ELSE
                     -- Circuito Invalido
                     RETURN 805692;   -- No es posible establecer el estado escogido
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 101283;   -- no se han podido grabar los datos
               END;
            WHEN OTHERS THEN
               RETURN 101283;   -- no se han podido grabar los datos
         END;
      END IF;
   END f_set_cierres;

/*F_fechas_nuevo_cierre
Retorna 0 si va todo bien.
Función que ha de mirar las fechas del último cierre del mismo tipo que entra por parámetro,
para proponer las del siguiente cierren, que serán:
   Pfperini :=  (fecha_final_ultimo_cierre + 1);
   Pfperfin :=  last_day(to_date((fecha_final_ultimo_cierre + 1) ));
   Pfcierre :=  last_day(to_date((fecha_final_ultimo_cierre + 1) ));


Parámetros

1. CEMPRES: : Entrada y numérico.
2. CTIPO: : Entrada y numérico.
3. FPERINI: Salida y Fecha.
5. FPERFIN: Salida y Fecha.
5. PFCIERRE: Salida y Fecha.


*/
   FUNCTION f_fechas_nuevo_cierre(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pfperini OUT DATE,
      pfperfin OUT DATE,
      pfcierre OUT DATE)
      RETURN NUMBER IS
      v_ffin         DATE;
      vcesanual      NUMBER;
--Función que ha de mirar las fechas del último cierre del mismo tipo que entra por parámetro, para proponer las del siguiente cierre
   BEGIN
      SELECT MAX(fperfin)
        INTO v_ffin
        FROM cierres
       WHERE cempres = pcempres
         AND ctipo = pctipo
         AND fcierre = (SELECT MAX(fcierre)
                          FROM cierres
                         WHERE cempres = pcempres
                           AND ctipo = pctipo);

      SELECT cesanual
        INTO vcesanual
        FROM pds_program_cierres
       WHERE cempres = pcempres
         AND ctipo = pctipo;

      IF NVL(vcesanual, 0) = 1 THEN
         pfperini :=(v_ffin + 1);
         pfperfin := ADD_MONTHS(pfperini, 12) - 1;
         pfcierre := ADD_MONTHS(pfperini, 12) - 1;
      ELSE
         pfperini :=(v_ffin + 1);
         pfperfin := LAST_DAY(TO_DATE((v_ffin + 1)));
         pfcierre := LAST_DAY(TO_DATE((v_ffin + 1)));
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_fechas_nuevo_cierre;

/*
F_config_cierre
Nueva función que nos devuelve la configuración del cierre.
Devolverá un numérico. 1 si ha podido recuperar su configuración y 0 si no la ha podido recuperar.

Parámetros
1. CEMPRES: Entrada y numérico.
2. CTIPO: Entrada y numérico.
3. PFECMODIF: Salida y numérico.
4. PPREVIO: Salida y numérico.

*/
   FUNCTION f_config_cierre(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pmodif OUT NUMBER,
      pprevio OUT NUMBER)
      RETURN NUMBER IS
      --Nueva función que nos devuelve la configuración del cierre.
      v_pmodif       NUMBER;
      v_pprevio      NUMBER;
   BEGIN
      SELECT NVL(fec_modif, 0)
        INTO v_pmodif
        FROM pds_program_cierres
       WHERE cempres = pcempres
         AND ctipo = pctipo;

      SELECT COUNT('*')
        INTO v_pprevio
        FROM pds_program_cierres
       WHERE cempres = pcempres
         AND ctipo = pctipo
         AND cprevi = 1;

      IF v_pprevio > 0 THEN
         pprevio := 1;
      ELSE
         pprevio := 0;
      END IF;

      pmodif := v_pmodif;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_config_cierre;

/*F_BORRAR_CIERRE
Nueva función que se utilizará para borrar un CIERRE (sólo se pueden borrar aquellos que esten pendientes).

Parámetros

1. PCEMPRES: Entrada y numérico. Empresa.
2. PCTIPO: Entrada y numérico. Tipo de cierre.
3. PFPERINI: Entrada y fecha. Fecha inicio del cierre.
4. PCESTADO: Entrada y númerico. Estado del cierre.

*/
   FUNCTION f_borrar_cierre(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pfperini IN DATE,
      pcestado IN NUMBER)
      RETURN NUMBER IS
      v_pmodif       NUMBER;
      v_pprevio      NUMBER;
   BEGIN
      IF pcestado <> 0 THEN
         RETURN 1;   -- en principio no deberia de entrar nunca por aquí.
      END IF;

      DELETE      cierres
            WHERE cempres = pcempres
              AND ctipo = pctipo
              AND fperini = pfperini;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_borrar_cierre;

/*F_FECHA_ULTCIERRE
Nueva función que devolverá la fecha del último cierre hecho del tipo que entra por parámetro
Param.
1. PCEMPRES: Empresa.
2. PCTIPO: Tipo de cierre
3.  PFECHA: Fecha fin del último cierre hecho
*/
   FUNCTION f_fecha_ultcierre(pcempres IN NUMBER, pctipo IN NUMBER)
      RETURN DATE IS
      vfecha         DATE;
   BEGIN
      SELECT MAX(fperfin)
        INTO vfecha
        FROM cierres
       WHERE cempres = pcempres
         AND ctipo = pctipo
         AND cestado = 1;   --Cerrado

      RETURN vfecha;
   END f_fecha_ultcierre;

-- BUG 0020701 - 02/01/2012 - JMF
   FUNCTION f_val_fcierre(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE)
      RETURN NUMBER IS
      v_cval_fierre  pds_program_cierres.cval_fcierre%TYPE;
      v_error        NUMBER;
   BEGIN
      v_error := 0;

      SELECT MAX(cval_fcierre)
        INTO v_cval_fierre
        FROM pds_program_cierres
       WHERE cempres = pcempres
         AND ctipo = pctipo;

      IF v_cval_fierre = 1 THEN
         -- Permitir f.cierre anterior parempresa
         NULL;
      ELSE
         IF (pfcierre < pfperfin) THEN
            -- Fecha de cierre no permitida
            v_error := 108127;
         END IF;
      END IF;

      RETURN v_error;
   END f_val_fcierre;
END pac_cierres;

/

  GRANT EXECUTE ON "AXIS"."PAC_CIERRES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CIERRES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CIERRES" TO "PROGRAMADORESCSI";
