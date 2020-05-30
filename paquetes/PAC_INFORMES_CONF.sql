--------------------------------------------------------
--  DDL for Package PAC_INFORMES_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_INFORMES_CONF" IS
/******************************************************************************
   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        04/02/2013  ETM              1.0024776: (CONFDE500)-Desarrollo-GAPS - Siniestros - Id 173 - Criterios de filtro listados
   2.0        04/03/2013  JGR              2.0025615: CONFPG100-(CONFPG100)-Parametrizacion- Administracion y Finanzas- Parametrizacion Cierres
   3.0        18/04/2013  ETM              3.0024933: CONFRE100-(CONFR100)-Informes y reportes-Administracion y finanzas
   4.0        02/05/2013  JMF              4.0025623 (CONFDE200)-Desarrollo-GAPS - Comercial - Id 56
   5.0        18/09/2012  ETM              5.0025615: CONFPG100-(CONFPG100)-Parametrizacion- Administracion y Finanzas- Parametrizacion Cierres
   6.0        19/02/2014  JTT              6.0024936: Listado del libro radicador de sinietros MAP 518
   7.0        26/02/2014  JTT              7.0034909: Listado del libro radicador de sinietros MAP 518
   8.0        10/05/2015  JTT              8.0035599: Listado del libro radicador de sinietros MAP 518
   9.0        28/05/2015  JTT              9.0035599: Listado del libro radicador de sinietros MAP 518 - Reaseguro
******************************************************************************/

   /******************************************************************************************
       Descripci¿: Funci¿ que genera texte cap¿elera per llistat dinamic siniestros abiertos en un periodo
       Par¿metres entrada:    - p_cidioma     -> codigo idioma
                              - p_cempres     -> codigo empresa
                              - p_cagrpro     ->
                              - p_cramo       -> ramo
                              - p_sproduc     -> Producto
                              - p_fdesde      -> fecha ini
                              - p_fhasta      -> fecha fin
                              - p_sucursal    -> Codigos de sucursal
                              - p_ccausin     -> codigo causa siniestro
                              - p_cmotsin     -> codigo motivo siniestro
                              - p_sprofes     -> codigo profesional
                              - p_tipoper     -> codigo tipo per, 1 tomador y 2 asegurado
                              - p_sperson     -> codigo sperson

       return:             texte cap¿elera

     ******************************************************************************************/
   --BUG 24776 -- 04/02/2013--ETM --INI
   FUNCTION f_list655_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cagrpro IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_sproduc IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_sucursal IN NUMBER DEFAULT NULL,
      p_ccausin IN NUMBER DEFAULT NULL,
      p_cmotsin IN NUMBER DEFAULT NULL,
      p_sprofes IN NUMBER DEFAULT NULL,
      p_tipoper IN NUMBER DEFAULT 1,
      p_sperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list655_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cagrpro IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_sproduc IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_sucursal IN NUMBER DEFAULT NULL,
      p_ccausin IN NUMBER DEFAULT NULL,
      p_cmotsin IN NUMBER DEFAULT NULL,
      p_sprofes IN NUMBER DEFAULT NULL,
      p_tipoper IN NUMBER DEFAULT 1,
      p_sperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

    /******************************************************************************************
        Descripci¿: Funci¿ que genera texte cap¿elera per llistat dinamic SINIESTROS SEGUN SITUACION
        Par¿metres entrada:    - p_cidioma     -> codigo idioma
                               - p_cempres     -> codigo empresa
                               - p_cagrpro     ->
                               - p_cramo       -> ramo
                               - p_sproduc     -> Producto
                               - p_cestsin     -> estado siniestro
                               - p_fdesde      -> fecha ini
                               - p_fhasta      -> fecha fin
                               - p_sucursal    -> Codigos de sucursal
                               - p_ccausin     -> codigo causa siniestro
                               - p_cmotsin     -> codigo motivo siniestro
                               - p_sprofes     -> codigo profesional
                               - p_tipoper     -> codigo tipo per, 1 tomador y 2 asegurado
                               - p_sperson     -> codigo sperson

        return:             texte cap¿elera
   ':CIDIOMA|:CEMPRES|:CAGRPRO|:CRAMO|:SPRODUC|:CESTSIN|:FDESDE|:FHASTA|:SUCURSAL|:CCAUSIN|:CMOTSIN|:SPROFES|:TIPO_PERS|:SPERSON|',

      ******************************************************************************************/
   FUNCTION f_list656_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cagrpro IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_sproduc IN NUMBER DEFAULT NULL,
      p_cestsin IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_sucursal IN NUMBER DEFAULT NULL,
      p_ccausin IN NUMBER DEFAULT NULL,
      p_cmotsin IN NUMBER DEFAULT NULL,
      p_sprofes IN NUMBER DEFAULT NULL,
      p_tipoper IN NUMBER DEFAULT 1,
      p_sperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list656_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cagrpro IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_sproduc IN NUMBER DEFAULT NULL,
      p_cestsin IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_sucursal IN NUMBER DEFAULT NULL,
      p_ccausin IN NUMBER DEFAULT NULL,
      p_cmotsin IN NUMBER DEFAULT NULL,
      p_sprofes IN NUMBER DEFAULT NULL,
      p_tipoper IN NUMBER DEFAULT 1,
      p_sperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
       Descripci¿: Funci¿ que genera texte cap¿elera per llistat de pagos liquidados en un periodo
       Par¿metres entrada:    - p_cidioma     -> codigo idioma
                              - p_cempres     -> codigo empresa
                              - p_cagrpro     ->
                              - p_cramo       -> ramo
                              - p_sproduc     -> Producto
                              - p_cagente     -> codigo de agente
                              - p_fdesde      -> fecha ini
                              - p_fhasta      -> fecha fin
                              - p_sucursal    -> Codigos de sucursal
                              - p_ccausin     -> codigo causa siniestro
                              - p_cmotsin     -> codigo motivo siniestro
                              - p_sprofes     -> codigo profesional
                              - p_tipoper     -> codigo tipo per, 1 tomador y 2 asegurado
                              - p_sperson     -> codigo sperson

       return:             texte cap¿elera
   ':CIDIOMA|:CEMPRES|:CAGRPRO|:CRAMO|:SPRODUC|:CAGENTE|:FDESDE|:FHASTA|:SUCURSAL|:CCAUSIN|:CMOTSIN|:SPROFES|:TIPO_PERS|:SPERSON',

     ******************************************************************************************/
   FUNCTION f_list657_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cagrpro IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_sproduc IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_sucursal IN NUMBER DEFAULT NULL,
      p_ccausin IN NUMBER DEFAULT NULL,
      p_cmotsin IN NUMBER DEFAULT NULL,
      p_sprofes IN NUMBER DEFAULT NULL,
      p_tipoper IN NUMBER DEFAULT 1,
      p_sperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
        Descripci¿: Funci¿ que genera el contigut per llistat pagos liquidados en un periodo (map 657 dinamic)
        Par¿metres entrada:  - p_cidioma     -> codigo idioma
                            - p_cempres     -> codigo empresa
                            - p_cagrpro     ->
                            - p_cramo       -> ramo
                            - p_sproduc     -> Producto
                            - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
                            - p_fdesde      -> fecha ini
                            - p_fhasta      -> fecha fin
                            - p_sucursal    -> Codigos de sucursal
                            - p_ccausin     -> codigo causa siniestro
                            - p_cmotsin     -> codigo motivo siniestro
                            - p_sprofes     -> codigo profesional
                             - p_tipoper     -> codigo tipo per, 1 tomador y 2 asegurado
                            - p_sperson     -> codigo sperson
   ':CIDIOMA|:CEMPRES|:CAGRPRO|:CRAMO|:SPRODUC|:CAGENTE|:FDESDE|:FHASTA|:SUCURSAL|:CCAUSIN|:CMOTSIN|:SPROFES|:TIPO_PERS|:SPERSON',
        return:              text select detall
      ******************************************************************************************/
   FUNCTION f_list657_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cagrpro IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_sproduc IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_sucursal IN NUMBER DEFAULT NULL,
      p_ccausin IN NUMBER DEFAULT NULL,
      p_cmotsin IN NUMBER DEFAULT NULL,
      p_sprofes IN NUMBER DEFAULT NULL,
      p_tipoper IN NUMBER DEFAULT 1,
      p_sperson IN NUMBER DEFAULT NULL,
      p_ctipdes IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list658_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cagrpro IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_sproduc IN NUMBER DEFAULT NULL,
      p_cestpag IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_sucursal IN NUMBER DEFAULT NULL,
      p_ccausin IN NUMBER DEFAULT NULL,
      p_cmotsin IN NUMBER DEFAULT NULL,
      p_sprofes IN NUMBER DEFAULT NULL,
      p_cestsin IN NUMBER DEFAULT NULL,
      p_tipoper IN NUMBER DEFAULT 1,
      p_sperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

