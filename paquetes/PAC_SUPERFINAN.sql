--------------------------------------------------------
--  DDL for Package PAC_SUPERFINAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SUPERFINAN" IS
/******************************************************************************
   NOMBRE:     PAC_SUPERFINAN
   PROPÓSITO:  Package que contiene las funciones propias de la interfaz con SUPERFINANCIERA

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/02/2012   JRH/ET          1.0 Creación del package.
   2.0        07/02/2012   JRH/ET          2.0 0020107: LCOL898 - Interfaces - Regulatorio - Reporte Reservas Superfinanciera
******************************************************************************/
-- Bug 20107 - 07/02/2012 - JRH  - Gastos en fichero Superfinanciera (Inicio)
-- Fi Bug 20107 - 07/02/2012 - JRH
   /*************************************************************************
       FUNCTION ff_gastos_admin
         Calcula los gastos de adiminstración a una fecha
         param in psseguro  : Identificador de seguro.
         param in pnriesgo  : Identificador del riesgo.
         param in pcgarant    : Garantía
         param in pfecha    : fecha
         return             : t_gastos
    *************************************************************************/
   FUNCTION ff_gastos_admin(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfecha IN DATE)
      RETURN NUMBER;

   /*************************************************************************
       FUNCTION ff_gastos_admin_tot
         Calcula los gastos de adiminstración totales (más comisión) a una fecha
         param in psseguro  : Identificador de seguro.
         param in pnriesgo  : Identificador del riesgo.
         param in pcgarant    : Garantía
         param in pfecha    : fecha
         return             : t_gastos
    *************************************************************************/
   FUNCTION ff_gastos_admin_tot(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfecha IN DATE)
      RETURN NUMBER;

   /*************************************************************************
       FUNCTION ff_gastos_adquis
         Calcula los gastos de adqusición  a una fecha
         param in psseguro  : Identificador de seguro.
         param in pnriesgo  : Identificador del riesgo.
         param in pcgarant    : Garantía
         param in pfecha    : fecha
         return             : t_gastos
    *************************************************************************/
   FUNCTION ff_gastos_adquis(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfecha IN DATE)
      RETURN NUMBER;

