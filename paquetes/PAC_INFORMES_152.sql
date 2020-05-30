--------------------------------------------------------
--  DDL for Package PAC_INFORMES_152
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_INFORMES_152" IS
/******************************************************************************
   NOMBRE:      PAC_INFORMES_COLM
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/03/2013   NSS              1. 0025887: RSA003 - Implementar provisión IBNR
   2.0        06/05/2013   JMF              0026721: RSA - Libros oficiales
   3.0        13/05/2013   JMF              0026800 RSA701-Informes reaseguro
   4.0        18/03/2013   JMF              bug 26430/146998 - 18/06/2013 - JMF
   5.0        31/03/2014   FAL              0035387: Libros legales no funcionan
   6.         17/06/2015   DCG              0036392: agregar un campo de factura a los recibos que agrupados y agrupador en colectivos (bug hermano interno)
   ******************************************************************************/

   -- Bug 0026430 - 11/03/2014 - JMF
   FUNCTION f_busca_plan(
      pseg IN NUMBER,
      prie IN NUMBER DEFAULT NULL,
      pmov IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   -- bug 26430 - 31/10/2013 - JMF
   -- Cedida toda lo cobrado: viene de f_get_linea_prima_cedida sin ramo solo cobro
   FUNCTION f_get_linea_prima_cedida_tc(pdesde IN DATE, phasta IN DATE, pcidioma IN NUMBER)
      RETURN NUMBER;

   -- bug 26430 - 31/10/2013 - JMF
   -- Cedida toda la emision: viene de f_get_linea_prima_cedida sin ramo solo emision
   FUNCTION f_get_linea_prima_cedida_te(pdesde IN DATE, phasta IN DATE, pcidioma IN NUMBER)
      RETURN NUMBER;

   -- bug 0026881 29-10-2013 JMF
   -- Para listado DWH 3.2.5 Affinity fin vigencia
   -- Calcular fecha final de un seguro, a partir de un rango de fechas.
   FUNCTION f_aff_vigenciafin(par_seg IN NUMBER, par_fecini IN DATE, par_fecfin IN DATE)
      RETURN DATE;

   -- bug 0026881 29-10-2013 JMF
   -- Para listado DWH 3.2.5 Affinity fin vigencia
   -- Calcular fecha inicial de un seguro, a partir de la fecha final calculada
   FUNCTION f_aff_vigenciaini(par_seg IN NUMBER, par_fecfin IN DATE)
      RETURN DATE;

   FUNCTION f_icesioncp(par_seg IN NUMBER, par_rie IN NUMBER, par_gar IN NUMBER)
      RETURN NUMBER;

   --
   -- Primas por pagar a Reaseguradores Proyectada
   FUNCTION f_proyectada(
      par_sproduc IN NUMBER,
      par_cactivi IN NUMBER,
      par_cgarant IN NUMBER,
      par_fecini IN DATE,
      par_fecfin IN DATE)
      RETURN NUMBER;

   /*
   f_caliva : para quitar el iva, igual que PAC_PROVTEC_SAM.f_commit_calcul_rrcsam
   */
   FUNCTION f_caliva(p_rec IN NUMBER, p_gar IN NUMBER, p_rie IN NUMBER)
      RETURN NUMBER;

   /************************************************************************************
       FF_BUSCAPREGUNSEG: Busca respuesta de una pregunta de póliza
       Primero por fecha, sino por movimiento, sino busca el último mov.
   *************************************************************************************/
   FUNCTION ff_buscapregunseg(
      p_seg IN NUMBER,
      p_rie IN NUMBER,
      p_pre IN NUMBER,
      p_mov IN NUMBER,
      p_fec IN DATE DEFAULT NULL)
      RETURN VARCHAR2;

   -- Calcular fecha provision
   FUNCTION f_fecprov(
      p_pro IN NUMBER,
      p_seg IN NUMBER,
      p_mov IN NUMBER,
      p_efe IN DATE,
      p_act IN DATE)
      RETURN DATE;

   -- Calcular descripcion estado recibo a mostrar en listados
   FUNCTION f_desrec(
      p_idi IN NUMBER,
      p_cestant IN NUMBER,
      p_cestact IN NUMBER,
      p_ctiprec IN NUMBER,
      p_parcial IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

   -- Calcular el total del recibo parcial, descontando el importe de iva
   FUNCTION f_parcialsiniva(p_rec IN NUMBER)
      RETURN NUMBER;

   /******************************************************************************************
     Descripció: Funció busca rut de una persona
     return:     codigo rut
     -- bug 0025887 29-05-2013 JMF
   ******************************************************************************************/
   FUNCTION f_rut(p_sperson IN NUMBER)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció busca browker correspondiente
     return:     codigo browker
     -- bug 26430/145282 - 28/05/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_busca_browker(
      p_ccompani IN NUMBER,
      p_nversio IN NUMBER,
      p_scontra IN NUMBER,
      p_ctramo IN NUMBER)
      RETURN NUMBER;

   /******************************************************************************************
     Descripció: Busca porcentaje comision
     return:     porcentaje
     -- bug 26721/143522 - 06/05/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_porcomis(
      p_sseguro IN NUMBER,
      p_sproduc IN NUMBER,
      p_act IN NUMBER,
      p_gar IN NUMBER,
      p_ccomisi_indirect IN NUMBER,
      p_cconcepto IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /******************************************************************************************
     Descripció: Busca porcentaje comision total, sin tener en cuenta garantias
     return:     porcentaje
   ******************************************************************************************/
   FUNCTION f_porcomis_total(
      p_sseguro IN NUMBER,
      p_sproduc IN NUMBER,
      p_act IN NUMBER,
      p_ccomisi IN NUMBER,
      p_cmodcom IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_provsinpag(
      p_seg IN NUMBER,
      p_fec IN DATE,
      p_tip IN NUMBER,
      p_spr IN NUMBER DEFAULT NULL,
      p_sin IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   -- bug 0026430 - 01/04/2014 - JMF
   FUNCTION f_impuestopag(p_sidepag IN NUMBER, p_nmovpag IN NUMBER)
      RETURN NUMBER;

   -- bug 26430/146998 - 18/06/2013 - JMF
   -- bug 0026430 - 01/04/2014 - JMF
   FUNCTION f_retencionpag(p_sidepag IN NUMBER, p_nmovpag IN NUMBER)
      RETURN NUMBER;

   -- bug 0026430 - 01/04/2014 - JMF
   FUNCTION f_montoapagar(p_sidepag IN NUMBER, p_nmovpag IN NUMBER)
      RETURN NUMBER;

   -- bug 0026430 - 01/04/2014 - JMF
   FUNCTION f_retencionmonto(p_sidepag IN NUMBER, p_nmovpag IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_cesionsobremontototal(p_sidepag IN NUMBER, p_seg IN NUMBER)
      RETURN NUMBER;

   /******************************************************************************************
     Descripció: F_888_cab Cabecera del map 720
     return:     texto cabecera
   ******************************************************************************************/
   FUNCTION f_888_cab(p_idioma IN NUMBER, fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_888_det(p_idioma IN NUMBER, fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: f_722_cab Cabecera del map 722
     return:     texto cabecera
   ******************************************************************************************/
   FUNCTION f_722_cab
      RETURN VARCHAR2;

   FUNCTION f_722_det(fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_get_rut_interme(pcagente IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_get_cober_afect(pcgarant IN NUMBER, pidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_get_contador_casos
      RETURN VARCHAR2;

   FUNCTION f_get_linea_negocio(psseguro IN NUMBER, pidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /* f_get_desramokeira = descripcion para listados */
   FUNCTION f_get_desramokeira(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pidioma IN NUMBER)
      RETURN VARCHAR2;

   /* f_get_dessubramokeira = descripcion para listados */
   FUNCTION f_get_dessubramokeira(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pidioma IN NUMBER)
      RETURN VARCHAR2;

   /* f_get_ramo_keira = descripcion para contabilidad */
   FUNCTION f_get_ramo_keira(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pidioma IN NUMBER)
      RETURN VARCHAR2;

   /* f_get_subramo_keira = descripcion para contabilidad */
   FUNCTION f_get_subramo_keira(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_get_nombre_corredor(pcagente IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_get_desc_sini_weather(pcevento IN VARCHAR2, p_idioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_get_nom_affinity(psseguro IN NUMBER, pidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   -- Bug 0026430 - 20/09/2013 - JMF
   FUNCTION f_get_tipo_negocio(psseguro IN NUMBER, pidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_get_rut_asegurado(psseguro IN NUMBER, pnriesgo IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_get_rut_contratante(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_get_nom_contratante(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_get_rut_benefi(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_get_nom_benefi(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_get_total_cobertura(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfdesde IN DATE)
      RETURN VARCHAR2;

   FUNCTION f_get_invalidez
      RETURN VARCHAR2;

   FUNCTION f_get_canal(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_get_cesiones(pnsinies IN VARCHAR2, pfdesde IN DATE, pfhasta IN DATE)
      RETURN VARCHAR2;

   FUNCTION f_get_cedido_treaty
      RETURN VARCHAR2;

   FUNCTION f_get_cedido_treaty_pesos
      RETURN VARCHAR2;

   FUNCTION f_get_cesiones_pesos(pnsinies IN VARCHAR2, pfdesde IN DATE, pfhasta IN DATE)
      RETURN VARCHAR2;

   FUNCTION f_723_cab
      RETURN VARCHAR2;

   FUNCTION f_723_det(fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_get_cober_afect_r(pcgarant IN NUMBER, pidioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_get_reserva_rea(
      pnsinies IN VARCHAR2,
      pcgarant IN NUMBER,
      pfdesde IN DATE,
      pfhasta IN DATE)
      RETURN VARCHAR2;

   FUNCTION f_get_cesiones_pesos_r(
      pnsinies IN VARCHAR2,
      pcgarant IN NUMBER,
      pfdesde IN DATE,
      pfhasta IN DATE)
      RETURN VARCHAR2;

-- Bug 26430/140998 - 09/04/2013 - AMC
   FUNCTION f_get_titulos_map710(pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 09/04/2013 - AMC
   -- Bug 26430 - 14/06/2013 - JMF: pprod 1=nueva produccion, 0=renovaciones, vacio=totdos
   FUNCTION f_get_prima_directa(
      phasta IN DATE,
      pcidioma IN NUMBER,
      pprod IN NUMBER DEFAULT NULL,
      ptipint IN NUMBER DEFAULT NULL,
      pconcep IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 09/04/2013 - AMC
   -- Bug 26430 - 14/06/2013 - JMF: pprod 1=nueva produccion, 0=renovaciones, vacio=totdos
   FUNCTION f_get_linea_prima_cedida(
      phasta IN DATE,
      pcidioma IN NUMBER,
      pprod IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 09/04/2013 - AMC
   FUNCTION f_get_prima_cedida(pcramofecu IN NUMBER, phasta IN DATE)
      RETURN NUMBER;

   -- Bug 26430/140998 - 09/04/2013 - AMC
   FUNCTION f_get_linea_prima_aceptada(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 10/04/2013 - AMC
   FUNCTION f_get_resriesgo_curso(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 10/04/2013 - AMC
   FUNCTION f_get_varresinsufi_prima(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 10/04/2013 - AMC
   FUNCTION f_get_varotrasrestec(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 10/04/2013 - AMC
   FUNCTION f_get_costo_sinidirectos(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 10/04/2013 - AMC
   FUNCTION f_get_costo_sinicedidos(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 10/04/2013 - AMC
   FUNCTION f_get_costo_siniaceptados(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 10/04/2013 - AMC
   FUNCTION f_get_comiage_directos(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 10/04/2013 - AMC
   FUNCTION f_get_comi_corredores(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 10/04/2013 - AMC
   FUNCTION f_get_comi_rea_aceptado(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 10/04/2013 - AMC
   FUNCTION f_get_comi_cedido(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 11/04/2013 - AMC
   FUNCTION f_get_dire_gastos(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 11/04/2013 - AMC
   FUNCTION f_get_dire_otros(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 11/04/2013 - AMC
   FUNCTION f_get_indire_gastos(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 11/04/2013 - AMC
   FUNCTION f_get_indire_otros(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 12/04/2013 - AMC
   FUNCTION f_get_ajuste_contrato(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- bug 26430/141410 - 12/04/2013 - JMF
   FUNCTION f_862_cab(fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   -- bug 26430/141410 - 12/04/2013 - JMF
   FUNCTION f_862_det(fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   -- bug 26430/141410 - 12/04/2013 - JMF
   FUNCTION f_863_cab(fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   -- bug 26430/141410 - 12/04/2013 - JMF
   FUNCTION f_863_det(fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   -- bug 26430/141410 - 12/04/2013 - JMF
   FUNCTION f_864_cab(p_fecha IN VARCHAR2, p_sproces IN NUMBER, p_cempres IN NUMBER)
      RETURN VARCHAR2;

   -- bug 26430/141410 - 12/04/2013 - JMF
   FUNCTION f_864_det(p_fecha IN VARCHAR2, p_sproces IN NUMBER, p_cempres IN NUMBER)
      RETURN VARCHAR2;

   -- bug 26430/141410 - 12/04/2013 - JMF
   FUNCTION f_865_cab(p_fecha IN VARCHAR2, p_sproces IN NUMBER, p_cempres IN NUMBER)
      RETURN VARCHAR2;

   -- bug 26430/141410 - 12/04/2013 - JMF
   FUNCTION f_865_det(p_fecha IN VARCHAR2, p_sproces IN NUMBER, p_cempres IN NUMBER)
      RETURN VARCHAR2;

   -- bug 26430/141410 - 12/04/2013 - JMF
   FUNCTION f_866_cab(p_fecha IN VARCHAR2, p_sproces IN NUMBER, p_cempres IN NUMBER)
      RETURN VARCHAR2;

   -- bug 26430/141410 - 12/04/2013 - JMF
   FUNCTION f_866_det(p_fecha IN VARCHAR2, p_sproces IN NUMBER, p_cempres IN NUMBER)
      RETURN VARCHAR2;

   -- bug 26430/141410 - 12/04/2013 - JMF
   FUNCTION f_867_cab(fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Detalle del map 867 Listado Pago Siniestros
     return:     texto detalle
   ******************************************************************************************/
   FUNCTION f_867_det(fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Cabecera del map 868 Listado de Recaudación
     return:     texto cabecera
     -- bug 26430/141410 - 12/04/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_868_cab(fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   -- bug 26430/141410 - 12/04/2013 - JMF
   FUNCTION f_868_det(fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_869_cab(
      p_fdesde IN VARCHAR2,
      p_fhasta IN VARCHAR2,
      p_cempres IN NUMBER,
      p_previo IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

   FUNCTION f_869_det(
      p_fdesde IN VARCHAR2,
      p_fhasta IN VARCHAR2,
      p_cempres IN NUMBER,
      p_previo IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

   -- bug 26430/141410 - 12/04/2013 - JMF
   FUNCTION f_870_cab(fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   -- bug 26430/141410 - 12/04/2013 - JMF
   FUNCTION f_870_det(fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   -- bug 26721/142621 - 18/04/2013 - MGM
   FUNCTION f_889_cab(fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   -- bug 26721/142621 - 18/04/2013 - MGM
   FUNCTION f_889_det(fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 15/04/2013 - AMC
   FUNCTION f_get_var_ressiniestros(pdesde IN DATE, phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 15/04/2013 - AMC
   FUNCTION f_get_sini_pagados(pdesde IN DATE, phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 15/04/2013 - AMC
   -- Bug 0026430/0146888 - 17/06/2013 - JMF : pdesde
   FUNCTION f_get_sinpagados_direc(
      pdesde IN DATE,
      phasta IN DATE,
      pcidioma IN NUMBER,
      pselect IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 15/04/2013 - AMC
   -- Bug 0026430/0146888 - 17/06/2013 - JMF : pdesde
   FUNCTION f_get_sinpagados_reacedido(
      pdesde IN DATE,
      phasta IN DATE,
      pcidioma IN NUMBER,
      pselect IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 15/04/2013 - AMC
   FUNCTION f_get_sinporpagar_liquidados(phasta IN DATE, pcidioma IN NUMBER, pselect IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 15/04/2013 - AMC
   -- Bug 0026430/0146888 - 17/06/2013 - JMF : pdesde
   FUNCTION f_get_sinporpagar_emprodliquid(
      pdesde IN DATE,
      phasta IN DATE,
      pcidioma IN NUMBER,
      pselect IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 15/04/2013 - AMC
   FUNCTION f_get_sinporpagar_ocunoreport(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 15/04/2013 - AMC
   -- Bug 0026430/0146888 - 17/06/2013 - JMF : pdesde
   FUNCTION f_get_sin_porpagar_peranterior(pdesde IN DATE, phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 16/04/2013 - AMC
   FUNCTION f_get_resriesgo_curso_ant(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 16/04/2013 - AMC
   FUNCTION f_get_prima_directa_1ano(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 16/04/2013 - AMC
   FUNCTION f_get_prima_cedida_1ano(pcramofecu IN NUMBER, phasta IN DATE)
      RETURN NUMBER;

   -- Bug 26430/140998 - 16/04/2013 - AMC
   FUNCTION f_get_linea_prima_cedida_1ano(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 16/04/2013 - AMC
   FUNCTION f_get_prima_directa_reno(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 16/04/2013 - AMC
   FUNCTION f_get_prima_cedida_reno(pcramofecu IN NUMBER, phasta IN DATE)
      RETURN NUMBER;

   -- Bug 26430/140998 - 16/04/2013 - AMC
   FUNCTION f_get_linea_prima_cedida_reno(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 17/04/2013 - AMC
   FUNCTION f_get_numsiniestros(pdesde IN DATE, phasta IN DATE)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 17/04/2013 - AMC
   FUNCTION f_get_num_indem_inval(pdesde IN DATE, phasta IN DATE)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 17/04/2013 - AMC
   FUNCTION f_get_num_indem_muerte(pdesde IN DATE, phasta IN DATE)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 17/04/2013 - AMC
   FUNCTION f_get_num_polcontradadas(pdesde IN DATE, phasta IN DATE)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 17/04/2013 - AMC
   -- Bug 0026430/0146888 - 17/06/2013 - JMF : pdesde
   FUNCTION f_get_num_itemcontradados(pdesde IN DATE, phasta IN DATE)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 17/04/2013 - AMC
   FUNCTION f_get_polizasvig(phasta IN DATE)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 17/04/2013 - AMC
   FUNCTION f_get_itemsvig(phasta IN DATE)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 17/04/2013 - AMC
   FUNCTION f_get_polizasnovig(pdesde IN DATE, phasta IN DATE)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 17/04/2013 - AMC
   FUNCTION f_get_numperase_per(pdesde IN DATE, phasta IN DATE)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 17/04/2013 - AMC
   FUNCTION f_get_numperase(phasta IN DATE)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 17/04/2013 - AMC
   FUNCTION f_get_capase_per(pdesde IN DATE, phasta IN DATE)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 17/04/2013 - AMC
   FUNCTION f_get_total_capase(phasta IN DATE)
      RETURN VARCHAR2;

   -- Bug 26430/140998 - 17/04/2013 - AMC
   FUNCTION f_get_num_fallecimientos(pdesde IN DATE, phasta IN DATE)
      RETURN VARCHAR2;

   -- Bug 26295/139618 - 15/04/2013 - NSS
   FUNCTION f_get_recibido_origen(pcusuari IN VARCHAR2, pfecha IN VARCHAR2, pcmoneop IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26295/139618 - 15/04/2013 - NSS
   FUNCTION f_get_recibido_pesos(pcusuari IN VARCHAR2, pfecha IN VARCHAR2, pcmoneop IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26295/139618 - 15/04/2013 - NSS
   FUNCTION f_get_medio_origen(
      pcusuari IN VARCHAR2,
      pfecha IN VARCHAR2,
      pcmoneop IN NUMBER,
      pcmedmov IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26295/139618 - 15/04/2013 - NSS
   FUNCTION f_get_medio_pesos(
      pcusuari IN VARCHAR2,
      pfecha IN VARCHAR2,
      pcmoneop IN NUMBER,
      pcmedmov IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26295/139618 - 15/04/2013 - NSS
   FUNCTION f_get_pagado_origen(pcusuari IN VARCHAR2, pfecha IN VARCHAR2, pcmoneop IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26295/139618 - 15/04/2013 - NSS
   FUNCTION f_get_pagado_pesos(pcusuari IN VARCHAR2, pfecha IN VARCHAR2, pcmoneop IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26295/139618 - 15/04/2013 - NSS
   FUNCTION f_get_total_origen(pcusuari IN VARCHAR2, pfecha IN VARCHAR2, pcmoneop IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26295/139618 - 15/04/2013 - NSS
   FUNCTION f_get_total_pesos(pcusuari IN VARCHAR2, pfecha IN VARCHAR2, pcmoneop IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 26295/139618 - 15/04/2013 - NSS
   FUNCTION f_get_desc_moneda(pcmoneop IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_871_cab(
      p_fhasta IN VARCHAR2,
      p_sproces IN NUMBER,
      p_cempres IN NUMBER,
      p_fdesde IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Detalle del map 871 Deudores primas pendientes
     return:     texto detalle
     -- bug 26430/143328 - 26/04/2013 - AMC
   ******************************************************************************************/
   FUNCTION f_871_det(
      p_fhasta IN VARCHAR2,
      p_sproces IN NUMBER,
      p_cempres IN NUMBER,
      p_fdesde IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Obtiene matriz o sucursal, en funcion del recaudo masivo o no
     return:     texto sucursal
   -- bug 26721/143522 - 06/05/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_sucursal_recaudo(p_seq NUMBER, p_emp NUMBER, p_age IN NUMBER, p_fec IN DATE)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Cabecera del map 746 Libro de recaudación
     return:     texto cabecera
   -- bug 26721/143522 - 06/05/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_890_cab(pidioma IN NUMBER, fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Detalle del map 746 Libro de recaudación
     return:     texto detalle
   -- bug 26721/143522 - 06/05/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_890_det(pidioma IN NUMBER, fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

    /******************************************************************************************
     Descripció: Cabecera del map 736 RSA-Nomina de primas individual
     return:     texto cabecera
   -- bug 26800/143704 - 13/05/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_736_cab(
      pcia IN VARCHAR2,
      pdes IN VARCHAR2,
      phas IN VARCHAR2,
      pidi IN NUMBER,
      ppre IN VARCHAR2,
      p_broker IN NUMBER)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Detalle del map 736 RSA-Nomina de primas individual
     return:     texto detalle
   -- bug 26800/143704 - 13/05/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_736_det(
      pcia IN VARCHAR2,
      pdes IN VARCHAR2,
      phas IN VARCHAR2,
      pidi IN NUMBER,
      ppre IN VARCHAR2,
      p_broker IN NUMBER)
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
   FUNCTION f_747_cab(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cinttec IN NUMBER DEFAULT NULL,
      p_ctiprea IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL,
      p_broker IN NUMBER DEFAULT NULL,
      p_cmoneda IN VARCHAR2 DEFAULT NULL)
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
   FUNCTION f_747_det(
      p_compani IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_cinttec IN NUMBER DEFAULT NULL,
      p_ctiprea IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT NULL,
      p_broker IN NUMBER DEFAULT NULL,
      p_cmoneda IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte capçelera per llistat bordero siniestros
     Paràmetres entrada: - p_cempres     -> Empresa
                       - p_compani     -> Cia propia
                       - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                       - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                       - p_estsini     -> estado siniestro (1- Pagados, 0-Pendientes)
                       - p_tipctr      -> tipus contracte (1- Ctr. aut. Proporcional, 2- Cuenta de Facultativo, 3- Ctr.aut. NO Proporcional (XL))
                       - p_tipcta      -> Tipo Cuenta (1- Reasegurador, 2-Tipo Cuenta Broker, 3-Tipo Cuenta Reasegurador / Bróker, 4-Tipo Cuenta Total)
                       - p_detall      -> Detall per companyia (si tipcta = 2, 3 i p_detall = 1- Detall per companyies, 2 - Agrupat per broker
                       - p_ciarea      -> reaseguradora/Broker
                       - p_cidioma     -> Idioma
                       - p_cprevio     -> (0-Real, 1-Previo).
                       - p_broker      -> broker
     return:             texte capçelera
   ******************************************************************************************/
   FUNCTION f_748_cab(
      p_cempres IN NUMBER DEFAULT NULL,
      p_compani IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_estsini IN NUMBER DEFAULT 1,
      p_tipctr IN NUMBER DEFAULT NULL,
      p_tipcta IN NUMBER DEFAULT NULL,
      p_detall IN NUMBER DEFAULT 0,
      p_ciarea IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT 0,
      p_broker IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

    /******************************************************************************************
     Descripció: Funció que genera texte detalle per llistat bordero siniestros
     Paràmetres entrada: - p_cempres     -> Empresa
                       - p_compani     -> Cia propia
                       - p_finiefe     -> Fecha_Inicio(DDMMAAAA)
                       - p_ffinefe     -> Fecha_Fin(DDMMAAAA)
                       - p_estsini     -> estado siniestro (1- Pagados, 0-Pendientes)
                       - p_tipctr      -> tipus contracte (1- Ctr. aut. Proporcional, 2- Cuenta de Facultativo, 3- Ctr.aut. NO Proporcional (XL))
                       - p_tipcta      -> Tipo Cuenta (1- Reasegurador, 2-Tipo Cuenta Broker, 3-Tipo Cuenta Reasegurador / Bróker, 4-Tipo Cuenta Total)
                       - p_detall      -> Detall per companyia (si tipcta = 2, 3 i p_detall = 1- Detall per companyies, 2 - Agrupat per broker
                       - p_ciarea      -> reaseguradora/Broker
                       - p_cidioma     -> Idioma
                       - p_cprevio     -> (0-Real, 1-Previo).
                       - p_broker      -> broker
     return:             texte capçelera
   ******************************************************************************************/
   FUNCTION f_748_det(
      p_cempres IN NUMBER DEFAULT NULL,
      p_compani IN NUMBER DEFAULT NULL,
      p_finiefe IN VARCHAR2 DEFAULT NULL,
      p_ffinefe IN VARCHAR2 DEFAULT NULL,
      p_estsini IN NUMBER DEFAULT 1,
      p_tipctr IN NUMBER DEFAULT NULL,
      p_tipcta IN NUMBER DEFAULT NULL,
      p_detall IN NUMBER DEFAULT 0,
      p_ciarea IN NUMBER DEFAULT NULL,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cprevio IN NUMBER DEFAULT 0,
      p_broker IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

/******************************************************************************************
  ******************************************************************************************/
   FUNCTION f_737_det(pcusuari IN VARCHAR2, pfecha IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_get_rrc_lib_anoant(phasta IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_get_rrc_cons_anoact(phasta IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_get_rrc_lib_anoact(phasta IN VARCHAR2)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Cabecera del map 872 AC - intermediarios
     return:     texto cabecera
   -- bug 26721/143522 - 06/05/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_872_cab(
      pidioma IN NUMBER,
      fecha_desde IN VARCHAR2,
      fecha_hasta IN VARCHAR2,
      p_cagente IN NUMBER)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Detalle del map 872 AC - intermediarios
     return:     texto detalle
   -- bug 26721/143522 - 06/05/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_872_det(
      pidioma IN NUMBER,
      fecha_desde IN VARCHAR2,
      fecha_hasta IN VARCHAR2,
      p_cagente IN NUMBER)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Cabecera 2 del map 872 AC - intermediarios
     return:     texto cabecera
   -- bug 26721/143522 - 06/05/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_872_cab2(
      pidioma IN NUMBER,
      fecha_desde IN VARCHAR2,
      fecha_hasta IN VARCHAR2,
      p_cagente IN NUMBER)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Detalle 2 del map 872 AC - intermediarios
     return:     texto detalle
   -- bug 26721/143522 - 06/05/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_872_det2(
      pidioma IN NUMBER,
      fecha_desde IN VARCHAR2,
      fecha_hasta IN VARCHAR2,
      p_cagente IN NUMBER)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Cabecera del map 709 - Margen solvencia
     return:     texto cabecera
   -- bug 26430 - 11/06/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_709_cab(pidioma IN NUMBER, fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Detalle del map 709 - Margen solvencia
     return:     texto detalle
   -- bug 26430 - 11/06/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_709_det(pidioma IN NUMBER, fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   -- BUG 26430 - FAL - 17/06/2013
   FUNCTION f_get_dif_resriesgo_curso(phasta IN DATE, pcidioma IN NUMBER)
      RETURN VARCHAR2;

-- FI BUG 26430 - FAL - 17/06/2013

   /******************************************************************************************
     Descripció: Ficheros de Superintendencia
     return:     texto detalle
     -- bug 0026721 - 20/06/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_751(
      pidioma IN NUMBER,
      fecha_desde IN VARCHAR2,
      fecha_hasta IN VARCHAR2,
      vimp OUT t_iax_impresion)
      RETURN NUMBER;

   /*
       Se utiliza en 707 Ni Reaseguradores y corredores
   */
   FUNCTION f_cedida_reasegurador(
      preasegurador IN NUMBER,
      pdesde IN VARCHAR2,
      phasta IN VARCHAR2)
      RETURN NUMBER;

   /*
       Se utiliza en 707 Ni Reaseguradores y corredores
   */
   FUNCTION f_cedida_corredor(pcorredor IN NUMBER, pdesde IN VARCHAR2, phasta IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
    Libro de compras, calculo monto afecto siniestros y facturas
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_lc_calmontoafecto(
      psidepag IN NUMBER,
      pliq IN NUMBER,
      page IN NUMBER,
      pemp IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    Libro de compras, calculo monto exento siniestros y facturas
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_lc_calmontoexento(
      psidepag IN NUMBER,
      pliq IN NUMBER,
      page IN NUMBER,
      pemp IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    Libro de compras, calculo codigo no recuperable
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_lc_codnorecuperable(psidepag IN NUMBER, pnfact IN VARCHAR2, page IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    Libro de compras, IVA uso comun
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_lc_ivacomun(psidepag IN NUMBER, pliq IN NUMBER, page IN NUMBER, pemp IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    Libro de compras, IVA no recuperable
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_lc_ivanorecuperable(
      psidepag IN NUMBER,
      pnfact IN VARCHAR2,
      pliq IN NUMBER,
      page IN NUMBER,
      pemp IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    Libro de compras, IVA recuperable
   -- bug 0028554 - 06/02/2014 - JMF
   *************************************************************************/
   FUNCTION f_lc_ivarecuperable(
      psidepag IN NUMBER,
      pliq IN NUMBER,
      page IN NUMBER,
      pemp IN NUMBER)
      RETURN NUMBER;

   /******************************************************************************************
     Descripció: Cabecera del map 757 - Libro de compras
     return:     texto cabecera
   -- bug 26430 - 11/06/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_757_cab(pidioma IN NUMBER, fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Detalle del map 757 - Libro de compras
     return:     texto detalle
   -- bug 26430 - 11/06/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_757_det(pidioma IN NUMBER, fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Cabecera del map 758 - Libro retencion de honorarios
     return:     texto cabecera
   -- bug 26430 - 11/06/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_758_cab(pidioma IN NUMBER, fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Detalle del map 758 - Libro retencion de honorarios
     return:     texto detalle
   -- bug 26430 - 11/06/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_758_det(pidioma IN NUMBER, fecha_desde IN VARCHAR2, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Cabecera del map 859 - Oficio circular 383
     return:     texto cabecera
   -- bug 0029917 - 01/04/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_891_cab(pidioma IN NUMBER, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Detalle del map 859 - Oficio circular 383
     return:     texto detalle
   -- bug 0029917 - 01/04/2013 - JMF
   ******************************************************************************************/
   FUNCTION f_891_det(pidioma IN NUMBER, fecha_hasta IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_893_cab(p_fecha IN VARCHAR2, p_sproces IN NUMBER, p_cempres IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_893_det(p_fecha IN VARCHAR2, p_sproces IN NUMBER, p_cempres IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_894_cab(
      p_fhasta IN VARCHAR2,
      p_sproces IN NUMBER,
      p_cempres IN NUMBER,
      p_fdesde IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Detalle del map 894(744 en RSA) Deudores primas pendientes
     return:     texto detalle
   ******************************************************************************************/
   FUNCTION f_894_det(
      p_fhasta IN VARCHAR2,
      p_sproces IN NUMBER,
      p_cempres IN NUMBER,
      p_fdesde IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   -- Bug 0032660/0190245 - 12/11/2014 - JMF
   -- Bug 32661/0189343 - 17/10/2014 - JMF
   -- Calcular importes medio pago efectivo del tipo saldo inicial
   FUNCTION f_get_saldocajamov(
      pcusuari IN VARCHAR2,
      pfecha IN VARCHAR2,
      pcmoneop IN NUMBER,
      ptipmov IN NUMBER,
      pcmedmov IN NUMBER,
      ptipo IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 0032660/0190245 - 12/11/2014 - JMF
   -- Bug 32661/0189343 - 17/10/2014 - JMF
   -- Calcular importes del tipo apunte manual
   FUNCTION f_get_apuntemanual(
      pcusuari IN VARCHAR2,
      pfecha IN VARCHAR2,
      pcmoneop IN NUMBER,
      ptipo IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 0032660/0190245 - 12/11/2014 - JMF
   -- Bug 32661/0189343 - 17/10/2014 - JMF
   -- Calcular importes medio pago efectivo o cheque, del tipo confirmacion deposito
   FUNCTION f_get_depositocajamov(
      pcusuari IN VARCHAR2,
      pfecha IN VARCHAR2,
      pcmoneop IN NUMBER,
      ptipo IN NUMBER,
      pmedio IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 0032660/0190245 - 12/11/2014 - JMF
   -- Bug 32661/0189343 - 17/10/2014 - JMF
   -- Calcular importes del saldo dia siguiente
   FUNCTION f_get_saldoantcajamov(
      pcusuari IN VARCHAR2,
      pfecha IN VARCHAR2,
      pcmoneop IN NUMBER,
      ptipo IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 0036392/0207888 - 17/06/2015 - DCG
   FUNCTION f_908_cab(p_idioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_908_det(
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      pdesde IN VARCHAR2,
      phasta IN VARCHAR2,
      pcestrec IN NUMBER DEFAULT NULL,
      pctiprec IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL,
      pcsituac IN NUMBER DEFAULT NULL,
      pfiltro IN NUMBER DEFAULT NULL,
      psproduc IN NUMBER DEFAULT NULL,
      pnpoliza IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;
END pac_informes_152;

/

  GRANT EXECUTE ON "AXIS"."PAC_INFORMES_152" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_INFORMES_152" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_INFORMES_152" TO "PROGRAMADORESCSI";
