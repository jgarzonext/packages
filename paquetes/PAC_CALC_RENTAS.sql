--------------------------------------------------------
--  DDL for Package PAC_CALC_RENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CALC_RENTAS" AUTHID CURRENT_USER IS
/******************************************************************************
      NOMBRE:     PAC_CALC_RENTAS
      PROPÓSITO:  Funciones contratación rentas

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX                1. Creación del package.
      1.1        30/01/2009   JRH                2. Bug-9173 Rentas Enea

   ******************************************************************************/
/******************************************************************************
  Package público para calculos de pólizas de ahorro

******************************************************************************/
   FUNCTION f_get_capitales_rentas(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      fecefecto IN DATE,
      tramolrc IN NUMBER,
      priesgo IN NUMBER DEFAULT 1,
      pnmovimi IN NUMBER DEFAULT 1,
      rentabruta OUT NUMBER,
      rentamin OUT NUMBER,
      capfall OUT NUMBER,
      intgarant OUT NUMBER,
      tablas VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

   FUNCTION f_get_duracion_renova(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psseguro IN NUMBER,
      pndurper OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_datos_poliza_renova(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psseguro IN NUMBER,
      psperson1 OUT NUMBER,
      psperson2 OUT NUMBER,
      picapgar OUT NUMBER,
      pndurper OUT NUMBER,
      pcidioma OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_forpagprest_poliza(
      ptablas IN VARCHAR2 DEFAULT 'SEG',
      psseguro IN NUMBER,
      pcidioma_user IN NUMBER,
      ptfprest OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION ff_get_aportacion_per(
      ptablas IN VARCHAR2 DEFAULT 'SEG',
      psseguro IN NUMBER,
      pfecha IN DATE DEFAULT f_sysdate)
      RETURN NUMBER;

   FUNCTION ff_get_formapagoren(ptablas IN VARCHAR2, psseguro IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
   Obtiene datos de las rentas para actualizar SEGUROS_REN después de la tarificación
   Param IN    psseguro : seguro
   Param IN psproduc : Producto
   Param IN    pfefecto : fecha efec
   Param IN    fecvto : Fecha vencimiento
   Param IN    nduraci : duración
   Param OUT  fecultpago: Fecha ultimo pago renta
   Param OUT fecprimpago: Fecha primer pago renta
   Param OUT   importebruto: Importe renta
   Param OUT fecfinrenta : Fecha fin de la renta
   Param OUT fechaproxpago: fecha pròximo pago
   Param OUT fechainteres : Fecha de voigencia interés
   Param OUT  estadopago: Estado en que se generan los pagos
   Param OUT estadopagos : Estado 2 en que se generan los pagos
   Param OUT  durtramo : Duración tramo interes
   Param OUT  capinirent: Capital inicial renta.
   Param OUT tipoint: Interés.
   Param OUT doscab : % Reversión.
   Param OUT capfallec : % Sobre capital de fallecimiento.
   Param OUT reserv : Importe incial de reserva.
   Param OUT fecrevi:  Fecha de Revisión
   Param IN   tablas : Tablas
   return número de error 0 si ha ido bien
****************************************************************************************/
   FUNCTION f_obtener_datos_rentas_ini(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      fecefecto IN DATE,
      fecvto IN DATE,
      nduraci IN NUMBER,
      fecultpago OUT DATE,
      fecprimpago OUT DATE,
      importebruto OUT estseguros_ren.ibruren%TYPE,
      fecfinrenta OUT DATE,
      fechaproxpago OUT DATE,
      fechainteres OUT DATE,
      estadopago OUT estseguros_ren.cestmre%TYPE,
      estadopagos OUT estseguros_ren.cblopag%TYPE,
      durtramo OUT NUMBER,   -- BUG 0009173 - 03/2009 - JRH  - 0009173: CRE - Rentas Enea. NUMBER
      capinirent OUT estseguros_ren.icapren%TYPE,
      tipoint OUT estseguros_ren.ptipoint%TYPE,
      doscab OUT estseguros_ren.pdoscab%TYPE,   --JRH IMP
      capfallec OUT estseguros_ren.pcapfall%TYPE,
      reserv OUT estseguros_ren.ireserva%TYPE,
      fecrevi OUT DATE,
      tablas IN VARCHAR2 DEFAULT 'EST',
      pnmovimi in number default 1)
      RETURN NUMBER;

   FUNCTION f_get_datos_revi(
      psseguro IN NUMBER,
      pcapini OUT NUMBER,
      pinter OUT NUMBER,
      pctreserv OUT NUMBER,
      pdurper OUT NUMBER,
      tablas VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;
END pac_calc_rentas;

/

  GRANT EXECUTE ON "AXIS"."PAC_CALC_RENTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_RENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_RENTAS" TO "PROGRAMADORESCSI";
