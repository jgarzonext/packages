--------------------------------------------------------
--  DDL for Package PAC_INFORMES_SIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_INFORMES_SIN" AUTHID CURRENT_USER IS
/******************************************************************************
   NOMBRE:      pac_informes_sin


   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/03/2012   JMF              0021662 LCOL_S001-SIN - Excel de movimientos económicos

******************************************************************************/

   /******************************************************************************************
     Descripció: Funció que genera texte capçelera per llistat dinamic Resumen_Siniestro.csv
     Paràmetres entrada: - p_nsinies     -> Siniestro
                         - p_cidioma     -> Idioma
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021662 - 14/03/2012 - JMF
   FUNCTION f_00520_cab(p_nsinies IN NUMBER DEFAULT NULL, p_cidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Resumen_Siniestro.csv
     Paràmetres entrada: - p_nsinies     -> Siniestro
                         - p_cidioma     -> Idioma
     return:             select detalle
   ******************************************************************************************/
   -- Bug 0021662 - 14/03/2012 - JMF
   FUNCTION f_00520_det(p_nsinies IN NUMBER DEFAULT NULL, p_cidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;
END pac_informes_sin;

/

  GRANT EXECUTE ON "AXIS"."PAC_INFORMES_SIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_INFORMES_SIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_INFORMES_SIN" TO "PROGRAMADORESCSI";
