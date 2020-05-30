--------------------------------------------------------
--  DDL for Package Body PAC_MNTDTOSESPECIALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MNTDTOSESPECIALES" AS
/******************************************************************************
    NOMBRE:      PAC_MNTDTOSESPECIALES
    PROPÓSITO:   Funciones para la gestión de descuentos especiales

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------  ------------------------------------
    1.0        15/05/2013   AMC       1. Creación del package. Bug 26615/143210
******************************************************************************/

   /**********************************************************************************************
      Función para recuperar campañas
      param in pccampanya:

      Bug 26615/143210 - 15/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_campanyas(pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      vobject        VARCHAR2(500) := 'pac_mntdtosespeciales.f_get_campanyas';
      vparam         VARCHAR2(550) := 'parámetros - pcidioma:' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vtexto         VARCHAR2(500);
   BEGIN
      vtexto := 'select ccampanya,tcampanya' || ' from descampanyas' || ' where cidioma = '
                || pcidioma;
      RETURN vtexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_get_campanyas;

   /**********************************************************************************************
      Función para insertar un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_set_dtosespeciales(
      pcempres IN NUMBER,
      pccampanya IN NUMBER,
      pfecini IN DATE,
      pfecfin IN DATE,
      pmodo IN VARCHAR2)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_mntdtosespeciales.f_set_dtosespeciales';
      vparam         VARCHAR2(550)
         := 'parámetros - pcempres:' || pcempres || ' pccampanya:' || pccampanya
            || ' pfecini:' || pfecini || ' pfecfin:' || pfecfin;
      vpasexec       NUMBER(5) := 1;
      vcount         NUMBER;
   BEGIN
      --JLV 25/06/2013 Controlar si es un proceso de alta.
      IF UPPER(pmodo) = 'NUEVO' THEN
         SELECT COUNT(1)
           INTO vcount
           FROM coddtosespeciales
          WHERE cempres = pcempres
            AND ccampanya = pccampanya;

         IF vcount > 0 THEN
            RETURN 9905632;
         END IF;

         INSERT INTO coddtosespeciales
                     (cempres, ccampanya, finicio, ffin)
              VALUES (pcempres, pccampanya, pfecini, pfecfin);
      ELSIF UPPER(pmodo) = 'MODIF' THEN
         -- Validamos que las fechas sean coherentes
         IF (pfecini IS NULL)
            OR(pfecfin IS NULL)
            OR(TRUNC(pfecfin) < TRUNC(f_sysdate))
            OR(TRUNC(pfecfin) < TRUNC(pfecini)) THEN
            RETURN 105981;
         END IF;

         UPDATE coddtosespeciales
            SET finicio = pfecini,
                ffin = pfecfin
          WHERE cempres = pcempres
            AND ccampanya = pccampanya;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_dtosespeciales;

   /**********************************************************************************************
      Función para insertar el detalle de un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_set_dtosespeciales_lin(
      pcempres IN NUMBER,
      pccampanya IN NUMBER,
      psproduc IN NUMBER,
      pcpais IN NUMBER,
      pcdpto IN NUMBER,
      pcciudad IN NUMBER,
      pcagrupa IN VARCHAR2,
      pcsucursal IN NUMBER,
      pcintermed IN NUMBER,
      ppdto IN NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_mntdtosespeciales.f_set_dtosespeciales';
      vparam         VARCHAR2(550)
         := 'parámetros - pcempres:' || pcempres || ' pccampanya:' || pccampanya
            || ' psproduc:' || psproduc || ' pcpais:' || pcpais || ' pcdpto:' || pcdpto
            || ' pcciudad:' || pcciudad || ' pcagrupa:' || pcagrupa || ' pcsucursal:'
            || pcsucursal || ' pcintermed:' || pcintermed || ' ppdto:' || ppdto;
      vpasexec       NUMBER(5) := 1;
      v_fini         DATE;
      v_ffin         DATE;
      v_totreg       NUMBER;
   BEGIN
      FOR c_dupc IN (SELECT pccampanya
                       FROM detdtosespeciales
                      WHERE cempres = pac_md_common.f_get_cxtempresa
                        --AND ccampanya = pccampanya
                        AND sproduc = psproduc
                        AND cdpto = pcdpto
                        AND cciudad = pcciudad
                        AND cagrupacion = pcagrupa
                        AND csucursal = pcsucursal
                        AND cintermediario = pcintermed
                        AND pdto = ppdto
                        AND cpais = pcpais) LOOP
         --Obtener fechas de la campaña tratada
         SELECT finicio, ffin
           INTO v_fini, v_ffin
           FROM coddtosespeciales
          WHERE ccampanya = c_dupc.pccampanya;

         --Verificar que no exista otra igual
         SELECT COUNT('1')
           INTO v_totreg
           FROM coddtosespeciales
          WHERE finicio = v_fini
            AND ffin = v_ffin;

         IF v_totreg > 1 THEN
            RETURN 9904284;
         END IF;
      END LOOP;

      BEGIN
         INSERT INTO detdtosespeciales
                     (cempres, ccampanya, sproduc, cpais, cdpto, cciudad, cagrupacion,
                      csucursal, cintermediario, pdto)
              VALUES (pcempres, pccampanya, psproduc, pcpais, pcdpto, pcciudad, pcagrupa,
                      pcsucursal, pcintermed, ppdto);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE detdtosespeciales
               SET pdto = ppdto
             WHERE cempres = pcempres
               AND ccampanya = pccampanya
               AND sproduc = psproduc
               AND cpais = pcpais
               AND cdpto = pcdpto
               AND cciudad = pcciudad
               AND cagrupacion = pcagrupa
               AND csucursal = pcsucursal
               AND cintermediario = pcintermed;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_set_dtosespeciales_lin;

    /**********************************************************************************************
      Función para borrar un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_dtosespeciales(pcempres IN NUMBER, pccampanya IN NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_mntdtosespeciales.f_del_dtosespeciales';
      vparam         VARCHAR2(550)
                       := 'parámetros - pcempres:' || pcempres || ' pccampanya:' || pccampanya;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      DELETE      detdtosespeciales
            WHERE cempres = pcempres
              AND ccampanya = pccampanya;

      DELETE      coddtosespeciales
            WHERE cempres = pcempres
              AND ccampanya = pccampanya;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_del_dtosespeciales;

    /**********************************************************************************************
      Función para borrar el detalle un descuento
      param in pccampanya:

      Bug 26615/143210 - 22/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_del_dtosespeciales_lin(
      pcempres IN NUMBER,
      pccampanya IN NUMBER,
      psproduc IN NUMBER,
      pcpais IN NUMBER,
      pcdpto IN NUMBER,
      pcciudad IN NUMBER,
      pcagrupa IN VARCHAR2,
      pcsucursal IN NUMBER,
      pcintermed IN NUMBER)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'pac_mntdtosespeciales.f_del_dtosespeciales_lin';
      vparam         VARCHAR2(550)
         := 'parámetros - pcempres:' || pcempres || ' pccampanya:' || pccampanya
            || ' psproduc:' || psproduc || ' pcpais:' || pcpais || ' pcdpto:' || pcdpto
            || ' pcciudad:' || pcciudad || ' pcagrupa:' || pcagrupa || ' pcsucursal:'
            || pcsucursal || ' pcintermed:' || pcintermed;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      DELETE      detdtosespeciales
            WHERE cempres = pcempres
              AND ccampanya = pccampanya
              AND sproduc = psproduc
              AND cpais = pcpais
              AND cdpto = pcdpto
              AND cciudad = pcciudad
              AND cagrupacion = pcagrupa
              AND csucursal = pcsucursal
              AND cintermediario = pcintermed;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_del_dtosespeciales_lin;

    /**********************************************************************************************
      Función para recuperar las agrupaciones tipo


      Bug 26615/143210 - 23/05/2013 - AMC
   ************************************************************************************************/
   FUNCTION f_get_cagrtipo
      RETURN VARCHAR2 IS
      vobject        VARCHAR2(500) := 'pac_mntdtosespeciales.f_get_cagrtipo';
      vparam         VARCHAR2(550);
      vpasexec       NUMBER(5) := 1;
      vtexto         VARCHAR2(500);
   BEGIN
      vtexto := 'select cagrtipo from aut_codagrtipo';
      RETURN vtexto;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_get_cagrtipo;
END pac_mntdtosespeciales;

/

  GRANT EXECUTE ON "AXIS"."PAC_MNTDTOSESPECIALES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MNTDTOSESPECIALES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MNTDTOSESPECIALES" TO "PROGRAMADORESCSI";