/******************************************************************************************
        Descripci¿: Funci¿ que genera el contigut per llistat pagos de siniestros por estado(map 658 dinamic)
        Par¿metres entrada:  - p_cidioma     -> codigo idioma
                            - p_cempres     -> codigo empresa
                            - p_cagrpro     -> codigo agrup produ
                            - p_cramo       -> codigo ramo
                            - p_sproduc     ->  codigo Producto
                            - p_cestpag     --> codigo estado pago
                            - p_fdesde      -> fecha ini
                            - p_fhasta      -> fecha fin
                            - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
                            - p_sucursal    -> Codigos de sucursal
                            - p_ccausin     -> codigo causa siniestro
                            - p_cmotsin     -> codigo motivo siniestro
                            - p_sprofes     -> codigo profesional
                            - p_cestsin     -> codigo de estado
                            - p_tipoper     -> codigo tipo per, 1 tomador y 2 asegurado
                            - p_sperson     -> codigo sperson
 ':CIDIOMA|:CEMPRES|:CAGRPRO|:CRAMO|:SPRODUC|:CESTPAG|:FDESDE|:FHASTA|:CAGENTE|:SUCURSAL|:CCAUSIN|:CMOTSIN|:SPROFES|:CESTSIN|:TIPO_PERS|:SPERSON|',

   return:              text select detall
      ******************************************************************************************/
   FUNCTION f_list658_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cagrpro IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_sproduc IN NUMBER DEFAULT NULL,
      p_cestpag IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_sucursal IN NUMBER DEFAULT NULL,
      p_ccausin IN NUMBER DEFAULT NULL,
      p_cmotsin IN NUMBER DEFAULT NULL,
      p_sprofes IN NUMBER DEFAULT NULL,
      p_cestsin IN NUMBER DEFAULT NULL,
      p_tipoper IN NUMBER DEFAULT 1,
      p_sperson IN NUMBER DEFAULT NULL,
      p_ctipdes IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

