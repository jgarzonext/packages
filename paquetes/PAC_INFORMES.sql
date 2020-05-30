--------------------------------------------------------
--  DDL for Package PAC_INFORMES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_INFORMES" IS
/******************************************************************************
   NOMBRE:      PAC_INFORMES


   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        29/11/2010   JMF               1. 0016529 CRT003 - Análisis listados
   2.0        29/12/2010   JMF               2. 0016529 CRT003 - Análisis listados
   3.0        24/10/2011   JMC               3. 0019844: AGM003-Listado Indicadores de Negocio
   4.0        12/12/2011   MDS               4. 0020101: LCOL898 - Financiero - Producci?n Mensual de comisiones
   5.0        15/12/2011   MDS               5. 0020102: LCOL898 - Interface - Financiero - Carga de Comisiones Liquidadas
   6.0        10/01/2012   MDS               6. 0020105: LCOL898 - Interfaces - Regulatorio - Reporte Encuesta Fasecolda
   7.0        10/01/2012   MDS               7. 0020106: LCOL898 - Interfaces - Regulatorio - Reporte Siniestros Radicados Fasecolda
   8.0        07/02/2012   ETM               8. 0020107: LCOL898 - Interfaces - Regulatorio - Reporte Reservas Superfinanciera
   9.0        15/06/2012   ETM               9. 0022517: MdP - TEC - Listado de detalle de primas
  10.0        25/11/2014   AQ               10. 0033287: CALI300-CALI - Revisions comptabilitat
******************************************************************************/

   /******************************************************************************************
     Descripció: Funció que genera texte capçelera per llistat (map 415 dinamic)
     Paràmetres entrada: - p_cinforme    -> codigo informe (detvalor 1021)
                         - p_cidioma     -> codigo idioma
                         - p_cempres     -> codigo empresa
                         - p_finiefe     -> fecha inicio
                         - p_ffinefe     -> fecha final
                         - p_ctipage     -> Tipo (detvalor 1022) (tipo agente)
                         - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
                         - p_sperson     -> codigo cliente
                         - p_cnegocio    -> Negocio (detvalor 1023)
                         - p_codigosn    -> Codigos de negocio (separados por comas)
                         - p_sproduc     -> Producto de la actividad
     return:             texte capçelera
   ******************************************************************************************/
   -- Bug 0016529 - 29/11/2010 - JMF
   FUNCTION f_list001_cab(
      p_cinforme IN NUMBER,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL,
      p_ctipage IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_sperson IN NUMBER DEFAULT NULL,
      p_cnegocio IN NUMBER DEFAULT NULL,
      p_codigosn IN VARCHAR2 DEFAULT NULL,
      p_sproduc IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_lis457_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_producto IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_cagrupa IN NUMBER DEFAULT NULL,
      p_ccompani IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list457_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_producto IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_cagrupa IN NUMBER DEFAULT NULL,
      p_ccompani IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte select detall per llistat (map 415 dinamic)
     Paràmetres entrada: - p_cinforme    -> codigo informe (detvalor 1021)
                         - p_cidioma     -> codigo idioma
                         - p_cempres     -> codigo empresa
                         - p_finiefe     -> fecha inicio
                         - p_ffinefe     -> fecha final
                         - p_ctipage     -> Tipo (detvalor 1022) (tipo agente)
                         - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
                         - p_sperson     -> codigo cliente
                         - p_cnegocio    -> Negocio (detvalor 1023)
                         - p_codigosn    -> Codigos de negocio (separados por comas)
                         - p_sproduc     -> Producto de la actividad
     return:             texte select detall
   ******************************************************************************************/
   -- Bug 0016529 - 29/11/2010 - JMF
   FUNCTION f_list001_det(
      p_cinforme IN NUMBER,
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL,
      p_ctipage IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_sperson IN NUMBER DEFAULT NULL,
      p_cnegocio IN NUMBER DEFAULT NULL,
      p_codigosn IN VARCHAR2 DEFAULT NULL,
      p_sproduc IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list002_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_filtro IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL,
      p_ctiprec IN NUMBER DEFAULT NULL,
      p_cestrec IN NUMBER DEFAULT NULL,
      p_cestado IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ccompani IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte select detall per llistat (map 453 dinamic) Listado Recibos
     Paràmetres entrada:
                         p_cidioma -> codigo idioma
                         p_filtro  -> codigo filtro
                         p_finiefe -> fecha inicio
                         p_ffinefe -> fecha final
                         p_ctiprec -> tipo recibo
                         p_cestrec -> estado recibo
                         p_cestado -> estado poliza
                         p_cempres -> codigo empresa
                         p_ccompani -> compañia
     return:             texto select detalle
   ******************************************************************************************/
   -- Bug 0018819 - 08/07/2011 - JMF
   FUNCTION f_list002_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_filtro IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL,
      p_ctiprec IN NUMBER DEFAULT NULL,
      p_cestrec IN NUMBER DEFAULT NULL,
      p_cestado IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ccompani IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list003_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_filtro IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL,
      p_ctiprec IN NUMBER DEFAULT NULL,
      p_cestrec IN NUMBER DEFAULT NULL,
      p_cestado IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ccompani IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /******************************************************************************************
     Descripció: Funció que genera texte select detall per llistat (map 454 dinamic) Listado Recibos
     Paràmetres entrada:
                         p_cidioma -> codigo idioma
                         p_filtro  -> codigo filtro
                         p_finiefe -> fecha inicio
                         p_ffinefe -> fecha final
                         p_ctiprec -> tipo recibo
                         p_cestrec -> estado recibo
                         p_cestado -> estado poliza
                         p_cempres -> codigo empresa
                         p_ccompani -> compañia
     return:             texto select detalle
   ******************************************************************************************/
   -- Bug 0018819 - 08/07/2011 - JMF
   FUNCTION f_list003_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_filtro IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL,
      p_ctiprec IN NUMBER DEFAULT NULL,
      p_cestrec IN NUMBER DEFAULT NULL,
      p_cestado IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_ccompani IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

-- INI Bug 0019844 - 24/10/2011 - JMC
   FUNCTION f_list470_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list470_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

-- FIN Bug 0019844 - 24/10/2011 - JMC

   -- INI Bug 0020101 - 12/12/2011 - MDS
   FUNCTION f_list478_cab1(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list478_cab2(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list478_cab3(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list478_det1(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list478_det2(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list478_det3(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

-- FIN Bug 0020101 - 12/12/2011 - MDS

   -- INI Bug 0020102 - 15/12/2011 - MDS
   FUNCTION f_list480_cab1(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

-- FIN Bug 0020102 - 15/12/2011 - MDS

   -- INI Bug 0020105 - 10/01/2012 - MDS
   FUNCTION f_list493_cab1(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list493_det1(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

-- FIN Bug 0020105 - 10/01/2012 - MDS

   -- INI Bug 0020106 - 10/01/2012 - MDS
   FUNCTION f_list494_cab1(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list494_det1(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_finiefe IN NUMBER DEFAULT NULL,
      p_ffinefe IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

-- FIN Bug 0020106 - 10/01/2012 - MDS

   -- INI Bug 20107  - 07/02/2012 - ETM
   FUNCTION f_list509_cab(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_mes IN NUMBER DEFAULT NULL,
      p_ano IN NUMBER DEFAULT NULL)
      RETURN CLOB;

   FUNCTION f_list509_det(
      p_cidioma IN NUMBER DEFAULT NULL,
      p_cempres IN NUMBER DEFAULT NULL,
      p_mes IN NUMBER DEFAULT NULL,
      p_ano IN NUMBER DEFAULT NULL)
      RETURN CLOB;

-- FIN Bug 20107  - 07/02/2012 - ETM

   -- INI Bug 21838 - 14/05/2012 - JLTS
   FUNCTION f_list526_det(
      p_idioma NUMBER DEFAULT NULL,
      p_fradica_ini VARCHAR2 DEFAULT NULL,   -- DDMMYYYY
      p_fradica_fin VARCHAR2 DEFAULT NULL,   -- DDMMYYYY
      p_focurren_ini VARCHAR2 DEFAULT NULL,   -- DDMMYYYY
      p_focurren_fin VARCHAR2 DEFAULT NULL,   -- DDMMYYYY
      p_faviso_ini VARCHAR2 DEFAULT NULL,   -- DDMMYYYY
      p_faviso_fin VARCHAR2 DEFAULT NULL,   -- DDMMYYYY
      p_fcontab_ini VARCHAR2 DEFAULT NULL,   -- DDMMYYYY
      p_fcontab_fin VARCHAR2 DEFAULT NULL,   -- DDMMYYYY
      p_cusuari sin_codtramitador.cusuari%TYPE DEFAULT NULL,
      p_ctramitad sin_tramita_movimiento.ctramitad%TYPE DEFAULT NULL,
      p_ramo siniestros.cramo%TYPE DEFAULT NULL,
      p_sproduc seguros.sproduc%TYPE DEFAULT NULL,
      p_ccausin sin_siniestro.ccausin%TYPE DEFAULT NULL,
      p_asistencia sin_tramitacion.ctramit%TYPE DEFAULT NULL,
      p_proveedor sin_tramita_gestion.sprofes%TYPE DEFAULT NULL,
      p_departamento sin_tramita_localiza.cprovin%TYPE DEFAULT NULL,
      p_ciudad sin_tramita_localiza.cpoblac%TYPE DEFAULT NULL)
      RETURN CLOB;

-- FIN Bug 21838 - 14/05/2012 - JLTS

   -- INI Bug 22517  - 15/06/2012 - ETM
   FUNCTION f_list532_cab(
      p_sseguro IN NUMBER DEFAULT NULL,
      p_nriesgo IN NUMBER DEFAULT NULL,
      p_tablas IN VARCHAR DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list532_det(
      p_sseguro IN NUMBER DEFAULT NULL,
      p_nriesgo IN NUMBER DEFAULT NULL,
      p_tablas IN VARCHAR DEFAULT NULL)
      RETURN CLOB;

-- FIN Bug 22517  - 15/06/2012 - ETM
   FUNCTION f_list344_cab(p_cidioma NUMBER DEFAULT NULL, p_cempres NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list344_det(
      p_cidioma NUMBER,
      p_cempres NUMBER,
      p_cestrec IN NUMBER DEFAULT NULL,
      p_fechadesde IN NUMBER DEFAULT NULL,
      p_fechahasta IN NUMBER DEFAULT NULL,
      p_ctiprec IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_cestado IN NUMBER DEFAULT NULL,
      p_cfiltro IN NUMBER DEFAULT NULL,
      p_compani IN NUMBER DEFAULT NULL,
      p_sproduc IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_ins_codiplantilla(
      pccodplan IN codiplantillas.ccodplan%TYPE,
      pidconsulta IN codiplantillas.idconsulta%TYPE,
      pgedox IN codiplantillas.gedox%TYPE,
      pidcat IN codiplantillas.idcat%TYPE,
      pcgenfich IN codiplantillas.cgenfich%TYPE DEFAULT NULL,
      pcgenpdf IN codiplantillas.cgenpdf%TYPE DEFAULT NULL,
      pcgenrep IN codiplantillas.cgenrep%TYPE DEFAULT NULL,
      pctipodoc IN codiplantillas.ctipodoc%TYPE DEFAULT NULL,
      pcfdigital IN codiplantillas.cfdigital%TYPE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_ins_detplantillas(
      pccodplan IN detplantillas.ccodplan%TYPE,
      pcidioma IN detplantillas.cidioma%TYPE,
      ptdescrip IN detplantillas.tdescrip%TYPE,
      pcinforme IN detplantillas.cinforme%TYPE,
      pcpath IN detplantillas.cpath%TYPE,
      pcmapead IN detplantillas.cmapead%TYPE DEFAULT NULL,
      pcfirma IN detplantillas.cfirma%TYPE DEFAULT 0,
      ptconfirma IN detplantillas.tconffirma%TYPE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_ins_cfglanzarinformes(
      pcempres IN cfg_lanzar_informes.cempres%TYPE,
      pcform IN cfg_lanzar_informes.cform%TYPE,
      pcmap IN cfg_lanzar_informes.cmap%TYPE,
      ptevento IN cfg_lanzar_informes.tevento%TYPE,
      psproduc IN cfg_lanzar_informes.sproduc%TYPE,
      pslitera IN cfg_lanzar_informes.slitera%TYPE,
      plparams IN cfg_lanzar_informes.lparams%TYPE,
      pgenerareport IN cfg_lanzar_informes.genera_report%TYPE,
      pccfgform IN cfg_lanzar_informes.ccfgform%TYPE,
      plexport IN cfg_lanzar_informes.lexport%TYPE,
      pctipo IN cfg_lanzar_informes.ctipo%TYPE)
      RETURN NUMBER;

   FUNCTION f_upd_cfglanzarinformes(
      pcempres IN cfg_lanzar_informes.cempres%TYPE,
      pcmap IN cfg_lanzar_informes.cmap%TYPE,
      ptevento IN cfg_lanzar_informes.tevento%TYPE,
      psproduc IN cfg_lanzar_informes.sproduc%TYPE,
      pccfgform IN cfg_lanzar_informes.ccfgform%TYPE,
      plexport IN cfg_lanzar_informes.lexport%TYPE,
      pslitera IN cfg_lanzar_informes.slitera%TYPE)
      RETURN NUMBER;

   FUNCTION f_del_detalleplantillas(pccodplan IN detplantillas.ccodplan%TYPE)
      RETURN NUMBER;

   FUNCTION f_ins_cfglanzarinformesparams(
      pcempres IN cfg_lanzar_informes_params.cempres%TYPE,
      pcform IN cfg_lanzar_informes_params.cform%TYPE,
      pcmap IN cfg_lanzar_informes_params.cmap%TYPE,
      ptevento IN cfg_lanzar_informes_params.tevento%TYPE,
      psproduc IN cfg_lanzar_informes_params.sproduc%TYPE,
      pccfgform IN cfg_lanzar_informes_params.ccfgform%TYPE,
      ptparam IN cfg_lanzar_informes_params.tparam%TYPE,
      pctipo IN cfg_lanzar_informes_params.ctipo%TYPE,
      pnorder IN cfg_lanzar_informes_params.norder%TYPE DEFAULT NULL,
      pslitera IN cfg_lanzar_informes_params.slitera%TYPE DEFAULT NULL,
      pnotnull IN cfg_lanzar_informes_params.notnull%TYPE DEFAULT NULL,
      PLValor IN cfg_lanzar_informes_params.lvalor%TYPE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_del_cfglanzarinformesparams(
      pcempres IN cfg_lanzar_informes_params.cempres%TYPE,
      pcform IN cfg_lanzar_informes_params.cform%TYPE,
      pcmap IN cfg_lanzar_informes_params.cmap%TYPE,
      ptevento IN cfg_lanzar_informes_params.tevento%TYPE,
      psproduc IN cfg_lanzar_informes_params.sproduc%TYPE,
      pccfgform IN cfg_lanzar_informes_params.ccfgform%TYPE)
      RETURN NUMBER;

   FUNCTION f_list366_cab(p_cidioma NUMBER DEFAULT NULL, p_cempres NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list366_det(
      p_cidioma NUMBER,
      p_cempres NUMBER,
      p_cproduc IN NUMBER DEFAULT NULL,
      p_fechadesde IN VARCHAR2 DEFAULT NULL,
      p_fechahasta IN VARCHAR2 DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_cgrpro IN NUMBER DEFAULT NULL,
      p_compani IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list320_cab(p_sproces NUMBER DEFAULT NULL, p_cempres NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list320_det(p_sproces NUMBER DEFAULT NULL, p_cempres NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   -- Bug 0031584 - 20/06/2014 - JMF
   /******************************************************************************************
     Descripció: Funció que genera texte select titols per llistat (map 316 dinamic APR-Previo a domiciliaciones)
     return:     texte select titols
   ******************************************************************************************/
   FUNCTION f_list316_cab
      RETURN VARCHAR2;

   -- Bug 0031584 - 20/06/2014 - JMF
   /******************************************************************************************
     Descripció: Funció que genera texte select detall per llistat (map 316 dinamic APR-Previo a domiciliaciones)
     return:     texte select detall
   ******************************************************************************************/
   FUNCTION f_list316_det(
      p_ffecha IN VARCHAR2,
      p_cramo IN VARCHAR2,
      p_sproduc IN VARCHAR2,
      p_cempres IN VARCHAR2,
      p_sprodcom IN VARCHAR2,
      p_ccobban IN VARCHAR2,
      p_cbanco IN VARCHAR2,
      p_ctipcuenta IN VARCHAR2,
      p_fventar IN VARCHAR2,
      p_creferencia IN VARCHAR2,
      p_dffecha IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_list323_cab(p_sproces NUMBER DEFAULT NULL, p_cempres NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list323_det(p_sproces NUMBER DEFAULT NULL, p_cempres NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list324_cab(p_cempres NUMBER DEFAULT NULL, p_fecha VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list324_det(p_cempres NUMBER DEFAULT NULL, p_fecha VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list325_cab(p_cempres NUMBER DEFAULT NULL, p_fecha VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_list325_det(p_cempres NUMBER DEFAULT NULL, p_fecha VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

-- 10.0 AQ Start
   FUNCTION f_907_cab
      RETURN VARCHAR2;

   FUNCTION f_907_det(
      pfcalculi VARCHAR2,   --fecha inicial  --pantalla
      pfcalculf VARCHAR2,   --fecha final    --pantalla
      pcorasuc VARCHAR2,   --compañia, ramo contable, sucursal, todo contcatenado  --pantalla
      pcempres NUMBER,   --empresa           --pantalla
      pnpoliza NUMBER,   --poliza
      pnrecibo NUMBER,   --recibo
      pnsinies NUMBER,   --siniestro
      pccuenta VARCHAR2,   --cuenta
      ppendient NUMBER)
      RETURN VARCHAR2;

-- 10.0 AQ End
   FUNCTION f_list271_cab(p_nidioma NUMBER, p_sproduc NUMBER, p_nlinea NUMBER)
      RETURN stringtable;

   FUNCTION f_list271_det(
      p_nidioma NUMBER,
      p_sproduc NUMBER,
      p_fdesde VARCHAR2,
      p_fhasta VARCHAR2)
      RETURN stringtable;

   FUNCTION f_list1001001(linea VARCHAR2)
      RETURN stringtable;

   FUNCTION f_list1001003(linea VARCHAR2)
      RETURN stringtable;

   -- Inicio Tarea 4136 Kaio
   -- INI IAXIS-4136 JRVG  23/04/2020
      function f_ins_obs_cuentacobro(
      pobservacion IN obs_cuentacobro.observacion%TYPE,
      psseguro IN obs_cuentacobro.sseguro%TYPE,
      pnrecibo IN obs_cuentacobro.nrecibo%TYPE,
      pmarca  IN  obs_cuentacobro.cmarca%TYPE,
      mensajes IN OUT t_iax_mensajes)

      RETURN NUMBER;
    -- FIN IAXIS-4136 JRVG  23/04/2020
    -- FIN Tarea 4136 Kaio

  --INI BUG IAXIS-10514 JRVG 02/04/2020
  PROCEDURE SET_OBS_CONSORCIO(PI_SPERSON IN NUMBER);		
  --FIN BUG IAXIS-10514 JRVG 02/04/2020

END pac_informes;

/

  GRANT EXECUTE ON "AXIS"."PAC_INFORMES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_INFORMES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_INFORMES" TO "PROGRAMADORESCSI";
