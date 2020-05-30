--------------------------------------------------------
--  DDL for Package PAC_INFORMES_REA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_INFORMES_REA" IS
/******************************************************************************
   NOMBRE:      PAC_INFORMES_REA


   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        31/01/2012   JMF               1. 0021129 LCOL_A002-Listados de reaseguro
   2.0        03/07/2012   JMF               0022682: LCOL_A002-Qtracker: 0004600: La cesi?n de siniestros XL no es correcta
   3.0        25/07/2012   JMF               0022678: LCOL_A002-Qtracker: 0004601: Error en cuenta tecnica de XL
   4.0        13/06/2014   EDA              4 0029038: Ajustar listado f_00504_det, para simplificarlo.

******************************************************************************/

   /******************************************************************************************
     Descripció: Funció que genera texte capçelera per llistat dinamic Bordero_ces_rea.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cmodali     -> modalidad(1: Altas, 3: Anulaciones, 2: Renovaciones)
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021129 - 31/01/2012 - JMF
   FUNCTION f_00504_cab(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cmodali IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Bordero_ces_rea.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cmodali     -> modalidad(1: Altas, 3: Anulaciones, 2: Renovaciones)
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021129 - 31/01/2012 - JMF
   FUNCTION f_00504_det(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cmodali IN NUMBER DEFAULT 0,   -- 13/06/2014   EDA  Bug 0029038
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte capçelera per llistat dinamic Cuenta técnica
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cinttec     -> interes tecnico
                         - p_ctiprea     -> tipo reaseguro valor.106
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021129 - 31/01/2012 - JMF
   -- Bug 0022678 - 25/07/2012 - JMF: p_cprevio
   FUNCTION f_00505_cabtecnica(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cinttec IN NUMBER DEFAULT NULL,
      p_ctiprea IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Cuenta técnica
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cinttec     -> interes tecnico
                         - p_ctiprea     -> tipo reaseguro valor.106
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021129 - 31/01/2012 - JMF
   -- Bug 0022678 - 25/07/2012 - JMF: p_cprevio
   FUNCTION f_00505_dettecnica(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cinttec IN NUMBER DEFAULT NULL,
      p_ctiprea IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte capçelera per llistat dinamic Cuenta técnica
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cinttec     -> interes tecnico
                         - p_ctiprea     -> tipo reaseguro valor.106
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021129 - 31/01/2012 - JMF
   -- Bug 0022678 - 25/07/2012 - JMF: p_cprevio
   FUNCTION f_00505_cabdeposito(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cinttec IN NUMBER DEFAULT NULL,
      p_ctiprea IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Cuenta técnica
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cinttec     -> interes tecnico
                         - p_ctiprea     -> tipo reaseguro valor.106
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021129 - 31/01/2012 - JMF
   -- Bug 0022678 - 25/07/2012 - JMF: p_cprevio
   FUNCTION f_00505_detdeposito(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cinttec IN NUMBER DEFAULT NULL,
      p_ctiprea IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte capçelera per llistat dinamic Bordero_siniestro.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_ctipsin     -> Siempre pagado --> anulado Tipus siniestro(1=Reservado, 2=Pagado)
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021129 - 31/01/2012 - JMF
   FUNCTION f_00506_cab(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_ctipsin IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Bordero_siniestro.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_ctipsin     -> Siempre pagado --> anulado Tipus siniestro(1=Reservado, 2=Pagado)
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021129 - 31/01/2012 - JMF
   FUNCTION f_00506_det(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_ctipsin IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Reserva_sin_rea.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cidioma     -> Idioma
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021129 - 31/01/2012 - JMF
   FUNCTION f_00507_cab(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Reserva_sin_rea.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cidioma     -> Idioma
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021129 - 31/01/2012 - JMF
   FUNCTION f_00507_det(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Liquida_xl_rea.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
    return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021129 - 31/01/2012 - JMF
   FUNCTION f_00508_cab(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Liquida_xl_rea.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0021129 - 31/01/2012 - JMF
   FUNCTION f_00508_det(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Reserva_sin_rea_XL.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0022682 - 03/07/2012 - JMF
   FUNCTION f_00533_cab(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat dinamic Reserva_sin_rea_XL.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cidioma     -> Idioma
                         - p_cprevio     -> (0-Real, 1-Previo).
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0022682 - 03/07/2012 - JMF
   FUNCTION f_00533_det(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte capçalera per llistat primes devengades reaseguro Prima_dev_rea.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cidioma     -> Idioma
     return:             text capçalera
   ******************************************************************************************/
   -- Bug 26718-XVM-09/05/2013
   FUNCTION f_00580_cab(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte detall per llistat primes devengades reaseguro Prima_dev_rea.csv
     Paràmetres entrada: - p_compani     -> Companyia
                         - p_cempres     -> Empresa
                         - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                         - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                         - p_cidioma     -> Idioma
     return:             text detall
   ******************************************************************************************/
   -- Bug 26718-XVM-09/05/2013
   FUNCTION f_00580_det(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   -- BUG 25373 - FAL - 18/10/2013
   FUNCTION f_00505_cabreservassini(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cinttec IN NUMBER DEFAULT NULL,
      p_ctiprea IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_00505_detreservassini(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cinttec IN NUMBER DEFAULT NULL,
      p_ctiprea IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;
-- FI BUG 25373 - FAL - 18/10/2013


     --INICIO IAXIS 4900  I.R.D
   /******************************************************************************************
     Descripción: Función que genera la cabecera del reporte Reserva_sin_rea_facult.csv
      ******************************************************************************************/
  
   FUNCTION f_00546_cab(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripción: Función que genera el detalle del reporte Reserva_sin_rea_facult.csv
   ******************************************************************************************/
 
   FUNCTION f_00546_det(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;
      
  --FIN IAXIS 4900  I.R.D

END pac_informes_rea;

/

  GRANT EXECUTE ON "AXIS"."PAC_INFORMES_REA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_INFORMES_REA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_INFORMES_REA" TO "PROGRAMADORESCSI";