/*************************************************************************
       FUNCTION  ff_codigo_compania
         Obtiene el codigo de compañia
         param in psseguro  : Identificador de seguro.
         return             : codigo de compañia
    *************************************************************************/
   FUNCTION ff_codigo_compania(psseguro IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
       FUNCTION  ff_titulo_prod
         Obtiene el titulo del producto
        param in psseguro  : Identificador de seguro.
        return             : titulo del producto
    *************************************************************************/
   FUNCTION ff_titulo_prod(psseguro IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
       FUNCTION  ff_estado_plan
         Obtiene el codigo para saber si se comercializa o no
         param in psseguro  : Identificador de seguro.
         return             : codigo 1 se comercializa, 2 no se comercializa
    *************************************************************************/
   FUNCTION ff_estado_plan(psseguro IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
       FUNCTION  ff_clase_seguro
         Obtiene el codigo  del tipo de seguro al que corresponde el palan
         param in psseguro  : Identificador de seguro.
         param in psproduc : Id de producto
         return             : codigos de clase de seguro
    *************************************************************************/
   FUNCTION ff_clase_seguro(psseguro IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
       FUNCTION   ff_tabla_mortalidad
         Obtiene el codigo  Primas y reservas del amparo
         param in psseguro  : Identificador de seguro.
         param in pcgarant : Id de producto
        return             : rimas y reservas del amparo
    *************************************************************************/
   FUNCTION ff_tabla_mortalidad(psseguro IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
       FUNCTION   ff_estado_poliza
         Obtiene el codigo de estado de la poliza
         param in psproduc  : Identificador de sproduc.
         return             : devuelve el estado de la poliza 1--1, Vigente ,2.. Prorrogada,3. Saldada
    *************************************************************************/
   FUNCTION ff_estado_poliza(psproduc IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
         FUNCTION    ff_fecha_pago_prima
           Obtiene  la fecha máxima de pago de primas
           param in psseguro  : Identificador de psseguro.
           parm in pfecha:  fecha
           return             : devuelve fecha max de pago de primas
      *************************************************************************/
   FUNCTION ff_fecha_pago_prima(psseguro IN NUMBER, pfefecto IN DATE)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION   ff_crecvalor_aseg
        Obtiene el codigo  Primas y reservas del amparo
        param in psseguro  : Identificador de seguro.
        param in ptipo :     Numerico si 1-->Tipo de Crecimiento  si 2-->Periodicidad
       return             : Corresponde al Tipo o Periodicidad  de crecimiento del valor asegurado del.amparo básico.
   *************************************************************************/
   FUNCTION ff_crecvalor_aseg(psseguro IN NUMBER, ptipo IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
         FUNCTION   ff_codigo_cobertura
           Obtiene el codigo cobertura saldado o prrogado
           param in psproduc  : Identificador de psproduc.
           return             : Codigo cobertura saldado o prrogado
      *************************************************************************/
   FUNCTION ff_codigo_cobertura(psproduc IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
         FUNCTION   ff_prima_unica
           Obtiene el Valor de la prima única del seguro prorrogado o seguro saldado,
            param in psseguro  : Identificador de seguro.
            param in pcgarant : id de garantia
             param in psproduc :id de poroducto
           return             : Valor de la prima única del seguro prorrogado o seguro saldado,
      *************************************************************************/
   FUNCTION ff_prima_unica(psseguro IN NUMBER, pcgarant IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER;

   FUNCTION ff_garantia_basica(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER;

   FUNCTION ff_gar_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER;

   -- devuelve 1 prorr, 2 saldado, 0 sino
   FUNCTION ff_saldado_prorrogado(p_pro IN NUMBER)
      RETURN NUMBER;

   -- Obtener respuesta a pregunt a de garantia en una fecha
   FUNCTION ff_pregungaranseg(
      p_seg IN NUMBER,
      p_rie IN NUMBER,
      p_fec IN DATE,
      p_gar IN NUMBER,
      p_pre IN NUMBER)
      RETURN NUMBER;

   -- Fecha Crecimiento de una garantia
   FUNCTION ff_fecha_crecimiento(
      p_seg IN NUMBER,
      p_rie IN NUMBER,
      p_fec IN DATE,
      p_gar IN NUMBER,
      pmodo IN NUMBER DEFAULT NULL)
      RETURN DATE;

   -- 110 - Tipo de Crecimiento (Cobertura Adicional)
   FUNCTION ff_tipocrecim_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER;

   -- 111 - Porcentaje Crecimiento (Cobertura Adicional)
   FUNCTION ff_porcrecim_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER;

   -- 112 - PERIODO_CRECIMIENTO adicional
   FUNCTION ff_periodocrecim_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN DATE;

   -- 113 - Crecimiento Hasta (Cobertura Adicional)
   FUNCTION ff_crecimhasta_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN DATE;

   -- 116 - Fecha Inicio Vigencia (Cobertura Adicional)
   FUNCTION ff_fecinivig_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN DATE;

   -- 117 - Cobertura Hasta (Cobertura Adicional)
   FUNCTION ff_coberturahasta_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER;

   -- 118 - Edad Inicial (Cobertura Adicional)
   FUNCTION ff_edadinicial_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER;

   -- 125 - Valor Asegurado lnicial
   FUNCTION ff_valase_inicial_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER;

   -- 126-Val.Aseg.Alcanzado C.Adicional
   FUNCTION ff_valase_alcanzado_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER;

   -- 127-Prima Riesgo C.Adicional
   FUNCTION ff_prima_riesgo_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER;

   -- 128-Reserva Cob.Adicional
   FUNCTION ff_reserva_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER;

   -- 129-Reserva Demas.Adicionales
   FUNCTION ff_reserva_demasadicionales(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER;

   -- 132-Reserva Total
   FUNCTION ff_reserva_total(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER;

   -- 133-Reserva Total Pesos
   FUNCTION ff_reserva_totalpesos(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER;

   FUNCTION ff_altura_mes(p_fecha1 IN DATE, p_fecha2 IN DATE)
      RETURN NUMBER;

   FUNCTION ff_buscasaldo(p_seg IN NUMBER, p_fec IN DATE)
      RETURN NUMBER;

   FUNCTION ff_altura(p_seg IN NUMBER, p_fecha1 IN DATE, p_fecha2 IN DATE)
      RETURN NUMBER;

   FUNCTION ff_prima_riesgo_basico(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER;

   -- Bug 28713/157181 - 21/11/2013 - AMC
   FUNCTION ff_edad_ingaseg_principal(p_seg IN NUMBER, p_fnacimi IN DATE, p_fec IN DATE)
      RETURN NUMBER;

   --Bug 28713/157181 - 21/11/2013 - AMC
   FUNCTION f_get_fexpedicion(p_seg IN NUMBER)
      RETURN VARCHAR2;
END pac_superfinan;

/

  GRANT EXECUTE ON "AXIS"."PAC_SUPERFINAN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SUPERFINAN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SUPERFINAN" TO "PROGRAMADORESCSI";