--FIN--BUG 24776 -- 04/02/2013--ETM --
   -- 2.0025615: POSPG100-(POSPG100)-Parametrizacion- Administracion y Finanzas- Parametrizacion Cierres - Inicio
   FUNCTION f_661_cab(pcempres IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_661_det(
      pfcalcul IN VARCHAR2,
      psproces IN VARCHAR2,
      pcempres IN VARCHAR2,
      pcramo IN VARCHAR2,
      pcmodali IN VARCHAR2,
      pctipseg IN VARCHAR2,
      pccolect IN VARCHAR2,
      pcagente IN VARCHAR2)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripci¿: f_662_det Detalle del map 662
     return:     texto cabecera
   ******************************************************************************************/
   FUNCTION f_662_det(fecha_calcul IN VARCHAR2, cproces IN VARCHAR2, cempres IN VARCHAR2)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripci¿: f_662_det Detalle del map 662 copia
     return:     texto cabecera
   ******************************************************************************************/
   FUNCTION f_662_det_copia(fecha_calcul IN VARCHAR2, cproces IN VARCHAR2, cempres IN VARCHAR2)
      RETURN VARCHAR2;


  /******************************************************************************************
     Descripci¿: f_664_det Detalle del map 664
     return:     texto cabecera
   ******************************************************************************************/
   FUNCTION f_664_det(fecha_calcul IN VARCHAR2, cproces IN VARCHAR2, cempres IN VARCHAR2)
      RETURN VARCHAR2;


  /******************************************************************************************
     Descripci¿: f_664_det Detalle del map 664
     return:     texto cabecera
   ******************************************************************************************/
   FUNCTION f_664_det_copia(fecha_calcul IN VARCHAR2, cproces IN VARCHAR2, cempres IN VARCHAR2)
      RETURN VARCHAR2;


  /******************************************************************************************
     Descripci¿: f_663_det Detalle del map 663
     return:     texto cabecera
   ******************************************************************************************/
   FUNCTION f_663_det(fecha_calcul IN VARCHAR2, cproces IN VARCHAR2, cempres IN VARCHAR2)
      RETURN VARCHAR2;

  /******************************************************************************************
     Descripci¿: f_perini_cab_det Detalle del map 663, 664, 662
     return:     texto cabecera
   ******************************************************************************************/
   FUNCTION f_perini_cab_det(fecha_calcul IN VARCHAR2, cproces IN VARCHAR2, cempres IN VARCHAR2)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripci¿: f_perifin_cab_det Detalle del map 663, 664, 662
     return:     texto cabecera
   ******************************************************************************************/
   FUNCTION f_perfin_cab_det(fecha_calcul IN VARCHAR2, cproces IN VARCHAR2, cempres IN VARCHAR2)
      RETURN VARCHAR2;

-- 2.0025615: POSPG100-(POSPG100)-Parametrizacion- Administracion y Finanzas- Parametrizacion Cierres - Fin
--BUG 24933 -- 18/04/2013--ETM --INI
-- BUG 0025623 - 02/05/2013 - JMF: afegir pperage
 /******************************************************************************************
       Descripci¿: Funci¿n que genera el texto cabecera para el Listado de Recibos segun situacion
       Par¿metres entrada:    - p_cidioma     -> codigo idioma
                              - p_cempres     -> codigo empresa
                              - p_cestrec     -> esstado de recibo
                              - p_fdesde       ->  fecha ini
                              - p_fhasta     -> fecha fin
                              - p_ctiprec     -> tipo de recibo
                              - p_cagente      -> codigo agente
                              - p_cestado      -> estado
                              - p_filtro    -> tipo filtro
                              - p_ccompani     -> codigo de compa¿ia
                              - p_perage       -> sperson del agente


       return:             texto cabecera
   'IDIOMA|EMPRESA|CESTREC|FDESDE|FHASTA|CTIPREC|AGENTE|CESTADO|FILTRO|CCOMPANI ',

     ******************************************************************************************/
   FUNCTION f_list733_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cestrec IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_ctiprec IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_cestado IN NUMBER DEFAULT NULL,
      p_filtro IN NUMBER DEFAULT NULL,
      p_ccompani IN NUMBER DEFAULT NULL,
      p_perage IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list733_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cestrec IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_ctiprec IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_cestado IN NUMBER DEFAULT NULL,
      p_filtro IN NUMBER DEFAULT NULL,
      p_ccompani IN NUMBER DEFAULT NULL,
      p_perage IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

-- BUG 0025623 - 02/05/2013 - JMF: afegir pperage
   /******************************************************************************************
        Descripci¿: Funci¿n que genera el texto cabecera para el Listado de Recibos pendientes por poliza
        Par¿metres entrada:    - p_cidioma     -> codigo idioma
                               - p_cempres     -> codigo empresa
                               - p_cestrec     -> esstado de recibo
                               - p_fdesde       ->  fecha ini
                               - p_fhasta     -> fecha fin
                               - p_ctiprec     -> tipo de recibo
                               - p_cagente      -> codigo agente
                               - p_cestado      -> estado
                               - p_perage       -> sperson del agente

        return:             texto cabecera
    'IDIOMA|EMPRESA|CESTREC|FDESDE|FHASTA|CTIPREC|AGENTE|CESTADO',

      ******************************************************************************************/
   FUNCTION f_list734_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cestrec IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_ctiprec IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_cestado IN NUMBER DEFAULT NULL,
      p_perage IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list734_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_cestrec IN NUMBER DEFAULT NULL,
      p_fdesde IN VARCHAR2 DEFAULT NULL,
      p_fhasta IN VARCHAR2 DEFAULT NULL,
      p_ctiprec IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_cestado IN NUMBER DEFAULT NULL,
      p_perage IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

--FIN--BUG 24933 -- 18/04/2013--ETM --

   /******************************************************************************************
       Descripci¿: Funci¿ que genera la cap¿alera per llistat sobrecomisions
       Par¿metres entrada:  - p_cidioma     -> codigo idioma
                           - p_cempres     -> codigo empresa
                           - p_mes         -> mes
                           - p_anyo         -> a¿o
                           - p_cramo       -> codigo ramo
                           - p_cagente     -> codigo intermediario
         ':MES :ANYO'
        ':CIDIOMA|:CEMPRES|:MES|:CANYO|:CRAMO|:CAGENTE',

                 return:              text select cabecera
     ******************************************************************************************/
   FUNCTION f_list752_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_mes IN NUMBER DEFAULT NULL,
      p_anyo IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
         Descripci¿: Funci¿ que genera el contigut per llistat sobrecomisions
          Par¿metres entrada:  - p_cidioma     -> codigo idioma
                           - p_cempres     -> codigo empresa
                           - p_mes         -> mes
                           - p_anyo         -> a¿o
                           - p_cramo       -> codigo ramo
                           - p_cagente     -> codigo intermediario
         ':MES :ANYO'
        ':CIDIOMA|:CEMPRES|:MES|:CANYO|:CRAMO|:CAGENTE',
                   return:              text select detall
       ******************************************************************************************/
   FUNCTION f_list752_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_mes IN NUMBER DEFAULT NULL,
      p_anyo IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

--BUG 0025615 -- 18/09/2012--ETM --INI
   FUNCTION f_663_cab_borrar
      RETURN VARCHAR2;

   FUNCTION f_663_det_borrar(pfcalcul VARCHAR2, psproces NUMBER, pcempres NUMBER)
      RETURN VARCHAR2;

--FIN--BUG 0025615 -- 18/09/2012--ETM
   /******************************************************************************************
       Descripci¿: Funci¿ que genera la cap¿alera pel llistat salaris
       Par¿metres entrada:  - p_cidioma     -> codigo idioma
                           - p_cempres     -> codigo empresa
                           - p_mes         -> mes
                           - p_anyo         -> a¿o
                           - p_cramo       -> codigo ramo
                           - p_cagente     -> codigo intermediario
         ':MES :ANYO'
        ':CIDIOMA|:CEMPRES|:MES|:CANYO|:CRAMO|:CAGENTE',

                 return:              text select cabecera
     ******************************************************************************************/
   FUNCTION f_list756_cab1(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_mes IN NUMBER DEFAULT NULL,
      p_anyo IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
         Descripci¿: Funci¿ que genera el contigut pel llistat salaris
          Par¿metres entrada:  - p_cidioma     -> codigo idioma
                           - p_cempres     -> codigo empresa
                           - p_mes         -> mes
                           - p_anyo         -> a¿o
                           - p_cramo       -> codigo ramo
                           - p_cagente     -> codigo intermediario
         ':MES :ANYO'
        ':CIDIOMA|:CEMPRES|:MES|:CANYO|:CRAMO|:CAGENTE',
                   return:              text select detall
       ******************************************************************************************/
   FUNCTION f_list756_det1(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_mes IN NUMBER DEFAULT NULL,
      p_anyo IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
         Descripci¿: Funci¿ que genera el contigut pel llistat salaris
          Par¿metres entrada:  - p_cidioma     -> codigo idioma
                           - p_cempres     -> codigo empresa
                           - p_mes         -> mes
                           - p_anyo         -> a¿o
                           - p_cramo       -> codigo ramo
                           - p_cagente     -> codigo intermediario
         ':MES :ANYO'
        ':CIDIOMA|:CEMPRES|:MES|:CANYO|:CRAMO|:CAGENTE',
                   return:              text select detall
       ******************************************************************************************/
   FUNCTION f_list756_det2(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_mes IN NUMBER DEFAULT NULL,
      p_anyo IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list777_cabecera1a(
      p_sproces IN NUMBER DEFAULT NULL,
      p_cgarant IN NUMBER DEFAULT 0,
      p_sproduc IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list777_linea1a(
      p_sproces IN NUMBER DEFAULT NULL,
      p_cgarant IN NUMBER DEFAULT 0,
      p_sproduc IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /*****************************************************************************************
      Descripcion: 518 - Listado radicador de siniestros

   *****************************************************************************************/
   FUNCTION f_518_cab
      RETURN VARCHAR2;

   /*****************************************************************************************
      Descripcion: 518 - Listado radicador de siniestros

      Par¿metres entrada:  - p_cidioma
                           - p_cempres
                           - fecha_desde
                           - fecha_hasta
                           - pcramo
                           - psproduc
         ':CEMPRES|:CIDIOMA|:FDESDE|:FHASTA|:CRAMO|:SPRODUC'
                  return:              text select detall
   *****************************************************************************************/
   FUNCTION f_518_det(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      fecha_desde IN VARCHAR2,
      fecha_hasta IN VARCHAR2,
      pcramo IN NUMBER,
      psproduc IN NUMBER)
      RETURN VARCHAR2;

   /*****************************************************************************************
      Descripcion: Develve la causa de modificacion/variacion de la reserva.
   *****************************************************************************************/
   FUNCTION f_get_causamodreserva(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pnmovres IN NUMBER,
      pcgarant IN NUMBER,
      pidres IN NUMBER)
      RETURN NUMBER;

   /*****************************************************************************************
      Descripcion: Develve que ha causado el movimiento de la reserva.
   *****************************************************************************************/
   FUNCTION f_get_estadomovreserva(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pnmovres IN NUMBER,
      pcgarant IN NUMBER,
      pidres IN NUMBER)
      RETURN NUMBER;

   /*****************************************************************************************
      Descripcion: Indica si es un Amparao de muerte
   *****************************************************************************************/
   FUNCTION f_esamparodemuerte(psproduc IN NUMBER, pcgarant IN NUMBER)
      RETURN NUMBER;

   /*****************************************************************************************
      Descripcion: Devuelve la descripcion de la causa del siniestro
   *****************************************************************************************/
   FUNCTION f_descausin(pccausin IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*****************************************************************************************
      Descripcion: Devuelve la descripcion del motivo del sinestro
   *****************************************************************************************/
   FUNCTION f_desmotsin(pccausin IN NUMBER, pcmotsin IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*****************************************************************************************
      Descripcion: Devuelve la parte de la reserva (en la moneda de la Cia) reasegurada.
   *****************************************************************************************/
   FUNCTION f_get_reserva_rea_moncia(
      pnsinies IN VARCHAR2,
      pcgarant IN NUMBER,
      pfdesde IN DATE,
      pfhasta IN DATE)
      RETURN NUMBER;

   /*****************************************************************************************
      Descripcion: Devuelve el valor cedido (en la moneda de la Cia) a al reasegurador.
   *****************************************************************************************/
   FUNCTION f_get_cesiones_moncia(pnsinies IN VARCHAR2, pfdesde IN DATE, pfhasta IN DATE)
      RETURN NUMBER;

   /*****************************************************************************************
      Descripcion: Devuelve el % del coaseguro correspondiente a la Cia
   *****************************************************************************************/
   FUNCTION f_plocal_coa(
      psseguro IN sin_siniestro.sseguro%TYPE,
      pfsinies IN sin_siniestro.fsinies%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pcgarant IN sin_tramita_reserva.cgarant%TYPE)
      RETURN NUMBER;

   /*****************************************************************************************
      Descripcion: Devuelve el % del reaseguro correspondiente a la Cia.
   *****************************************************************************************/
   FUNCTION f_plocal_rea(
      psseguro IN sin_siniestro.sseguro%TYPE,
      pfsinies IN sin_siniestro.fsinies%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pcgarant IN sin_tramita_reserva.cgarant%TYPE)
      RETURN NUMBER;

   /*****************************************************************************************
      Descripcion: Devuelve el % del reaseguro correspondiente a la Cia
      teniendo en centa la parte del Coaseguro local
   *****************************************************************************************/
   FUNCTION f_plocal_rea_coa(
      psseguro IN sin_siniestro.sseguro%TYPE,
      pfsinies IN sin_siniestro.fsinies%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pcgarant IN sin_tramita_reserva.cgarant%TYPE)
      RETURN NUMBER;
END pac_informes_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_INFORMES_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_INFORMES_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_INFORMES_CONF" TO "PROGRAMADORESCSI";
