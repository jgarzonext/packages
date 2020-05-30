--------------------------------------------------------
--  DDL for Package Body PAC_PROD_GENERICOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROD_GENERICOS" IS
/******************************************************************************
   NOMBRE:       pac_prod_genericos
   PROPÓSITO: Funciones para gestionar productos genericos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/08/2010    XPL              1. Creación del package.
   2.0        03/01/2011    LCF              2. Modificacion prescompanias
******************************************************************************/

   /*************************************************************************
   Obtiene las companias asociadas al seguro especificado
   param in psseguro   : Codigo sseguro
   param out psquery   : Select
   param in pidioma    : Codi idioma
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_obtener_companias(psseguro IN NUMBER, pquery OUT VARCHAR2, pidioma IN NUMBER)
      RETURN NUMBER IS
      vselect        VARCHAR2(500);
      vfrom          VARCHAR2(500);
      vwhere         VARCHAR2(500);
   BEGIN
      vselect := 'SELECT c.ccompani, co.tcompani, c.cagencorr, c.sproducesp ';
      vfrom := ' FROM companipro c, companias co ';
      vwhere := ' WHERE c.sproduc = (SELECT s.sproduc FROM seguros s WHERE s.sseguro = '
                || psseguro || ') ' || 'AND  c.ccompani = co.ccompani ';
      pquery := vselect || vfrom || vwhere;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PROD_GENERICOS', 1,
                     'f_obtener_companias.Error Imprevisto:', SQLERRM);
         RETURN 103212;
   END f_obtener_companias;

   /*************************************************************************
   Obtiene las companias asociadas al seguro especificado haciendo join con presseguros(presupuestos pedidos)
   param in psseguro   : Codigo sseguro
   param out psquery   : Select
   param in pidioma    : Codi idioma
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_obtener_prescompanias(psseguro IN NUMBER, pquery OUT VARCHAR2, pidioma IN NUMBER)
      RETURN NUMBER IS
      vselect        VARCHAR2(500);
      vfrom          VARCHAR2(500);
      vwhere         VARCHAR2(500);
   BEGIN
      vselect :=
         'SELECT c.ccompani, co.tcompani, c.cagencorr, c.sproducesp, c.sproduc, ps.iddoc, ps.cmarcar, ps.fpresupuesto ';
      vfrom := ' FROM companipro c, companias co, presseguro ps ';
      vwhere :=
         ' WHERE c.sproduc = (SELECT s.sproduc FROM seguros s WHERE s.sseguro = ' || psseguro
         || ') '
         || 'AND  c.ccompani = co.ccompani and  c.ccompani =  ps.ccompani(+)
      and c.sproducesp =  ps.sproduc(+)
      AND PS.SSEGURO(+) = '
         || psseguro;
      pquery := vselect || vfrom || vwhere;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PROD_GENERICOS', 1,
                     'f_obtener_prescompanias.Error Imprevisto:', SQLERRM);
         RETURN 103212;
   END f_obtener_prescompanias;

    /*************************************************************************
   Actualiza la tabla estseguros y obtiene campos que necesitamos
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pssegpol OUT NUMBER,
      pcramo OUT NUMBER,
      pcmodali OUT NUMBER,
      pctipseg OUT NUMBER,
      pccolect OUT NUMBER,
      pcactivi OUT NUMBER
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_traspasar_especifico(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pssegpol OUT NUMBER,
      pcramo OUT NUMBER,
      pcmodali OUT NUMBER,
      pctipseg OUT NUMBER,
      pccolect OUT NUMBER,
      pcactivi OUT NUMBER)
      RETURN NUMBER IS
      vselect        VARCHAR2(500);
      vfrom          VARCHAR2(500);
      vwhere         VARCHAR2(500);
   BEGIN
      SELECT sseguro.NEXTVAL
        INTO pssegpol
        FROM DUAL;

      SELECT cramo, cmodali, ctipseg, ccolect
        INTO pcramo, pcmodali, pctipseg, pccolect
        FROM productos
       WHERE sproduc = psproduc;

      UPDATE estseguros
         SET sproduc = psproduc,
             ssegpol = pssegpol,
             npoliza = psseguro,
             nsolici = psseguro,
             cramo = pcramo,
             cmodali = pcmodali,
             ctipseg = pctipseg,
             ccolect = pccolect
       WHERE sseguro = psseguro;

      BEGIN
         SELECT a.cactivi
           INTO pcactivi
           FROM activiprod a, productos p
          WHERE a.cramo = p.cramo
            AND a.cmodali = p.cmodali
            AND a.ctipseg = p.ctipseg
            AND a.ccolect = p.ccolect
            AND p.sproduc = psproduc;
      EXCEPTION
         WHEN OTHERS THEN
            pcactivi := 0;   --BUG 9916 02/07/2009: ETM : añadimos
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PROD_GENERICOS', 1,
                     'f_traspasar_especifico.Error Imprevisto:', SQLERRM);
         RETURN 103212;
   END f_traspasar_especifico;

   /*************************************************************************
   Marca el producto correspondiente al seguro especificado
   param in psseguro   : Codigo sseguro
   param in pccompani  : Codigo compania
   param in pmarcar    : Marca
   param in pmodo      : Modo

   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_marcar_compania(
      psseguro IN NUMBER,
      pccompani IN NUMBER,
      psproduc IN NUMBER,
      pmarcar IN NUMBER,
      piddoc IN NUMBER)
      RETURN NUMBER IS
      vselect        VARCHAR2(500);
      vfrom          VARCHAR2(500);
      vwhere         VARCHAR2(500);
   BEGIN
      BEGIN
         INSERT INTO presseguro
                     (sseguro, ccompani, sproduc, iddoc, cmarcar, fpresupuesto)
              VALUES (psseguro, pccompani, psproduc, piddoc, pmarcar, f_sysdate);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE presseguro
               SET iddoc = piddoc,
                   cmarcar = pmarcar,
                   fpresupuesto = f_sysdate
             WHERE sseguro = psseguro
               AND sproduc = psproduc;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PROD_GENERICOS', 1,
                     'f_marcar_compania.Error Imprevisto:', SQLERRM);
         RETURN 103212;
   END f_marcar_compania;
END pac_prod_genericos;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROD_GENERICOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_GENERICOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_GENERICOS" TO "PROGRAMADORESCSI";
