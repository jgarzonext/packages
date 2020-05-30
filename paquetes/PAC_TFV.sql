--------------------------------------------------------
--  DDL for Package PAC_TFV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_TFV" AUTHID CURRENT_USER IS
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
   FUNCTION f_insert_estseguros(
      psseguro IN NUMBER,
      pssegpol IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pnsuplem IN NUMBER,
      pcempres IN NUMBER,
      pcagrpro IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcobjase IN NUMBER,
      pctarman IN NUMBER,
      pfefecto IN DATE,
      pcrecman IN NUMBER,
      pcsituac IN NUMBER,
      pnanuali IN NUMBER,
      pcreafac IN NUMBER,
      pctiprea IN NUMBER,
      pcasegur IN NUMBER,
      pcagente IN NUMBER,
      pctipreb IN NUMBER,
      pcactivi IN NUMBER,
      psproduc IN NUMBER,
      pnrenova IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_insert_esttomadores(
      pnordtom IN NUMBER,
      psperson IN NUMBER,
      pcdomici IN NUMBER,
      psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_insert_estassegurats(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pnorden IN NUMBER,
      pcdomici IN NUMBER,
      pffecini IN DATE)
      RETURN NUMBER;

   FUNCTION f_update_estseguros(
      pcasegur IN NUMBER,
      pcactivi IN NUMBER,
      pcidioma IN NUMBER,
      pfefecto IN DATE,
      pcagente IN NUMBER,
      pctipcom IN NUMBER,
      pcforpag IN NUMBER,
      pnfracci IN NUMBER,
      pcduraci IN NUMBER,
      pcreccob IN NUMBER,
      pctipreb IN NUMBER,
      pcreteni IN NUMBER,
      pcbancar IN VARCHAR2,
      pccobban IN NUMBER,
      pccompani IN NUMBER,
      pcagencorr IN VARCHAR2,
      pnpolcoa IN VARCHAR2,
      pnrenova IN NUMBER,
      pcrecfra IN NUMBER,
      pcrevali IN NUMBER,
      psseguro IN NUMBER,
      pctipban IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_insert_estriesgos(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovima IN NUMBER,
      pfefecto IN DATE,
      ptnatrie IN VARCHAR2,
      psperson IN NUMBER,
      pcdomici IN NUMBER,
      pspermin IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   -- Bug 12668 - 17/02/2010 - AMC - Se anaden los campos para la normalización de la dirección
   FUNCTION f_insert_estsitriesgo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ptdomici IN VARCHAR2,
      pcprovin IN NUMBER,
      pcpostal IN codpostal.cpostal%TYPE,   --3606 jdomingo 29/11/2007  canvi format codi postal
      pcpoblac IN NUMBER,
      pcsiglas IN NUMBER,
      ptnomvia IN VARCHAR2,
      pnnumvia IN NUMBER,
      ptcomple IN VARCHAR2,
      pcciudad IN NUMBER,
      pfgisx IN FLOAT,
      pfgisy IN FLOAT,
      pfgisz IN FLOAT,
      pcvalida IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_insert_estgaranseg(
      pcgarant IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psseguro IN NUMBER,
      pfiniefe IN DATE,
      pnorden IN NUMBER,
      pcrevali IN NUMBER,
      picapital IN NUMBER,
      piprianu IN NUMBER,
      pipritar IN NUMBER,
      pftarifa IN DATE,
      pitarifa IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_insert_estclaubenseg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psclaben IN NUMBER,
      pfiniclau IN DATE)
      RETURN NUMBER;

   FUNCTION f_insert_estclaususeg(
      psseguro IN NUMBER,
      psclagen IN NUMBER,
      pfiniclau IN DATE,
      pffinclau IN DATE,
      pnmovimi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_insert_estclausuesp(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcclaesp IN NUMBER,
      pnordcla IN NUMBER,
      pfiniclau IN DATE,
      psclagen IN NUMBER,
      ptclaesp IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_insert_estclauparesp(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psclagen IN NUMBER,
      pnparame IN NUMBER,
      pcclaesp IN NUMBER,
      pnordcla IN NUMBER,
      pctippar IN NUMBER,
      ptvalor IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_pre_calcular_tarifa(psseguro IN NUMBER, pnriesgo IN NUMBER, psproces OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_traspaso_tablas(
      psseguro IN NUMBER,
      psproces IN NUMBER,
      psproduc IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      piprianu IN NUMBER DEFAULT NULL,
      pprecarg IN NUMBER DEFAULT NULL,
      pirecarg IN NUMBER DEFAULT NULL,
      pipritar IN NUMBER DEFAULT NULL,
      ptasa IN NUMBER DEFAULT NULL,
      pirevali IN NUMBER DEFAULT NULL,
      pprevali IN NUMBER DEFAULT NULL,
      pidtocom IN NUMBER DEFAULT NULL,
      pdtocom IN NUMBER DEFAULT NULL,
      pifranqu IN NUMBER DEFAULT NULL,
      pctipfra IN NUMBER DEFAULT NULL,
      pcformul IN NUMBER DEFAULT NULL,
      piextrap IN NUMBER DEFAULT NULL,
      picapital IN NUMBER DEFAULT NULL,
      ppctarifa IN NUMBER DEFAULT NULL,
      pcrevali IN NUMBER DEFAULT NULL,
      pnorden IN NUMBER DEFAULT NULL,
      pctarifa IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_tarifar(
      psseguro IN NUMBER,
      psproces IN NUMBER,
      psproduc IN NUMBER,
      pcclapri IN NUMBER,
      pnriesgo IN NUMBER,
      piprimin OUT NUMBER,
      piprianu OUT NUMBER,
      pmensa OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_traspaso_tmp_a_estgaranseg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      piprianu IN NUMBER DEFAULT NULL,
      pprecarg IN NUMBER DEFAULT NULL,
      pirecarg IN NUMBER DEFAULT NULL,
      pipritar IN NUMBER DEFAULT NULL,
      ptasa IN NUMBER DEFAULT NULL,
      pirevali IN NUMBER DEFAULT NULL,
      pprevali IN NUMBER DEFAULT NULL,
      pidtocom IN NUMBER DEFAULT NULL,
      pdtocom IN NUMBER DEFAULT NULL,
      pifranqu IN NUMBER DEFAULT NULL,
      pctipfra IN NUMBER DEFAULT NULL,
      pcformul IN NUMBER DEFAULT NULL,
      piextrap IN NUMBER DEFAULT NULL,
      picapital IN NUMBER DEFAULT NULL,
      ppctarifa IN NUMBER DEFAULT NULL,
      pcrevali IN NUMBER DEFAULT NULL,
      pnorden IN NUMBER DEFAULT NULL,
      pctarifa IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_aportacion(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pimovimi IN NUMBER,
      pfvalor IN DATE,
      pmovimi OUT NUMBER)
      RETURN NUMBER;

-- Control saldos de prestaciones
   FUNCTION f_saldo_presta_posterior(psseguro IN NUMBER, fecha_hasta IN DATE, tipo IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_saldo_presta_actual(psseguro IN NUMBER, fecha_hasta IN DATE, tipo IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_calcula_importe_anual(psseguro IN NUMBER, pano IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_crea_parte_prestaciones(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pfcontin IN DATE,
      pctipren IN NUMBER,
      pctipjub IN NUMBER,
      pnivel IN NUMBER,
      ppartis IN NUMBER,
      ppartisret IN NUMBER,
      ptippresta IN NUMBER DEFAULT NULL,
      pimpcap IN NUMBER DEFAULT NULL,
      pfcap IN DATE DEFAULT NULL,
      pimprenta IN NUMBER DEFAULT NULL,
      pfrenta IN DATE DEFAULT NULL,
      pnif IN VARCHAR2 DEFAULT NULL,
      pnombre IN VARCHAR2 DEFAULT NULL,
      ptelf IN VARCHAR2 DEFAULT NULL,
      pparte OUT NUMBER)
      RETURN NUMBER;

-- Traspasos de Salida Internos
   FUNCTION f_crea_traspaso_salida_interno(
      psseguro_desde IN NUMBER,
      psseguro_hasta IN NUMBER,
      pimporte IN NUMBER,
      pctiptras IN NUMBER,
      pfsolici IN DATE,
      pmemo IN VARCHAR2,
      pstras OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_crea_traspas_entrada_externo(
      psseguro_destino IN NUMBER,
      pccodpla_origen IN NUMBER DEFAULT NULL,
      ptnompla_externo IN VARCHAR DEFAULT NULL,
      pimporte IN NUMBER DEFAULT NULL,
      pctiptras IN NUMBER,
      pfsolici IN DATE,
      pmemo IN VARCHAR2,
      pstras OUT NUMBER)
      RETURN NUMBER;

-- Funcion que realiza un Rollback o un Commit para JAVA
   FUNCTION f_rollback
      RETURN NUMBER;

   FUNCTION f_commit
      RETURN NUMBER;

   FUNCTION f_historico_seguros(psseguro IN NUMBER, pmovimi OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_suplemento(
      psseguro IN NUMBER,
      pmotivo IN NUMBER,
      pfvalor IN DATE,
      pnummovimi OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_crea_domicilio(
      psperson IN NUMBER,
      pctipdir IN NUMBER,
      pcpostal IN codpostal.cpostal%TYPE,   --3606 jdomingo 29/11/2007  canvi format codi postal
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      pcsiglas IN NUMBER,
      ptnomvia IN VARCHAR2,
      pnnumvia IN NUMBER,
      ptcomple IN VARCHAR2,
      pcidioma IN NUMBER,
      pcdomici OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_aportaciones_anuales_pp(
      psseguro IN NUMBER,
      pano IN NUMBER,
      phasta IN DATE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_saldo_3112_pp(psseguro IN NUMBER, pano IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_sup_fpago(
      psseguro IN NUMBER,
      pfsuplem IN DATE,
      pcforpag_nou IN NUMBER,
      pcforpag_ant IN NUMBER,
      pgrabar IN NUMBER,
      pfcarpro OUT DATE,
      pfcaranu OUT DATE)
      RETURN NUMBER;

   FUNCTION f_sup_ccc(psseguro IN NUMBER, pccc IN VARCHAR2, pctipban IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_sup_ccc_prestacion(
      psprestaplan IN NUMBER,
      psperson IN NUMBER,
      pccc IN VARCHAR2,
      pctipban IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_sup_importe_prestacion(
      psprestaplan IN NUMBER,
      psperson IN NUMBER,
      pctipcap IN NUMBER,
      pimporte IN NUMBER)
      RETURN NUMBER;

   FUNCTION generar_impresion_libreta(
      psseguro IN NUMBER,
      pfreimp IN DATE DEFAULT NULL,
      psesion OUT NUMBER)
      RETURN NUMBER;

   FUNCTION guardar_impresion_libreta(
      psseguro IN NUMBER,
      psesion IN NUMBER,
      pcodlin IN NUMBER,
      ppagina IN NUMBER,
      plinea IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_control_cumul(psseguro IN NUMBER, pnriesgo IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;

   FUNCTION f_cumulos_pp(psseguro IN NUMBER, ptexto OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_idioma_seguro(psseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_ultima_fval(psseguro IN NUMBER)
      RETURN DATE;

   FUNCTION f_perfil_usuario(
      puser IN VARCHAR2,
      pcdelega IN NUMBER,
      pctipemp IN NUMBER,
      pcategoria IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_aportaciones_pp(psseguro IN NUMBER, pano IN NUMBER)
      RETURN NUMBER;
END pac_tfv;

/

  GRANT EXECUTE ON "AXIS"."PAC_TFV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_TFV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_TFV" TO "PROGRAMADORESCSI";
