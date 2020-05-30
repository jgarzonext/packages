--------------------------------------------------------
--  DDL for Package Body PAC_COMPANIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_COMPANIAS" IS
/******************************************************************************
   NOMBRE:     PAC_COMPANIAS
   PROPOSITO:  Package que contiene las funciones para indicadores de impuesto

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
     1.0        27/10/2017   JVG            CONF: Impuestos
   ******************************************************************************/

   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/*************************************************************************
      FUNCTION f_get_tipiva
      Funcion que dado una compa?ia y una fecha retorna el % tipo de iva a la fecha
      param in pccompani   : Codigo compa?ia
      param in pfecha      : Fecha en activo
      return               : % Tipo de iva a aplicar
     *************************************************************************/

   FUNCTION f_get_tipiva(pccompani IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      pptipiva       NUMBER;
   BEGIN
      SELECT ptipiva
        INTO pptipiva
        FROM tipoiva t, companias c
       WHERE c.ccompani = pccompani
         AND t.ctipiva = c.ctipiva
         AND TRUNC(pfecha) >= TRUNC(finivig)
         AND TRUNC(pfecha) < TRUNC(NVL(ffinvig, pfecha + 1));

      RETURN pptipiva;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_COMPANIAS.f_get_tipiva', 1,
                     'pccompani = ' || pccompani || '; pfecha = '
                     || TO_CHAR(pfecha, 'dd/mm/yyyy'),
                     SQLERRM);
         RETURN NULL;
   END f_get_tipiva;

    /*************************************************************************
      FUNCTION f_retefuente
      Encontrar el valor retefuente
      param in pccompani     : codigo agente
      param out pretefuente  : devuelve el valor del retefuente a buscar dentro de las vigencias
   *************************************************************************/
   FUNCTION f_retefuente(pccompani IN NUMBER) RETURN NUMBER IS
      vvalor NUMBER;
   BEGIN
      IF pccompani is not null

     THEN
         --
         BEGIN
            --
            SELECT DECODE(r.cregfiscal, 6, 0, 8, 0,DECODE(c.ctipcom,0,3,3,2))
              INTO vvalor
              FROM companias c, per_personas p,
                   (SELECT sperson,cregfiscal
                      FROM per_regimenfiscal
                      WHERE (sperson, fefecto) IN
                            (SELECT sperson, MAX(fefecto)
                               FROM per_regimenfiscal
                              GROUP BY sperson)) r
             WHERE c.ccompani = pccompani
               AND p.sperson = c.sperson
               AND p.sperson = r.sperson(+);
          END ;
    END IF;

      RETURN vvalor;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     'PAC_companias.f_retefuente',
                     1,
                     SQLCODE,
                     SQLERRM);

         RETURN 0;
   END f_retefuente;

END PAC_COMPANIAS;

/

  GRANT EXECUTE ON "AXIS"."PAC_COMPANIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_COMPANIAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_COMPANIAS" TO "PROGRAMADORESCSI";
