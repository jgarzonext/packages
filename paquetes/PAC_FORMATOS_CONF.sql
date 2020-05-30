--------------------------------------------------------
--  DDL for Package PAC_FORMATOS_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_FORMATOS_CONF" AS
/******************************************************************************
   NOMBRE:      pac_formatos_conf
   PROP¿SITO:   Funciones para obtener la data de cada formato para Confianza

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        06/09/2013   RCM              1. Creaci¿n del package.
******************************************************************************/
   TYPE t_array_number IS VARRAY(10) OF INTEGER;

/*************************************************************************
    FUNCTION f_get_primas_por_recaudar
       Obtiene los registro de las primas por recaudar para la generacion
       del formato 232
       param in p_empres: empresa
       param in p_tgestor: codigo de gestor
       param in p_tformato: codigo de formato
       param in p_anio : objeto fichero
       param in p_mes: archivo de carga
       param in p_dia : objeto fichero
       param in p_separador: separador de la tabla fic_gestores
    *************************************************************************/
   /*FUNCTION f_get_primas_por_recaudar(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;*/

   /*************************************************************************
    FUNCTION f_get_prov_primas_por_recaudar
       Obtiene los registro de la provision de  primas por recaudar para
       la generacion del formato 233
       param in p_empres: empresa
       param in p_tgestor: codigo de gestor
       param in p_tformato: codigo de formato
       param in p_anio : objeto fichero
       param in p_mes: archivo de carga
       param in p_dia : objeto fichero
       param in p_separador: separador de la tabla fic_gestores
    *************************************************************************/
   /*FUNCTION f_get_prov_primas_por_recaudar(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;*/

   /*************************************************************************
    FUNCTION f_get_nomina_reaseguradores
       Obtiene los registro de la nomina de reaseguradores - contratos de reaseguros
       proporcionales y no proporcionales para la generacion del formato 485.
       param in p_empres: empresa
       param in p_tgestor: codigo de gestor
       param in p_tformato: codigo de formato
       param in p_anio : objeto fichero
       param in p_mes: archivo de carga
       param in p_dia : objeto fichero
       param in p_separador: separador de la tabla fic_gestores
    *************************************************************************/
    FUNCTION f_get_nomina_reaseguradores(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;

   /*************************************************************************
    FUNCTION f_get_contratos_noproporcional
       Obtiene los registro de los contratos de reaseguros de tipo no proporcionales
       para la generacion del formato 484.
       param in p_empres: empresa
       param in p_tgestor: codigo de gestor
       param in p_tformato: codigo de formato
       param in p_anio : objeto fichero
       param in p_mes: archivo de carga
       param in p_dia : objeto fichero
       param in p_separador: separador de la tabla fic_gestores
    *************************************************************************/
   fUNCTION f_get_contratos_noproporcional(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;

   /*************************************************************************
    FUNCTION f_get_contratos_proporcionales
       Obtiene los registro de los contratos de reaseguros de tipo proporcionales
       para la generacion del formato 483.
       param in p_empres: empresa
       param in p_tgestor: codigo de gestor
       param in p_tformato: codigo de formato
       param in p_anio : objeto fichero
       param in p_mes: archivo de carga
       param in p_dia : objeto fichero
       param in p_separador: separador de la tabla fic_gestores
    *************************************************************************/
   FUNCTION f_get_contratos_proporcionales(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;

   /*************************************************************************
    FUNCTION f_get_primas_aceptadas
       Obtiene los registro de las primas aceptadas en reaseguros
       para la generacion del formato 486
       param in p_empres: empresa
       param in p_tgestor: codigo de gestor
       param in p_tformato: codigo de formato
       param in p_anio : objeto fichero
       param in p_mes: archivo de carga
       param in p_dia : objeto fichero
       param in p_separador: separador de la tabla fic_gestores
    *************************************************************************/
   /*FUNCTION f_get_primas_aceptadas(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;*/

   /*************************************************************************
    FUNCTION f_get_primas_cedidas
       Obtiene los registro de las primas cedidas en reaseguros
       para la generacion del formato 487
       param in p_empres: empresa
       param in p_tgestor: codigo de gestor
       param in p_tformato: codigo de formato
       param in p_anio : objeto fichero
       param in p_mes: archivo de carga
       param in p_dia : objeto fichero
       param in p_separador: separador de la tabla fic_gestores
    *************************************************************************/
   FUNCTION f_get_primas_cedidas(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;

   /*************************************************************************
    FUNCTION f_get_primas_exterior_no_lista
       Obtiene los registro de las primas cedidas a reaseguradores, aceptadas
       de compa¿¿as cedentes del exterior y contratos suscritos con reaseguradores
       y cedentes que no se encuentren incluidos en el listado de reaseguradores
       del exterior, para la generacion del formato 488.
       param in p_empres: empresa
       param in p_tgestor: codigo de gestor
       param in p_tformato: codigo de formato
       param in p_anio : objeto fichero
       param in p_mes: archivo de carga
       param in p_dia : objeto fichero
       param in p_separador: separador de la tabla fic_gestores
    *************************************************************************/
  /* FUNCTION f_get_primas_exterior_no_lista(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;*/

          /*************************************************************************
     FUNCTION f_get_garant_u_cumplimiento
        Obtiene los registro de la nomina de reaseguradores - GARANT¿AS ¿NICAS DE CUMPLIMIENTO DE
		ENTIDADES ESTATALES del formato 489.
        param in p_empres: empresa
        param in p_tgestor: codigo de gestor
        param in p_tformato: codigo de formato
        param in p_anio : objeto fichero
        param in p_mes: archivo de carga
        param in p_dia : objeto fichero
        param in p_separador: separador de la tabla fic_gestores
     *************************************************************************/

   FUNCTION f_get_garant_u_cumplimiento(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;

        /*************************************************************************
   FUNCTION f_get_saldos_siniestros
      Obtiene los registro de los Saldos cuenta corriente y reservas para siniestros
      para la generacion del formato 490.
      param in p_empres: empresa
      param in p_tgestor: codigo de gestor
      param in p_tformato: codigo de formato
      param in p_anio : objeto fichero
      param in p_mes: archivo de carga
      param in p_dia : objeto fichero
      param in p_separador: separador de la tabla fic_gestores
   *************************************************************************/
   FUNCTION f_get_saldos_siniestros(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;

     /*************************************************************************
   FUNCTION f_get_reserva_matematica
      Obtiene los registro de las subcuentas de reservas
      para la generacion del formato 235.
      param in p_empres: empresa
      param in p_tgestor: codigo de gestor
      param in p_tformato: codigo de formato
      param in p_anio : a¿o generacion fichero
      param in p_mes: mes generacion fichero
      param in p_dia : dia generacion fichero
      param in p_separador: separador de la tabla fic_gestores
   *************************************************************************/
  /* FUNCTION f_get_reserva_matematica(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;*/

      /*************************************************************************
   FUNCTION f_get_reserva_matematica_pol
      Obtiene los registro de las subcuentas de reservas
      para la generacion del formato 394.
      param in p_empres: empresa
      param in p_tgestor: codigo de gestor
      param in p_tformato: codigo de formato
      param in p_anio : a¿o generacion fichero
      param in p_mes: mes generacion fichero
      param in p_dia : dia generacion fichero
      param in p_separador: separador de la tabla fic_gestores
   *************************************************************************/
   /*UNCTION f_get_reserva_matematica_pol(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;*/

/*************************************************************************
   FUNCTION f_get_reserva_matematica_pol_f
      Obtiene los registro de las subcuentas de reservas
      para la generacion del formato 394 para fasecolda.
      param in p_empres: empresa
      param in p_tgestor: codigo de gestor
      param in p_tformato: codigo de formato
      param in p_anio : a¿o generacion fichero
      param in p_mes: mes generacion fichero
      param in p_dia : dia generacion fichero
      param in p_separador: separador de la tabla fic_gestores
   *************************************************************************/
   /*FUNCTION f_get_reserva_matematica_pol_f(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;*/

     /*************************************************************************
     FUNCTION f_get_reserva_riegos_curso
      Obtiene los registro de las reservas tecnicas de riesgos en curso
      del formato 235
      param in p_empres: empresa
      param in p_tgestor: codigo de gestor
      param in p_tformato: codigo de formato
      param in p_anio : objeto fichero
      param in p_mes: archivo de carga
      param in p_dia : objeto fichero
      param in p_separador: separador de la tabla fic_gestores
   *************************************************************************/
   /*FUNCTION f_get_reserva_riegos_curso(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros;*/

      /*************************************************************************
     FUNCTION f_obtener_tasa_crecimiento
      Obtiene la tasa de crecimiento de la reserva por seguro para positiva formato 394
      param in psseguro: numero de seguro
      param in pnriesgo: numero de riesgo
      param in psproduc: producto
      param in pffin : fecha de efecto
      param in pcrevali: codigo revalorizacion
      param in pprevali : porcentaje revalorizacion
      param in psesion: variable de sesion
   *************************************************************************/
  /* FUNCTION f_obtener_tasa_crecimiento(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psproduc IN NUMBER,
      pffin IN DATE,
      pcrevali IN NUMBER,
      pprevali IN NUMBER,
      psesion IN NUMBER DEFAULT -1)
      RETURN NUMBER;*/

     -- BUG 0026180 - 28/08/2014 - JMF
      /*************************************************************************
     FUNCTION f_obtener_interes_tecnico
      Obtiene el inter¿s t¿cnico de la reserva por seguro para positiva formato 394
      param in psseguro: numero de seguro
      param in psproduc: producto
      param in pffin : fecha de efecto
   *************************************************************************/
   /*FUNCTION f_obtener_interes_tecnico(psseguro IN NUMBER, psproduc IN NUMBER, pffin IN DATE)
      RETURN VARCHAR2;*/

/* *************************************************************************/
   /*FUNCTION f_obtener_tipo_crecimiento(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pnriesgo NUMBER,
      pffin IN DATE)
      RETURN VARCHAR2;*/



END pac_formatos_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_FORMATOS_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FORMATOS_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FORMATOS_CONF" TO "PROGRAMADORESCSI";
