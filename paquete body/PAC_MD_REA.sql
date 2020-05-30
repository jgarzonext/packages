--------------------------------------------------------
--  DDL for Package Body PAC_MD_REA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "AXIS"."PAC_MD_REA" IS
/******************************************************************************
 NAME:       pac_md_rea
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/06/2009                    1. Created this package body.
   2.0        17/06/2009    ETM             2. Se a?aden nuevas funciones--0010471: IAX - REA: Desarrollo PL de la consulta de cesiones
   3.0        18/06/2009    ETM             3. 0010487: IAX - REA: Desarrollo PL del mantenimiento de Facultativo
   4.0        02/09/2009    ICV             4. 0010487: IAX - REA: Desarrollo PL del mantenimiento de Facultativo
   5.0        07/09/2009    ICV             5. 0010990: IAX - REA: Desarrollo PL del mantenimiento de contratos
   6.0        08/09/2009    ICV             6. 0010471: IAX - REA: Desarrollo PL de la consulta de cesiones
   7.0        23/09/2009    DRA             7. 0011183: CRE - Suplemento de alta de asegurado ya existente
   8.0        29/10/2009    AMC             8. 0011605: CRE - Adaptar consulta de cessions als reemborsaments.
   9.0        30/10/2009    ICV             9. 0011353: CEM - Parametrizaci?n mantenimiento de contratos Reaseguro
  10.0        14/05/2010    AVT             10. 0014536: CRE200 - Reaseguro: Se requiere que un contrato se pueda utilizar
                                                en varias agrupaciones de producto
  11.0        28/06/2010    ETM             11.0015190: CRE800 - Consulta de Contractes
  12.0        03/03/2011    JGR             12.0017672: CEM800 - Contracte Reaseguro 2011 - A?adir nuevo par?metro w_cdetces
  13.0        04/07/2011    APD             13. 0018319: LCOL003 - Pantalla de mantenimiento del contrato de reaseguro
  14.0        04/04/2012    AVT             14.0021829: LCOL_A002-Incidencias en el calculo del reaseguro XL
  15.0        23/05/2012    AVT             15.0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
  16.0        20/08/2012    AVT             16.0022374: LCOL_A004-Mantenimiento de facultativo - Fase 2
  17.0        08/11/2012    AVT             17.0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
  18.0        14/01/2013    AEG             18.0025502: LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos
  19.0        15/02/2013    DCT             19.0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
  20.0        22/03/2013    ECP             20.0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
  21.0        03/05/2013    AMJ             21.0026830: QT: 7418, 7419, 7420 y 7421 Cesiones de póliza en Producción
  220.        08/05/2013    AVT             22.0026252: RSA003 - Realizar la cesión del reaseguro por recibo cobrado
  23.0        13/05/2013    FAL             23.0022320: GIP800 - La consulta de cessions únicament mostra cessions del 1º risc
  24.0        06/06/2013    AVT             24. 22678: LCOL_A002-Qtracker: 0004601: Error en cuenta tecnica de XL
  25.0        10/07/2013    DCT             25.0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
  26.0        12/07/2013    KBR             26.0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 23830/0140221)
  27.0        06/08/2013    AVT             27. 23830/0150483 se ajustan variables vparam
  28.0        31/07/2013    ETM             28.0026444: (POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 150 -entidad economica de las agrupaciones (Fase3)
  29.0        23/08/2013    KBR             29.0027911: LCOL_A004-Qtracker: 6163: Validacion campos pantalla mantenimiento cuentas reaseguro (Liquidaciones)
  30.0        05/09/2013    KBR             30.0027911: 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca
  31.0        30/09/2013    RCL             31. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
  32.0        09/10/2013    SHA             32.0028454: LCOL895-Añadir la compañ?a propia en la consulta y en el mantenimiento de las cuentas t?cnicas de reaseguro
  33.0        25/10/2013    KBR             33. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
  34.0        05/11/2013    RCL             34. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
  35.0        11/11/2013    AVT             35. 0028777: Incidencia 28761: POSREA Reaseguro facultativo
  36.0        11/11/2013    SHA             36.0028083: LCOL_A004-0008945: Error en pantalla consulta de reposiciones
  37.0        14/11/2013    DCT             37.0028492: LCOLF3BREA-Revisi?n de los contratos de REASEGURO F3B
  38.0        19/11/2013    RMF             38.0023830: Modificació de f_get_ctatecnica per retornar el sproces en el cas de que la consulta sigui per numero de liquidacio per la reimpresio deldocument
  39.0        19/11/2013    JDS             39.0028493: LCOLF3BREA-Revisi?n interfaces Liquidaci?n Reaseguro F3B
  40.0        02/12/2013    FAL             40.0028827: Resseguro: Reporte de erros e pedidos de esclarecimento
  41.0        21/01/2014    JAM             41.0023830: 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca
  42.0        26/03/2014    KAB             42.0028159: MSV0002 - REA - Numero de riesgo (caso) compa?ia
  43.0        27/03/2014    AGG             43.0030702: POSPG400-POSREA-V.I.REASEGUROS
  44.0        04/04/2014    DCT             44.0030203: LCOL_A004-Qtracker: 8993, 8995, 9865, 8987, 8991 Liquidaci?n de saldos
  45.0        09/04/2014    KBR             45.0030940: NO SE MUESTRA LAS CESIONES A REASEGUROS MODULO DE CONSULTA CESIONES UAT
  46.0        10/04/2014    DCT             45.0029564: LCOL895-Parametrizar Contratos Reaseguro 2014
  47.0        02/05/2014    KBR             47.0025860: (POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 81 - Monitorizacion tasas variables/comisiones
  48.0        13/05/2014    AGG             48.0026622: POSND100-(POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 97 - Comisiones calculadas solo sobre extraprima
  49.0        12/06/2014    AGG             49.0031306: POSDE400-Id 80 - Bono por no reclamación
  50.0        26/06/2014    EDA             50.0031849: QT 13047 Modificación de consultas de reposiciones (177636)
  51.0        18/07/2014    KBR             51. 0030203: LCOL_A004-Qtracker: 8993, 8995, 9865, 8987, 8991 Liquidaci?n de saldos
  52.0        24/07/2014    DCT             52.0032230: LCOL_A004-QT 13572, 13584 y 13616: Validar Límites de Contratos
  53.0        10/09/2014    KBR             53. 0030203: LCOL_A004-Qtracker: 8993, 8995, 9865, 8987, 8991 Liquidaci?n de saldos
  54.0        22/09/2014    MMM             54. 0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales
  55.0        26/09/2014    MMM             54. 0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales
  56.0        26/02/2015    dlF             56. 0032364: Reaseguro - Problemas en la consulta de cesiones
  57.0        13/05/2015    KJSC            57. 33116-189842 Cambiar la select de pac_md_rea.f_get_contratos_rea perque retorni un DISTINCT
  58.0        13/05/2015    KJSC            58. 33116-189843 Ordenar els contractesseleccionats
  59.0        19/11/2015    DCT             59. 0038692: POSPT500-POS REASEGUROS CESIÓN DE VIDA INDIVIDUAL Y COMISIONES SOBRE EXTRA PRIMAS
  60.0        02/09/2016    HRE              60. CONF-250: Se incluye manejo de contratos Q1, Q2, Q3
  61.0        06/21/2019    JRR             61. IAXIS-4481: Se agrega distinct y condición al join entre REARIESGOS y CUAFACUL, para asegurar consulta de cuadros facultativos
  62.0        07/15/2019    FEPP            62 IAXIS-4611:Campo para grabar la prioridad por tramo y el limite por tramo
  63.0        26/01/2020    INFORCOL        63 Reaseguro facultativo - ajuste para deposito en prima retenida
  64.0        26/05/2020    DFRP            64.IAXIS-5361: Modificar el facultativo antes de la emisión
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

---------------------------------------------------------------------------------------------------------------------------------
   PROCEDURE p_agrega_where(p_where IN OUT VARCHAR2, p_add IN VARCHAR2) IS
   BEGIN
      IF p_where IS NOT NULL THEN
         p_where := p_where || ' and ';
      END IF;

      p_where := p_where || p_add;
   END p_agrega_where;

---------------------------------------------------------------------------------------------------------------------------------
   FUNCTION f_get_contratos_rea(
      pscontra IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pctiprea IN NUMBER,
      psconagr IN NUMBER,

      pccompani IN NUMBER,
      pcdevento IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800)   -- 23830/0150483 AVT 06/08/2013  VARCHAR2(200)
         := 'par?metros - pscontra:' || pscontra || ' - pcempres:' || pcempres || ' - pcramo:'
            || pcramo || ' - pcmodali:' || pcmodali || ' - pctipseg:' || pctipseg
            || ' - pccolect:' || pccolect || ' - pcactivi:' || pcactivi || ' - pcgarant:'
            || pcgarant || ' - pctiprea:' || pctiprea || ' - psconagr:' || psconagr
            || ' - pccompani:' || pccompani || ' - pcdevento:' || pcdevento;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_Contratos_Rea';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      v_max_reg      NUMBER := f_parinstalacion_n('N_MAX_REG');
      -- n?mero m?xim de registres mostrats
      v_where        VARCHAR2(4000);
   BEGIN
      -- Bug 18319 - APD  - 05/07/2011 - se a?aden los campos cmoneda, tmoneda y descripcion
      vsquery :=

         --BUG 33116-189842 KJSC 13/05/2015 Cambiar la select de pac_md_rea.f_get_contratos_rea perque retorni un DISTINCT
         --'SELECT c.scontra, (select tempres from empresas where cempres = c.cempres) as tempres,-- AVT PROV.CONCEPTE-GEN_V 07/10/2014
         'SELECT DISTINCT c.scontra, (select tempres from empresas where cempres = c.cempres) as tempres,
                         a.cramo||''-''||a.cmodali||''-''||a.ctipseg||''-''||a.ccolect||''. ''||
                         decode(a.ccolect,
                                      null, (SELECT tramo FROM RAMOS WHERE cidioma = '
         || vidioma
         || ' AND cramo = a.cramo) ,
                                      f_desproducto_t(a.cramo, a.cmodali, a.ctipseg, a.ccolect, 1, '
         || vidioma
         || ')) tproduc,
                         decode(cactivi, null, null, cactivi||''.-''||(SELECT tactivi FROM ACTIVISEGU WHERE cidioma = '
         || vidioma
         || ' AND cramo = a.cramo AND cactivi = a.cactivi)) as tactivi,
                         decode(cgarant, null, null, cgarant||''.-''||(SELECT tgarant FROM GARANGEN WHERE cidioma = '
         || vidioma
         || ' AND cgarant = a.cgarant)) as tgarant,
                         ff_desvalorfijo (106, '
         || vidioma
         || ', c.ctiprea) tctiprea,
                         decode(c.sconagr, null, null, c.sconagr||''-''||(select tconagr from descontratosagr where sconagr = c.sconagr and cidioma = '
         || vidioma || ')) TCONAGR, '
         || ' c.cmoneda,
         (SELECT TMONEDA FROM eco_desmonedas WHERE cmoneda = c.cmoneda and cidioma= '
         || vidioma || ')  tmoneda, cdevento'
         || ' tdescripcion, cvalid
                  FROM codicontratos c, agr_contratos a';
      -- Fin Bug 18319 - APD  - 05/07/2011
      vpasexec := 2;
      -- BUG 15190 - 28/06/2010 - ETM - CRE800 - Consulta de Contractes
      p_agrega_where(v_where, ' where c.scontra = a.scontra(+)');

      -- fin BUG 15190 - 28/06/2010 - ETM - CRE800 - Consulta de Contractes
      IF pscontra IS NOT NULL THEN
         p_agrega_where(v_where, 'c.scontra = ' || pscontra);
      END IF;

      IF pcempres IS NOT NULL THEN
         p_agrega_where(v_where, 'c.cempres = ' || pcempres);
      END IF;

      IF pcramo IS NOT NULL THEN
         p_agrega_where(v_where, 'a.cramo = ' || pcramo);
      END IF;

      IF pcmodali IS NOT NULL THEN
         p_agrega_where(v_where, 'a.cmodali = ' || pcmodali);
      END IF;

      IF pctipseg IS NOT NULL THEN
         p_agrega_where(v_where, 'a.ctipseg = ' || pctipseg);
      END IF;

      IF pccolect IS NOT NULL THEN
         p_agrega_where(v_where, 'a.ccolect = ' || pccolect);
      END IF;

      IF pcactivi IS NOT NULL THEN
         p_agrega_where(v_where, 'a.cactivi = ' || pcactivi);
      END IF;

      IF pcgarant IS NOT NULL THEN
         p_agrega_where(v_where, 'a.cgarant = ' || pcgarant);
      END IF;

      IF pctiprea IS NOT NULL THEN
         p_agrega_where(v_where, 'c.ctiprea = ' || pctiprea);
      END IF;

      IF pcgarant IS NOT NULL THEN
         p_agrega_where(v_where, 'a.cgarant = ' || pcgarant);
      END IF;

      IF psconagr IS NOT NULL THEN
         p_agrega_where(v_where, 'c.sconagr = ' || psconagr);
      END IF;

      IF pcdevento IS NOT NULL THEN
         p_agrega_where(v_where, 'c.cdevento = ' || pcdevento);
      END IF;

      IF pccompani IS NOT NULL THEN
         p_agrega_where(v_where,
                        'exists (select 1 from cuadroces where CCOMPANI = ' || pccompani
                        || ' and SCONTRA = c.scontra)');
      END IF;

      vpasexec := 3;

      IF v_max_reg IS NOT NULL THEN
         IF INSTR(vsquery, 'order by', -1, 1) > 0 THEN
            -- se hace de esta manera para mantener el orden de los registros
            vsquery := 'select * from (' || vsquery || ') where rownum <= ' || v_max_reg;
         ELSE
            p_agrega_where(v_where, 'rownum <= ' || v_max_reg);
         END IF;
      END IF;

      vsquery := vsquery || v_where;
      --33116-189843  KJSC Ordenar los contratos por scontra
      vsquery := vsquery || ' order by c.scontra';
      -- fin BUG 15190 - 28/06/2010 - ETM - CRE800 - Consulta de Contractes
      vpasexec := 4;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 5;

      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 6;
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_contratos_rea;

---------------------------------------------------------------------------------------------------------------------------------
   FUNCTION f_get_contratos_rea(
      pscontra IN NUMBER,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pctiprea IN NUMBER,
      psconagr IN NUMBER,
      pccompani IN NUMBER,
      pcdevento IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800)   -- 23830/0150483 AVT 06/08/2013  VARCHAR2(200)
         := 'par?metros - pscontra:' || pscontra || ' - pcempres:' || pcempres
            || ' - psproduc:' || psproduc || ' - pcactivi:' || pcactivi || ' - pcgarant:'
            || pcgarant || ' - pctiprea:' || pctiprea || ' - psconagr:' || psconagr
            || ' - pccompani:' || pccompani;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_Contratos_Rea(sproduc)';
      vcursor        sys_refcursor;
      verror         NUMBER := 0;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
   BEGIN
      IF psproduc IS NOT NULL THEN
         verror := f_def_producto(psproduc, vcramo, vcmodali, vctipseg, vccolect);

         IF verror != 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      vcursor := f_get_contratos_rea(pscontra, pcempres, vcramo, vcmodali, vctipseg, vccolect,
                                     pcactivi, pcgarant, pctiprea, psconagr, pccompani,
                                     pcdevento, mensajes);

      IF NOT vcursor%ISOPEN THEN
         RAISE e_object_error;
      END IF;

      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_contratos_rea;

---------------------------------------------------------------------------------------------------------------------------------
   FUNCTION f_get_version_rea(pscontra IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'par?metros - pscontra:' || pscontra;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_Version_Rea';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      v_max_reg      NUMBER := f_parinstalacion_n('N_MAX_REG');
   -- n?mero m?xim de registres mostrats
   BEGIN
      IF pscontra IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vsquery :=
         'SELECT c.scontra, c.nversio, cd.cempres,
                         f_desproducto_t (cd.cramo, cd.cmodali, cd.ctipseg, cd.ccolect, 1,  '
         || vidioma
         || ') tsproduc,
                         c.fconini, c.fconfin, cd.cactivi, cd.cgarant, c.pcomext
                         FROM codicontratos cd, contratos c, agr_contratos a
                         WHERE cd.scontra = a.scontra(+) AND cd.scontra = c.scontra AND cd.scontra = '
         || pscontra;
      vpasexec := 3;

      IF v_max_reg IS NOT NULL THEN
         IF INSTR(vsquery, 'order by', -1, 1) > 0 THEN
            -- se hace de esta manera para mantener el orden de los registros
            vsquery := 'select * from (' || vsquery || ') where rownum <= ' || v_max_reg;
         ELSE
            vsquery := vsquery || ' and rownum <= ' || v_max_reg;
         END IF;
      END IF;

      vpasexec := 4;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 5;

      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 6;
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_version_rea;

---------------------------------------------------------------------------------------------------------------------------------
   FUNCTION f_get_detallecab_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_codicontrato_rea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'par?metros - pscontra:' || pscontra;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_DetalleCab_Rea';
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      vretorno       ob_iax_codicontrato_rea := ob_iax_codicontrato_rea();
      vcursor        sys_refcursor;
   BEGIN
      IF pscontra IS NULL THEN
         -- Error en los par?metros
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      -- OB_IAX_CODICONTRATO_REA
      -- Bug 18319 - APD  - 05/07/2011 - se a?aden los campos cmoneda, tmoneda y descripcion
      vsquery :=
         'SELECT c.scontra, c.spleno, cempres, (select tempres from empresas where cempres = c.cempres) as tempres,
                         ctiprea, ff_desvalorfijo (106, '
         || vidioma || ', c.ctiprea) tctiprea,'
         ||   --finictr,
           'cramo, cmodali, ctipseg, ccolect,
                         decode(a.ccolect,
                                   null, (SELECT tramo FROM RAMOS WHERE cidioma = '
         || vidioma
         || ' AND cramo = a.cramo) ,
                                   f_desproducto_t(a.cramo, a.cmodali, a.ctipseg, a.ccolect, 1, '
         || vidioma
         || ')) tproduc,
                         cactivi, (SELECT tactivi FROM ACTIVISEGU WHERE cidioma = '
         || vidioma
         || ' AND cramo = a.cramo AND cactivi = a.cactivi) as tactivi,
                         cgarant, (SELECT tgarant FROM GARANGEN WHERE cidioma = '
         || vidioma || ' AND cgarant = a.cgarant) as tgarant,'
         ||   --ffinctr, nconrel, sconagr,
           'cvidaga, ff_desvalorfijo (161, ' || vidioma
         || ', cvidaga) tvidaga, CTIPCUM, ff_desvalorfijo (225, ' || vidioma
         || ', ctipcum) TTIPCUM, SCONAGR,
         (SELECT TCONAGR FROM descontratosagr WHERE sconagr = c.sconagr and cidioma= '
         || vidioma || ')  TCONAGR, '
         || ' c.cmoneda,
         (SELECT TMONEDA FROM eco_desmonedas WHERE cmoneda = c.cmoneda and cidioma= '
         || vidioma || ')  tmoneda, '
         || ' tdescripcion, cvalid, cdevento
                  FROM codicontratos c, agr_contratos a
                  WHERE c.scontra = a.scontra(+) AND c.scontra = '
         || pscontra;
      -- fin Bug 18319 - APD  - 05/07/2011
      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         -- Se ha producido un error en PAC_MD_LOG.F_LOG_CONSULTAS
         RAISE e_object_error;
      END IF;

      IF NOT vcursor%ISOPEN THEN
         vpasexec := 5;
         -- Se ha producido un error en PAC_IAX_LISTVALORES.F_Opencursor
         RAISE e_object_error;
      ELSE
         vpasexec := 6;

         -- Bug 18319 - APD  - 05/07/2011 - se a?aden los campos cmoneda, tmoneda y descripcion
         FETCH vcursor
          INTO vretorno.scontra, vretorno.spleno, vretorno.cempres, vretorno.tempres,
               vretorno.ctiprea, vretorno.ttiprea,
                                                  --vretorno.finictr,
                                                  vretorno.cramo, vretorno.cmodali,
               vretorno.ctipseg, vretorno.ccolect, vretorno.tproduc, vretorno.cactivi,
               vretorno.tactivi, vretorno.cgarant, vretorno.tgarant,
                                                                    --vretorno.ffinctr,

                                                                    --vretorno.nconrel, vretorno.sconagr,
                                                                    vretorno.cvidaga,
               vretorno.tvidaga, vretorno.ctipcum, vretorno.ttipcum, vretorno.sconagr,
               vretorno.tconagr, vretorno.cmoneda, vretorno.tmoneda, vretorno.tdescripcion,
               vretorno.cvalid, vretorno.cdevento;

         -- Fin Bug 18319 - APD  - 05/07/2011
         vpasexec := 7;

         --p_tab_error (f_sysdate,f_USER,'PAC_MD_REA', 1, 'vretorno.cvidaga : '||vretorno.cvidaga||' vretorno.tvidaga : '||vretorno.tvidaga,sqlerrm);
         IF vcursor%NOTFOUND THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000624);
         ELSE
            vretorno.contratos := f_get_contratos_rea(vretorno.scontra, pnversio, mensajes);
         END IF;
      END IF;

      vpasexec := 9;
      RETURN vretorno;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RAISE;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RAISE;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RAISE;
   END f_get_detallecab_rea;

---------------------------------------------------------------------------------------------------------------------------------
   FUNCTION f_get_contratos_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_contrato_rea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                           := 'par?metros - pscontra:' || pscontra || ' pnversio:' || pnversio;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_Contratos_Rea';
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      vcontratos     t_iax_contrato_rea;
      vobjcontrato   ob_iax_contrato_rea;
      vcursor        sys_refcursor;
   BEGIN
      IF pscontra IS NULL THEN
         -- Error en los par?metros
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      -- Bug 18319 - APD - 05/07/2011 - se a?aden los campos CLAVECBR, CERCARTERA,
      -- IPRIMAESPERADAS, NANYOSLOSS, CBASEXL, CLOSSCORRIDOR, CCAPPEDRATIO, SCONTRAPROT, CESTADO
     -- INI EDBR - 11/06/2019 - IAXIS3338 - se agrega campos de Retencion por poliza NRETPOL y Retencion por Cumulo NRETCUL
      vsquery :=
         'SELECT SCONTRA, NVERSIO, NPRIORI, FCONINI, NCONREL, ' || --CONF-910
                         'DECODE(FCONINI, FCONFIN, NVL(FCONFINAUX, FCONFIN), NVL(FCONFIN, FCONFINAUX)) FCONFIN, IAUTORI, ' || --CONF-910
                         'IRETENC, IMINCES, ICAPACI, IPRIOXL, PPRIOSL, TCONTRA, TOBSERV,
                         PCEDIDO, PRIESGOS, PDESCUENTO, PGASTOS, PPARTBENE, CREAFAC, PCESEXT,
                         CGARREL, CFRECUL, SCONQP, NVERQP, IAGREGA, IMAXAGR,
                         CLAVECBR, CERCARTERA, ff_desvalorfijo (828, '
         || vidioma
         || ', cercartera) TERCARTERA, IPRIMAESPERADAS, NANYOSLOSS,
                         CBASEXL, ff_desvalorfijo (341, '
         || vidioma
         || ', cbasexl) TBASEXL, CLOSSCORRIDOR, (SELECT tdescripcion FROM clausulas_reas WHERE ccodigo = CLOSSCORRIDOR and cidioma= '
         || vidioma
         || ') TLOSSCORRIDOR,
                         CCAPPEDRATIO, (SELECT tdescripcion FROM clausulas_reas WHERE ccodigo = CCAPPEDRATIO and cidioma= '
         || vidioma
         || ') TCAPPEDRATIO, SCONTRAPROT, (SELECT cc.scontra||''-''||tdescripcion||''/''||c.nversioprot FROM codicontratos cc WHERE c.scontraprot = cc.scontra) TSCONTRAPROT, CESTADO, NVERSIOPROT, pcomext, NRETPOL, NRETCUL
                  FROM contratos c
                  WHERE scontra = '
         || pscontra;
		-- FIN EDBR - 11/06/2019 - IAXIS3338 - se agrega campos de Retencion por poliza NRETPOL y Retencion por Cumulo NRETCUL

      -- Fin Bug 18319 - APD - 05/07/2011
      IF pnversio IS NOT NULL THEN
         vsquery := vsquery || ' and nversio = ' || pnversio;
      END IF;

      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         -- Se ha producido un error en PAC_MD_LOG.F_LOG_CONSULTAS
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      IF NOT vcursor%ISOPEN THEN
         -- Se ha producido un error en  PAC_IAX_LISTVALORES.F_Opencursor
         RAISE e_object_error;
      ELSE
         vcontratos := t_iax_contrato_rea();
         vpasexec := 6;

         LOOP
            vobjcontrato := ob_iax_contrato_rea();
            vpasexec := 6.1;

            -- Bug 18319 - APD - 05/07/2011 - se a?aden los campos CLAVECBR, CERCARTERA,
            -- IPRIMAESPERADAS, NANYOSLOSS, CBASEXL, CLOSSCORRIDOR, CCAPPEDRATIO, SCONTRAPROT, CESTADO
            FETCH vcursor
             INTO vobjcontrato.scontra, vobjcontrato.nversio, vobjcontrato.npriori,
                  vobjcontrato.fconini, vobjcontrato.nconrel, vobjcontrato.fconfin,
                  vobjcontrato.iautori, vobjcontrato.iretenc, vobjcontrato.iminces,
                  vobjcontrato.icapaci, vobjcontrato.iprioxl, vobjcontrato.ppriosl,
                  vobjcontrato.tcontra, vobjcontrato.tobserv, vobjcontrato.pcedido,
                  vobjcontrato.priesgos, vobjcontrato.pdescuento, vobjcontrato.pgastos,
                  vobjcontrato.ppartbene, vobjcontrato.creafac, vobjcontrato.pcesext,
                  vobjcontrato.cgarrel, vobjcontrato.cfrecul, vobjcontrato.sconqp,
                  vobjcontrato.nverqp, vobjcontrato.iagrega, vobjcontrato.imaxagr,
                  vobjcontrato.clavecbr, vobjcontrato.cercartera, vobjcontrato.tercartera,
                  vobjcontrato.iprimaesperadas, vobjcontrato.nanyosloss, vobjcontrato.cbasexl,
                  vobjcontrato.tbasexl, vobjcontrato.closscorridor_con,
                  vobjcontrato.tlosscorridor_con, vobjcontrato.ccappedratio_con,
                  vobjcontrato.tcappedratio_con, vobjcontrato.scontraprot,
                  vobjcontrato.tscontraprot, vobjcontrato.cestado, vobjcontrato.nversioprot,
                  vobjcontrato.pcomext, vobjcontrato.nretpol, vobjcontrato.nretcul; -- EDBR - 11/06/2019 - IAXIS3338 - se agrega campos de Retencion por poliza NRETPOL y Retencion por Cumulo NRETCUL al cursor

            -- Fin Bug 18319 - APD - 05/07/2011
            vpasexec := 6.2;

            IF vcursor%NOTFOUND THEN
               EXIT;
            END IF;

            vpasexec := 6.3;
            vobjcontrato.ttramos := f_get_tramos_rea(vobjcontrato.scontra,
                                                     vobjcontrato.nversio, mensajes);
            vpasexec := 6.4;
            vcontratos.EXTEND;
            vcontratos(vcontratos.LAST) := vobjcontrato;
            vpasexec := 6.5;
         END LOOP;

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 7;
      RETURN vcontratos;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RAISE;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RAISE;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RAISE;
   END f_get_contratos_rea;

---------------------------------------------------------------------------------------------------------------------------------
   FUNCTION f_get_detalle_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_contrato_rea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                         := 'par?metros - pscontra:' || pscontra || ' - pnversio:' || pnversio;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_Detalle_Rea';
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      vretorno       ob_iax_contrato_rea := ob_iax_contrato_rea();
      vcursor        sys_refcursor;
   BEGIN
      p_tab_error(f_sysdate, f_user, 'pac_md_rea.f_get_detalle_rea', 852,
                  'entra f_get_detalle_rea', NULL);

      IF pscontra IS NULL
         OR pnversio IS NULL THEN
         -- Error en los par?metros
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      -- OB_IAX_CONTRATO_REA
      -- Bug 18319 - APD - 05/07/2011 - se a?aden los campos CLAVECBR, CERCARTERA,
      -- IPRIMAESPERADAS, NANYOSLOSS, CBASEXL, CLOSSCORRIDOR, CCAPPEDRATIO, SCONTRAPROT, CESTADO
      -- INI EDBR - 11/06/2019 - IAXIS3338 - se agrega campos de Retencion por poliza NRETPOL y Retencion por Cumulo NRETCUL
      vsquery :=
         'SELECT scontra, nversio, npriori, fconini, nconrel, fconfin, iautori,iretenc,
                         iminces, icapaci iprioxl, ppriosl, tcontra, tobserv, pcedido,
                         priesgos, pdescuento, pgastos, ppartbene, creafac, pcesext, cgarrel,
                         cfrecul, sconqp, nverqp, iagrega, imaxagr, CLAVECBR, CERCARTERA, ff_desvalorfijo (828, '
         || vidioma
         || ', cercartera) TERCARTERA, IPRIMAESPERADAS, NANYOSLOSS,
                         CBASEXL, ff_desvalorfijo (341, '
         || vidioma
         || ', cbasexl) TBASEXL, CLOSSCORRIDOR, (SELECT tdescripcion FROM clausulas_reas WHERE ccodigo = CLOSSCORRIDOR and cidioma= '
         || vidioma
         || ') TLOSSCORRIDOR,
                         CCAPPEDRATIO, (SELECT tdescripcion FROM clausulas_reas WHERE ccodigo = CCAPPEDRATIO and cidioma= '
         || vidioma
         || ') TCAPPEDRATIO, SCONTRAPROT, (SELECT cc.scontra||''-''||tdescripcion||''/''||c.nversioprot FROM codicontratos cc WHERE c.scontraprot = cc.scontra) TSCONTRAPROT, CESTADO, NVERSIOPROT, PCOMEXT, nretpol, nretcul,
                  FROM contratos c
                  WHERE scontra = '
         || pscontra || ' AND nversio = ' || pnversio;
		 -- FIN EDBR - 11/06/2019 - IAXIS3338 - se agrega campos de Retencion por poliza NRETPOL y Retencion por Cumulo NRETCUL
      -- Fin Bug 18319 - APD - 05/07/2011
      vpasexec := 8.1;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 8.2;

      -- Se guarda el log de la consulta.
      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         -- Se ha producido un error al guardar el log de la consulta.
         RAISE e_object_error;
      END IF;

      IF NOT vcursor%ISOPEN THEN
         vpasexec := 8.3;
         -- Se ha producido un error en PAC_IAX_LISTVALORES.F_Opencursor
         RAISE e_object_error;
      ELSE
         vpasexec := 8.4;
         vpasexec := 8.5;

         -- Bug 18319 - APD - 05/07/2011 - se a?aden los campos CLAVECBR, CERCARTERA,
         -- IPRIMAESPERADAS, NANYOSLOSS, CBASEXL, CLOSSCORRIDOR, CCAPPEDRATIO, SCONTRAPROT, CESTADO

         --AGG 13/05/2014 Se añade el campo comisión de la extra prima, visible solo para POSITIVA
         FETCH vcursor
          INTO vretorno.scontra, vretorno.nversio, vretorno.npriori, vretorno.fconini,
               vretorno.nconrel, vretorno.fconfin, vretorno.iautori, vretorno.iretenc,
               vretorno.iminces, vretorno.icapaci, vretorno.iprioxl, vretorno.ppriosl,
               vretorno.tcontra, vretorno.tobserv, vretorno.pcedido, vretorno.priesgos,
               vretorno.pdescuento, vretorno.pgastos, vretorno.ppartbene, vretorno.creafac,
               vretorno.pcesext, vretorno.cgarrel, vretorno.cfrecul, vretorno.sconqp,
               vretorno.nverqp, vretorno.iagrega, vretorno.imaxagr, vretorno.clavecbr,
               vretorno.cercartera, vretorno.tercartera, vretorno.iprimaesperadas,
               vretorno.nanyosloss, vretorno.cbasexl, vretorno.tbasexl,
               vretorno.closscorridor_con, vretorno.tlosscorridor_con,
               vretorno.ccappedratio_con, vretorno.tcappedratio_con, vretorno.scontraprot,
               vretorno.tscontraprot, vretorno.cestado, vretorno.nversioprot,
               vretorno.pcomext, vretorno.nretpol, vretorno.nretcul; -- EDBR - 11/06/2019 - IAXIS3338 - se agrega campos de Retencion por poliza NRETPOL y Retencion por Cumulo NRETCUL AL CURSOR

         -- Fin Bug 18319 - APD - 05/07/2011
         p_tab_error(f_sysdate, f_user, 'pac_md_rea.f_get_detalle_rea', 852,
                     'pcomext: ' || vretorno.pcomext, NULL);
         vpasexec := 8.7;

         IF vcursor%NOTFOUND THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000625);
         ELSE
            -- OB_IAX_TRAMOS_REA
            vretorno.ttramos := f_get_tramos_rea(pscontra, pnversio, mensajes);
         END IF;

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 9;
      RETURN vretorno;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RAISE;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RAISE;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RAISE;
   END f_get_detalle_rea;

---------------------------------------------------------------------------------------------------------------------------------
   FUNCTION f_get_tramos_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_tramos_rea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                         := 'par?metros - pscontra:' || pscontra || ' - pnversio:' || pnversio;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_Tramos_Rea';
      vsquery        VARCHAR2(9000);
      vtramos        t_iax_tramos_rea;
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      vobjtramos     ob_iax_tramos_rea;
      vcursor        sys_refcursor;
      --INI BUG CONF-250  Fecha (02/09/2016) - HRE - manejo de contratos Q1, Q2, Q3
      v_tiprea        codicontratos.ctiprea%TYPE;--
      v_valor         detvalores.cvalor%TYPE;
      --FIN BUG CONF-250  - Fecha (02/09/2016) - HRE
   BEGIN
      IF pscontra IS NULL
         OR pnversio IS NULL THEN
         -- Error en los par?metros
         RAISE e_param_error;
      END IF;

      --INI BUG CONF-250  Fecha (02/09/2016) - HRE - manejo de contratos Q1, Q2, Q3
      SELECT ctiprea
        INTO v_tiprea
        FROM codicontratos
       WHERE scontra = pscontra;

      IF (v_tiprea = 5) THEN
         v_valor := 8002002;
      ELSE
         v_valor := 105;
      END IF;
      --FIN BUG CONF-250  - Fecha (02/09/2016) - HRE

      vpasexec := 2;
      -- Bug 18319 - APD - 06/07/2011 - se a?aden los campos
      -- IDAA, ILAA, CTPRIMAXL, IPRIMAFIJAXL, IPRIMAESTIMADA, CAPLICTASAXL, '
      -- CTIPTASAXL, CTRAMOTASAXL, PCTPDXL, CFORPAGPDXL, PCTMINXL, PCTPB, '
      -- NANYOSLOSS, CLOSSCORRIDOR, CAPPEDRATIO, CREPOS, '
      -- IBONOREC, IMPAVISO, IMPCONTADO, PCTCONTADO, PCTDEP, CFORPAGDEP, '
      -- INTDEP, PCTGASTOS, PTASAAJUSTE, ICAPCOASEG
      -- 21829 04/04/2012 AVT es canvia el 113 de TFREPMD per VF=17
      vsquery :=
         'SELECT nversio, scontra, ctramo, ff_desvalorfijo ('||v_valor||', ' || vidioma--BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
         || ', ctramo) ttramo,
                         itottra, nplenos, cfrebor, plocal, ixlprio, ixlexce, pslprio,
                         pslexce, ncesion, fultbor, imaxplo, norden, nsegcon, nsegver, iminxl, idepxl, nctrxl,
                         nverxl, ptasaxl, ipmd, cfrepmd, ff_desvalorfijo (17, '
         || vidioma || ', cfrepmd) tfrepmd, caplixl, plimgas, pliminx, ff_desvalorfijo (113, '
         || vidioma || ', cfrebor) tfrebor, '
         || ' IDAA, ILAA, CTPRIMAXL, ff_desvalorfijo (342, ' || vidioma
         || ', ctprimaxl) ttprimaxl, IPRIMAFIJAXL, IPRIMAESTIMADA, CAPLICTASAXL, ff_desvalorfijo (343, '
         || vidioma || ', caplictasaxl) taplictasaxl, '
         || ' CTIPTASAXL, ff_desvalorfijo (344, ' || vidioma
         || ', ctiptasaxl) ttiptasaxl, CTRAMOTASAXL, (SELECT tdescripcion FROM clausulas_reas WHERE ccodigo = CTRAMOTASAXL and cidioma= '
         || vidioma || ') ttramotasaxl, PCTPDXL, ' || ' CFORPAGPDXL, ff_desvalorfijo (113, '
         || vidioma || ', CFORPAGPDXL) tforpagpdxl, PCTMINXL, PCTPB, '
         || ' NANYOSLOSS, CLOSSCORRIDOR, (SELECT tdescripcion FROM clausulas_reas WHERE ccodigo = CLOSSCORRIDOR and cidioma= '
         || vidioma || ') tlosscorridor, '
         || ' cCAPPEDRATIO, (SELECT tdescripcion FROM clausulas_reas WHERE ccodigo = cCAPPEDRATIO and cidioma= '
         || vidioma
         || ') tcappedratio, CREPOS, (SELECT tdescripcion FROM reposiciones WHERE ccodigo = CREPOS and cidioma= '
         || vidioma
         || ') trepos, (SELECT COUNT(norden) FROM reposiciones_det WHERE ccodigo = crepos) nrepos, '
         || ' IBONOREC, IMPAVISO, IMPCONTADO, PCTCONTADO, PCTGASTOS, PTASAAJUSTE, ICAPCOASEG, ICOSTOFIJO, PCOMISINTERM, PTRAMO,IPRIO 
                  FROM tramos
                  WHERE scontra = '
         || pscontra || ' AND nversio = ' || pnversio; --BUG CONF-250  Fecha (02/09/2016) - HRE - se adiciona PTRAMO a vsquery
      -- 26/06/2014 EDA Bug: 31849/177636 nrepos Numero reposicion
      -- fIN Bug 18319 - APD - 06/07/2011
      --Se  agrega campo IPRIO IAXIS-4611
      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         -- Se ha producido un error en PAC_MD_LOG.F_LOG_CONSULTAS
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      IF NOT vcursor%ISOPEN THEN
         -- Se ha producido un error en  PAC_IAX_LISTVALORES.F_Opencursor
         RAISE e_object_error;
      ELSE
         vtramos := t_iax_tramos_rea();
         vpasexec := 6;

         LOOP
            vobjtramos := ob_iax_tramos_rea();
            vpasexec := 6.1;

            -- Bug 18319 - APD - 06/07/2011 - se a?aden los campos
            -- IDAA, ILAA, CTPRIMAXL, IPRIMAFIJAXL, IPRIMAESTIMADA, CAPLICTASAXL, '
            -- CTIPTASAXL, CTRAMOTASAXL, PCTPDXL, CFORPAGPDXL, PCTMINXL, PCTPB, '
            -- NANYOSLOSS, CLOSSCORRIDOR, CAPPEDRATIO, CREPOS, '
            -- IBONOREC, IMPAVISO, IMPCONTADO, PCTCONTADO, PCTDEP, CFORPAGDEP, '
            -- INTDEP, PCTGASTOS, PTASAAJUSTE, ICAPCOASEG
            FETCH vcursor
             INTO vobjtramos.nversio, vobjtramos.scontra, vobjtramos.ctramo,
                  vobjtramos.ttramo, vobjtramos.itottra, vobjtramos.nplenos,
                  vobjtramos.cfrebor, vobjtramos.plocal, vobjtramos.ixlprio,
                  vobjtramos.ixlexce, vobjtramos.pslprio, vobjtramos.pslexce,
                  vobjtramos.ncesion, vobjtramos.fultbor, vobjtramos.imaxplo,
                  vobjtramos.norden, vobjtramos.nsegcon, vobjtramos.nsegver,
                  vobjtramos.iminxl, vobjtramos.idepxl, vobjtramos.nctrxl, vobjtramos.nverxl,
                  vobjtramos.ptasaxl, vobjtramos.ipmd, vobjtramos.cfrepmd, vobjtramos.tfrepmd,
                  vobjtramos.caplixl, vobjtramos.plimgas, vobjtramos.pliminx,
                  vobjtramos.tfrebor, vobjtramos.idaa, vobjtramos.ilaa, vobjtramos.ctprimaxl,
                  vobjtramos.ttprimaxl, vobjtramos.iprimafijaxl, vobjtramos.iprimaestimada,
                  vobjtramos.caplictasaxl, vobjtramos.taplictasaxl, vobjtramos.ctiptasaxl,
                  vobjtramos.ttiptasaxl, vobjtramos.ctramotasaxl, vobjtramos.ttramotasaxl,
                  vobjtramos.pctpdxl, vobjtramos.cforpagpdxl, vobjtramos.tforpagpdxl,
                  vobjtramos.pctminxl, vobjtramos.pctpb, vobjtramos.nanyosloss,
                  vobjtramos.closscorridor, vobjtramos.tlosscorridor, vobjtramos.ccappedratio,
                  vobjtramos.tcappedratio, vobjtramos.crepos, vobjtramos.trepos,
                  vobjtramos.nrepos, vobjtramos.ibonorec, vobjtramos.impaviso,
                  vobjtramos.impcontado, vobjtramos.pctcontado, vobjtramos.pctgastos,
                  vobjtramos.ptasaajuste, vobjtramos.icapcoaseg, vobjtramos.icostofijo,
                  vobjtramos.pcomisinterm, vobjtramos.ptramo,vobjtramos.iprio/*, vobjtramos.narrastrecont*/; --BUG CONF-250  Fecha (02/09/2016) - HRE - se adiciona PTRAMO a vobjtramos

            -- 26/06/2014 EDA Bug: 31849/177636 Se añade nrepos (Numero de reposiciones)
            --AGG 04/06/2014 31306/0176671 Se añaden los campos ICOSTOFIJO, PCOMISINTERM
            -- fIN Bug 18319 - APD - 06/07/2011
            --Se agrega campo IPRIO IAXIS-4611 campo  prioridad del tramo.
            vpasexec := 6.2;

            IF vcursor%NOTFOUND THEN
               EXIT;
            END IF;

            vpasexec := 6.3;
            vobjtramos.cuadroces := f_get_cuadroces_rea(vobjtramos.scontra, vobjtramos.nversio,
                                                        vobjtramos.ctramo, mensajes);
            vpasexec := 6.4;
            vobjtramos.tramosinbono := f_get_tramo_sin_bono(vobjtramos.scontra,
                                                            vobjtramos.nversio,
                                                            vobjtramos.ctramo, mensajes);
            vpasexec := 6.5;
            vtramos.EXTEND;
            vtramos(vtramos.LAST) := vobjtramos;
            vpasexec := 6.6;
         END LOOP;

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 7;
      RETURN vtramos;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RAISE;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RAISE;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RAISE;
   END f_get_tramos_rea;

---------------------------------------------------------------------------------------------------------------------------------
   FUNCTION f_get_dettramo_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_tramos_rea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'par?metros - pscontra:' || pscontra || ' - pnversio:' || pnversio
            || ' - pctramo:' || pctramo;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_DetTramo_Rea';
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      vcursor        sys_refcursor;
      vobjtramo      ob_iax_tramos_rea := ob_iax_tramos_rea();
   BEGIN
      IF pscontra IS NULL
         OR pnversio IS NULL
         OR pctramo IS NULL THEN
         -- Error en los par?metros.
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      -- Bug 18319 - APD - 06/07/2011 - se a?aden los campos
      -- IDAA, ILAA, CTPRIMAXL, IPRIMAFIJAXL, IPRIMAESTIMADA, CAPLICTASAXL, '
      -- CTIPTASAXL, CTRAMOTASAXL, PCTPDXL, CFORPAGPDXL, PCTMINXL, PCTPB, '
      -- NANYOSLOSS, CLOSSCORRIDOR, CAPPEDRATIO, CREPOS, '
      -- IBONOREC, IMPAVISO, IMPCONTADO, PCTCONTADO, PCTDEP, CFORPAGDEP, '
      -- INTDEP, PCTGASTOS, PTASAAJUSTE, ICAPCOASEG
      -- 21829 04/04/2012 AVT es canvia el 113 de TFREPMD per VF=17

      --AGG 04/06/2014 Se añaden los campos ICOSTOFIJO, PCOMISINTERM
      vsquery :=
         'SELECT nversio, scontra, ctramo, ff_desvalorfijo (105, ' || vidioma
         || ', ctramo) ttramo,
                         itottra, nplenos, cfrebor, plocal, ixlprio, ixlexce, pslprio,
                         pslexce, ncesion, fultbor, imaxplo, norden, nsegcon, nsegver, iminxl, idepxl, nctrxl,
                         nverxl, ptasaxl, ipmd, cfrepmd, ff_desvalorfijo (17, '
         || vidioma || ', cfrepmd) tfrepmd, caplixl, plimgas, pliminx, ff_desvalorfijo (113, '
         || vidioma || ', cfrebor) tfrebor, '
         || ' IDAA, ILAA, CTPRIMAXL, ff_desvalorfijo (342, ' || vidioma
         || ', ctprimaxl) ttprimaxl, IPRIMAFIJAXL, IPRIMAESTIMADA, CAPLICTASAXL, ff_desvalorfijo (343, '
         || vidioma || ', caplictasaxl) taplictasaxl, '
         || ' CTIPTASAXL, ff_desvalorfijo (344, ' || vidioma
         || ', ctiptasaxl) ttiptasaxl, CTRAMOTASAXL, (SELECT tdescripcion FROM clausulas_reas WHERE ccodigo = CTRAMOTASAXL and cidioma= '
         || vidioma || ') ttramotasaxl, PCTPDXL, ' || ' CFORPAGPDXL, ff_desvalorfijo (113, '
         || vidioma || ', CFORPAGPDXL) tforpagpdxl, PCTMINXL, PCTPB, '
         || ' NANYOSLOSS, CLOSSCORRIDOR, (SELECT tdescripcion FROM clausulas_reas WHERE ccodigo = CLOSSCORRIDOR and cidioma= '
         || vidioma || ') tlosscorridor, '
         || ' cCAPPEDRATIO, (SELECT tdescripcion FROM clausulas_reas WHERE ccodigo = cCAPPEDRATIO and cidioma= '
         || vidioma
         || ') tcappedratio, CREPOS, (SELECT tdescripcion FROM reposiciones WHERE ccodigo = CREPOS and cidioma= '
         || vidioma || ') trepos, '
         || ' IBONOREC, IMPAVISO, IMPCONTADO, PCTCONTADO, PCTGASTOS, PTASAAJUSTE, PTRAMO, PREEST,ICAPCOASEG, ICOSTOFIJO, PCOMISINTERM,IPRIO
                  FROM tramos
                  WHERE scontra = '
         || pscontra || ' AND nversio = ' || pnversio || ' and ctramo = ' || pctramo;--BUG CONF-250  Fecha (02/09/2016) - HRE - se adiciona PTRAMO a vsquery
      -- fIN Bug 18319 - APD - 06/07/2011
      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      -- se guarda el log de la consulta.
      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         -- Se ha producido un error al intentar guardar el log de la consulta
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      IF NOT vcursor%ISOPEN THEN
         -- Se ha producido un error en PAC_MD_LOG.F_LOG_CONSULTAS
         RAISE e_object_error;
      ELSE
         -- Bug 18319 - APD - 06/07/2011 - se a?aden los campos
         -- IDAA, ILAA, CTPRIMAXL, IPRIMAFIJAXL, IPRIMAESTIMADA, CAPLICTASAXL, '
         -- CTIPTASAXL, CTRAMOTASAXL, PCTPDXL, CFORPAGPDXL, PCTMINXL, PCTPB, '
         -- NANYOSLOSS, CLOSSCORRIDOR, CAPPEDRATIO, CREPOS, '
         -- IBONOREC, IMPAVISO, IMPCONTADO, PCTCONTADO, PCTDEP, CFORPAGDEP, '
         -- INTDEP, PCTGASTOS, PTASAAJUSTE, ICAPCOASEG
         FETCH vcursor
          INTO vobjtramo.nversio, vobjtramo.scontra, vobjtramo.ctramo, vobjtramo.ttramo,
               vobjtramo.itottra, vobjtramo.nplenos, vobjtramo.cfrebor, vobjtramo.plocal,
               vobjtramo.ixlprio, vobjtramo.ixlexce, vobjtramo.pslprio, vobjtramo.pslexce,
               vobjtramo.ncesion, vobjtramo.fultbor, vobjtramo.imaxplo, vobjtramo.norden,
               vobjtramo.nsegcon, vobjtramo.nsegver, vobjtramo.iminxl, vobjtramo.idepxl,
               vobjtramo.nctrxl, vobjtramo.nverxl, vobjtramo.ptasaxl, vobjtramo.ipmd,
               vobjtramo.cfrepmd, vobjtramo.tfrepmd, vobjtramo.caplixl, vobjtramo.plimgas,
               vobjtramo.pliminx, vobjtramo.tfrebor, vobjtramo.idaa, vobjtramo.ilaa,
               vobjtramo.ctprimaxl, vobjtramo.ttprimaxl, vobjtramo.iprimafijaxl,
               vobjtramo.iprimaestimada, vobjtramo.caplictasaxl, vobjtramo.taplictasaxl,
               vobjtramo.ctiptasaxl, vobjtramo.ttiptasaxl, vobjtramo.ctramotasaxl,
               vobjtramo.ttramotasaxl, vobjtramo.pctpdxl, vobjtramo.cforpagpdxl,
               vobjtramo.tforpagpdxl, vobjtramo.pctminxl, vobjtramo.pctpb,
               vobjtramo.nanyosloss, vobjtramo.closscorridor, vobjtramo.tlosscorridor,
               vobjtramo.ccappedratio, vobjtramo.tcappedratio, vobjtramo.crepos,
               vobjtramo.trepos, vobjtramo.ibonorec, vobjtramo.impaviso, vobjtramo.impcontado,
               vobjtramo.pctcontado, vobjtramo.pctgastos, vobjtramo.ptasaajuste,vobjtramo.ptramo, --BUG CONF-250  Fecha (02/09/2016) - HRE - se adiciona vobjtramo.ptramo
               vobjtramo.preest, vobjtramo.icapcoaseg, vobjtramo.icostofijo, vobjtramo.pcomisinterm,vobjtramo.iprio;

         -- fIN Bug 18319 - APD - 06/07/2011
         vpasexec := 6;

         IF vcursor%NOTFOUND THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000626);
         END IF;

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 7;
      RETURN vobjtramo;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RAISE;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RAISE;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RAISE;
   END f_get_dettramo_rea;

---------------------------------------------------------------------------------------------------------------------------------
   FUNCTION f_get_cuadroces_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_cuadroces_rea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'par?metros - pscontra:' || pscontra || ' - pnversio:' || pnversio
            || ' - pctramo:' || pctramo;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_Cuadroces_Rea';
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      vcursor        sys_refcursor;
      vcuadros       t_iax_cuadroces_rea;
      vcuadro        ob_iax_cuadroces_rea;
   BEGIN
      IF pscontra IS NULL
         OR pnversio IS NULL
         OR pctramo IS NULL THEN
         -- Error en los par?metros
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      -- Bug 18319 - APD - 06/07/2011 - se a?aden los campos
      -- CTIPCOMIS, PCTCOMIS, CTRAMOCOMISION
      vsquery :=
         'SELECT c.ccompani, substr((select tcompani from companias where ccompani = c.ccompani),1,30) || pac_md_rea.f_compania_cutoff(c.ccompani, SYSDATE) tcompani,
                         nversio, scontra, ctramo, ff_desvalorfijo (105, '
         || vidioma
         || ', ctramo) ttramo,
                         ccomrea, (select TDESCRI from descomisioncontra where CCOMREA = c.CCOMREA and CIDIOMA = '
         || vidioma
         || ') as tcomrea,
                         pcesion, nplenos, icesfij,
                         icomfij, isconta, preserv, pintres, iliacde, ppagosl, ccorred,
                         cintref, cresref, cintres, ireserv, ptasaj, fultliq, iagrega, imaxagr, substr((select tcompani from companias where ccompani = c.ccorred),1,40) descorred, '
         || ' CTIPCOMIS, ff_desvalorfijo (345, ' || vidioma
         || ', ctipcomis) ttipcomis, PCTCOMIS, '
         || ' CTRAMOCOMISION, (SELECT tdescripcion FROM clausulas_reas WHERE ccodigo = CTRAMOCOMISION and cidioma= '
         || vidioma
         || ') ttramocomision
                  FROM cuadroces c
                  WHERE scontra = '
         || pscontra || ' AND nversio = ' || pnversio || ' AND ctramo = ' || pctramo;
      -- Fin Bug 18319 - APD - 06/07/2011
      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      -- Se guarda el log de la consulta.
      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         -- Se ha producido un error al guardar el log de la consulta.
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      IF NOT vcursor%ISOPEN THEN
         RAISE e_object_error;
      ELSE
         vcuadros := t_iax_cuadroces_rea();
         vpasexec := 6;

         LOOP
            vcuadro := ob_iax_cuadroces_rea();
            vpasexec := 6.1;

            -- Bug 18319 - APD - 06/07/2011 - se a?aden los campos
            -- CTIPCOMIS, PCTCOMIS, CTRAMOCOMISION
            FETCH vcursor
             INTO vcuadro.ccompani, vcuadro.tcompani, vcuadro.nversio, vcuadro.scontra,
                  vcuadro.ctramo, vcuadro.ttramo, vcuadro.ccomrea, vcuadro.tcomrea,
                  vcuadro.pcesion, vcuadro.nplenos, vcuadro.icesfij, vcuadro.icomfij,
                  vcuadro.isconta, vcuadro.preserv, vcuadro.pintres, vcuadro.iliacde,
                  vcuadro.ppagosl, vcuadro.ccorred, /*vcuadro.pctgastos, */vcuadro.cintref, vcuadro.cresref,
                  vcuadro.cintres, vcuadro.ireserv, vcuadro.ptasaj, vcuadro.fultliq,
                  vcuadro.iagrega, vcuadro.imaxagr, vcuadro.descorred, vcuadro.ctipcomis,
                  vcuadro.ttipcomis, vcuadro.pctcomis, vcuadro.ctramocomision,
                  vcuadro.ttramocomision;

            -- Fin Bug 18319 - APD - 06/07/2011
            vpasexec := 6.2;

            IF vcursor%NOTFOUND THEN
               EXIT;
            END IF;

            vpasexec := 6.3;
            vcuadros.EXTEND;
            vcuadros(vcuadros.LAST) := vcuadro;
            vpasexec := 6.4;
         END LOOP;

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 7;
      RETURN vcuadros;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RAISE;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RAISE;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RAISE;
   END f_get_cuadroces_rea;

---------------------------------------------------------------------------------------------------------------------------------
   FUNCTION f_get_detcuadro_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pccompani IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_cuadroces_rea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'par?metros - pscontra:' || pscontra || ' - pnversio:' || pnversio
            || ' - pctramo:' || pctramo || ' - pccompani:' || pccompani;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_DetCuadro_Rea';
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      vcursor        sys_refcursor;
      vcuadro        ob_iax_cuadroces_rea := ob_iax_cuadroces_rea();
   BEGIN
      IF pscontra IS NULL
         OR pnversio IS NULL
         OR pctramo IS NULL
            AND pccompani IS NULL THEN
         -- Error en los par?metros
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      -- Bug 18319 - APD - 06/07/2011 - se a?aden los campos
      -- CTIPCOMIS, PCTCOMIS, CTRAMOCOMISION
      vsquery :=
         'SELECT ccompani, substr((select tcompani from companias where ccompani = c.ccompani),1,40) tcompani,
                         nversio, scontra, ctramo, ff_desvalorfijo (105, '
         || vidioma
         || ', ctramo) ttramo,
                         ccomrea, (select TDESCRI from descomisioncontra where CCOMREA = c.CCOMREA and CIDIOMA = '
         || vidioma
         || ') as tcomrea,
                         pcesion,nplenos, icesfij,
                         icomfij, isconta, preserv, pintres, pctgastos, iliacde, ppagosl,ccorred, cintref, cresref,
                         cintres, ireserv, ptasaj, fultliq, iagrega, imaxagr, '
         || ' CTIPCOMIS, ff_desvalorfijo (345, ' || vidioma
         || ', ctipcomis) ttipcomis, PCTCOMIS, '
         || ' CTRAMOCOMISION, (SELECT tdescripcion FROM clausulas_reas WHERE ccodigo = CTRAMOCOMISION and cidioma= '
         || vidioma
         || ') ttramocomision
                  FROM cuadroces
                  WHERE scontra = '
         || pscontra || ' AND nversio = ' || pnversio || ' AND ctramo = ' || pctramo
         || ' and ccompani = ' || pccompani;
      -- Fin Bug 18319 - APD - 06/07/2011
      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      -- Se guarda el log de la consulta.
      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         -- Se ha producido un error al intentar guargar el log de la consulta.
         RAISE e_object_error;
      END IF;

      IF NOT vcursor%ISOPEN THEN
         -- Se ha producido un error en el PAC_IAX_LISTVALORES.F_Opencursor
         RAISE e_object_error;
      ELSE
         vpasexec := 5;

         -- Bug 18319 - APD - 06/07/2011 - se a?aden los campos
         -- CTIPCOMIS, PCTCOMIS, CTRAMOCOMISION
         FETCH vcursor
          INTO vcuadro.ccompani, vcuadro.tcompani, vcuadro.nversio, vcuadro.scontra,
               vcuadro.ctramo, vcuadro.ttramo, vcuadro.ccomrea, vcuadro.tcomrea,
               vcuadro.pcesion, vcuadro.nplenos, vcuadro.icesfij, vcuadro.icomfij,
               vcuadro.isconta, vcuadro.preserv, vcuadro.pintres, /*vcuadro.pctgastos, */vcuadro.iliacde,
               vcuadro.ppagosl, vcuadro.ccorred, vcuadro.cintref, vcuadro.cresref,
               vcuadro.cintres, vcuadro.ireserv, vcuadro.ptasaj, vcuadro.fultliq,
               vcuadro.iagrega, vcuadro.imaxagr, vcuadro.ctipcomis, vcuadro.ttipcomis,
               vcuadro.pctcomis, vcuadro.ctramocomision, vcuadro.ttramocomision;

         -- Fin Bug 18319 - APD - 06/07/2011
         vpasexec := 6;

         IF vcursor%NOTFOUND THEN
            -- No se han encontrado registros.
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000627);
         END IF;

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 7;
      RETURN vcuadro;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RAISE;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RAISE;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RAISE;
   END f_get_detcuadro_rea;

 /*************************************************************************
	Selecciona informaci?n sobre la cesiones
	param in pnpoliza   : n?mero de p?liza
	param in pncertif  : n?mero de certificado
	param in pnsinies  : n?mero de sinietro
	param in pnrecibo : n?mero de recibo
	param in pfefeini : fecha inicio efecto(Inicio rango)
	param in pfefefin : fecha fin efecto(Fin rango)
	param in pnreemb  : n? de reembolso
	param out mensajes : mensajes de error

	BUG 10471 - 17/06/2009 - ETM - IAX : REA: Desarrollo PL de la consulta de cesiones
	Bug 11605 - 29/06/2009 - AMC - CRE : Adaptar consulta de cessions als reemborsaments.
*************************************************************************/
FUNCTION f_get_consulta_cesiones(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnsinies IN NUMBER,
      pnrecibo IN NUMBER,
      pfefeini IN DATE,
      pfefefin IN DATE,
      pnreemb IN NUMBER,
      pscumulo IN NUMBER,
      mensajes OUT t_iax_mensajes)      
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(900)
         := 'par?metros - pnpoliza:' || pnpoliza || ' - pncertif:' || pncertif
            || ' - pnsinies:' || pnsinies || ' - pnrecibo:' || pnrecibo || ' - pfefeini:'
            || pfefeini || ' - pfefefin:' || pfefefin || ' - pnreemb:' || pnreemb
            || ' - pscumulo:' || pscumulo;
      vobject        VARCHAR2(80) := 'pac_md_rea.f_get_Consulta_Cesiones';
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      v_where        VARCHAR2(4000);
      vcursor        sys_refcursor;
      -- ML - 28/05/2019 - VARIABLE PARA ALMACENAR EL NUMERO DE PAGOS
      v_con_pagos NUMBER := 0;
      -- ML - 28/05/2019 - VARIABLE PARA ALMACENAR EL CODIGO DE EL PAGO
      v_id_pago NUMBER := 0;
     -- ML - 28/05/2019 - VARIABLE PARA ALMACENAR SI EXISTE EL PAGO ACEPTADO
      v_pago_aceptado NUMBER := 0;
   BEGIN
      -- BUG: 17672 JGR 23/02/2011 desde
      --
      -- En la SELECT din?mica se ha eliminado :
      --         NVL(f_parproductos_v(s.sproduc, ''REASEGURO''), 0) tipo_rea
      -- Se ha sustituido a?adido por:
      --         NVL(c.cdetces,0) tipo_rea
      --
      -- BUG: 17672 JGR 23/02/2011 - desde
      -- INI - ML - 31/05/2019 - SE AGREGA UNIONES EN LA CONSULTA PRINCIPAL	
      vsquery :=   ---etm 2 parte
         'SELECT DISTINCT npoliza, ncertif, s.fefecto, s.fvencim,
                 ff_desvalorfijo(61, '
         || vidioma
         || ', s.csituac) tsituac, s.sseguro,
            c.scumulo
            FROM cesionesrea c, seguros s, RECIBOS r WHERE c.sseguro = s.sseguro AND r.sseguro (+) = c.sseguro ';
      vpasexec := 2;     
     /*
      p_agrega_where
         (v_where,
          'c.sseguro = s.sseguro
                       AND r.sseguro (+) = c.sseguro
                       ');
     */
     -- FIN - ML - 31/05/2019 - SE AGREGA UNIONES EN LA CONSULTA PRINCIPAL
      vpasexec := 3;

      -- Bug 11605 - 29/10/2009 - AMC
      IF pnsinies IS NULL
         AND pnreemb IS NULL THEN
         p_agrega_where(v_where, 'r.nmovimi (+) = c.nmovimi');
      END IF;

      -- Fi Bug 11605 - 29/10/2009 - AMC
      IF pnpoliza IS NOT NULL THEN
         p_agrega_where(v_where, 's.npoliza = ' || pnpoliza);
      END IF;

      IF pncertif IS NOT NULL THEN
         p_agrega_where(v_where, 's.ncertif = ' || pncertif);
      END IF;

      -- BUG 0028827 - FAL - 02/12/2012
      /*
      IF pnsinies IS NOT NULL THEN
         p_agrega_where(v_where, 'c.nsinies = ' || pnsinies);
      END IF;
      */
      IF pnsinies IS NOT NULL THEN
      	 -- INI - ML - 28/5/2019 - SE ADECUA FILTRO POR SINIESTRO, PARA QUE VALIDE EXISTENCIA DE PAGO, Y VERIFIQUE SI EL PAGO ESTA VALIDADO	
      	 	-- VERIFICAR SI EXISTE ALGUN PAGO REGISTRADO
      	 	SELECT COUNT(1) INTO v_con_pagos FROM SIN_TRAMITA_PAGO WHERE NSINIES = pnsinies;
      	 	IF v_con_pagos > 0 THEN
      	 		-- GUARDAR ID DE PAGO      	 		
      	 		SELECT MAX(SIDEPAG) INTO v_id_pago FROM SIN_TRAMITA_PAGO WHERE NSINIES = pnsinies;
      	 		-- VERIFICAR SI EL MOVIMIENTO DEL PAGO ESTA EN PAGADO (CESTPAG = 2)
      	 		SELECT COUNT(1) INTO v_pago_aceptado FROM SIN_TRAMITA_MOVPAGO WHERE SIDEPAG = v_id_pago AND CESTPAG = 2;
      	 		IF v_pago_aceptado > 0 THEN
      	 			-- PODRIA BUSCARLO EN LA TABLA CESIONESREA
      	 			-- p_agrega_where(v_where, 'c.cgenera = 2 and c.nsinies = ' || pnsinies);
      	 			-- BUSCAR UNIENDO TABLA SIN_SINIESTRO
					vsquery := 'SELECT DISTINCT npoliza, ncertif, s.fefecto, s.fvencim, ff_desvalorfijo(61, ' || vidioma || ', s.csituac) tsituac, s.sseguro, c.scumulo
					            FROM cesionesrea c, seguros s, RECIBOS r, sin_siniestro sin WHERE c.sseguro = s.sseguro AND r.sseguro (+) = c.sseguro AND c.sseguro = sin.sseguro ';					
					p_agrega_where (v_where, 'sin.NSINIES = ' || pnsinies);
      	 		ELSE 
      	 			-- RETORNA MENSAJE DE QUE EL PAGO NO ESTA ACEPTADO      	 			
	      	 		pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 89906312);
	      	 		RETURN vcursor;
      	 		END IF;      	 		
      	 	ELSE 
      	 		-- RETORNAR QUE NO EXISTEN PAGOS ASOCIADOS      	 		      	 		
	      	 	pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 89906313);
	      	 	RETURN vcursor;
      	 	END IF;         
        -- FIN - ML - 28/5/2019 - SE ADECUA FILTRO POR SINIESTRO, PARA QUE VALIDE EXISTENCIA DE PAGO, Y VERIFIQUE SI EL PAGO ESTA VALIDADO	
      ELSE
         p_agrega_where(v_where, 'c.cgenera <> 2');
      END IF;

      -- FI BUG 0028827 - FAL - 02/12/2012
      IF pfefeini IS NOT NULL THEN
         p_agrega_where(v_where,
                        'c.fefecto >= to_date(''' || TO_CHAR(pfefeini, 'dd/mm/yyyy')
                        || ''',''dd/mm/yyyy'')');
      END IF;

      IF pfefefin IS NOT NULL THEN
         p_agrega_where(v_where,
                        'c.fefecto <=to_date(''' || TO_CHAR(pfefefin, 'dd/mm/yyyy')
                        || ''',''dd/mm/yyyy'')');   -- AVT 14-10-2009
      END IF;

      IF pnrecibo IS NOT NULL THEN
         p_agrega_where(v_where, 'r.nrecibo = ' || pnrecibo);
      END IF;

      -- Bug 11605 - 29/10/2009 - AMC
      IF pnreemb IS NOT NULL THEN
         p_agrega_where(v_where, 'c.nreemb = ' || pnreemb);
      END IF;

      -- Fi Bug 11605 - 29/10/2009 - AMC

      -- Bug 29564/168256 - 03/03/2014 - SHA
      IF pscumulo IS NOT NULL THEN
         p_agrega_where(v_where, 'c.scumulo = ' || pscumulo);
      END IF;

      -- Fi Bug 29564/168256 - 203/03/2014 - SHA
      IF v_where IS NOT NULL THEN
	     -- INI - ML - 31/05/2019 - SE MODIFICA CONCATENACION DE WHERE PARA QUE SOLO UTILICE LOS FILTROS	
         --vsquery := vsquery || ' where ' || v_where;
         vsquery := vsquery || ' AND ' || v_where;
         -- FIN - ML - 31/05/2019 - SE MODIFICA CONCATENACION DE WHERE PARA QUE SOLO UTILICE LOS FILTROS	
      END IF;

      vsquery := vsquery || ' order by s.fefecto';
      vpasexec := 7;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 8;

      IF pac_log.f_log_consultas(vsquery, vobject, 5, 2, f_sysdate, f_user) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 9;

      IF NOT vcursor%ISOPEN
         OR vcursor%NOTFOUND THEN
         -- Se ha producido un error
         RAISE e_object_error;
      END IF;

      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_consulta_cesiones;

   /*************************************************************************
        Selecciona informaci?n sobre la cesiones de la poliza seleccionada
        param in psseguro   :  numero de seguro
        param out mensajes : mensajes de error

     *************************************************************************/
   FUNCTION f_get_consulta_det_cesiones(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200) := 'par?metros- psseguro:' || psseguro;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_consulta_det_cesiones';
      vsquery        VARCHAR2(3000);
      vsquery2       VARCHAR2(3000);
      vsquery3       VARCHAR2(6000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      vcursor        sys_refcursor;
      v_coma         VARCHAR2(10) := '||'', ''||';
   BEGIN
      IF psseguro IS NULL THEN
         -- Error en los par?metros
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
       --Se elimina AND c.nriesgo = a.nriesgo de la join ya que el riesgo del asegurado no es currecto pendiente de otro bug
       --KBR 30940 09/04/2014 Se agrega OUTER JOIN a la tabla GARANSEG para aquellas cesiones que son de productos que agrupan garantías
      -- Bug 32364 - Reaseguro - Problemas en la consulta de cesiones - 29-II-2015 - dlF
      -- TO_NUMBER a la icapces, icesion, PrimaRet, ya que se han detectado errores en el formateo en pantalla, ya que devuelve un STRING
      vsquery :=
         'SELECT c.scesrea, s.npoliza, s.ncertif, c.nsinies, '
         || ' NVL(c.NREEMB, c.sidepag) sidepag, c.nmovimi, c.nriesgo, a.sperson, '
         || ' regexp_replace(f_desriesgo_t(s.sseguro, a.nriesgo, NULL, ' || vidioma
         || '),''([[:cntrl:]])|(^\t)'',null) nom, c.cgarant, '   -- BUG 0022320 - FAL - 13/05/2013
         || ' g.tgarant, c.cgenera, ff_desvalorfijo(128,' || vidioma
         || ', c.cgenera) tcgenera, '
         || ' c.fefecto, c.fvencim, c.fanulac, c.fregula, c.scontra, c.nversio, '
         || ' ct.tcontra, ff_desvalorfijo(105, ' || vidioma
         || ', c.ctramo) tctramo, c.sfacult, '
         || ' DECODE(cd.ctiprea, 3, cast(DECODE(NVL(pac_parametros.f_parempresa_n(s.cempres, ''NO_CONSULTA_XL''), 0), 1, NULL, c.pcesion) as number), c.pcesion) pcesion, '   -- 28777 11/11/2013 NO SURTI A LA CONSULTA XL POS
         || ' (100 - NVL(t.plocal,0)) * c.pcesion / 100 PCESION_CP,'
         || ' TO_NUMBER(DECODE(cd.ctiprea, 3, cast(DECODE(NVL(pac_parametros.f_parempresa_n(s.cempres, ''NO_CONSULTA_XL''), 0), 1, NULL, c.icapces) as number), c.icapces)) icapces, '   -- 28777 11/11/2013 NO SURTI A LA CONSULTA XL POS
         || ' TO_NUMBER(DECODE(cd.ctiprea, 3, cast(DECODE(NVL(pac_parametros.f_parempresa_n(s.cempres, ''NO_CONSULTA_XL''), 0), 1, NULL, c.icesion) as number), c.icesion)) icesion, '   -- 28777 11/11/2013 NO SURTI A LA CONSULTA XL POS
         || ' (100 - NVL(t.plocal,0)) * c.icesion / 100 ICESION_CP, '   -- 26252 AVT 08/05/2013
         || ' TO_NUMBER(DECODE(c.ctramo, 0, gs.iprianu - gs.itarrea, null)) as PrimaRet, icomext, NVL(c.cdetces,0) tipo_rea '   --0030630 AGG 21/03/2014
         || ' FROM cesionesrea c, seguros s, riesgos a, garangen g, contratos ct, sin_tramita_pago_gar pa, TRAMOS T, CODICONTRATOS CD, garanseg gs '   -- BUG 0022320 - FAL - 13/05/2013
         || ' WHERE c.sseguro = s.sseguro' || ' AND s.sseguro = ' || psseguro
         || ' AND s.sseguro = a.sseguro'
         || ' AND c.nriesgo = a.nriesgo'   -- BUG 0022320 - FAL - 13/05/2013
         || ' AND c.scontra = ct.scontra (+)' || ' AND c.nversio = ct.nversio (+)'
         || '     AND c.scontra = t.scontra(+) ' || ' AND c.nversio = t.nversio(+) '
         || '     AND c.ctramo = t.ctramo (+)'
         || ' AND (a.fanulac >= c.fefecto OR a.fanulac is null)'
         || ' AND g.cidioma(+)='   -- BUG 0022320 - FAL - 13/05/2013
                                || vidioma || ' AND c.cgarant = g.cgarant (+)'
         || ' AND (c.sidepag=pa.sidepag (+)' || ' AND c.cgarant = pa.cgarant(+))'
         || ' AND cd.scontra = c.scontra '
                                          --0030630 AGG 21/03/2014
         || ' AND gs.sseguro(+) = c.sseguro ' || ' AND gs.nriesgo(+) = c.nriesgo '
         || ' AND gs.cgarant(+) = c.cgarant ' || ' AND gs.nmovimi(+) = c.nmovimi '
         --BUG 32230 DCT 24/07/2014
         || ' AND c.pcesion <> 0 ';
      vpasexec := 3;
      vsquery2 :=
         'SELECT c.scesrea, s.npoliza, s.ncertif, c.nsinies, NVL(c.nreemb, c.sidepag) sidepag, '
         || ' c.nmovimi, c.nriesgo, a.sperson, regexp_replace(f_desriesgo_t(s.sseguro, a.nriesgo, NULL, '
         || vidioma || '),''([[:cntrl:]])|(^\t)'',null) nom, '
         || ' c.cgarant, g.tgarant, c.cgenera, ff_desvalorfijo(128, ' || vidioma
         || ', c.cgenera) tcgenera, '
         || ' c.fefecto, c.fvencim, c.fanulac, c.fregula, 0 scontra, 0 nversio, ''Facultat.exclus.'' tcontra, '
         || ' ff_desvalorfijo(105, ' || vidioma || ', c.ctramo) tctramo, c.sfacult, '
         || ' c.pcesion pcesion, c.pcesion pcesion_cp, c.icapces, c.icesion , '
         || ' c.icesion icesion_cp, TO_NUMBER(DECODE(c.ctramo, 0, gs.iprianu - gs.itarrea, NULL)) AS primaret, icomext, NVL(c.cdetces,0) tipo_rea '
         || 'FROM cesionesrea c, seguros s, riesgos a, garangen g, sin_tramita_pago_gar pa, garanseg gs '
         || 'WHERE c.sseguro = s.sseguro ' || ' AND s.sseguro = ' || psseguro
         || ' AND c.ctramo = 5 ' || 'AND c.scontra IS NULL ' || ' AND c.nversio IS NULL '
         || ' AND s.sseguro = a.sseguro ' || ' AND c.nriesgo = a.nriesgo '
         || ' AND(a.fanulac >= c.fefecto ' || '    OR a.fanulac IS NULL) '
         || ' AND g.cidioma(+) = ' || vidioma || ' AND c.cgarant = g.cgarant(+) '
         || ' AND(c.sidepag = pa.sidepag(+) ' || '    AND c.cgarant = pa.cgarant(+)) '
         || ' AND gs.sseguro(+) = c.sseguro ' || ' AND gs.nriesgo(+) = c.nriesgo '
         || ' AND gs.cgarant(+) = c.cgarant ' || ' AND gs.nmovimi(+) = c.nmovimi '
         || ' AND c.pcesion <> 0';
      vsquery3 := 'SELECT * FROM (' || vsquery || ' UNION ALL ' || vsquery2
                  || ') ORDER BY scesrea';
      vpasexec := 4;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery3, mensajes);
      vpasexec := 5;

      IF pac_log.f_log_consultas(vsquery3, vobject, 5, 2, f_sysdate, f_user) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 6;

      IF NOT vcursor%ISOPEN
         OR vcursor%NOTFOUND THEN
         -- Se ha producido un error
         RAISE e_object_error;
      END IF;

      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_consulta_det_cesiones;

     /*************************************************************************
      Recupera informaci?n de cabecera de la cesiones por recibo para uno en concreto o para un movimiento de cesi?n anulizada
      param in psseguro   :  numero de seguro
      param in pnmovimi  : n?mero de movimiento
      param in pnrecibo : n?mero de recibo
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_recibos_ces(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200)
                          := 'par?metros- psseguro:' || psseguro || ' - pnmovimi:' || pnmovimi;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_Recibos_Ces';
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      vcursor        sys_refcursor;
   BEGIN
      IF psseguro IS NULL
         OR pnmovimi IS NULL THEN
         -- Error en los par?metros
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vsquery :=
         'SELECT r.sreaemi, re.nmovimi, r.nrecibo, r.nfactor, r.fefecte, r.fvencim, r.fcierre, r.cmotces,
                         ff_desvalorfijo(250, '
         || vidioma
         || ', r.cmotces) tcmotces
                      FROM reasegemi r, recibos re
                     WHERE r.nrecibo = re.nrecibo
                       AND r.sseguro = re.sseguro
                       AND re.sseguro = '
         || psseguro || ' AND nmovimi = ' || pnmovimi;
      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      IF pac_log.f_log_consultas(vsquery, vobject, 5, 2, f_sysdate, f_user) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 5;

      IF NOT vcursor%ISOPEN
         OR vcursor%NOTFOUND THEN
         -- Se ha producido un error
         RAISE e_object_error;
      END IF;

      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_recibos_ces;

   /*************************************************************************
        Recupera informaci?n en detalle de la cesiones por recibo
        param in psreaemi  : n?mero de psreaemi
        param out mensajes : mensajes de error

     *************************************************************************/
   FUNCTION f_get_datosrecibo_ces(psreaemi IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200) := 'par?metros - psreaemi:' || psreaemi;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_Datosrecibo_Ces';
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      v_coma         VARCHAR2(10) := '||'', ''||';
      vcursor        sys_refcursor;
   BEGIN
      IF psreaemi IS NULL THEN
         -- Error en los par?metros
         RAISE e_param_error;
      END IF;

      --Se elimina AND c.nriesgo = a.nriesgo de la join ya que el riesgo del asegurado no es currecto pendiente de otro bug
      vpasexec := 2;
      --Se elimina el join con PER_DETPER KBR 15/07/2013
      vsquery :=
         'SELECT d.nriesgo, regexp_replace(f_desriesgo_t(c.sseguro, a.nriesgo, NULL, '
         || vidioma || '),''([[:cntrl:]])|(^\t)'',null) nom, '
         || ' d.cgarant, g.tgarant, cgenera, d.scontra, d.nversio, c.ctramo,ff_desvalorfijo(105,'
         || vidioma || ', c.ctramo) tctramo, d.sfacult, d.pcesion,'
         || ' (100 - NVL(t.plocal,0)) * d.pcesion / 100 pcesion_cp, '
         || ' d.icapces, d.icesion, '
         || ' (100 - NVL(t.plocal,0)) * d.icesion / 100 icesion_cp,'
         || ' d.ipritarrea, d.idtosel, d.psobreprima, d.iextrap, d.iextrea'
         || ', c.scesrea, c.fefecto'
         || ' FROM detreasegemi d, cesionesrea c, riesgos a, garangen g, contratos ct, TRAMOS T'
         || ' WHERE d.scesrea = c.scesrea' || ' AND g.cidioma (+) = ' || vidioma
         || ' AND c.sseguro = a.sseguro' || ' AND d.nriesgo = a.nriesgo'
         || ' AND c.scontra = ct.scontra (+)' || ' AND c.nversio = ct.nversio (+)'
         || ' AND c.scontra = t.scontra(+)' || ' AND c.nversio = t.nversio(+)'
         || ' AND c.ctramo = t.ctramo(+)'
         || ' AND (a.fanulac >= c.fefecto OR a.fanulac is null)' || ' AND g.cidioma (+) = '
         || vidioma || ' AND c.cgarant = g.cgarant (+)' || ' AND sreaemi = ' || psreaemi
         || ' AND c.pcesion <> 0 ';
      --vsquery := vsquery || ' order by c.fefecto, c.scesrea ';
      vsquery := vsquery || ' order by d.sreaemi, c.scesrea ';
      p_tab_error(f_sysdate, f_user, 'f_get_datosrecibo_ces', 666, 'vsquery', vsquery);
      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      IF pac_log.f_log_consultas(vsquery, vobject, 5, 2, f_sysdate, f_user) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 5;

      IF NOT vcursor%ISOPEN
         OR vcursor%NOTFOUND THEN
         -- Se ha producido un error
         RAISE e_object_error;
      END IF;

      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_datosrecibo_ces;

/* FIN BUG 10471 - 17/06/2009 - ETM */
/*BUG 10487 - 18/06/2009 - ETM - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
 /*************************************************************************
      Selecciona las cabeceras de cuadros facultativos
      param in ptempres   : C?digo y descripci?n de la empresa
      param in ptramo  : C?digo y descripci?n del ramo
      param in ptsproduc  : Descripci?n del producto
      param in pnpoliza  : n?mero de poliza
      param in pncertif  : Certificado
      param in psfacult  :  C?digo cuadro facultativo
      param in tcestado : C?digo y descripci?n del estado del cuadro
      param in pfefeini  :  Fecha inicio efecto(Inicio del rango)
      param in pfefefin  :  Fecha fin efecto(Fin del rango)
      param out mensajes : mensajes de error

  *************************************************************************/
   FUNCTION f_get_cuafacul_rea(
      ptempres IN NUMBER,
      ptramo IN NUMBER,
      ptsproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psfacult IN NUMBER,
      tcestado IN NUMBER,
      pfefeini IN DATE,
      pfefefin IN DATE,
      pscumulo IN NUMBER,
      pnsolici IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'par?metros- ptempres:' || ptempres || ' - ptramo:' || ptramo || ' - ptsproduc:'
            || ptsproduc || ' - pnpoliza:' || pnpoliza || ' - pncertif:' || pncertif
            || ' - psfacult:' || psfacult || ' - tcestado:' || tcestado || ' - pfefeini:'
            || pfefeini || ' - pfefefin:' || pfefefin || ' - pscumulo:' || pscumulo
            || ' - pnsolici:' || pnsolici;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_cuafacul_rea';
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      v_where        VARCHAR2(4000);
      vcursor        sys_refcursor;
   BEGIN
      -- Bug 11605 - 02/11/2009 - AMC
      vsquery :=

         'SELECT distinct(s.npoliza), s.sseguro, s.ncertif, c.nmovimi, NVL(c.nriesgo, r.nriesgo) nriesgo, c.cgarant, c.sfacult, c.cestado, ff_desvalorfijo(118,' ----IAXIS-4481
         || vidioma
         || ', c.cestado) testado,
                 c.scontra, c.nversio, c.finicuf, c.ffincuf, c.scumulo, c.plocal, c.pfacced, c.ifacced, c.ctipfac, c.ptasaxl
                 FROM cuafacul c, reariesgos r,  seguros s ';
      vpasexec := 2;
      /*p_agrega_where
               (v_where,
                ' ((c.scumulo is null and c.sseguro = s.sseguro) or (c.scumulo = r.scumulo)) ');*/
      p_agrega_where
         (v_where,
          ' (c.sseguro = s.sseguro or (c.sseguro IS NULL AND c.scumulo = r.scumulo)) ');
      --INI IAXIS-4481
      p_agrega_where(v_where, ' (r.sseguro(+) = s.sseguro and ((c.scumulo IS NOT NULL AND c.scumulo = r.scumulo)OR c.scumulo is null)) ');
      --FIN IAXIS-4481
      --Fi Bug 11605 - 02/11/2009 - AMC
      vpasexec := 3;

      IF ptempres IS NOT NULL THEN
         p_agrega_where(v_where, 's.cempres = ' || ptempres);
      END IF;

      IF ptramo IS NOT NULL THEN
         p_agrega_where(v_where, 's.cramo = ' || ptramo);
      END IF;
      

      IF ptsproduc IS NOT NULL THEN
         p_agrega_where(v_where, 's.sproduc = ' || ptsproduc);
      END IF;

      IF pnpoliza IS NOT NULL THEN
         p_agrega_where(v_where, 's.npoliza = ' || pnpoliza);
      END IF;

      IF pncertif IS NOT NULL THEN
         p_agrega_where(v_where, 's.ncertif = ' || pncertif);
      END IF;

      -- 22374 AVT 22/08/2012 nous camps
      IF pnsolici IS NOT NULL THEN
         p_agrega_where(v_where, 's.nsolici = ' || pnsolici);
      END IF;

      IF tcestado IS NOT NULL THEN
         p_agrega_where(v_where, 'c.cestado = ' || tcestado);
      END IF;

      IF pfefeini IS NOT NULL THEN
         p_agrega_where(v_where,
                        'c.finicuf >= to_date(''' || TO_CHAR(pfefeini, 'dd/mm/yyyy')
                        || ''',''dd/mm/yyyy'')');
      END IF;

      IF pfefefin IS NOT NULL THEN
         p_agrega_where(v_where,
                        ' c.finicuf <= to_date(''' || TO_CHAR(pfefefin, 'dd/mm/yyyy')
                        || ''',''dd/mm/yyyy'')');
      END IF;

      IF psfacult IS NOT NULL THEN
         p_agrega_where(v_where, 'c.sfacult = ' || psfacult);
      END IF;

      IF pscumulo IS NOT NULL THEN
         -- AVT 13-10-2009 s'ajusta aquesta part de la Where
         p_agrega_where(v_where,
                        'r.sseguro = s.sseguro AND c.scumulo= r.scumulo AND c.scumulo = '
                        || pscumulo || '');
      END IF;

      vpasexec := 4;

      IF v_where IS NOT NULL THEN
         vsquery := vsquery || ' where ' || v_where;
      END IF;

      vpasexec := 5;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 6;

      IF pac_log.f_log_consultas(vsquery, vobject, 5, 2, f_sysdate, f_user) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 7;

      IF NOT vcursor%ISOPEN
         OR vcursor%NOTFOUND THEN
         -- Se ha producido un error
         RAISE e_object_error;
      END IF;

      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_cuafacul_rea;

/*************************************************************************
       Recupera la informaci?n en detalle para un cuadro
       param in psfacult   : C?digo de cuadro facultativo
       param in psseguro  : C?digo del Seguro
       param out mensajes : mensajes de error

    *************************************************************************/
   FUNCTION f_get_cuafacul_det_rea(
      psfacult IN NUMBER,
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_cuafacul IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800) := 'par?metros- psfacult:' || psfacult;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_cuafacul_det_rea';
      vsquery        VARCHAR2(9000);
      vcursor        sys_refcursor;
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      vretorno       ob_iax_cuafacul := ob_iax_cuafacul();
   BEGIN
      IF psfacult IS NULL THEN
         -- Error en los par?metros
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      -- Bug 25502 - 09-01-2013 - AEG
      -- Bug 11605 - 02/11/2009 - AMC
      vsquery :=
         'SELECT s.npoliza, s.ncertif, t.tcontra, c.nmovimi, c.nriesgo, c.cgarant, c.sfacult, c.cestado, ff_desvalorfijo(118, '
         || vidioma
         || ', c.cestado) testado,
                c.scontra, c.nversio, c.finicuf, c.ffincuf, c.scumulo, c.plocal, c.pfacced, c.ifacced,
                pac_md_obtenerdatos.f_desriesgos(''POL'', ri.sseguro, ri.nriesgo) triesgo,
                ff_desgarantia(c.cgarant, '
         || vidioma
         || ' ) tgarant, c.ctipfac, c.ptasaxl
                FROM cuafacul c, seguros s, reariesgos r, contratos t, riesgos ri
                WHERE c.sfacult = '
         || psfacult || ' AND s.sseguro = ' || psseguro
         || '
              AND r.sseguro(+) = s.sseguro
              and ((c.scumulo is null and c.sseguro = s.sseguro) or (c.scumulo = r.scumulo))
              and c.scontra = t.scontra (+)
              and c.nversio = t.nversio (+)
              and s.sseguro = ri.sseguro
              AND s.sseguro = ri.sseguro
              AND  ri.nriesgo =
              (
              select max(ri.nriesgo)
              from   riesgos rie
              where  rie.SSEGURO = s.sseguro
              ) ';
      --Fi Bug 11605 - 02/11/2009 - AMC
      --Fi Bug 25502 - 09-01-2013 - AEG
      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      IF pac_log.f_log_consultas(vsquery, vobject, 5, 2, f_sysdate, f_user) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      IF NOT vcursor%ISOPEN THEN
         vpasexec := 5;
         -- Se ha producido un error
         RAISE e_object_error;
      ELSE
         vpasexec := 6;

         FETCH vcursor
          INTO vretorno.npoliza, vretorno.ncertif, vretorno.tcontra, vretorno.nmovimi,
               vretorno.nriesgo, vretorno.cgarant, vretorno.sfacult, vretorno.cestado,
               vretorno.testado, vretorno.scontra, vretorno.nversio, vretorno.finicuf,
               vretorno.ffincuf, vretorno.scumulo, vretorno.plocal, vretorno.pfacced,
               vretorno.ifacced, vretorno.triesgo, vretorno.tgarant, vretorno.ctipfac,
               vretorno.ptasaxl;

         vpasexec := 7;

         BEGIN
            SELECT mot.tmotmov
              INTO vretorno.tmovimi
              FROM movseguro mov, motmovseg mot
             WHERE mov.sseguro = psseguro
               AND mov.nmovimi = vretorno.nmovimi
               AND mov.cmotmov = mot.cmotmov
               AND mot.cidioma = vidioma;
         EXCEPTION
            WHEN OTHERS THEN
               vretorno.tmovimi := '**';
         END;

         IF vcursor%NOTFOUND THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001821);
         END IF;

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 8;
      RETURN vretorno;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RAISE;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RAISE;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RAISE;
   END f_get_cuafacul_det_rea;

/*************************************************************************
      Recupera la informacion en detalle del cuadro de compa?ias que se reparten el riesgo
      param in psfacult   : C?digo de cuadro facultativo
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_cuacesfac_rea(psfacult IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800) := 'parámetros- psfacult:' || psfacult;
      vobject        VARCHAR2(80) := 'pac_md_rea._get_cuacesfac_rea';
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      vcursor        sys_refcursor;
   BEGIN
      IF psfacult IS NULL THEN
         -- Error en los par?metros
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      -- 22374 - AVT - 04/09/2012 s'afegeix el ccalifi i el tcalifi
      -- INICIO INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
      vsquery :=
         'SELECT sfacult, c.ccompani, tcompani, pcesion, icesfij, ccomrea, pcomisi, icomfij, isconta,
                 preserv, presrea, pintres, cintres, NVL(s.pimpint, c.pimpint), ccorred, cfreres, cresrea,
                 cconrec, fgarpri, fgardep, s.ccalifi, ff_desvalorfijo(800100, '
         || vidioma
         || ', s.ccalifi) tcalifi,c.tidfcom
            FROM cuacesfac c, companias s
           WHERE c.ccompani = s.ccompani
             AND sfacult =  '
         || psfacult;
      -- FIN INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      IF pac_log.f_log_consultas(vsquery, vobject, 5, 2, f_sysdate, f_user) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 5;

      IF NOT vcursor%ISOPEN
         OR vcursor%NOTFOUND THEN
         -- Se ha producido un error
         RAISE e_object_error;
      END IF;

      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_cuacesfac_rea;

   /*************************************************************************
      Recupera la informacion en detalle para una compa?ia reaseguradora en concreto
      param in psfacult   : C?digo de cuadro facultativo
      param in pccompani  : Compa?ia
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_cuacesfac_det_rea(
      psfacult IN NUMBER,
      pccompani IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_cuacesfac IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
                        := 'par?metros- psfacult:' || psfacult || ' - pccompani:' || pccompani;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_cuacesfac_det_rea';
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      vretorno       ob_iax_cuacesfac := ob_iax_cuacesfac();
      vcursor        sys_refcursor;
   BEGIN
      IF psfacult IS NULL
         OR pccompani IS NULL THEN
         -- Error en los par?metros
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      -- 22374 AVT 21/08/2012  s'afegeixen: ccorred, cfreres, cresrea, cconrec, fgarpri, fgardep
      -- 25502 AEG 18-01-2013 se remplaza s.pimpint por c.pimpint -->> AVT: NVL(s.pimpint, c.pimpint)
      -- INICIO INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
      vsquery :=
         'SELECT sfacult, c.ccompani, tcompani, pcesion, icesfij, ccomrea, pcomisi, icomfij, isconta,
                 preserv, presrea, pintres, cintres, NVL(s.pimpint, c.pimpint), ccorred, cfreres, cresrea,
                 cconrec, fgarpri, fgardep, c.tidfcom
            FROM cuacesfac c, companias s
           WHERE c.ccompani = s.ccompani
             AND sfacult =  '
         || psfacult || ' AND c.ccompani = ' || pccompani;
      -- FIN INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      IF pac_log.f_log_consultas(vsquery, vobject, 5, 2, f_sysdate, f_user) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      IF NOT vcursor%ISOPEN THEN
         vpasexec := 5;
         -- Se ha producido un error
         RAISE e_object_error;
      ELSE
         vpasexec := 6;

         FETCH vcursor
          INTO vretorno.sfacult, vretorno.ccompani, vretorno.tcompani, vretorno.pcesion,
               vretorno.icesfij, vretorno.ccomrea, vretorno.pcomisi, vretorno.icomfij,
               -- INICIO INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
               vretorno.isconta, vretorno.preserv, vretorno.presrea,vretorno.pintres, vretorno.cintres,
               -- FIN INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
               vretorno.pimpint, vretorno.ccorred, vretorno.cfreres, vretorno.cresrea,
               vretorno.cconrec, vretorno.fgarpri, vretorno.fgardep, vretorno.tidfcom;

         vpasexec := 7;

         IF vcursor%NOTFOUND THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001822);
         END IF;

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 8;
      RETURN vretorno;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RAISE;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RAISE;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RAISE;
   END f_get_cuacesfac_det_rea;

    /*************************************************************************
        funcion que se encargar? de guardar la informaci?n del detalle del cuadro de facultativo introducido.
        PSFACULT in NUMBER
        PCESTADO in NUMBER
        PFINCUF in DATE
        PPLOCAL in number
        PCCOMPANI in NUMBER
        PPCESION in NUMBER
        PICESFIJ in NUMBER
        PCCOMREA in NUMBER
        PPCOMISI in NUMBER
        PICOMFIG in NUMBER
        PISCONTA in NUMBER
        PPRESERV in NUMBER
        PCINTRES in NUMBER
        PINTRES in NUMBER
        param in out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_set_cuadro_fac(
      psfacult IN NUMBER,
      pcestado IN NUMBER,
      pfincuf IN DATE,
      pplocal IN NUMBER,
      pifacced IN NUMBER, -- IAXIS-5361 26/05/2020
      pccompani IN NUMBER,
      ppcesion IN NUMBER,
      picesfij IN NUMBER,
      pccomrea IN NUMBER,
      ppcomisi IN NUMBER,
      picomfij IN NUMBER,
      pisconta IN NUMBER,
      ppreserv IN NUMBER,
      -- INICIO INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
      ppresrea IN NUMBER,
      -- FIN INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
      pcintres IN NUMBER,
      pintres IN NUMBER,
      pctipfac IN NUMBER,   -- 20/08/2012 AVT 22374 CUAFACUL
      pptasaxl IN NUMBER,
      pccorred IN NUMBER,   -- 20/08/2012 AVT 22374
      pcfreres IN NUMBER,
      pcresrea IN NUMBER,
      pcconrec IN NUMBER,
      pfgarpri IN DATE,
      pfgardep IN DATE,
      ppimpint IN NUMBER,
      ptidfcom IN VARCHAR2,   -- BUG: 25502 17-01-2013 AEG
      psseguro IN NUMBER,   --BUG38692 19/11/2015 DCT
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'par?metros- psfacult :' || psfacult || ' pcestado : ' || pcestado
            || ' pfincuf : ' || pfincuf || ' pplocal :' || pplocal || ' pccompani : '
            || pccompani || ' ppcesion : ' || ppcesion || ' picesfij : ' || picesfij
            || ' pccomrea : ' || pccomrea || ' ppcomisi : ' || ppcomisi || ' picomfij : '
            || picomfij || ' pisconta : ' || pisconta || ' ppreserv : ' || ppreserv
            -- INICIO INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
            || ' ppresrea : ' || ppresrea
            -- FIN INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
            || ' pcintres : ' || pcintres || ' pintres : ' || pintres || ' pifacced : ' || pifacced; -- IAXIS-5361 26/05/2020
      vobject        VARCHAR2(50) := 'pac_md_rea.F_SET_CUADRO_FAC';
      v_error        NUMBER := 0;
   BEGIN
      --  BUG : 2552 AEG 17-01-2013 se agrega ppimpint
      v_error := pac_rea.f_valida_cuadro_fac(psfacult, pcestado, pfincuf, pplocal, pifacced, pccompani, -- IAXIS-5361 26/05/2020
                                             ppcesion, picesfij, pccomrea, ppcomisi, picomfij,
                                             -- INICIO INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
                                             pisconta, ppreserv, ppresrea, pcintres, pintres, pctipfac,
                                             -- FIN INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
                                             pptasaxl, pccorred, pcfreres, pcresrea, pcconrec,
                                             pfgarpri, pfgardep, ppimpint, ptidfcom, psseguro);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_cuadro_fac;

/*FIN BUG 10487 - 18/06/2009 - ETM */

   /*BUG 10487 - 02/09/2009 - ICV - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
   /*************************************************************************
          funci?n que se encargar? de borrar un registro de compa??a participante en el cuadro.
          PSFACULT in NUMBER
          PCESTADO in NUMBER
          PCCOMPANI in NUMBER
          param out mensajes : mensajes de error

     *************************************************************************/
   FUNCTION f_anula_cia_fac(
      psfacult IN NUMBER,
      pcestado IN NUMBER,
      pccompani IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'par?metros- psfacult: ' || psfacult || ' pcestado : ' || pcestado
            || ' pccompani : ' || pccompani;
      vobject        VARCHAR2(50) := 'pac_md_rea.F_ANULA_CIA_FAC';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_rea.f_anula_cia_fac(psfacult, pcestado, pccompani);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_anula_cia_fac;

   /*FIN BUG 10487 - 02/09/2009 - ICV */

   /*BUG 10990 - 07/09/2009 - 0010990: IAX - REA: Desarrollo PL del mantenimiento de contratos*/
   /*************************************************************************
         funci?n que inserta o actualiza informaci?n en cuadroces.
         PCCOMPANI in number,  ob
         PNVERSIO in number, ob
         PSCONTRA in number, ob
         PCTRAMO in number,    ob
         PCCOMREA in number,
         PCESION in number,
         PNPLENOS in number,
         PICESFIJ in number,
         PICOMFIJ in number,
         PISCONTA in number,
         PRESERV in number,
         PINTRES in number,
         PILIACDE in number,
         PPAGOSL in number,
         PCORRED in number,
         PCINTRES in number,
         PCINTREF in number,
         PCRESREF in number,
         PIRESERV in number,
         PTASAJ in number,
         PFUTLIQ in date,
         PIAGREGA in number,
         PIMAXAGR in number,
           -- Bug 18319 - APD - 05/07/2011
           CTIPCOMIS in number,              Tipo Comisi?n
           PCTCOMIS in number,            % Comisi?n fija / provisional
           CTRAMOCOMISION in number,            Tramo comisi?n variable
           -- fin Bug 18319 - APD - 05/07/2011
         mensajes IN OUT t_iax_mensajes
   *************************************************************************/
   FUNCTION f_set_cuadroces(
      pccompani IN NUMBER,   --ob
      pnversio IN NUMBER,   --ob
      pscontra IN NUMBER,   --ob
      pctramo IN NUMBER,   --ob
      pccomrea IN NUMBER,
      ppcesion IN NUMBER,
      pnplenos IN NUMBER,
      picesfij IN NUMBER,
      picomfij IN NUMBER,
      pisconta IN NUMBER,
      ppreserv IN NUMBER,
      ppintres IN NUMBER,
      piliacde IN NUMBER,
      pppagosl IN NUMBER,
      pccorred IN NUMBER,
      pcintres IN NUMBER,
      pcintref IN NUMBER,
      pcresref IN NUMBER,
      pireserv IN NUMBER,
      pptasaj IN NUMBER,
      pfutliq IN DATE,
      piagrega IN NUMBER,
      pimaxagr IN NUMBER,
      -- Bug 18319 - APD - 05/07/2011
      pctipcomis IN NUMBER,   -- Tipo Comisi?n
      ppctcomis IN NUMBER,   -- % Comisi?n fija / provisional
      pctramocomision IN NUMBER,   --Tramo comisi?n variable
      pctgastosrea    IN NUMBER,   --% Gastos Reasegurador (CONF-587)
      -- Fin Bug 18319 - APD - 05/07/2011
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'par?metros- pccompani: ' || pccompani || ' pnversio : ' || pnversio
            || ' pscontra : ' || pscontra || ' pctramo : ' || pctramo;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_cuadroces';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Bug 18319 - APD - 05/07/2011 - se a?aden los campos pctipcomis,
      -- ppctcomis, pctramocomision
      -- INI - AXIS 4451 - 20/06/2019 - AABG - SE ENVIA PARAMETRO GASTOSREA
      vnumerr := pac_rea.f_set_cuadroces(pccompani, pnversio, pscontra, pctramo, pccomrea,
                                         ppcesion, pnplenos, picesfij, picomfij, pisconta,
                                         ppreserv, ppintres, piliacde, pppagosl, pccorred,
                                         pcintres, pcintref, pcresref, pireserv, pptasaj,
                                         pfutliq, piagrega, pimaxagr, pctipcomis, ppctcomis,
                                         pctramocomision,  pctgastosrea
                                         );
     -- FIN - AXIS 4451 - 20/06/2019 - AABG - SE ENVIA PARAMETRO GASTOSREA                                         

      -- fin Bug 18319 - APD - 05/07/2011
      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_cuadroces;

   /*************************************************************************
         funci?n que inserta o actualiza informaci?n en tramos.
        --TRAMOS
        PNVERSIO in number--pk
        PSCONTRA in number,--pk
        PCTRAMO in number,--pk
        PITOTTRA in number,
        PNPLENOS in number,
        PCFREBOR in number,--not null
        PLOCAL in number,
        PIXLPRIO in number,
        PIXLEXCE in number,
        PSLPRIO in number,
        PPSLEXCE in number,
        PNCESION in number,
        FULTBOR in date,
        PIMAXPLO in number,
        PNORDEN in number,--not null
        PNSEGCON in number,
        PNSEGVER in number,
        PIMINXL in number,
        PIDEPXL in number,
        PNCTRXL in number,
        PNVERXL in number,
        PTASAXL in number,
        PIPMD in number,
        PCFREPMD in number,
        PCAPLIXL in number,
        PPLIMGAS in number,
        PLIMINX in number,
      -- Bug 18319 - APD - 04/04/2011
      pidaa IN NUMBER,   -- Deducible anual
      pilaa IN NUMBER,   -- L?mite agregado anual
      pctprimaxl IN NUMBER,   -- Tipo Prima XL
      piprimafijaxl IN NUMBER,   -- Prima fija XL
      piprimaestimada IN NUMBER,   -- Prima Estimada para el tramo
      pcaplictasaxl IN NUMBER,   -- Campo aplicaci?n tasa XL
      pctiptasaxl IN NUMBER,   -- Tipo tasa XL
      pctramotasaxl IN NUMBER,   -- Tramo de tasa variable XL
      ppctpdxl IN NUMBER,   -- % Prima Dep?sito
      pcforpagpdxl IN NUMBER,   -- Forma pago prima de dep?sito XL
      ppctminxl IN NUMBER,   -- % Prima M?nima XL
      ppctpb IN NUMBER,   -- % PB
      pnanyosloss IN NUMBER,   -- A?os Loss Corridor
      pclosscorridor IN NUMBER,   -- C?digo cl?usula Loss Corridor
      pcappedratio IN NUMBER,   -- C?digo cl?usula Capped Ratio
      pcrepos IN NUMBER,   -- C?digo Reposici?n Xl
      pibonorec IN NUMBER,   -- Bono Reclamaci?n
      pimpaviso IN NUMBER,   -- Importe Avisos Siniestro
      pimpcontado IN NUMBER,   -- Importe pagos contado
      ppctcontado IN NUMBER,   -- % Pagos Contado
      ppctdep IN NUMBER,   -- % Dep?sito de primas
      pcforpagdep IN NUMBER,   -- Periodo devoluci?n de. primas
      pintdep IN NUMBER,   -- Intereses sobre dep?sito de primas
      ppctgastos IN NUMBER,   -- Gastos
      pptasaajuste IN NUMBER,   -- Tasa ajuste
      picapcoaseg IN NUMBER,   -- Capacidad seg?n coaseguro
      -- Fin Bug 18319 - APD - 04/04/2011
        mensajes IN OUT t_iax_mensajes
    *************************************************************************/
   FUNCTION f_set_tramos(
      pnversio IN NUMBER,   --pk
      pscontra IN NUMBER,   --pk
      pctramo IN NUMBER,   --pk
      pitottra IN NUMBER,
      pnplenos IN NUMBER,
      pcfrebor IN NUMBER,   --not null
      pplocal IN NUMBER,
      pixlprio IN NUMBER,
      pixlexce IN NUMBER,
      ppslprio IN NUMBER,
      ppslexce IN NUMBER,
      pncesion IN NUMBER,
      pfultbor IN DATE,
      pimaxplo IN NUMBER,
      pnorden IN NUMBER,   --not null
      pnsegcon IN NUMBER,
      pnsegver IN NUMBER,
      piminxl IN NUMBER,
      pidepxl IN NUMBER,
      pnctrxl IN NUMBER,
      pnverxl IN NUMBER,
      pptasaxl IN NUMBER,
      pipmd IN NUMBER,
      pcfrepmd IN NUMBER,
      pcaplixl IN NUMBER,
      pplimgas IN NUMBER,
      ppliminx IN NUMBER,
      -- Bug 18319 - APD - 04/04/2011
      pidaa IN NUMBER,   -- Deducible anual
      pilaa IN NUMBER,   -- L?mite agregado anual
      pctprimaxl IN NUMBER,   -- Tipo Prima XL
      piprimafijaxl IN NUMBER,   -- Prima fija XL
      piprimaestimada IN NUMBER,   -- Prima Estimada para el tramo
      pcaplictasaxl IN NUMBER,   -- Campo aplicaci?n tasa XL
      pctiptasaxl IN NUMBER,   -- Tipo tasa XL
      pctramotasaxl IN NUMBER,   -- Tramo de tasa variable XL
      ppctpdxl IN NUMBER,   -- % Prima Dep?sito
      pcforpagpdxl IN NUMBER,   -- Forma pago prima de dep?sito XL
      ppctminxl IN NUMBER,   -- % Prima M?nima XL
      ppctpb IN NUMBER,   -- % PB
      pnanyosloss IN NUMBER,   -- A?os Loss Corridor
      pclosscorridor IN NUMBER,   -- C?digo cl?usula Loss Corridor
      pccappedratio IN NUMBER,   -- C?digo cl?usula Capped Ratio
      pcrepos IN NUMBER,   -- C?digo Reposici?n Xl
      pibonorec IN NUMBER,   -- Bono Reclamaci?n
      pimpaviso IN NUMBER,   -- Importe Avisos Siniestro
      pimpcontado IN NUMBER,   -- Importe pagos contado
      ppctcontado IN NUMBER,   -- % Pagos Contado
      ppctgastos IN NUMBER,   -- Gastos
      pptasaajuste IN NUMBER,   -- Tasa ajuste
      picapcoaseg IN NUMBER,   -- Capacidad seg?n coaseguro
      picostofijo IN NUMBER,   --Costo Fijo de la capa
      ppcomisinterm IN NUMBER,   --% de comisión de intermediación
      -- Fin Bug 18319 - APD - 04/04/2011
      pptramo      IN NUMBER, --BUG CONF-250 Fecha (02/09/2016) - HRE - se adiciona pptramo
      ppreest      IN NUMBER,--BUG CONF-1048  Fecha (29/08/2017) - HRE - se adiciona ppreest
      ppiprio IN NUMBER,--Agregar campo prioridad tramo IAXIS-4611
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'par?metros- pnversio : ' || pnversio || ' pscontra : ' || pscontra
            || ' pctramo : ' || pctramo;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_tramos';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Bug 18319 - APD - 06/04/2011 - se a?aden los campos
      -- pidaa, pilaa, pctprimaxl, piprimafijaxl, piprimaestimada, pcaplictasaxl, pctiptasaxl,
      -- pctramotasaxl, ppctpdxl, pcforpagpdxl, ppctminxl, ppctpb, pnanyosloss, pclosscorridor, pcappedratio,
      -- pcrepos, pibonorec, pimpaviso, pimpcontado, ppctcontado,  ppctdep, pcforpagdep, pintdep, ppctgastos, pptasaajuste,
      -- picapcoaseg
      vnumerr := pac_rea.f_set_tramos(pnversio, pscontra, pctramo, pitottra, pnplenos,
                                      pcfrebor, pplocal, pixlprio, pixlexce, ppslprio,
                                      ppslexce, pncesion, pfultbor, pimaxplo, pnorden,
                                      pnsegcon, pnsegver, piminxl, pidepxl, pnctrxl, pnverxl,
                                      pptasaxl, pipmd, pcfrepmd, pcaplixl, pplimgas, ppliminx,
                                      pidaa, pilaa, pctprimaxl, piprimafijaxl,
                                      piprimaestimada, pcaplictasaxl, pctiptasaxl,
                                      pctramotasaxl, ppctpdxl, pcforpagpdxl, ppctminxl,
                                      ppctpb, pnanyosloss, pclosscorridor, pccappedratio,
                                      pcrepos, pibonorec, pimpaviso, pimpcontado, ppctcontado,
                                      ppctgastos, pptasaajuste, picapcoaseg, picostofijo,
                                      ppcomisinterm, pptramo, ppreest,ppiprio); --BUG CONF-250  Fecha (02/09/2016) - HRE - se adiciona pptramo

      -- Fin Bug 18319 - APD - 06/04/2011
      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_tramos;

    /*************************************************************************
       funci?n que inserta o actualiza informaci?n en contratos.
       PSCONTRA in number,
       PNVERSIO in number,
       PNPRIORI in number, --not null
       PFCONINI in date, --not null
       PNCONREL in number,
       PFCONFIN in date,
       PIAUTORI in number,
       PIRETENC in number,
       PIMINCES in number,
       PICAPACI in number,
       PIPRIOXL in number,
       PPPRIOSL in number,
       PTCONTRA in varchar2,
       PTOBSERV in varchar2,
       PPCEDIDO in number,
       PPRIESGOS in number,
       PPDESCUENTO in number,
       PPGASTOS in number,
       PPARTBENE in number,
       PCREAFAC in number,
       PPCESEXT in number,
       PCGARREL in number,
       PCFRECUL in number,
       PSCONQP in number,
       PNVERQP in number,
       PIAGREGA in number, comunes con cuadroces
       PIMAXAGR in number
      -- Bug 18319 - APD - 04/07/2011
      pclavecbr NUMBER,   -- F?rmula para el CBR
      pcercartera NUMBER,   -- Tipo E/R cartera
      piprimaesperadas NUMBER,   -- Primas esperadas totales para la versi?n
      pnanyosloss NUMBER,   -- A?os Loss-Corridos
      pcbasexl NUMBER,   -- Base para el c?lculo XL
      pclosscorridor NUMBER,   -- C?digo cl?usula Loss Corridor
      pccappedratio NUMBER,   -- C?digo cl?usula Capped Ratio
      pscontraprot NUMBER,   -- Contrato XL protecci?n
      pcestado NUMBER,   --Estado de la versi?n
      -- Fin Bug 18319 - APD - 04/07/2011
       mensajes IN OUT t_iax_mensajes
   *************************************************************************/
   FUNCTION f_set_contratos(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pnpriori IN NUMBER,   --not null
      pfconini IN DATE,   --not null
      pnconrel IN NUMBER,
      pfconfin IN DATE,
      piautori IN NUMBER,
      piretenc IN NUMBER,
      piminces IN NUMBER,
      picapaci IN NUMBER,
      piprioxl IN NUMBER,
      pppriosl IN NUMBER,
      ptcontra IN VARCHAR2,
      ptobserv IN VARCHAR2,
      ppcedido IN NUMBER,
      ppriesgos IN NUMBER,
      ppdescuento IN NUMBER,
      ppgastos IN NUMBER,
      pppartbene IN NUMBER,
      pcreafac IN NUMBER,
      ppcesext IN NUMBER,
      pcgarrel IN NUMBER,
      pcfrecul IN NUMBER,
      psconqp IN NUMBER,
      pnverqp IN NUMBER,
      piagrega IN NUMBER,
      pimaxagr IN NUMBER,
      -- Bug 18319 - APD - 04/07/2011
      pclavecbr NUMBER,   -- F??rmula para el CBR
      pcercartera NUMBER,   -- Tipo E/R cartera
      piprimaesperadas NUMBER,   -- Primas esperadas totales para la versi??n
      pnanyosloss NUMBER,   -- A??os Loss-Corridos
      pcbasexl NUMBER,   -- Base para el c?!lculo XL
      pclosscorridor NUMBER,   -- C??digo cl?!usula Loss Corridor
      pccappedratio NUMBER,   -- C??digo cl?!usula Capped Ratio
      pscontraprot NUMBER,   -- Contrato XL protecci??n
      pcestado NUMBER,   --Estado de la versi??n
      pnversioprot NUMBER,   -- Version del Contrato XL protecci??n
      pncompext NUMBER,   --% Comisión extra prima (solo para POSITIVA)
	  pnretpol in NUMBER, -- EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por poliza NRETPOL 
      pnretcul in NUMBER, -- EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por Cumulo NRETCUL
      -- Fin Bug 18319 - APD - 04/07/2011
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'par?metros- pnversio : ' || pnversio || ' pscontra : ' || pscontra
            || ' pnversio : ' || pnversio;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_contratos';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Bug 18319 - APD - 06/07/2011 - se a?aden los campos
      -- clavecbr, cercartera, iprimaesperadas, nanyosloss,
      -- cbasexl, closscorridor, ccappedratio, scontraprot, cestado
      vnumerr := pac_rea.f_set_contratos(pscontra, pnversio, pnpriori, pfconini, pnconrel,
                                         pfconfin, piautori, piretenc, piminces, picapaci,
                                         piprioxl, pppriosl, ptcontra, ptobserv, ppcedido,
                                         ppriesgos, ppdescuento, ppgastos, pppartbene,
                                         pcreafac, ppcesext, pcgarrel, pcfrecul, psconqp,
                                         pnverqp, piagrega, pimaxagr, pclavecbr, pcercartera,
                                         piprimaesperadas, pnanyosloss, pcbasexl,
                                         pclosscorridor, pccappedratio, pscontraprot,
                                         pcestado, pnversioprot, pncompext, pnretpol, pnretcul); -- EDBR - 11/06/2019 - IAXIS3338 - se agregan parametros de Retencion por poliza NRETPOL y Retencion por Cumulo NRETCUL
      -- fin Bug 18319 - APD - 06/07/2011
      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_contratos;

     /*************************************************************************
       funci?n que inserta o actualiza informaci?n en codicontratos.
       PSCONTRA in number,--pk
       PSPLENO in number,
       PCEMPRES in number, --not null,
       PCTIPREA in number, --not null
       PFINICTR in date, -- not null
       PCRAMO in number,
       PCACTIVI in number,
       PCMODALI in number,
       PCCOLECT in number,
       PCTIPSEG in number,
       PCGARANT in number,
       PFFINCTR in date
       PNCONREL in number,
       PSCONAGR in number,
       PCVIDAGA in number,
       PCVIDAIR in number,
       PCTIPCUM in number,
       PCVALID in number
       PCMONEDA in varchar  -- Bug 18319 - APD - 04/07/2011
       PTDESCRIPCION in varchar  -- Bug 18319 - APD - 04/07/2011
       mensajes IN OUT t_iax_mensajes
   *************************************************************************/
   FUNCTION f_set_codicontratos(
      pscontra IN NUMBER,   --pk
      pspleno IN NUMBER,
      pcempres IN NUMBER,   --not null,
      pctiprea IN NUMBER,   --not null
      pfinictr IN DATE,   -- not null
      pcramo IN NUMBER,
      pcactivi IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      pcgarant IN NUMBER,
      pffinctr IN DATE,
      pnconrel IN NUMBER,
      psconagr IN NUMBER,
      pcvidaga IN NUMBER,
      pcvidair IN NUMBER,
      pctipcum IN NUMBER,
      pcvalid IN NUMBER,
      pcmoneda IN VARCHAR,   -- Bug 18319 - APD - 04/07/2011
      ptdescripcion IN VARCHAR,   -- Bug 18319 - APD - 04/07/2011
      pcdevento IN NUMBER,
      pnversio IN NUMBER,   -- INI - AXIS 4853 - 26/07/2019 - AABG - SE AGREGA ATRIBUTO PNVERSIO PARA AGR_CONTRATOS
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800) := 'par?metros- pscontra : ' || pscontra;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_codicontratos';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Bug 18319 - APD - 05/07/2011 - se a?aden los campos pcmoneda,ptdescripcion
      vnumerr := pac_rea.f_set_codicontratos(pscontra, pspleno, pcempres, pctiprea, pfinictr,
                                             pcramo, pcactivi, pcmodali, pccolect, pctipseg,
                                             pcgarant, pffinctr, pnconrel, psconagr, pcvidaga,
                                             pcvidair, pctipcum, pcvalid, pcmoneda,
                                             ptdescripcion, pcdevento, pnversio);
    -- FIN - AXIS 4853 - 26/07/2019 - AABG - SE AGREGA ATRIBUTO PNVERSIO PARA AGR_CONTRATOS                                             

      -- Fin Bug 18319 - APD - 05/07/2011
      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_codicontratos;

     /*************************************************************************
      Funci? per consultar els riscs que formen part d'un c?mul quan el SCUMULO del quadre estigui informat
      pscumulo in number
      mensajes in out t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_reariesgos(pscumulo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'par?metros - pscumulo:' || pscumulo;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_reariesgos';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(4000);
   BEGIN
      IF pscumulo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vsquery :=
         'SELECT s.npoliza, s.ncertif, r.nriesgo,
                    pac_md_obtenerdatos.f_desriesgos(''POL'', r.sseguro, r.nriesgo) triesgo
                 FROM reariesgos r, seguros s
                 WHERE r.sseguro = s.sseguro
                 AND scumulo = '
         || pscumulo
         || '
                 AND r.freafin IS NULL
                 order by s.fefecto';
      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 5;
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_reariesgos;

   /*FIN BUG 10990 : 07/09/2009 : ICV */

    /*BUG 11353 - 12/10/2009 - ICV - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
   /*************************************************************************
    Funci?n que inserta o modifica un contrato incluyendo TRAMOS, CUADROS
   *************************************************************************/
   FUNCTION f_set_contrato_rea(
      pscontra NUMBER,   -- Secuencia del contrato
      pspleno NUMBER,   -- Identificador del pleno
      pcempres NUMBER,   -- C?digo de empresa
      pctiprea NUMBER,   -- C?digo tipo contrato
      pcramo NUMBER,   -- C?digo de ramo
      pcmodali NUMBER,   -- C?digo de modalidad
      pctipseg NUMBER,   -- C?digo de tipo de seguro
      pccolect NUMBER,   -- C?digo de colectivo
      pcactivi NUMBER,   -- Actividad
      pcgarant NUMBER,   -- C?digo de garant?a
      pcvidaga NUMBER,   -- C?digo de forma de c?lculo
      psconagr NUMBER,
      pcvidair NUMBER,
      pctipcum NUMBER,
      pcvalid NUMBER,
      pnversio NUMBER,   -- N?mero versi?n contrato reas.
      pnpriori NUMBER,   -- Porcentaje local asumible
      pfconini DATE,   -- Fecha inicial de versi?n
      pnconrel NUMBER,   -- Contrato relacionado
      pfconfin DATE,   -- Fecha final de versi?n
      piautori NUMBER,   -- Importe con autorizaci?n
      piretenc NUMBER,   -- Importe pleno neto de retenci?n
      piminces NUMBER,
      -- Importe m?nimo cesi?n (Pleno neto de retenci?n)
      picapaci NUMBER,   -- Importe de capacidad m?xima
      piprioxl NUMBER,   -- Importe prioridad XL
      pppriosl NUMBER,   -- Prioridad SL
      ptobserv VARCHAR2,   -- Observaciones varias
      ppcedido NUMBER,   -- Porcentaje cedido
      ppriesgos NUMBER,   -- Porcentaje riesgos agravados
      ppdescuento NUMBER,
      -- Porcentaje de descuenctros de selecci?n
      ppgastos NUMBER,   -- Porcentaje de gastos (PB)
      pppartbene NUMBER,
      -- Porcentaje de participaci?n en beneficios (PB)
      pcreafac NUMBER,   -- C?digo de facultativo
      ppcesext NUMBER,
      -- Porcentaje de cesi?n sobre la extraprima
      pcgarrel NUMBER,   -- C?digo de la garant?a relacionada
      pcfrecul NUMBER,   -- Frecuencia de liquidaci?n con cia
      psconqp NUMBER,   -- Contrato CP relacionado
      pnverqp NUMBER,   -- Versi?n CP relacionado
      piagrega NUMBER,   -- Importe agregado XL
      pimaxagr NUMBER,
      -- Importe agregado m?ximo XL (L.A.A.),
      ptcontra VARCHAR2,
      p_tobtramos t_iax_tramos_rea,
      -- Bug 18319 - APD - 04/07/2011
      pcmoneda IN VARCHAR,   -- Codigo de la moneda
      ptdescripcion IN VARCHAR,   -- Descripcion del contrato
      pclavecbr NUMBER,   -- F?rmula para el CBR
      pcercartera NUMBER,   -- Tipo E/R cartera
      piprimaesperadas NUMBER,
      -- Primas esperadas totales para la versi?n
      pnanyosloss NUMBER,   -- A?os Loss-Corridos
      pcbasexl NUMBER,   -- Base para el c?lculo XL
      pclosscorridor NUMBER,   -- C?digo cl?usula Loss Corridor
      pccappedratio NUMBER,   -- C?digo cl?usula Capped Ratio
      pscontraprot NUMBER,   -- Contrato XL protecci?n
      pcestado NUMBER,   --Estado de la versi?n
      pnversioprot NUMBER,   -- Version del Contrato XL protecci?n
      pcdevento IN NUMBER,	  
      -- Fin Bug 18319 - APD - 04/07/2011
      pncomext NUMBER,   --% Comisión extra prima (solo para POSITIVA)
	  pnretpol NUMBER, -- EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por poliza NRETPOL
      pnretcul NUMBER, -- EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por Cumulo NRETCUL
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_MD_REA.f_set_contrato_rea';
      vparam         VARCHAR2(500)
                       := 'par?metros - pnversio: ' || pnversio || ' - pscontra: ' || pscontra;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_scontra      codicontratos.scontra%TYPE;
      v_dummy        NUMBER := 0;
      v_ultver       NUMBER := 0;
      vfconfin       DATE; --CONF-910
      vexistversion NUMBER := 0;
   BEGIN
      vpasexec := 2;

      --p_tab_error (f_sysdate,f_USER,'PAC_MD_REA', 1,  'pscontra : '||pscontra||' pnversio : '||pnversio ,sqlerrm);
      IF pscontra IS NULL THEN   --Estamos dando de alta uno nuevo
         -- Bug 18319 - APD - 11/07/2011 - se a?ade el IF pcramo IS NOT NULL
         -- ya que se quiere poder dar de alta contratos sin obligar a introducir el cramo
         IF pcramo IS NOT NULL THEN
            --Validaciones extra
            --Validacions de coherencia
            SELECT COUNT('1')
              INTO v_dummy
              FROM productos p
             WHERE p.cramo = pcramo
               AND(pcmodali IS NULL
                   OR p.cmodali = pcmodali)
               AND(pctipseg IS NULL
                   OR p.ctipseg = pctipseg)
               AND(pccolect IS NULL
                   OR p.ccolect = pccolect);

            IF v_dummy = 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 104347);
               RAISE e_object_error;
            END IF;

            IF pcactivi IS NOT NULL THEN
               SELECT COUNT('1')
                 INTO v_dummy
                 FROM activiprod a
                WHERE a.cramo = pcramo
                  AND a.cactivi = pcactivi
                  AND(pcmodali IS NULL
                      OR a.cmodali = pcmodali)
                  AND(pctipseg IS NULL
                      OR a.ctipseg = pctipseg)
                  AND(pccolect IS NULL
                      OR a.ccolect = pccolect);

               IF v_dummy = 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 500057);
                  RAISE e_object_error;
               END IF;
            END IF;

            IF pcgarant IS NOT NULL THEN
               SELECT COUNT('1')
                 INTO v_dummy
                 FROM garanpro g
                WHERE g.cramo = pcramo
                  AND g.cgarant = pcgarant
                  AND(pcmodali IS NULL
                      OR g.cmodali = pcmodali)
                  AND(pctipseg IS NULL
                      OR g.ctipseg = pctipseg)
                  AND(pccolect IS NULL
                      OR g.ccolect = pccolect)
                  AND(pcactivi IS NULL
                      OR g.cactivi = pcactivi);

               IF v_dummy = 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 105710);
                  RAISE e_object_error;
               END IF;
            END IF;

            --Validar que no hi ha cap contracte vigent pel mateix: cramo, cmodali, ctipseg, ccolect, cactivi i/o cgarant
            SELECT COUNT('1')
              INTO v_dummy
              FROM codicontratos c, contratos con, agr_contratos a
             WHERE c.scontra = con.scontra
               AND c.scontra = a.scontra(+)   -- 14536 14-05-2010 AVT
               AND a.cramo = pcramo
               AND(pcmodali IS NULL
                   OR a.cmodali = pcmodali)
               AND(pctipseg IS NULL
                   OR a.ctipseg = pctipseg)
               AND(pccolect IS NULL
                   OR a.ccolect = pccolect)
               AND(pcactivi IS NULL
                   OR a.cactivi = pcactivi)
               --INI BUG CONF-1048  Fecha (29/08/2017) - HRE - Contratos no proporcionales
               AND(pcdevento IS NULL
                   OR c.cdevento = pcdevento)
               --FIN BUG CONF-1048  - Fecha (29/08/2017) - HRE
               AND(pcgarant IS NULL
                   OR a.cgarant = pcgarant)
               AND con.fconini >= pfconini
               AND(con.fconfin IS NULL
                   OR con.fconfin <= NVL(pfconfin, pfconini));

            IF v_dummy > 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9900813);
               RAISE e_object_error;
            END IF;
         END IF;
      -- Fin Bug 18319 - APD - 11/07/2011
      END IF;

      --p_tab_error (f_sysdate,f_USER,'PAC_MD_REA', 3,  'pscontra : '||pscontra||' pnversio : '||pnversio|| 'pcvalid : '||pcvalid,sqlerrm);
      IF pcvalid = 1 THEN   --Si el contrato es valido, validamos
         -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion del objeto mensajes
         vnumerr := pac_md_rea.f_valida_contrato_rea(pctiprea, piretenc, picapaci,
                                                     p_tobtramos, mensajes);

         IF vnumerr <> 0 THEN
            --p_tab_error(f_sysdate, f_user, 'PAC_MD_REA', 3, 'vnumerr : ' || vnumerr, SQLERRM);
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 3;

      IF pscontra IS NULL THEN   --Estamos dando de alta uno nuevo
         SELECT scontra.NEXTVAL
           INTO v_scontra
           FROM DUAL;

         pac_iax_rea.v_new_scontra := v_scontra;
      ELSE
         v_scontra := pscontra;

         SELECT MAX(nversio)
           INTO v_ultver
           FROM contratos
          WHERE scontra = pscontra;
      END IF;

      --p_tab_error (f_sysdate,f_USER,'PAC_MD_REA', 4,  'v_scontra : '||v_scontra||' pnversio : '||pnversio|| 'pcvalid : '||pcvalid,sqlerrm);
      vpasexec := 4;

      --Insertamos Codcontratos
      IF pscontra IS NULL THEN
         -- Bug 18319 - APD - 04/07/2011 - se a?aden los campo pcmoneda y ptdescripcion
         -- INI - AXIS 4853 - 26/07/2019 - AABG - SE AGREGA ATRIBUTO PNVERSIO PARA AGR_CONTRATOS
         vnumerr := pac_md_rea.f_set_codicontratos(v_scontra, pspleno, pcempres, pctiprea,
                                                   TRUNC(f_sysdate), pcramo, pcactivi,
                                                   pcmodali, pccolect, pctipseg, pcgarant,
                                                   NULL, pnconrel, psconagr, pcvidaga,
                                                   pcvidair, pctipcum, pcvalid, pcmoneda,
                                                   ptdescripcion, pcdevento, pnversio, mensajes);
        -- FIN - AXIS 4853 - 26/07/2019 - AABG - SE AGREGA ATRIBUTO PNVERSIO PARA AGR_CONTRATOS                                                   

         -- Fin Bug 18319 - APD - 04/07/2011
         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;
      ELSE
         --Solamente modificamos el cvalid de codicontratos si existe.
         UPDATE codicontratos
            SET cvalid = pcvalid
          WHERE scontra = pscontra;
          
          -- INI - AXIS 4853 - 26/07/2019 - AABG - SE AGREGA VALIDACION PARA SABER SI YA EXISTE LA VERSION DEL CONTRATO EN AGR_CONTRATOS
          IF pcramo IS NOT NULL THEN
          
              SELECT COUNT(1) INTO vexistversion 
              FROM agr_contratos 
              WHERE scontra = pscontra AND cramo = pcramo AND nversio = pnversio;
              
              IF vexistversion <= 0 THEN
                --INSERTAR NUEVA VERSION
                vnumerr := pac_rea.f_set_agr_contratos(v_scontra, pnversio, pcramo, pcmodali,
                                                          pccolect, pctipseg, NULL, pcactivi, pcgarant, NULL);
                 IF vnumerr <> 0 THEN
                    RETURN vnumerr;
                 END IF;
              END IF;
          END IF;          
          -- FIN - AXIS 4853 - 26/07/2019 - AABG - SE AGREGA VALIDACION PARA SABER SI YA EXISTE LA VERSION DEL CONTRATO EN AGR_CONTRATOS
      END IF;

      vpasexec := 5;
      --Insertamos en CONTRATOS fconini = fconfin inicio y vencimiento han de ser iguales.
      -- Bug 18319 - APD - 04/07/2011 - se a?aden los campo pclavecbr, pcercartera, piprimaesperadas,
      -- pnanyosloss, pcbasexl, pclosscorridor, pccappedratio, pscontraprot, pcestado
      --CONF-910 Inicio
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'INFORMA_FECHA_FIN'),0) = 1 THEN
        vfconfin := pfconfin;
      ELSE
        vfconfin := pfconini;
      END IF;
      --CONF-910 End

      vnumerr := pac_md_rea.f_set_contratos(v_scontra, pnversio, pnpriori, pfconini, pnconrel,
                                            vfconfin, piautori, piretenc, piminces, picapaci,
                                            piprioxl, pppriosl, ptcontra, ptobserv, ppcedido,
                                            ppriesgos, ppdescuento, ppgastos, pppartbene,
                                            pcreafac, ppcesext, pcgarrel, pcfrecul, psconqp,
                                            pnverqp, piagrega, pimaxagr, pclavecbr,
                                            pcercartera, piprimaesperadas, pnanyosloss,
                                            pcbasexl, pclosscorridor, pccappedratio,
                                            pscontraprot, pcestado, pnversioprot, pncomext,pnretpol, pnretcul,
                                            mensajes);-- EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por poliza NRETPOL y Retencion por Cumulo NRETCUL

      -- Fin Bug 18319 - APD - 04/07/2011
      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      --Duplicamos las tablas REAFORMULA si se est? haciendo una nueva versi?n
      IF pscontra IS NOT NULL THEN
         --Solamente si estamos dando de alta una nueva versi?n

         /* p_tab_error (f_sysdate,f_USER,'PAC_MD_REA', 2,  'pscontra : '||pscontra
                  ||' pnversio : '||pnversio||'v_ultver :'|| v_ultver ,sqlerrm);*/
         IF pnversio <> v_ultver THEN
            --p_tab_error (f_sysdate,f_USER,'PAC_MD_REA', 6,  'MODIFICO-1',sqlerrm);
            FOR rc IN (SELECT *
                         FROM reaformula r
                        WHERE r.scontra = pscontra
                          AND r.nversio =(pnversio - 1)) LOOP
               vnumerr := pac_md_rea.f_set_reaformula(v_scontra, pnversio, rc.cgarant,
                                                      rc.ccampo, rc.clave, rc.sproduc,
                                                      mensajes);

               IF vnumerr <> 0 THEN
                  RETURN vnumerr;
               END IF;
            END LOOP;
         END IF;
      END IF;

      --p_tab_error (f_sysdate,f_USER,'PAC_MD_REA', 5,  'v_scontra : '||v_scontra||' pnversio : '||pnversio|| 'pcvalid : '||pcvalid,sqlerrm);
      vpasexec := 6;
      --p_tab_error (f_sysdate,f_USER,'PAC_MD_REA', 6,  'RECIBO T_OBTRAMOS COUNT : '||p_tobtramos.count,sqlerrm);
      /*FOR v_tramo IN cur_tramos LOOP
         --p_tab_error (f_sysdate,f_USER,'PAC_MD_REA', 7,  'INSERTAMOS EL TRAMO NVERSIO :'||p_tobtramos(i).nversio||' V_SCONTRA : '||v_scontra,sqlerrm);

         --Insertamos el TRAMO
         vnumerr := pac_md_rea.f_set_tramos(p_tobtramos(i).nversio, v_scontra,
                                            p_tobtramos(i).ctramo, p_tobtramos(i).itottra,
                                            p_tobtramos(i).nplenos, p_tobtramos(i).cfrebor,
                                            p_tobtramos(i).plocal, p_tobtramos(i).ixlprio,
                                            p_tobtramos(i).ixlexce, p_tobtramos(i).pslprio,
                                            p_tobtramos(i).pslexce, p_tobtramos(i).ncesion,
                                            p_tobtramos(i).fultbor, p_tobtramos(i).imaxplo,
                                            p_tobtramos(i).norden, p_tobtramos(i).nsegcon,
                                            p_tobtramos(i).nsegver, p_tobtramos(i).iminxl,
                                            p_tobtramos(i).idepxl, p_tobtramos(i).nctrxl,
                                            p_tobtramos(i).nverxl, p_tobtramos(i).ptasaxl,
                                            p_tobtramos(i).ipmd, p_tobtramos(i).cfrepmd,
                                            p_tobtramos(i).caplixl, p_tobtramos(i).plimgas,
                                            p_tobtramos(i).pliminx,
                                            -- Bug 18319 - APD - 04/04/2011
                                            p_tobtramos(i).idaa, p_tobtramos(i).ilaa,
                                            p_tobtramos(i).ctprimaxl,
                                            p_tobtramos(i).iprimafijaxl,
                                            p_tobtramos(i).iprimaestimada,
                                            p_tobtramos(i).caplictasaxl,
                                            p_tobtramos(i).ctiptasaxl,
                                            p_tobtramos(i).ctramotasaxl,
                                            p_tobtramos(i).pctpdxl,
                                            p_tobtramos(i).cforpagpdxl,
                                            p_tobtramos(i).pctminxl, p_tobtramos(i).pctpb,
                                            p_tobtramos(i).nanyosloss,
                                            p_tobtramos(i).closscorridor,
                                            p_tobtramos(i).ccappedratio,
                                            p_tobtramos(i).crepos, p_tobtramos(i).ibonorec,
                                            p_tobtramos(i).impaviso,
                                            p_tobtramos(i).impcontado,
                                            p_tobtramos(i).pctcontado,
                                            p_tobtramos(i).pctgastos,
                                            p_tobtramos(i).ptasaajuste,
                                            p_tobtramos(i).icapcoaseg,
                                            -- Fin Bug 18319 - APD - 04/04/2011
                                            mensajes);

         IF vnumerr <> 0 THEN
            --p_tab_error (f_sysdate,f_USER,'PAC_MD_REA', 7,  'CASQUE PAC_MD_REA_SET_TRAMOS :'||vnumerr,sqlerrm);
            RETURN vnumerr;
         END IF;

         vpasexec := 7;

         --Insertamos los cuadros del tramo
         IF p_tobtramos(i).cuadroces IS NOT NULL THEN
            vpasexec := 8;

            IF p_tobtramos(i).cuadroces.COUNT > 0 THEN
               FOR n IN p_tobtramos(i).cuadroces.FIRST .. p_tobtramos(i).cuadroces.LAST LOOP
                  --Duplicamos las tablas ctatecnica si se est? haciendo una nueva versi?n por TRAMO y cuadro

                  /p_tab_error (f_sysdate,f_USER,'PAC_MD_REA', 1,  'pscontra : '||pscontra
                  ||' pnversio : '||pnversio||'v_ultver :'|| v_ultver||' p_tobtramos(i).ctramo '|| p_tobtramos(i).ctramo||' p_tobtramos(i).cuadroces(n).ccompani '|| p_tobtramos(i).cuadroces(n).ccompani ,sqlerrm);/
                  IF pscontra IS NOT NULL THEN
                     IF pnversio <> v_ultver THEN
                        --p_tab_error (f_sysdate,f_USER,'PAC_MD_REA', 6,  'MODIFICO-2',sqlerrm);
                        FOR rc IN (SELECT *
                                     FROM ctatecnica c
                                    WHERE c.scontra = pscontra
                                      AND c.nversio =(pnversio - 1)
                                      AND c.ctramo = p_tobtramos(i).ctramo
                                      AND c.ccompani = p_tobtramos(i).cuadroces(n).ccompani) LOOP
                           vnumerr :=
                              pac_md_rea.f_set_ctatecnica
                                                       (p_tobtramos(i).cuadroces(n).ccompani,
                                                        v_scontra, pnversio,
                                                        p_tobtramos(i).ctramo,
                                                        (rc.nctatec + 1), 3, 1, NULL, NULL,
                                                        pcempres, 0,
                                                        p_tobtramos(i).cuadroces(n).ccorred,
                                                        mensajes);
                        END LOOP;

                        IF vnumerr <> 0 THEN
                           RETURN vnumerr;
                        END IF;
                     END IF;
                  END IF;

                  -- Bug 18319 - APD - 05/07/2011 - se a?aden los campos pctipcomis,
                  -- ppctcomis, pctramocomision
                  vnumerr :=
                     pac_md_rea.f_set_cuadroces(p_tobtramos(i).cuadroces(n).ccompani,
                                                p_tobtramos(i).cuadroces(n).nversio,
                                                v_scontra,
                                                p_tobtramos(i).cuadroces(n).ctramo,
                                                p_tobtramos(i).cuadroces(n).ccomrea,
                                                p_tobtramos(i).cuadroces(n).pcesion,
                                                p_tobtramos(i).cuadroces(n).nplenos,
                                                p_tobtramos(i).cuadroces(n).icesfij,
                                                p_tobtramos(i).cuadroces(n).icomfij,
                                                p_tobtramos(i).cuadroces(n).isconta,
                                                p_tobtramos(i).cuadroces(n).preserv,
                                                p_tobtramos(i).cuadroces(n).pintres,
                                                p_tobtramos(i).cuadroces(n).iliacde,
                                                p_tobtramos(i).cuadroces(n).ppagosl,
                                                p_tobtramos(i).cuadroces(n).ccorred,
                                                p_tobtramos(i).cuadroces(n).cintres,
                                                p_tobtramos(i).cuadroces(n).cintref,
                                                p_tobtramos(i).cuadroces(n).cresref,
                                                p_tobtramos(i).cuadroces(n).ireserv,
                                                p_tobtramos(i).cuadroces(n).ptasaj,
                                                p_tobtramos(i).cuadroces(n).fultliq,
                                                p_tobtramos(i).cuadroces(n).iagrega,
                                                p_tobtramos(i).cuadroces(n).imaxagr,
                                                p_tobtramos(i).cuadroces(n).ctipcomis,
                                                p_tobtramos(i).cuadroces(n).pctcomis,
                                                p_tobtramos(i).cuadroces(n).ctramocomision,
                                                mensajes);

                  -- Fin Bug 18319 - APD - 05/07/2011
                  IF vnumerr <> 0 THEN
                     RETURN vnumerr;
                  END IF;
               END LOOP;
            END IF;
         END IF;

         vpasexec := 9;
      END LOOP;*/

      /* vpasexec := 10;
       IF vnumerr = 0 THEN
         COMMIT;
       ELSE
          ROLLBACK;
       END IF;*/
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         --p_tab_error (f_sysdate,f_USER,'PAC_MD_REA', 7,  'OTHERS :',sqlerrm);
         RETURN 1;
   END f_set_contrato_rea;

   /*************************************************************************
    Funci?n que devuelve la ?ltima versi?n de un contrato.
   *************************************************************************/
   FUNCTION f_get_nversio(
      pscontra IN NUMBER,
      pnversio_datos OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'par?metros - pscontra:' || pscontra;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(2000);
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_nversio';
      v_nversio      NUMBER;
   BEGIN
      -- se devuelve el nversio de la ultima version del contrato
      -- ya que se necesita por pantalla para recuperar los datos de la
      -- version anterior en el caso que se este dando de alta una nueva
      -- version
      -- en el caso que se est? modificando una version, el parametro de salida
      -- pnversio_datos y el nversio que devuelve la funcion sera el mismo
      SELECT NVL(MAX(c2.nversio), 1)
        INTO pnversio_datos
        FROM contratos c2
       WHERE c2.scontra = pscontra;

      --SELECT DECODE(c.fconfin, NULL,(c.nversio + 1), nversio) nversio
	  SELECT NVL(c.nversio,0) + 1            -- EDBR - 03/07/2019 - IAXIS4529 - se cambia el select para que retorne dato de NUEVA VERSION
        INTO v_nversio
        FROM contratos c
       WHERE c.scontra = pscontra
         AND c.nversio = (SELECT MAX(c2.nversio)
                            FROM contratos c2
                           WHERE c2.scontra = c.scontra);

      RETURN v_nversio;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_get_nversio;

   /*************************************************************************
     Funci?n que inicializa el objeto de BD en memoria
     *************************************************************************/
   FUNCTION f_set_t_tramo_mem(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_tramos_rea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                         := 'par?metros - pscontra:' || pscontra || ' - pnversio:' || pnversio;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_t_tramo_mem';
      v_tobtramos    t_iax_tramos_rea;
      v_nvernuevo    contratos.nversio%TYPE;
      v_nversio_datos contratos.nversio%TYPE;
   BEGIN
      IF pscontra IS NULL
         OR pnversio IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      --Recuperamos los tramos de la versi?n a modificar
      v_tobtramos := pac_md_rea.f_get_tramos_rea(pscontra, pnversio, mensajes);
      --Recuperamos el nversi? nuevo
      v_nvernuevo := f_get_nversio(pscontra, v_nversio_datos, mensajes);

      --Actualizamos el nversio del objeto si se est? creando una nueva versi?n.
      IF v_nvernuevo <> pnversio THEN
         FOR i IN v_tobtramos.FIRST .. v_tobtramos.LAST LOOP
            v_tobtramos(i).nversio := v_nvernuevo;

            IF v_tobtramos(i).cuadroces IS NOT NULL THEN
               FOR n IN v_tobtramos(i).cuadroces.FIRST .. v_tobtramos(i).cuadroces.LAST LOOP
                  v_tobtramos(i).cuadroces(n).nversio := v_nvernuevo;
               END LOOP;
            END IF;
         END LOOP;
      END IF;

      RETURN v_tobtramos;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RAISE;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RAISE;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RAISE;
   END f_set_t_tramo_mem;

   /*************************************************************************
   Funci?n que inserta / actualiza las formulas del reaseguro
   *************************************************************************/
   FUNCTION f_set_reaformula(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      psproduc IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'par?metros- pscontra :' || pscontra || ' pnversio : ' || pnversio
            || ' pcgarant : ' || pcgarant || ' pccampo :' || pccampo || ' pclave : ' || pclave
            || ' psproduc : ' || psproduc;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_reaformula';
      v_error        NUMBER := 0;
   BEGIN
      v_error := pac_rea.f_set_reaformula(pscontra, pnversio, pcgarant, pccampo, pclave,
                                          psproduc);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_reaformula;

   /*************************************************************************
   Funci?n que inserta / actualiza las cuentas t?cnicas del reaseguro
   *************************************************************************/
   FUNCTION f_set_ctatecnica(
      pccompani IN NUMBER,
      pnversio IN NUMBER,
      pscontra IN NUMBER,
      pctramo IN NUMBER,
      pnctatec IN NUMBER,
      pcfrecul IN NUMBER,
      pcestado IN NUMBER,
      pfestado IN DATE,
      pfultimp IN DATE,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pccorred IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'par?metros- pccompani :' || pccompani || ' pscontra :' || pscontra
            || ' pnversio : ' || pnversio || ' pctramo : ' || pctramo || ' pNCTATEC :'
            || pnctatec || ' pCFRECUL : ' || pcfrecul || ' pCESTADO : ' || pcestado
            || ' pfestado : ' || pfestado || ' pFULTIMP : ' || pfultimp;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_ctatecnica';
      v_error        NUMBER := 0;
   BEGIN
      v_error := pac_rea.f_set_ctatecnica(pccompani, pnversio, pscontra, pctramo, pnctatec,
                                          pcfrecul, pcestado, pfestado, pfultimp, pcempres,
                                          psproduc, pccorred);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_ctatecnica;

/*FIN BUG 11353 : 12/10/2009 : ICV */

   -- Bug 18319 - APD - 07/07/2011
   -- se crea la funcion
   FUNCTION f_del_cuadroces(
      pccompani IN NUMBER,   --ob
      pnversio IN NUMBER,   --ob
      pscontra IN NUMBER,   --ob
      pctramo IN NUMBER,   --ob
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'par?metros- pccompani :' || pccompani || ' pscontra :' || pscontra
            || ' pnversio : ' || pnversio || ' pctramo : ' || pctramo;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_del_cuadroces';
      v_error        NUMBER := 0;
   BEGIN
      v_error := pac_rea.f_del_cuadroces(pccompani, pnversio, pscontra, pctramo);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_cuadroces;

   -- Bug 18319 - APD - 07/07/2011
   -- se crea la funcion
   FUNCTION f_del_tramos(
      pnversio IN NUMBER,
      pscontra IN NUMBER,
      pctramo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'par?metros- pscontra :' || pscontra || ' pnversio : ' || pnversio
            || ' pctramo : ' || pctramo;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_del_tramos';
      v_error        NUMBER := 0;
   BEGIN
      v_error := pac_rea.f_del_tramos(pnversio, pscontra, pctramo);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_tramos;

   /*************************************************************************
   Funci?n que selecciona todas las cl?usulas de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_cod_clausulas_reas(
      pccodigo IN NUMBER,
      pctipo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pccodigo = ' || pccodigo || ';pctipo = ' || pctipo;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_cod_clausulas_reas';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
   BEGIN
      vsquery :=
         'Select ccr.ccodigo codigo, cr.tdescripcion descripccion,
                  ccr.ctipo, ff_desvalorfijo(346,'
         || vidioma
         || ',ccr.ctipo) ttipo,
                  ccr.fefecto fefecto, ccr.fvencim fvencim
           From cod_clausulas_reas ccr, clausulas_reas cr
          Where (ccr.ccodigo = NVL('
         || NVL(TO_CHAR(pccodigo), 'NULL') || ',ccr.ccodigo))' || ' AND (ccr.ctipo = NVL('
         || NVL(TO_CHAR(pctipo), 'NULL') || ',ccr.ctipo))'
         || ' AND ccr.ccodigo = cr.ccodigo(+) ' || ' AND cr.cidioma(+) = ' || vidioma;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_cod_clausulas_reas;

   /*************************************************************************
   Funci?n que dada una cl?usula de reaseguro, devuelve su descripci?n
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_clausulas_reas(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pccodigo = ' || pccodigo || ';pcidioma = ' || pcidioma;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_clausulas_reas';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
   BEGIN
      vsquery :=
         'Select cr.cidioma, ff_desvalorfijo(255,' || vidioma
         || ', cr.cidioma) tidioma,
                 cr.tdescripcion tdescripcion
           From clausulas_reas cr
          Where (cr.ccodigo = NVL('
         || NVL(TO_CHAR(pccodigo), 'NULL') || ',cr.ccodigo))' || ' AND (cr.cidioma = NVL('
         || NVL(TO_CHAR(pcidioma), 'NULL') || ',cr.cidioma))';
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_clausulas_reas;

   /*************************************************************************
   Funci?n que dada una cl?usula de reaseguro, devuelve sus tramos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_clausulas_reas_det(
      pccodigo IN NUMBER,
      pctramo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pccodigo = ' || pccodigo || ';pctramo = ' || pctramo;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_clausulas_reas_det';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
   BEGIN
      vsquery :=
         'Select crd.ctramo, crd.ilim_inf, crd.ilim_sup, crd.pctpart,
           crd.pctmin, crd.pctmax
           From clausulas_reas_det crd
          Where (crd.ccodigo = NVL('
         || NVL(TO_CHAR(pccodigo), 'NULL') || ',crd.ccodigo))' || ' AND (crd.ctramo = NVL('
         || NVL(TO_CHAR(pctramo), 'NULL') || ',crd.ctramo))';
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_clausulas_reas_det;

   /*************************************************************************
   Funci?n que graba una cl?usula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_cod_clausulas_reas(
      pcmodo IN NUMBER,
      pccodigo IN NUMBER,
      pctipo IN NUMBER,
      pfefecto IN DATE,
      pfvencim IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'par?metros- pcmodo : ' || pcmodo || '; pccodigo : ' || pccodigo || '; pctipo : '
            || pctipo || '; pfefecto : ' || pfefecto || '; pfvencim : ' || pfvencim;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_cod_clausulas_reas';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_rea.f_set_cod_clausulas_reas(pcmodo, pccodigo, pctipo, pfefecto,
                                                  pfvencim);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_cod_clausulas_reas;

   /*************************************************************************
   Funci?n que guarda una descripci?n de una cl?usula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_clausulas_reas(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      ptdescripcion IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'par?metros- pccodigo : ' || pccodigo || '; pcidioma : ' || pcidioma
            || '; ptdescripcion : ' || ptdescripcion;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_clausulas_reas';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Bug 18319 - APD - 05/07/2011 - se a?aden los campos pcmoneda,ptdescripcion
      vnumerr := pac_rea.f_set_clausulas_reas(pccodigo, pcidioma, ptdescripcion);

      -- Fin Bug 18319 - APD - 05/07/2011
      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_clausulas_reas;

   /*************************************************************************
   Funci?n que guarda un tramo de una cl?usula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_clausulas_reas_det(
      pcmodo IN NUMBER,
      pccodigo IN NUMBER,
      pctramo IN NUMBER,
      plim_inf IN NUMBER,
      plim_sup IN NUMBER,
      ppctpart IN NUMBER,
      ppctmin IN NUMBER,
      ppctmax IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'par?metros- pcmodo : ' || pcmodo || '; pccodigo : ' || pccodigo || '; pctramo : '
            || pctramo || '; plim_inf : ' || plim_inf || '; plim_sup : ' || plim_sup
            || '; ppctpart : ' || ppctpart || '; ppctmin : ' || ppctmin || '; ppctmax : '
            || ppctmax;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_clausulas_reas_det';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Bug 18319 - APD - 05/07/2011 - se a?aden los campos pcmoneda,ptdescripcion
      vnumerr := pac_rea.f_set_clausulas_reas_det(pcmodo, pccodigo, pctramo, plim_inf,
                                                  plim_sup, ppctpart, ppctmin, ppctmax);

      -- Fin Bug 18319 - APD - 05/07/2011
      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_clausulas_reas_det;

   /*************************************************************************
   Funci?n que elimina una descripci?n una cl?usula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_clausulas_reas(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
                       := 'par?metros- pccodigo : ' || pccodigo || '; pcidioma : ' || pcidioma;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_del_clausulas_reas';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Bug 18319 - APD - 04/07/2011 - se a?aden los parametros pcmoneda y ptdescripcion
      vnumerr := pac_rea.f_del_clausulas_reas(pccodigo, pcidioma);

      -- Fin Bug 18319 - APD - 04/07/2011
      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_clausulas_reas;

   /*************************************************************************
   Funci?n que elimina un tramo una cl?usula de reaseguro o un tramo escalonado
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_clausulas_reas_det(
      pccodigo IN NUMBER,
      pctramo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
                         := 'par?metros- pccodigo : ' || pccodigo || '; pctramo : ' || pctramo;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_del_clausulas_reas_det';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_rea.f_del_clausulas_reas_det(pccodigo, pctramo);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_clausulas_reas_det;

   /*************************************************************************
   Funci?n que selecciona todas las reposiciones
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_cod_reposicion(pccodigo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pccodigo = ' || pccodigo;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_cod_reposicion';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
   BEGIN
      vsquery :=
         'Select cr.ccodigo ccodigo, r.tdescripcion tdescripcion
           From cod_reposicion cr, reposiciones r
          Where (cr.ccodigo = NVL('
         || NVL(TO_CHAR(pccodigo), 'NULL') || ',cr.ccodigo))'
         || ' AND cr.ccodigo = r.ccodigo(+) ' || ' AND r.cidioma(+) = ' || vidioma;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_cod_reposicion;

   /*************************************************************************
   Funci?n que dada una reposicion, devuelve su descripci?n
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_reposiciones(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pccodigo = ' || pccodigo || ';pcidioma = ' || pcidioma;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_reposiciones';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
   BEGIN
      vsquery :=
         'Select ff_desvalorfijo(255,' || vidioma
         || ', r.cidioma) tidioma,
                 r.tdescripcion tdescripcion
           From reposiciones r
          Where (r.ccodigo = NVL('
         || NVL(TO_CHAR(pccodigo), 'NULL') || ',r.ccodigo))' || ' AND (r.cidioma = NVL('
         || NVL(TO_CHAR(pcidioma), 'NULL') || ',r.cidioma))';
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_reposiciones;

   /*************************************************************************
   Funci?n que dada una reposicion, devuelve sus tramos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_reposiciones_det(
      pccodigo IN NUMBER,
      pnorden IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pccodigo = ' || pccodigo || ';pnorden = ' || pnorden;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_reposiciones_det';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
   BEGIN
      vsquery :=
         'Select rd.norden, rd.icapacidad, rd.ptasa
           From reposiciones_det rd
          Where (rd.ccodigo = NVL('
         || NVL(TO_CHAR(pccodigo), 'NULL') || ',rd.ccodigo))' || ' AND (rd.norden = NVL('
         || NVL(TO_CHAR(pnorden), 'NULL') || ',rd.norden))';
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_reposiciones_det;

/*************************************************************************
Funci?n que graba una reposicion
*************************************************************************/
-- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_cod_reposicion(pccodigo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800) := 'par?metros- pccodigo : ' || pccodigo;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_cod_reposicion';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_rea.f_set_cod_reposicion(pccodigo);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_cod_reposicion;

   /*************************************************************************
   Funci?n que guarda una descripci?n de una reposicion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_reposiciones(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      ptdescripcion IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'par?metros- pccodigo : ' || pccodigo || '; pcidioma : ' || pcidioma
            || '; ptdescripcion : ' || ptdescripcion;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_reposiciones';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_rea.f_set_reposiciones(pccodigo, pcidioma, ptdescripcion);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_reposiciones;

   /*************************************************************************
   Funci?n que guarda un tramo de una reposicion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_reposiciones_det(
      pcmodo IN NUMBER,
      pccodigo IN NUMBER,
      pnorden IN NUMBER,
      picapacidad IN NUMBER,
      pptasa IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'par?metros- pcmodo : ' || pcmodo || '; pccodigo : ' || pccodigo || '; pnorden : '
            || pnorden || '; picapacidad : ' || picapacidad || '; pptasa : ' || pptasa;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_reposiciones_det';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_rea.f_set_reposiciones_det(pcmodo, pccodigo, pnorden, picapacidad,
                                                pptasa);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_reposiciones_det;

   /*************************************************************************
   Funci?n que elimina una reposici?n
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_cod_reposicion(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
                       := 'par?metros- pccodigo : ' || pccodigo || '; pcidioma : ' || pcidioma;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_del_cod_reposicion';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_rea.f_del_cod_reposicion(pccodigo, pcidioma);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_cod_reposicion;

   /*************************************************************************
   Funci?n que elimina un detalle de una reposici?n
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_reposiciones_det(
      pccodigo IN NUMBER,
      pnorden IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
                         := 'par?metros- pccodigo : ' || pccodigo || '; pnorden : ' || pnorden;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_del_reposiciones_det';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_rea.f_del_reposiciones_det(pccodigo, pnorden);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_reposiciones_det;

   /*************************************************************************
   Funci?n que guarda una agrupacion de contrato
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_agrupcontrato(psconagr IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800) := 'par?metros- psconagr : ' || psconagr;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_agrupcontrato';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_rea.f_set_agrupcontrato(psconagr);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_agrupcontrato;

   /*************************************************************************
   Funci?n que guarda una descripcion de una agrupacion de contrato
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_desagrupcontrato(
      psconagr IN NUMBER,
      pcidioma IN NUMBER,
      ptconagr IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'par?metros- psconagr : ' || psconagr || '; pcidioma : ' || pcidioma
            || '; ptconagr = ' || ptconagr;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_desagrupcontrato';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_rea.f_set_desagrupcontrato(psconagr, pcidioma, ptconagr);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_desagrupcontrato;

   /*************************************************************************
   Funci?n que selecciona todas las asociaciones de productos a contratos
   *************************************************************************/
   -- BUG 28492 - INICIO - DCT - 11/10/2013 - Añadir pilimsub
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_agr_contratos(
      pscontra IN NUMBER,
      psversion IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800)
         := 'pscontra = ' || pscontra || '; psversion = ' || psversion || '; pcramo = '
            || pcramo || '; pcmodali = ' || pcmodali || '; pccolect = ' || pccolect
            || '; pctipseg = ' || pctipseg || '; psproduc = ' || psproduc || '; pcactivi = '
            || pcactivi || '; pcgarant = ' || pcgarant;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_agr_contratos';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      vcramo         agr_contratos.cramo%TYPE;
      vcmodali       agr_contratos.cmodali%TYPE;
      vccolect       agr_contratos.ccolect%TYPE;
      vctipseg       agr_contratos.ctipseg%TYPE;
   BEGIN
      vcramo := pcramo;
      vcmodali := pcmodali;
      vccolect := pccolect;
      vctipseg := pctipseg;

      IF psproduc IS NOT NULL THEN
         SELECT cramo, cmodali, ccolect, ctipseg
           INTO vcramo, vcmodali, vccolect, vctipseg
           FROM productos
          WHERE sproduc = psproduc;
      END IF;

      vsquery :=
         '  Select agrc.scontra, agrc.nversio, ' || 'agrc.cramo, '
         || ' (select tramo from ramos where cramo = agrc.cramo and cidioma = pac_md_common.f_get_cxtidioma()) tramo, '
         || ' agrc.cmodali, agrc.ccolect, agrc.ctipseg, '
         || ' (SELECT sproduc FROM productos WHERE cramo = agrc.cramo and cmodali = agrc.cmodali and ccolect = agrc.ccolect and ctipseg = agrc.ctipseg) sproduc, '
         || ' (SELECT ttitulo FROM titulopro WHERE cramo = agrc.cramo and cmodali = agrc.cmodali and ccolect = agrc.ccolect and ctipseg = agrc.ctipseg and cidioma = pac_md_common.f_get_cxtidioma()) tproduc, '
         || ' agrc.cactivi, '
         || ' (select ttitulo from activisegu where cactivi = agrc.cactivi and cramo = agrc.cramo and cidioma = pac_md_common.f_get_cxtidioma) tactivi, '
         || ' agrc.cgarant, '
         || ' (SELECT tgarant FROM garangen WHERE cgarant = agrc.cgarant AND cidioma = pac_md_common.f_get_cxtidioma()) tgarant, '
         || ' agrc.ilimsub ' || ' From agr_contratos agrc' || ' Where (agrc.scontra = NVL('
         || NVL(TO_CHAR(pscontra), 'NULL') || ',agrc.scontra))'
         || ' AND (NVL(agrc.nversio,1) = NVL(' || NVL(TO_CHAR(psversion), 'NULL')
         || ',NVL(agrc.nversio,1)))' || ' AND (agrc.cramo = NVL('
         || NVL(TO_CHAR(vcramo), 'NULL') || ',agrc.cramo))'
         || ' AND (NVL(agrc.cmodali,1) = NVL(' || NVL(TO_CHAR(vcmodali), 'NULL')
         || ',NVL(agrc.cmodali,1)))' || ' AND (NVL(agrc.ccolect,1) = NVL('
         || NVL(TO_CHAR(vccolect), 'NULL') || ',NVL(agrc.ccolect,1)))'
         || ' AND (NVL(agrc.ctipseg,1) = NVL(' || NVL(TO_CHAR(vctipseg), 'NULL')
         || ',NVL(agrc.ctipseg,1)))' || ' AND (NVL(agrc.cactivi,1) = NVL('
         || NVL(TO_CHAR(pcactivi), 'NULL') || ',NVL(agrc.cactivi,1)))'
         || ' AND (NVL(agrc.cgarant,1) = NVL(' || NVL(TO_CHAR(pcgarant), 'NULL')
         || ',NVL(agrc.cgarant,1)))';
      --|| ',NVL(agrc.cgarant,1))) ORDER BY agrc.scontra, agrc.nversio';   --33116-189843  KJSC Ordenar els contractesseleccionats
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_agr_contratos;

/*************************************************************************
Funci?n que graba una asociacion
*************************************************************************/
-- BUG 28492 - INICIO - DCT - 11/10/2013 - Añadir pilimsub
-- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_agr_contratos(
      pscontra IN NUMBER,
      psversion IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pilimsub IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'pscontra = ' || pscontra || '; psversion = ' || psversion || '; pcramo = '
            || pcramo || '; pcmodali = ' || pcmodali || '; pccolect = ' || pccolect
            || '; pctipseg = ' || pctipseg || '; psproduc = ' || psproduc || '; pcactivi = '
            || pcactivi || '; pcgarant = ' || pcgarant || '; pilimsub  = ' || pilimsub;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_agr_contratos';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_rea.f_set_agr_contratos(pscontra, psversion, pcramo, pcmodali, pccolect,
                                             pctipseg, psproduc, pcactivi, pcgarant, pilimsub);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_agr_contratos;

-- BUG 28492 - FIN - DCT - 11/10/2013 - Añadir pilimsub

   /*************************************************************************
Funci?n que elimina una asociacion
*************************************************************************/
-- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_agr_contratos(
      pscontra IN NUMBER,
      psversion IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'pscontra = ' || pscontra || '; psversion = ' || psversion || '; pcramo = '
            || pcramo || '; pcmodali = ' || pcmodali || '; pccolect = ' || pccolect
            || '; pctipseg = ' || pctipseg || '; psproduc = ' || psproduc || '; pcactivi = '
            || pcactivi || '; pcgarant = ' || pcgarant;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_del_agr_contratos';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_rea.f_del_agr_contratos(pscontra, psversion, pcramo, pcmodali, pccolect,
                                             pctipseg, psproduc, pcactivi, pcgarant);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_agr_contratos;

   /*************************************************************************
   Funci?n que selecciona todas las asociaciones de f?rmulas a garant?as
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_reaformula(
      pscontra IN NUMBER,
      pnversion IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800)
         := 'pscontra = ' || pscontra || '; pnversion = ' || pnversion || '; psproduc = '
            || psproduc || '; pcactivi = ' || pcactivi || '; pcgarant = ' || pcgarant
            || '; pccampo = ' || pccampo || '; pclave = ' || pclave;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_reaformula';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
   BEGIN
      vsquery :=
         '  Select reaf.scontra, reaf.nversio, reaf.sproduc, '
         || ' (SELECT t.ttitulo FROM titulopro t, productos p
               WHERE p.cramo = t.cramo and p.cmodali = t.cmodali and p.ccolect = t.ccolect and p.ctipseg = t.ctipseg and cidioma = pac_md_common.f_get_cxtidioma()
                 AND p.sproduc = reaf.sproduc) tproduc, '
         --|| 'reaf.cactivi, '
         || ' reaf.cgarant, '
         || ' (SELECT tgarant FROM garangen WHERE cgarant = reaf.cgarant AND cidioma = pac_md_common.f_get_cxtidioma()) tgarant,'
         || 'reaf.ccampo, reaf.clave, ' || ' cc.tcampo, sgt.codigo '
         || ' From reaformula reaf,' || ' codcampo cc, sgt_formulas sgt '
         || ' Where reaf.ccampo = cc.ccampo ' || ' AND reaf.clave = sgt.clave '
         || ' AND (reaf.scontra = NVL(' || NVL(TO_CHAR(pscontra), 'null') || ',reaf.scontra))'
         || ' AND (reaf.nversio = NVL(' || NVL(TO_CHAR(pnversion), 'null')
         || ',reaf.nversio))' || ' AND (NVL(reaf.sproduc,1) = NVL('
         || NVL(TO_CHAR(psproduc), 'null') || ',NVL(reaf.sproduc,1)))'
         --|| ' AND (reaf.cactivi = NVL(' || NVL(TO_CHAR(pcactivi), 'NULL') || ',reaf.cactivi))'
         || ' AND (reaf.cgarant = NVL(' || NVL(TO_CHAR(pcgarant), 'null') || ',reaf.cgarant))'
         || ' AND (reaf.ccampo = NVL(' || NVL(TO_CHAR(pccampo), 'null') || ',reaf.ccampo))'
         || ' AND (reaf.clave = NVL(' || NVL(TO_CHAR(pclave), 'null') || ',reaf.clave))';
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_reaformula;

   /*************************************************************************
   Funci?n que graba una asociacion de f?rmulas a garant?as
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   -- 20/09/2011 - de momento no se crea esta funcion y se utiliza la funcion
   -- f_set_reaformula ya existente
/*
   FUNCTION f_set_reaformula(
      pscontra IN NUMBER,
      pnversion IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'pscontra = ' || pscontra || '; pnversion = ' || pnversion || '; psproduc = '
            || psproduc || '; pcactivi = ' || pcactivi || '; pcgarant = ' || pcgarant
            || '; pccampo = ' || pccampo || '; pclave = ' || pclave;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_reaformula';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_rea.f_set_reaformula(pscontra, pnversion, psproduc, pcactivi, pcgarant,
                                          pccampo, pclave);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_reaformula;
*/

   /*************************************************************************
   Funci?n que elimina una asociacion de f?rmulas a garant?as
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_reaformula(
      pscontra IN NUMBER,
      pnversion IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'pscontra = ' || pscontra || '; pnversion = ' || pnversion || '; psproduc = '
            || psproduc || '; pcactivi = ' || pcactivi || '; pcgarant = ' || pcgarant
            || '; pccampo = ' || pccampo || '; pclave = ' || pclave;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_del_reaformula';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_rea.f_del_reaformula(pscontra, pnversion, psproduc, pcactivi, pcgarant,
                                          pccampo, pclave);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_reaformula;

   /*************************************************************************
   Funci?n que selecciona todas las agrupaciones de contratos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_contratosagr(
      psconagr IN NUMBER,
      pcidioma IN NUMBER,
      ptconagr IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800)
         := 'psconagr = ' || psconagr || '; pcidioma = ' || pcidioma || '; ptconagr = '
            || ptconagr;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_contratosagr';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
   BEGIN
      vsquery :=
         '  Select dcagr.sconagr, dcagr.cidioma, dcagr.tconagr
            From descontratosagr dcagr'
         || ' Where (dcagr.sconagr = NVL(' || NVL(TO_CHAR(psconagr), 'NULL')
         || ',dcagr.sconagr))' || ' AND (dcagr.cidioma = NVL('
         || NVL(TO_CHAR(pcidioma), 'NULL') || ',dcagr.cidioma))'
         || 'AND (dcagr.tconagr LIKE ''%' || ptconagr || '%'' OR dcagr.tconagr IS NULL)';
--         || ' AND (dcagr.tconagr = NVL(' || NVL(TO_CHAR(ptconagr), 'NULL')
--         || ',dcagr.tconagr))';
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_contratosagr;

   /*************************************************************************
   Funci?n que graba una agrupacion de contratos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_contratosagr(
      psconagr IN NUMBER,
      pcidioma IN NUMBER,
      ptconagr IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'psconagr = ' || psconagr || '; pcidioma = ' || pcidioma || '; ptconagr = '
            || ptconagr;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_contratosagr';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_rea.f_set_contratosagr(psconagr, pcidioma, ptconagr);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_contratosagr;

   /*************************************************************************
   Funci?n que elimina una agrupacion de contratos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_contratosagr(
      psconagr IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800) := 'psconagr = ' || psconagr || '; pcidioma = ' || pcidioma;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_del_contratosagr';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_rea.f_del_contratosagr(psconagr, pcidioma);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_contratosagr;

   /*************************************************************************
   Funci?n que devuelve el siguiente codigo de agrupacion de contrato
   *************************************************************************/
   -- Bug 19724 - APD - 10/10/2011 - se crea la funcion
   FUNCTION f_get_sconagr_next(psmaxconagr OUT NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800) := NULL;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_sconagr_next';
      vnumerr        NUMBER := 0;
      vsmaxconagr    NUMBER;
   BEGIN
      vnumerr := pac_rea.f_get_sconagr_next(vsmaxconagr);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      psmaxconagr := vsmaxconagr;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_sconagr_next;

   /*************************************************************************
   Funci?n que recupera el objeto ob_iax_clausulas_reas.
   *************************************************************************/
   -- Bug 19724 - APD - 10/10/2011 - se crea la funcion
   FUNCTION f_get_objeto_clausulas_reas(
      pccodigo IN NUMBER,   -- C?digo de la cl?usula
      pobj_clausulas_reas OUT ob_iax_clausulas_reas,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'par?metros - pccodigo:' || pccodigo;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_objeto_clausulas_reas';
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      vob_clausulas_reas ob_iax_clausulas_reas := ob_iax_clausulas_reas();
      vtdescclausulas_reas t_iax_descclausulas_reas;
      vobdescclausulas_reas ob_iax_descclausulas_reas;
      vtclausulas_reas_det t_iax_clausulas_reas_det;
      vobclausulas_reas_det ob_iax_clausulas_reas_det;
      vcursor        sys_refcursor;
   BEGIN
      IF pccodigo IS NULL THEN
         -- Error en los par?metros
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vsquery :=
         'Select ccr.ccodigo codigo,
                  ccr.ctipo, ff_desvalorfijo(346,' || vidioma
         || ',ccr.ctipo) ttipo,
                  ccr.fefecto fefecto, ccr.fvencim fvencim
           From cod_clausulas_reas ccr
          Where (ccr.ccodigo = NVL('
         || NVL(TO_CHAR(pccodigo), 'NULL') || ',ccr.ccodigo))';
      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         -- Se ha producido un error en PAC_MD_LOG.F_LOG_CONSULTAS
         RAISE e_object_error;
      END IF;

      vpasexec := 4;

      IF NOT vcursor%ISOPEN THEN
         vpasexec := 5;
         -- Se ha producido un error en PAC_IAX_LISTVALORES.F_Opencursor
         RAISE e_object_error;
      ELSE
         vpasexec := 6;

         FETCH vcursor
          INTO vob_clausulas_reas.ccodigo, vob_clausulas_reas.ctipo, vob_clausulas_reas.ttipo,
               vob_clausulas_reas.fefecto, vob_clausulas_reas.fvencim;

         vpasexec := 7;

         IF vcursor%NOTFOUND THEN
            IF vcursor%ISOPEN THEN
               CLOSE vcursor;
            END IF;

            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000254);
         -- No se han encontrado datos.
         ELSE
            IF vcursor%ISOPEN THEN
               CLOSE vcursor;
            END IF;

------------------------------------------------------
-- recupera las descripciones de las clausulas --
------------------------------------------------------
            vsquery :=
               'Select cr.ccodigo, cr.cidioma, ff_desvalorfijo(255,' || vidioma
               || ', cr.cidioma) tidioma,
                 cr.tdescripcion tdescripcion
           From clausulas_reas cr
          Where (cr.ccodigo = NVL('
               || NVL(TO_CHAR(pccodigo), 'NULL') || ',cr.ccodigo))';
            vpasexec := 3;
            vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
            vpasexec := 4;

            IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
               -- Se ha producido un error en PAC_MD_LOG.F_LOG_CONSULTAS
               RAISE e_object_error;
            END IF;

            vpasexec := 4;

            IF NOT vcursor%ISOPEN THEN
               vpasexec := 5;
               -- Se ha producido un error en PAC_IAX_LISTVALORES.F_Opencursor
               RAISE e_object_error;
            ELSE
               vtdescclausulas_reas := t_iax_descclausulas_reas();

               LOOP
                  vobdescclausulas_reas := ob_iax_descclausulas_reas();

                  FETCH vcursor
                   INTO vobdescclausulas_reas.ccodigo, vobdescclausulas_reas.cidioma,
                        vobdescclausulas_reas.tidioma, vobdescclausulas_reas.tdescripcion;

                  IF vcursor%NOTFOUND THEN
                     EXIT;
                  END IF;

                  vtdescclausulas_reas.EXTEND;
                  vtdescclausulas_reas(vtdescclausulas_reas.LAST) := vobdescclausulas_reas;
               END LOOP;

               IF vcursor%ISOPEN THEN
                  CLOSE vcursor;
               END IF;

               vob_clausulas_reas.cdescri := vtdescclausulas_reas;
            END IF;

------------------------------------------------------
-- recupera los tramos de las clausulas --
------------------------------------------------------
            vsquery :=
               'Select crd.ccodigo, crd.ctramo, crd.ilim_inf, crd.ilim_sup, crd.pctpart,
           crd.pctmin, crd.pctmax
           From clausulas_reas_det crd
          Where (crd.ccodigo = NVL('
               || NVL(TO_CHAR(pccodigo), 'NULL') || ',crd.ccodigo))';
            vpasexec := 3;
            vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
            vpasexec := 4;

            IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
               -- Se ha producido un error en PAC_MD_LOG.F_LOG_CONSULTAS
               RAISE e_object_error;
            END IF;

            vpasexec := 4;

            IF NOT vcursor%ISOPEN THEN
               vpasexec := 5;
               -- Se ha producido un error en PAC_IAX_LISTVALORES.F_Opencursor
               RAISE e_object_error;
            ELSE
               vtclausulas_reas_det := t_iax_clausulas_reas_det();

               LOOP
                  vobclausulas_reas_det := ob_iax_clausulas_reas_det();

                  FETCH vcursor
                   INTO vobclausulas_reas_det.ccodigo, vobclausulas_reas_det.ctramo,
                        vobclausulas_reas_det.ilim_inf, vobclausulas_reas_det.ilim_sup,
                        vobclausulas_reas_det.pctpart, vobclausulas_reas_det.pctmin,
                        vobclausulas_reas_det.pctmax;

                  IF vcursor%NOTFOUND THEN
                     EXIT;
                  END IF;

                  vtclausulas_reas_det.EXTEND;
                  vtclausulas_reas_det(vtclausulas_reas_det.LAST) := vobclausulas_reas_det;
               END LOOP;

               IF vcursor%ISOPEN THEN
                  CLOSE vcursor;
               END IF;

               vob_clausulas_reas.cdetalle := vtclausulas_reas_det;
            END IF;
         END IF;
      END IF;

      vpasexec := 9;
      pobj_clausulas_reas := vob_clausulas_reas;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_objeto_clausulas_reas;

   /*************************************************************************
   Funci?n que recupera el objeto ob_iax_reposicion.
   *************************************************************************/
   -- Bug 19724 - APD - 10/10/2011 - se crea la funcion
   FUNCTION f_get_objeto_reposicion(
      pccodigo IN NUMBER,   -- C?digo de la reposicion
      pobj_reposicion OUT ob_iax_reposicion,
      mensajes IN OUT t_iax_mensajes,
      filtro_norden IN VARCHAR)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'par?metros - pccodigo:' || pccodigo;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_objeto_reposicion';
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      vob_reposicion ob_iax_reposicion := ob_iax_reposicion();
      vtreposiciones_det t_iax_reposiciones_det;
      vobreposiciones_det ob_iax_reposiciones_det;
      vcursor        sys_refcursor;
   BEGIN
      --IF pccodigo IS NULL THEN
         -- Error en los par?metros
       --  RAISE e_param_error;
      --END IF;
      vpasexec := 2;
      vsquery :=
         'Select cr.ccodigo codigo, r.tdescripcion descripcion
           From cod_reposicion cr, reposiciones r
          Where (cr.ccodigo = NVL('
         || NVL(TO_CHAR(pccodigo), 'NULL') || ',cr.ccodigo))'
         || ' AND cr.ccodigo = r.ccodigo(+) ' || ' AND r.cidioma(+) = ' || vidioma;
      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         -- Se ha producido un error en PAC_MD_LOG.F_LOG_CONSULTAS
         RAISE e_object_error;
      END IF;

      vpasexec := 4;

      IF NOT vcursor%ISOPEN THEN
         vpasexec := 5;
         -- Se ha producido un error en PAC_IAX_LISTVALORES.F_Opencursor
         RAISE e_object_error;
      ELSE
         vpasexec := 6;

         FETCH vcursor
          INTO vob_reposicion.ccodigo, vob_reposicion.tdescripcion;

         vpasexec := 7;

         IF vcursor%NOTFOUND THEN
            IF vcursor%ISOPEN THEN
               CLOSE vcursor;
            END IF;

            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000254);
         -- No se han encontrado datos.
         ELSE
            IF vcursor%ISOPEN THEN
               CLOSE vcursor;
            END IF;

------------------------------------------------------
-- recupera los tramos de las reposiciones --
------------------------------------------------------
            vsquery :=
               'Select rd.ccodigo, rd.norden, rd.icapacidad, rd.ptasa
           From reposiciones_det rd
          Where (rd.ccodigo = NVL('
               || NVL(TO_CHAR(pccodigo), 'NULL') || ',rd.ccodigo))';

            IF filtro_norden IS NOT NULL
               AND LENGTH(filtro_norden) > 0 THEN
               vsquery := vsquery || ' and norden not in (' || filtro_norden || ')';
            END IF;

            vpasexec := 3;
            vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
            vpasexec := 4;

            IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
               -- Se ha producido un error en PAC_MD_LOG.F_LOG_CONSULTAS
               RAISE e_object_error;
            END IF;

            vpasexec := 4;

            IF NOT vcursor%ISOPEN THEN
               vpasexec := 5;
               -- Se ha producido un error en PAC_IAX_LISTVALORES.F_Opencursor
               RAISE e_object_error;
            ELSE
               vtreposiciones_det := t_iax_reposiciones_det();

               LOOP
                  vobreposiciones_det := ob_iax_reposiciones_det();

                  FETCH vcursor
                   INTO vobreposiciones_det.ccodigo, vobreposiciones_det.norden,
                        vobreposiciones_det.icapacidad, vobreposiciones_det.ptasa;

                  IF vcursor%NOTFOUND THEN
                     EXIT;
                  END IF;

                  vtreposiciones_det.EXTEND;
                  vtreposiciones_det(vtreposiciones_det.LAST) := vobreposiciones_det;
               END LOOP;

               IF vcursor%ISOPEN THEN
                  CLOSE vcursor;
               END IF;

               vob_reposicion.cdetalle := vtreposiciones_det;
            END IF;
         END IF;
      END IF;

      vpasexec := 9;
      pobj_reposicion := vob_reposicion;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_objeto_reposicion;

-- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la funcion del pac_rea y se pasa aqui.
   FUNCTION f_valida_contrato_rea(
      pctiprea IN NUMBER,
      piretenc IN NUMBER,
      picapaci IN NUMBER,
      p_tobtramos IN t_iax_tramos_rea,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      v_retenc       NUMBER := 0;
      v_total        NUMBER := 0;
      v_100          NUMBER := 0;
	  v_100_nomina   NUMBER := 0;-- EDBR - 21/06/2019 -  IAXIS4480 se crea variable de 100% para nomina
      v_icesfij      NUMBER := 0;
      v_norden       NUMBER := 0;
      v_aux_ord      VARCHAR2(400);
      v_exces        NUMBER := 0;
      v_excesp       NUMBER := 0;
      v_ple_sus_cor  NUMBER := 0;
      v_ple_ret_cor  NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'par?metros - pctiprea:' || pctiprea || ' -piretenc:' || piretenc || ' -picapaci:'
            || picapaci;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_valida_contrato_rea';
   BEGIN
      vpasexec := 2;

      IF pctiprea = 2 THEN
         v_retenc := piretenc;
         v_total := piretenc;
      END IF;

      vpasexec := 3;

      IF p_tobtramos IS NOT NULL THEN
         p_tab_error(f_sysdate, f_user, 'f_valida_contrato_rea', 66, 'antes paso 4', NULL);
         vpasexec := 4;

         IF p_tobtramos.COUNT > 0 THEN
            FOR i IN p_tobtramos.FIRST .. p_tobtramos.LAST LOOP
               --Control para el orden
               p_tab_error(f_sysdate, f_user, 'f_valida_contrato_rea', 66, 'antes paso 5',
                           NULL);
               vpasexec := 5;

               IF p_tobtramos(i).norden > p_tobtramos.COUNT THEN
                  RETURN 105775;
               END IF;

               p_tab_error(f_sysdate, f_user, 'f_valida_contrato_rea', 66, 'antes paso 6',
                           NULL);
               vpasexec := 6;

               IF v_aux_ord IS NULL THEN
                  v_aux_ord := p_tobtramos(i).norden;
               ELSE
                  IF INSTR(v_aux_ord, p_tobtramos(i).norden) <> 0 THEN
                     RETURN 105775;
                  END IF;

                  v_aux_ord := v_aux_ord || '-' || p_tobtramos(i).norden;
               END IF;

               vpasexec := 7;

               --Fin control orden

               --Pleno de suscripci?n -> sempre ha de tenir el 1er tram del tipus 1- Quota Part
               IF pctiprea = 1
                  AND p_tobtramos(i).ctramo = 1 THEN
                  v_ple_sus_cor := 1;
               ELSIF pctiprea = 2
                     AND p_tobtramos(i).ctramo = 2 THEN
                  v_ple_ret_cor := 1;
               END IF;

               vpasexec := 8;

              IF pctiprea != 5 THEN
                 IF p_tobtramos(i).ctramo = 1 THEN
                    v_100 := NVL(p_tobtramos(i).plocal, 0);
                 ELSE
                    v_100 := 0;
                 END IF;
              ELSIF pctiprea = 5 THEN
                  IF p_tobtramos(i).ctramo = 1 OR p_tobtramos(i).ctramo = 2  THEN
                    v_100 := NVL(p_tobtramos(i).plocal, 0);
                  ELSE
                    v_100 := 0;
                  END IF;
              END IF;IF pctiprea != 5 THEN
                 IF p_tobtramos(i).ctramo = 1 THEN
                    v_100 := NVL(p_tobtramos(i).plocal, 0);
                 ELSE
                    v_100 := 0;
                 END IF;
              ELSIF pctiprea = 5 THEN
                  IF p_tobtramos(i).ctramo = 1 OR p_tobtramos(i).ctramo = 2  THEN
                    v_100 := NVL(p_tobtramos(i).plocal, 0);
                  ELSE
                    v_100 := 0;
                  END IF;
              END IF;

               vpasexec := 9;
               v_icesfij := 0;

               --Recorremos los cuadros del tramo
               IF p_tobtramos(i).cuadroces IS NOT NULL
                  AND p_tobtramos(i).cuadroces.COUNT > 0 THEN
                  FOR n IN p_tobtramos(i).cuadroces.FIRST .. p_tobtramos(i).cuadroces.LAST LOOP
                     IF NVL(p_tobtramos(i).cuadroces(n).pcesion, 0) <> 0 THEN                        
						--v_100 := v_100 + p_tobtramos(i).cuadroces(n).pcesion;
                        v_100_nomina := v_100_nomina + p_tobtramos(i).cuadroces(n).pcesion;   -- EDBR - 21/06/2019 -  IAXIS4480 se acumula los datos en  variable para nomina 
                     END IF;

                     IF NVL(p_tobtramos(i).cuadroces(n).icesfij, 0) <> 0 THEN
                        v_icesfij := v_icesfij + p_tobtramos(i).cuadroces(n).icesfij;
                     END IF;
                  END LOOP;
               ELSE
                  --Ha de existir almenos un cuadro para cada tramo
                  RETURN 104177;
               END IF;

               vpasexec := 10;

               --Comprobar que el total de los tramos sea correcto para ctiprea = 2
               --FALTA!!!! A?ADIR CONTROL POR INSTALACI?N DE SI SE DEBE CONTROLA EL N?MERO DE PLENOS
               IF pctiprea = 2 THEN
                  IF NVL(p_tobtramos(i).itottra, 0) <>
                                                 ROUND((p_tobtramos(i).nplenos * v_retenc), 2) THEN
                     RETURN 104072;
                  END IF;
               END IF;

               vpasexec := 11;

               --Comprobar que els % de Cessi? sumin 100 o que els imports fixes sumin el tram
               IF v_100 <> 100 AND v_100 <> 0
					and v_100_nomina <> 0 and  v_100_nomina <> 100 THEN  -- EDBR - 21/06/2019 -  IAXIS4480 se agrega la condicion de la variable de 100 de nommina
                  --p_tab_error(f_sysdate, f_user, 'PAC_REA.F_VALIDA_CONTRATO', 1,  'v_100 : ' || v_100, SQLERRM);
                  RETURN 103901;
               END IF;

               vpasexec := 12;

               --Importes fijos de cession que no suman el tramo
               IF v_icesfij <> 0
                  AND pctiprea IN(1, 2, 9)
                  AND v_icesfij <> NVL(p_tobtramos(i).itottra, 0) THEN
                  RETURN 104189;
               END IF;

               vpasexec := 13;

               IF v_icesfij <> 0
                  AND pctiprea = 2
                  AND v_icesfij <> NVL(p_tobtramos(i).ixlprio, 0) THEN
                  RETURN 104189;
               END IF;

               vpasexec := 14;

               IF pctiprea IN(1, 2, 9) THEN
                  v_total := v_total + NVL(p_tobtramos(i).itottra, 0);
               END IF;

               vpasexec := 15;

               --Comprobar encadenamiento de excesos y prioridades (ctiprea 3, 4)
               /*IF pctiprea = 3 THEN
                  IF p_tobtramos(i).ctramo > 6 THEN
                     IF NVL(p_tobtramos(i).ixlexce, 0) <> v_exces THEN
                        RETURN 104176;
                     END IF;
                  END IF;

                  v_exces := NVL(p_tobtramos(i).ixlexce, 0) + NVL(p_tobtramos(i).ixlprio, 0);
               END IF;*/

               vpasexec := 16;

               IF pctiprea = 4 THEN
                  IF p_tobtramos(i).ctramo > 11 THEN
                     IF NVL(p_tobtramos(i).pslexce, 0) <> v_excesp THEN
                        RETURN 104176;
                     END IF;
                  END IF;

                  v_excesp := NVL(p_tobtramos(i).pslexce, 0) + NVL(p_tobtramos(i).pslprio, 0);
               END IF;
            END LOOP;
         END IF;
      END IF;

      vpasexec := 17;

    /*  IF pctiprea IN(1, 2, 9) THEN
         IF picapaci IS NOT NULL
            AND picapaci <> v_total THEN
            --agg ojo quitar
            p_tab_error(f_sysdate, f_user, 'pac_md_rea', 999,
                        'picapaci: ' || picapaci || ' v_total: ' || v_total, NULL);
            RETURN 104071;
         END IF;
      END IF; */

      vpasexec := 18;

    /*  IF pctiprea = 1
         AND v_ple_sus_cor = 0 THEN
         RETURN 9900855;
      ELSIF pctiprea = 2
            AND v_ple_ret_cor = 0 THEN
         RETURN 9900856;
      END IF; */

      vpasexec := 19;
      RETURN num_err;
   EXCEPTION
      -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion del when others utilizando p_tab_error y se adicionan las dem?s
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 9900741;
/*      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_valida_contrato_rea', 1,
                     ' pctiprea :' || pctiprea || ' piretenc : ' || piretenc || ' picapaci : '
                     || picapaci,
                     SQLERRM);
         RETURN 9900741;*/
   END f_valida_contrato_rea;

   /*************************************************************************
   Funci?n que obtiene la lista de cuentas
   *************************************************************************/
   -- Bug 22076 - AVT - 22/05/2012 - se crea la funcion
   FUNCTION f_get_ctatecnica(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pccorred IN NUMBER,
      pccompani IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnsinies IN NUMBER,
      pcestado IN NUMBER,
      pciaprop IN NUMBER DEFAULT NULL,
      psproces IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800)   -- 23830/0150483 AVT 06/08/2013  VARCHAR2(200)
         := 'par?metros - pcempres:' || pcempres || ' - pcramo:' || pcramo || ' - psproduc:'
            || psproduc || ' - pccorred:' || pccorred || ' - pccompani:' || pccompani
            || ' - pscontra:' || pscontra || ' - pnversio:' || pnversio || ' - pctramo:'
            || pctramo || ' - pfcierre:' || pfcierre || ' - pnpoliza:' || pnpoliza
            || ' - pncertif:' || pncertif || ' - pnsinies:' || pnsinies || ' - psproces:'
            || psproces;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_ctatecnica';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      v_max_reg      NUMBER := f_parinstalacion_n('N_MAX_REG');
      -- n?mero m?xim de registres mostrats
      v_where        VARCHAR2(4000);
      -- KB QT 6163 16/09/2013
      v_saldo        VARCHAR2(250);
      v_groupby_saldo VARCHAR2(50);
      -- JAM 23830-161685
      vnumerr        NUMBER;
      --KBR QT 10598 29/01/2014
      v_saldo2       VARCHAR2(250);
      v_cestado      VARCHAR2(350);
	   -- INI - ML - 4610 - MOSTRAR SALDO EN MONEDA CONTABLE
     v_saldo1_1        VARCHAR2(250);
     v_saldo2_1        VARCHAR2(250);
     -- FIN - ML - 4610 - MOSTRAR SALDO EN MONEDA CONTABLE
   BEGIN
      vpasexec := 1;
      -- JAM 23830-161685
      vnumerr := pac_md_rea.f_set_reten_liquida(pccompani, pnversio, pscontra, pctramo, NULL,
                                                pccorred, pcempres, psproduc, pfcierre, 1, 4,
                                                mensajes);

      -- Fin JAM 23830-161685
      IF pcestado IS NOT NULL THEN
         --Liquidada o En Aprobación
         IF pcestado = 0
            OR pcestado = 2 THEN
            v_saldo :=
               ' NVL((select sum(NVL(m2.iimport, 0)) from movctatecnica m2 where m2.spagrea = m.spagrea and m2.cconcep = 10 and m2.cestado = '
               || pcestado || '), 0) ';
			-- INI - ML - 4610 - MOSTRAR SALDO EN MONEDA CONTABLE
            v_saldo1_1 :=
               ' NVL((select sum(NVL(m2.IIMPORT_MONCON, 0)) from movctatecnica m2 where m2.spagrea = m.spagrea and m2.cconcep = 10 and m2.cestado = '
               || pcestado || '), 0) ';
            -- FIN - ML - 4610 - MOSTRAR SALDO EN MONEDA CONTABLE
            v_groupby_saldo := ', m.spagrea';
            v_saldo2 := v_saldo;
	    --IAXIS 13108 AABC cambios del query para liquidados 
            v_saldo2_1 := v_saldo; 
         --Pendiente
         ELSE
            --Columna: Saldo Pendiente
            --9549/9552 KBR 12/08/2014: Se deben mostrar saldos POSITIVOS-> A favor del Reasegurador NEGATIVOS-> A cargo del Reasegurador
            --Para ello invertimos los signos en el calculo del saldo "cdebhab: 1->2"
            v_saldo :=
               ' SUM(DECODE(m.cestado, 1, DECODE(m.cdebhab, 2, iimport, -iimport), 0)) + SUM(DECODE(m.cestado, 4, DECODE(m.cdebhab, 2, iimport, -iimport), 0)) ';
			-- INI - ML - 4610 - MOSTRAR SALDO EN MONEDA CONTABLE
            v_saldo1_1 :=
	            ' SUM(DECODE(m.cestado, 1, DECODE(m.cdebhab, 2, IIMPORT_MONCON, -IIMPORT_MONCON), 0)) + SUM(DECODE(m.cestado, 4, DECODE(m.cdebhab, 2, IIMPORT_MONCON, -IIMPORT_MONCON), 0)) ';
            -- FIN - ML - 4610 - MOSTRAR SALDO EN MONEDA CONTABLE
            --Columna: Saldo a Liquidar
            v_saldo2 :=
                     ' SUM(DECODE(m.cestado, 1, DECODE(m.cdebhab, 2, iimport, -iimport), 0)) ';
			-- INI - ML - 4610 - MOSTRAR SALDO EN MONEDA CONTABLE
            v_saldo2_1 :=
	            ' SUM(DECODE(m.cestado, 1, DECODE(m.cdebhab, 2, IIMPORT_MONCON, -IIMPORT_MONCON), 0)) ';
            -- FIN - ML - 4610 - MOSTRAR SALDO EN MONEDA CONTABLE
         END IF;
      ELSE
         IF psproces IS NOT NULL THEN
            v_saldo :=
               ' NVL((select sum(NVL(m2.iimport, 0)) from movctatecnica m2 where m2.spagrea = m.spagrea and m2.cconcep = 10 ), 0) ';
            v_groupby_saldo := ', m.spagrea';
			 -- INI - ML - 4610 - MOSTRAR SALDO EN MONEDA CONTABLE
            v_saldo1_1 :=
	             ' NVL((select sum(NVL(m2.IIMPORT_MONCON, 0)) from movctatecnica m2 where m2.spagrea = m.spagrea and m2.cconcep = 10 ), 0) ';
            -- FIN - ML - 4610 - MOSTRAR SALDO EN MONEDA CONTABLE
            v_saldo2 := v_saldo;
			-- INI - ML - 4610 - MOSTRAR SALDO EN MONEDA CONTABLE
            v_saldo2_1 := v_saldo1_1;
            -- FIN - ML - 4610 - MOSTRAR SALDO EN MONEDA CONTABLE
         END IF;
      END IF;

      IF psproces IS NULL THEN
         v_cestado := ' -99 estado, ';
      ELSE
         v_cestado :=
            ' DECODE((SELECT COUNT(DISTINCT cestado) FROM movctatecnica WHERE spagrea = m.spagrea), 1, (SELECT DISTINCT cestado
                                                     FROM movctatecnica
                                                    WHERE spagrea = m.spagrea and rownum = 1), 1) estado,';
      END IF;

      vpasexec := 2;
       -- INI - ML - 4610 - OBTENER MONEDA DEL PRODUCTO ASOCIADO
        /*
         * Query anterior
          vsquery :=
         'SELECT ' || v_cestado
         || ' nvl(c.cempres, 0) cempres, c.ccompani, c.scontra, e.tempres, tcompani, m.sproduc, m.spagrea, '
         || ' NVL((SELECT ttitulo FROM productos p, titulopro t '
         || ' WHERE p.cramo= t.cramo AND p.cmodali = t.cmodali AND p.ctipseg = t.ctipseg '
         || ' AND p.ccolect = t.ccolect AND p.sproduc = m.sproduc AND t.cidioma =' || vidioma
         || ' ), (SELECT tramo FROM ramos r WHERE cramo IN(SELECT MAX(g.cramo) FROM agr_contratos g '
         || '  WHERE g.scontra = c.scontra) AND r.cidioma = ' || vidioma || ')) tproduc,'
         || ' (SELECT cc.scontra || '' - '' || cc.tcontra FROM contratos cc  WHERE cc.scontra = c.scontra '
         || ' AND cc.nversio = c.nversio) tcontra, c.nversio, c.ctramo,'
         || ' ff_desvalorfijo(105, ' || vidioma || ', c.ctramo) ttramo, m.fmovimi fcierre, '
         || ' c.ccorred, (SELECT cmoneda FROM codicontratos s WHERE s.scontra = c.scontra) moneda,'
         || v_saldo || 'isaldo, ' || v_saldo2 || 'isaldo2, '   --KBR QT 10598 29/01/2014
         || ' (SELECT tmoneda FROM eco_desmonedas em, codicontratos s WHERE em.cmoneda = s.cmoneda '
         || '  AND s.scontra = c.scontra AND em.cidioma = ' || vidioma
         || ') tmoneda, m.ccompapr ';
        */
     
     	 vsquery :=
         'SELECT ' || v_cestado
         || ' nvl(c.cempres, 0) cempres, c.ccompani, c.scontra, e.tempres, tcompani, m.sproduc, m.spagrea, '
         || ' NVL((SELECT ttitulo FROM productos p, titulopro t '
         || ' WHERE p.cramo= t.cramo AND p.cmodali = t.cmodali AND p.ctipseg = t.ctipseg '
         || ' AND p.ccolect = t.ccolect AND p.sproduc = m.sproduc AND t.cidioma =' || vidioma
         || ' ), (SELECT tramo FROM ramos r WHERE cramo IN(SELECT MAX(g.cramo) FROM agr_contratos g '
         || '  WHERE g.scontra = c.scontra) AND r.cidioma = ' || vidioma || ')) tproduc,'
         || ' (SELECT cc.scontra || '' - '' || cc.tcontra FROM contratos cc  WHERE cc.scontra = c.scontra '
         || ' AND cc.nversio = c.nversio) tcontra, c.nversio, c.ctramo,'
         || ' ff_desvalorfijo(105, ' || vidioma || ', c.ctramo) ttramo, m.fmovimi fcierre, '
         || ' c.ccorred, (SELECT pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_divisa((SELECT CDIVISA FROM PRODUCTOS WHERE SPRODUC = m.SPRODUC AND rownum = 1))) FROM dual) moneda,' -- ML - CODIGO ALFANUMERICO DE LA MONEDA, MEDIANTE LA DIVISA
         || v_saldo || 'isaldo, ' || v_saldo2 || 'isaldo2, '   --KBR QT 10598 29/01/2014
         -- INI - ML - 4610 - SALDOS EN MONEDA CONTABLE
         || v_saldo1_1 || 'isaldo_con, ' || v_saldo2_1 || 'isaldo2_con, ' 
         -- FIN - ML - 4610 - SALDOS EN MONEDA CONTABLE
         || ' (SELECT TMONEDA FROM eco_desmonedas WHERE CIDIOMA = ' || vidioma || ' AND CMONEDA = (SELECT pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_divisa((SELECT CDIVISA FROM PRODUCTOS WHERE SPRODUC = m.SPRODUC AND rownum = 1))) FROM dual)) tmoneda, ' -- ML - TEXTO DE LA MONEDA
		 || 'm.ccompapr ';
        
        -- FIN - ML - 4610 - OBTENER MONEDA DEL PRODUCTO ASOCIADO

      --Esto hará falta???
      IF psproces IS NOT NULL THEN
         vsquery :=
            vsquery
            || ' , (select distinct(sproces) from movctatecnica mt1 where mt1.sproces = '
            || psproces || ' and mt1.cconcep = 10 and sproces is not null) sproces ';
      END IF;

      vsquery :=
         vsquery
         || ' FROM ctatecnica c, companias pa, empresas e, movctatecnica m, tipoctarea t  '
         || ' WHERE c.ccompani = pa.ccompani AND e.cempres = c.cempres AND c.scontra = m.scontra '
         || ' AND NVL(M.SPRODUC, 0) = NVL(C.SPRODUC(+), 0) ' || ' AND m.cconcep = t.cconcep '
         || ' AND t.ctipcta = 1 AND m.cempres = t.cempres '
         || ' AND c.nversio = m.nversio  AND c.ctramo = m.ctramo AND c.ccompani = m.ccompani AND m.cconcep < 50';
      vpasexec := 3;

      IF pcempres IS NOT NULL THEN
         vsquery := vsquery || ' AND c.cempres = ' || pcempres;
      END IF;

      IF pfcierre IS NOT NULL THEN
         vsquery := vsquery || ' AND m.fmovimi   = ' || 'to_date('''
                    || TO_CHAR(pfcierre, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')';
      END IF;

      IF pscontra IS NOT NULL THEN
         vsquery := vsquery || ' AND c.scontra   = ' || pscontra;
      END IF;

      IF pnversio IS NOT NULL THEN
         vsquery := vsquery || ' AND c.nversio  = ' || pnversio;
      END IF;

      IF pctramo IS NOT NULL THEN
         vsquery := vsquery || ' AND c.ctramo    = ' || pctramo;
      END IF;

      IF pccompani IS NOT NULL THEN
         vsquery := vsquery || ' AND c.ccompani  = ' || pccompani;
      END IF;

      IF pccorred IS NOT NULL THEN
         vsquery := vsquery || ' AND c.ccorred  = ' || pccorred;   -- 23830 AVT 15/11/2012 si busca per corredor i no troba, no ha de treure res.
      END IF;

      -- S'AFEGEIX EL SSEGURO PER MOVIMENTS FACULTATIUS
      IF pnpoliza IS NOT NULL THEN
         --KBR 12/07/2013 QT: 6339 / Mantis: 23830-140221
         --vsquery := vsquery || ' AND m.npoliza  = ' || pnpoliza || ' AND m.ncertif = ' || NVL(pncertif, 0);
         vsquery := vsquery || ' AND m.npoliza  = ' || pnpoliza;
      END IF;

      -- S'AFEGEIX EL SINISTRE
      IF pnsinies IS NOT NULL THEN
         vsquery := vsquery || ' AND m.nsinies  = ' || pnsinies;
      END IF;

      --KBR 06/09/2013
      --QT 6163: Ajustes en consulta de cta técnica de reaseguro
      /*IF pcramo IS NOT NULL
         AND psproduc IS NOT NULL THEN
         vsquery := vsquery || ' AND ( nvl(m.sproduc,0) =0 or m.sproduc  = ' || psproduc
                    || ' )';
      END IF;*/
      IF pcramo IS NOT NULL THEN
         vsquery :=
            vsquery
            || ' AND (m.scontra, NVL(m.sproduc, 0)) IN (SELECT DISTINCT scontra, sproduc FROM agr_contratos ac, productos pp  WHERE ac.cramo = '
            || pcramo || ' AND pp.cramo = ac.cramo)';
      END IF;

      IF psproduc IS NOT NULL THEN
         vsquery :=
            vsquery || ' AND (m.sproduc = ' || psproduc
            || ' OR(NVL(m.sproduc, 0) = 0 AND EXISTS(SELECT 1 FROM cesionesrea cr, seguros ss WHERE cr.scontra = m.scontra AND cr.sseguro = ss.sseguro AND ss.sproduc = '
            || psproduc || ')))';
      END IF;

      --BUG: 0030203 - INICIO- DCT - 18/02/2014-  Añadir spagrea is not null
      --Fin KB QT:6163
      IF pcestado IS NOT NULL
--         AND psproces IS NULL
      THEN
         vsquery := vsquery || ' AND ( m.cestado = ' || pcestado || ' OR m.cestado = 4 ) ';

         IF pcestado = 0 THEN   --Liquidado
            vsquery := vsquery || ' AND m.spagrea IS NOT NULL ';
         END IF;
      END IF;

      --BUG: 0030203 - FIN- DCT - 18/02/2014-  Añadir spagrea is not null
      IF pciaprop IS NOT NULL THEN
         	-- ML - APUNTES MANUALES - 4818
         --vsquery := vsquery || ' AND NVL(m.ccompapr,0)  = ' || pciaprop;
         vsquery := vsquery || ' AND (NVL(m.ccompapr,0)  = ' || pciaprop || ' OR m.nid IS NOT NULL)';
      END IF;

      --BUG 23830/157563 - 31/10/2013 - RCL - Nuevo filtro
      IF psproces IS NOT NULL THEN
         vsquery :=
            vsquery
            || ' AND m.spagrea IN(SELECT x.spagrea
                        FROM movctatecnica x
                       WHERE x.sproces = '
            || psproces || ')';
      END IF;

      vpasexec := 4;
--BUG 23830 - INICIO - DCT - 10/07/2013 - LCOL_A004 Ajustar el Manteniment dels Comptes de Reassegurança

      /* IF v_max_reg IS NOT NULL THEN
          IF INSTR(vsquery, ' order by', -1, 1) > 0 THEN
             -- se hace de esta manera para mantener el orden de los registros
             vsquery := 'select * from (' || vsquery || ') where rownum <= ' || v_max_reg;
          ELSE
             vsquery := vsquery || ' AND rownum <= ' || v_max_reg;
          END IF;
       END IF;

       vpasexec := 4;*/
       --BUG 23830 - FIN - DCT - 10/07/2013 - LCOL_A004 Ajustar el Manteniment dels Comptes de Reassegurança
      vsquery :=
         --  bug 23830 -- ECP -- 23/03/2013 se quita del group by --nvl(m.npoliza, 0), nvl(m.ncertif, 0), nvl(m.nsinies, 0),
         vsquery
         || ' GROUP BY NVL(c.cempres, 0), c.ccompani, c.scontra, e.tempres, tcompani, m.sproduc, c.sproduc,'
         || ' c.scontra, c.nversio, c.ctramo, c.ctramo, m.fmovimi, c.ccorred, m.spagrea, m.ccompapr '
         || v_groupby_saldo;
      vpasexec := 5;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 6;
       -- dc_p_trazas(7777777, ' en pac_md_rea.f_get_ctatecnica, vsquery: '||vsquery);
      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 7;
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         -- Error, buscando las cuentas t?cnicas de reaseguro
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9903013, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_ctatecnica;

   /*************************************************************************
     Funci?n que devuelve la cabecera de la cuenta t?cnica de reaseguro consultada
     *************************************************************************/-- Bug 22076 - AVT - 22/05/2012 - se crea la funcion
   FUNCTION f_get_cab_movcta(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      psproduc IN NUMBER,
      pccompani IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      pcestado IN NUMBER,   --23830 KBR 12/07/2013
      pnpoliza IN NUMBER,   --23830 KBR 12/07/2013
      pciaprop IN NUMBER DEFAULT NULL,   --23830 DCT 27/12/2013
      pspagrea IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800)   -- 23830/0150483 AVT 06/08/2013  VARCHAR2(200)
         := 'par?metros - pcempres:' || pcempres || ' - psproduc:' || psproduc
            || ' - pccompani:' || pccompani || ' - pscontra:' || pscontra || ' - pnversio:'
            || pnversio || ' - pctramo:' || pctramo || ' - pfcierre:' || pfcierre
            || ' - pcestado:' || pcestado || ' - pnpoliza:' || pnpoliza || ' - pciaprop:'
            || pciaprop || ' - pspagrea:' || pspagrea;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_cab_movcta';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      v_max_reg      NUMBER := f_parinstalacion_n('N_MAX_REG');
      -- n?mero m?xim de registres mostrats
      v_where        VARCHAR2(4000);
   BEGIN
      --KBR 25/10/2013 Agregamos uso de moneda contable para evitar diferencia de decimales cuando sea la misma moneda
      --9549/9552 KBR 12/08/2014: Se deben mostrar saldos POSITIVOS-> A favor del Reasegurador NEGATIVOS-> A cargo del Reasegurador
      --Para ello invertimos los signos en el calculo del saldo "cdebhab: 1->2"
      vsquery :=
         'SELECT   m.cempres, (select tempres from empresas e where e.cempres = m.cempres) tempres ,m.sproduc,'
         || ' NVL((SELECT ttitulo FROM productos p, titulopro t '
         || ' WHERE p.cramo= t.cramo AND p.cmodali = t.cmodali AND p.ctipseg = t.ctipseg '
         || ' AND p.ccolect = t.ccolect AND p.sproduc = m.sproduc AND t.cidioma =' || vidioma
         || '), (SELECT tramo FROM ramos r WHERE cramo IN(SELECT MAX(g.cramo) FROM agr_contratos g '
         || ' WHERE g.scontra = m.scontra) AND r.cidioma = ' || vidioma || ')) tproduc,'
         || ' m.ccompani, (select ca.tcompani from companias ca where ca.ccompani = m.ccompani) tcompani,'
         || ' c.ccorred broker, (select ca.tcompani from companias ca where ca.ccompani = c.ccorred) tccorred, m.scontra, '
         || ' (select ct.scontra || '' - '' || tcontra from contratos ct where ct.scontra = m.scontra and ct.nversio = m.nversio) tcontra, '
         || ' m.nversio, m.ctramo, ff_desvalorfijo (105, ' || vidioma
         || ', m.ctramo) ttramo, m.fmovimi fcierre,'
         || ' SUM(DECODE(pac_monedas.f_cmoneda_t(pac_parametros.f_parempresa_n(m.cempres, ''MONEDAEMP'')),
                pac_monedas.f_moneda_producto_char(c.sproduc), DECODE(m.cdebhab, 2, iimport_moncon, -iimport_moncon), DECODE(m.cdebhab, 2, iimport, -iimport))) isaldo, '
         || ' SUM(DECODE(m.cdebhab, 2, iimport_moncon, -iimport_moncon)) isaldo_moncon '
         || ' FROM movctatecnica m, ctatecnica c, tipoctarea t ';
      vpasexec := 2;
      p_agrega_where(v_where,
                     ' WHERE c.ccompani = m.ccompani  AND m.cempres = c.cempres '
                     || ' AND m.scontra = c.scontra' || ' AND m.nversio = c.nversio'
                     || ' AND m.ccompani = c.ccompani' || ' AND m.ctramo = c.ctramo'
                     || ' AND NVL(M.SPRODUC, 0) = NVL(C.SPRODUC(+), 0)'
                     || ' AND m.cempres = t.cempres ' || ' AND m.cconcep = t.cconcep '
                     || ' AND m.cempres  = ' || pcempres || ' AND m.fmovimi = '
                     || 'to_date(''' || TO_CHAR(pfcierre, 'dd/mm/yyyy')
                     || ''',''dd/mm/yyyy'')' || ' AND m.ccompani = ' || pccompani
                     || ' AND t.ctipcta = 1' || ' AND m.scontra =' || pscontra
                     || ' AND m.nversio = ' || pnversio || ' AND m.ctramo = ' || pctramo);
      vpasexec := 3;

      IF psproduc IS NOT NULL THEN
         --p_agrega_where(v_where, '( NVL(m.sproduc,0) =0 OR m.sproduc = ' || psproduc || ' ) ');
         p_agrega_where(v_where, ' m.sproduc = ' || psproduc);
      END IF;

      --KBR 12/07/2013
      IF pcestado IS NOT NULL THEN
         p_agrega_where(v_where, ' ( m.cestado = ' || pcestado || ' OR m.cestado = 4 )');
      END IF;

      IF pnpoliza IS NOT NULL THEN
         p_agrega_where(v_where, ' m.npoliza  = ' || pnpoliza);
      END IF;

      --23830 DCT 27/12/2013
      IF pciaprop IS NOT NULL THEN
         -- ML - APUNTES MANUALES - 4818
         --p_agrega_where(v_where, ' NVL(m.ccompapr,0)  = ' || pciaprop);
         p_agrega_where(v_where, ' (NVL(m.ccompapr,0)  = ' || pciaprop || ' OR m.nid IS NOT NULL)');
      END IF;

      --30203/168483 SHA 04/03/2014
      IF pspagrea IS NOT NULL THEN
         p_agrega_where(v_where, ' m.spagrea  = ' || pspagrea);
      END IF;

      --30203/168483 SHA 04/03/2014

      -- fin BUG: 25502 AVT 18/01/2013
      IF v_max_reg IS NOT NULL THEN
         IF INSTR(vsquery, 'order by', -1, 1) > 0 THEN
            -- se hace de esta manera para mantener el orden de los registros
            vsquery := 'select * from (' || vsquery || ') where rownum <= ' || v_max_reg;
         ELSE
            p_agrega_where(v_where, 'rownum <= ' || v_max_reg);
         END IF;
      END IF;

      vsquery :=
         vsquery || v_where
         || ' GROUP BY m.cempres, m.sproduc, m.ccompani, c.ccorred, m.scontra, m.nversio, m.ctramo, m.fmovimi  ';
      vpasexec := 4;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 5;

      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 6;
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_cab_movcta;

   /*************************************************************************
   Funci?n que devuelve las cuentas t?cnicas de la reaseguradora consultada
   *************************************************************************/
   -- Bug 22076 - AVT - 22/05/2012 - se crea la funcion
   FUNCTION f_get_movctatecnica(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      psproduc IN NUMBER,
      pccompani IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      pcestado IN NUMBER,
      pnpoliza IN NUMBER,
      pciaprop IN NUMBER DEFAULT NULL,
      pspagrea IN NUMBER,
      pcheckall IN NUMBER DEFAULT 0,   --KBR 02/05/2014 Gap 81
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800)   -- 23830/0150483 AVT 06/08/2013  VARCHAR2(200)
         := 'par?metros - pcempres:' || pcempres || ' - psproduc:' || psproduc
            || ' - pccompani:' || pccompani || ' - pscontra:' || pscontra || ' - pnversio:'
            || pnversio || ' - pctramo:' || pctramo || ' - pfcierre:' || pfcierre
            || ' - pcestado:' || pcestado || ' - pnpoliza:' || pnpoliza || ' - pciaprop:'
            || pciaprop || ' - pspagrea:' || pspagrea || ' - pcheckall:' || pcheckall;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_movctatecnica';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      v_max_reg      NUMBER := f_parinstalacion_n('N_MAX_REG');
      -- n?mero m?xim de registres mostrats
      v_where        VARCHAR2(4000);
      v_sproduc VARCHAR2(10);
   BEGIN
      IF (psproduc IS NULL) THEN
         v_sproduc := 'NULL';
      ELSE
         v_sproduc := psproduc;
      END IF;

       vsquery :=
         'SELECT m.nnumlin, DECODE(NVL(m.ctipmov, 0), 0, ''Auto'', ''Manual'') ttipmov,'
         || ' NVL((SELECT ttitulo FROM productos p, titulopro t '
         || ' WHERE p.cramo= t.cramo AND p.cmodali = t.cmodali AND p.ctipseg = t.ctipseg '
         || ' AND p.ccolect = t.ccolect AND p.sproduc = m.sproduc AND t.cidioma =' || vidioma
         || ' ),(SELECT tramo FROM ramos r WHERE cramo IN(select cramo from productos where sproduc = NVL('
         || v_sproduc || ', (SELECT MAX(g.cramo) FROM agr_contratos g'
         || ' WHERE g.scontra = m.scontra))) AND r.cidioma = ' || vidioma || ')) tproduc, '
         || ' fmovimi fcierre,' || ' ff_desvalorfijo(800106, ' || vidioma
         || ' , m.cestado) testado,' || ' ff_desvalorfijo(124, ' || vidioma
         -- INI - ML - 4610 - MONEDA CONTABLE
         || ', m.cconcep) tconcep,' || ' DECODE(m.cdebhab, 1, m.iimport, 0) idebe, '
         || ' DECODE(m.cdebhab, 2, m.iimport, 0) ihaber, DECODE(m.cdebhab, 1, m.IIMPORT_MONCON, 0) idebe_moncon, '         
         || ' DECODE(m.cdebhab, 2, m.IIMPORT_MONCON, 0) ihaber_moncon,  m.tdescri, em.tmoneda, em.CMONEDA, ' -- ML - 4610 - CODIGO DE MONEDA
         -- FIN - ML - 4610 - MONEDA CONTABLE
         || ' ct.tdescripcion, m.nversio, m.sproduc, m.tdocume, m.cdebhab, m.iimport'
         || ' , m.cestado, nvl(m.ctipmov,0) ctipmov, m.npoliza, m.ncertif, m.nsinies, m.cconcep, m.sidepag, m.spagrea, t.ctipcta'
         || ' FROM movctatecnica m, codicontratos ct, eco_desmonedas em, tipoctarea t ';
      vpasexec := 2;
      p_agrega_where(v_where,
                     ' WHERE m.scontra = ct.scontra' || ' AND m.cempres = t.cempres'
                     || ' AND m.cconcep = t.cconcep ' || ' AND m.cempres  = ' || pcempres
                     || ' AND m.fmovimi = ' || 'to_date(''' || TO_CHAR(pfcierre, 'dd/mm/yyyy')
                     || ''',''dd/mm/yyyy'')' || ' AND m.ccompani = ' || pccompani
                     || ' AND m.scontra =' || pscontra || ' AND m.nversio = ' || pnversio
                     || ' AND m.ctramo = ' || pctramo
                     || ' AND ct.cmoneda = em.cmoneda AND em.cidioma = ' || vidioma
                     || ' AND m.iimport <> 0' || ' AND m.cconcep != 30');
      vpasexec := 3;

      --KBR 02/05/2014 Gap 81: Condición para que aparezcan todos los movimientos
      IF psproduc IS NOT NULL THEN
         IF pcheckall = 0 THEN
            p_agrega_where(v_where, ' m.sproduc = ' || psproduc);
         ELSE
            p_agrega_where(v_where,
                           ' (m.sproduc = ' || psproduc
                           || ' OR (m.sproduc IS NULL AND t.ctipcta <> 1))');
         END IF;
      END IF;

      --KBR 02/05/2014 Gap 81: Condición para que aparezcan todos los movimientos
      IF pcheckall = 0 THEN
         p_agrega_where(v_where, ' t.ctipcta IN(1,2) ');
      END IF;

      --BUG: 0030203 - INICIO- DCT - 18/02/2014-  Añadir spagrea is not null
      --KBR 12/07/2013
      IF pcestado IS NOT NULL THEN
         p_agrega_where(v_where, ' ( m.cestado = ' || pcestado || ' OR m.cestado = 4 ) ');

         IF pcestado = 0 THEN
            p_agrega_where(v_where, ' m.spagrea IS NOT NULL ');   --BUG30203 - 04/04/2014 - DCT
         END IF;
      END IF;

      --BUG: 0030203 - FIN- DCT - 18/02/2014-  Añadir spagrea is not null
      IF pnpoliza IS NOT NULL THEN
         p_agrega_where(v_where, ' m.npoliza  = ' || pnpoliza);
      END IF;

      --30203/168483 SHA 04/03/2014
      IF pspagrea IS NOT NULL THEN
         p_agrega_where(v_where, ' m.spagrea  = ' || pspagrea);
      END IF;

      --30203/168483 SHA 04/03/2014

      --23830 DCT 27/12/2013
      IF pciaprop IS NOT NULL THEN
         -- ML - AJUSTES MANUALES - 4818
      	--p_agrega_where(v_where, ' NVL(m.ccompapr,0)  = ' || pciaprop);
         p_agrega_where(v_where, ' (NVL(m.ccompapr,0)  = ' || pciaprop || ' OR m.nid IS NOT NULL)');
      END IF;

      -- fin BUG: 25502 AVT 18/01/2013
      IF v_max_reg IS NOT NULL THEN
         IF INSTR(vsquery, 'order by', -1, 1) > 0 THEN
            -- se hace de esta manera para mantener el orden de los registros
            vsquery := 'select * from (' || vsquery || ') where rownum <= ' || v_max_reg;
         ELSE
            p_agrega_where(v_where, 'rownum <= ' || v_max_reg);
         END IF;
      END IF;

      vsquery := vsquery || v_where;
      vpasexec := 4;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 5;

      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 6;
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9001936, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_movctatecnica;

      /*************************************************************************
   Funci?n que elimina un movimiento manual de la cuenta t?cnica del reaseguro
   *************************************************************************/
   -- Bug 22076 - AVT - 22/05/2012 - se crea la funcion
   FUNCTION f_del_movctatecnica(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      psproduc IN NUMBER,
      pccompani IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      pcconcep IN NUMBER,
      pnnumlin IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnsinies IN NUMBER,
      pciaprop IN NUMBER DEFAULT NULL,   --23830 DCT 27/12/2013
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := ' pcempres:' || pcempres || ' - psproduc:' || psproduc || ' - pccompani:'
            || pccompani || ' - pscontra:' || pscontra || ' - pnversio:' || pnversio
            || ' - pctramo:' || pctramo || ' - pfcierre:' || pfcierre || ' - pcconcep:'
            || pcconcep || ' - pnnumlin:' || pnnumlin || ' - pnpoliza:' || pnpoliza
            || ' - pncertif:' || pncertif || ' - pnsinies:' || pnsinies || ' - pciaprop:'
            || pciaprop;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_del_movctatecnica';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_rea.f_del_movctatecnica(pcempres, psproduc, pccompani, pscontra,
                                             pnversio, pctramo, pfcierre, pcconcep, pnnumlin,
                                             pnpoliza, pncertif, pnsinies, pciaprop);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_movctatecnica;

   /*************************************************************************
   Funci?n que apunta en la tabla de liquidaci?n los importes pendientes de la cuenta t?cnica del reaseguro.
   *************************************************************************/
   -- Bug 22076 - AVT - 24/05/2012 - se crea la funcion
   FUNCTION f_liquida_ctatec_rea(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      psproduc IN NUMBER,
      pccorred IN NUMBER,
      pccompani IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      psproces IN NUMBER,
      pcliquidar IN NUMBER DEFAULT 0,
      pciaprop IN NUMBER DEFAULT NULL,
      pultimoreg IN NUMBER DEFAULT 0,   --KBR 18/07/2014
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := ' pcempres:' || pcempres || ' - psproduc:' || psproduc || ' - pccompani:'
            || pccompani || ' - pscontra:' || pscontra || ' - pnversio:' || pnversio
            || ' - pctramo:' || pctramo || ' - pfcierre:' || pfcierre || ' - pciaprop:'
            || pciaprop;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_liquida_ctatec_rea';
      vnumerr        NUMBER := 0;
      vproceslin     NUMBER := 0;
      vproceslin_prev NUMBER := 0;
      --psproces       NUMBER; -- 22076/123753 AVT 26/09/2012
      --vmens          VARCHAR2(250);
      v_ttexto       VARCHAR2(1000);
      v_llinia       NUMBER := 0;
      vidioma        NUMBER;
   BEGIN
      vidioma := pac_md_common.f_get_cxtidioma;

      SELECT COUNT(*)
        INTO vproceslin_prev
        FROM procesoslin
       WHERE sproces = psproces;

      -- KBR 27911/150911 - Se añade param. "pcliquidar"
      -- KBR 18/07/2014 - Se agrega el parametro "pultimoreg" 0-No, 1-Si
      vnumerr := pac_rea.f_liquida_ctatec_rea(pcempres, psproduc, pccorred, pccompani,
                                              pscontra, pnversio, pctramo, pfcierre, vidioma,
                                              psproces, pcliquidar, pciaprop, pultimoreg);

      SELECT COUNT(*)
        INTO vproceslin
        FROM procesoslin
       WHERE sproces = psproces;

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
         v_ttexto := f_axis_literales(vnumerr, vidioma);
         vnumerr := f_proceslin(psproces, v_ttexto, 0, v_llinia);
         vnumerr := f_procesfin(psproces, vproceslin);
         RAISE e_object_error;
      END IF;

      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_CTATECREA_AGRUP'), 0) = 0 THEN
         vnumerr := f_procesfin(psproces, vproceslin);

         IF vproceslin > 0
            AND vnumerr = 0
            AND vproceslin > vproceslin_prev THEN
            vnumerr := 1;
         END IF;
      ELSE
         IF pultimoreg = 1 THEN
            vnumerr := f_procesfin(psproces, vproceslin);

            IF vproceslin > 0
               AND vnumerr = 0
               AND vproceslin > vproceslin_prev THEN
               vnumerr := 1;
            END IF;
         END IF;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL,
                                           f_axis_literales(9000493,
                                                            pac_md_common.f_get_cxtidioma)
                                           || ' : ' || psproces);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_liquida_ctatec_rea;

   /*************************************************************************
       Funci?n que insertar? o modificar? un movimiento de cuenta t?cnica en funci?n del pmodo
   *************************************************************************/
   -- Bug 22076 - AVT - 25/05/2012 - se crea la funcion
   FUNCTION f_set_movctatecnica(
      pccompani IN NUMBER,
      pnversio IN NUMBER,
      pscontra IN NUMBER,
      pctramo IN NUMBER,
      pnnumlin IN NUMBER,
      pfmovimi IN DATE,
      pfefecto IN DATE,
      pcconcep IN NUMBER,
      pcdebhab IN NUMBER,
      piimport IN NUMBER,
      pcestado IN NUMBER,
      psproces IN NUMBER,
      pscesrea IN NUMBER,
      piimport_moncon IN NUMBER,
      pfcambio IN DATE,
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pdescrip IN VARCHAR2,
      pdocumen IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnsinies IN NUMBER,
      psproduc IN NUMBER,
      pmodo IN NUMBER,
      psidepag IN NUMBER DEFAULT NULL,   --QT-6164
      pciaprop IN NUMBER DEFAULT NULL,   --23830 DCT /AVT 27/12/2013
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'params : pccompani : ' || pccompani || ', pnversio : ' || pnversio
            || ', pscontra : ' || pscontra || ' , pctramo : ' || pctramo || ', pnnumlin : '
            || pnnumlin || ', pfmovimi : ' || pfmovimi || ', pfefecto : ' || pfefecto
            || ', pcconcep : ' || pcconcep || ' , pcdebhab : ' || pcdebhab || ', piimport :'
            || piimport || ', pcestado : ' || pcestado || ', psproces : ' || psproces
            || ', pscesrea : ' || pscesrea || ', piimport_moncon : ' || piimport_moncon
            || ', pfcambio : ' || pfcambio || ', pcempres : ' || pcempres || ', pdescrip : '
            || pdescrip || ', pdocumen : ' || pdocumen || ' - pnpoliza:' || pnpoliza
            || ' - pncertif:' || pncertif || ' - pnsinies:' || pnsinies || ' psproduc:'
            || psproduc || ' pmodo:' || pmodo || ' pciaprop:' || pciaprop;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_movctatecnica';
      vnumerr        NUMBER := 0;
      v_ttexto       VARCHAR2(1000);
      v_llinia       NUMBER := 0;
      vidioma        NUMBER;
   BEGIN
      vidioma := pac_md_common.f_get_cxtidioma;
      vnumerr := pac_rea.f_set_movctatecnica(pccompani, pnversio, pscontra, pctramo, pnnumlin,
                                             pfmovimi, pfefecto, pcconcep, pcdebhab, piimport,
                                             pcestado, psproces, pscesrea, piimport_moncon,
                                             pfcambio, pcempres, pdescrip, pdocumen, pnpoliza,
                                             pncertif, pnsinies, psproduc, pmodo, psidepag,
                                             pciaprop);

      IF vnumerr <> 0 THEN   -- hay errores
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         v_ttexto := f_axis_literales(vnumerr, vidioma);
         vnumerr := f_proceslin(psproces, v_ttexto, 0, v_llinia);
         vnumerr := f_procesfin(psproces, 1);
         ROLLBACK;
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_movctatecnica;

   /***************************************************************************
  Funci?n que retiene un movimiento de cuenta t?cnica para que no se liquide
****************************************************************************/
-- Bug 22076 - AVT - 21/06/2012 - se crea la funcion
   FUNCTION f_set_reten_liquida(
      pccompani IN NUMBER,
      pnversio IN NUMBER,
      pscontra IN NUMBER,
      pctramo IN NUMBER,
      pnnumlin IN NUMBER,
      pccorred IN NUMBER DEFAULT NULL,
      pcempres IN NUMBER DEFAULT NULL,
      psproduc IN NUMBER DEFAULT NULL,
      pfcierre IN DATE DEFAULT NULL,
      pestadonew IN NUMBER,
      pestadoold IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'params : pccompani : ' || pccompani || ', pnversio : ' || pnversio
            || ', pscontra : ' || pscontra || ' , pctramo : ' || pctramo || ', pnnumlin : '
            || pnnumlin || ' , pestadoNew : ' || pestadonew || ' , pestadoOld : '
            || pestadoold || ' , pccorred : ' || pccorred || ' , pcempres : ' || pcempres
            || ' , psproduc : ' || psproduc || ' , pfcierre : ' || pfcierre;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_reten_liquida';
      vnumerr        NUMBER := 0;
      v_ttexto       VARCHAR2(1000);
      v_llinia       NUMBER := 0;
      vidioma        NUMBER;
   BEGIN
      vidioma := pac_md_common.f_get_cxtidioma;
      vnumerr := pac_rea.f_set_reten_liquida(pccompani, pnversio, pscontra, pctramo, pnnumlin,
                                             pccorred, pcempres, psproduc, pfcierre,
                                             pestadonew, pestadoold);

      IF vnumerr <> 0 THEN   -- hay errores
         v_ttexto := f_axis_literales(vnumerr, vidioma);
         ROLLBACK;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_reten_liquida;

      /*******************************************************************************
   FUNCION F_REGISTRA_PROCESO
   Esta función deberá realizar una llamada a la función de la capa de negocio pac_rea.f_inicializa_liquida_rea
    Parámetros
     Entrada :
       Pfperini NUMBER : Fecha inicio
       Pcempres NUMBER : Empresa

     Salida :
       Mensajes   T_IAX_MENSAJES

    Retorna : NUMBER con el número de proceso.
   ********************************************************************************/
   FUNCTION f_registra_proceso(
      pfperini IN DATE,
      pcempres IN NUMBER,
      pnproceso OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := ' pfperini=' || pfperini || 'pcempres=' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_MD_REA.F_REGISTRA_PROCESO';
      vnumerr        NUMBER;
      vtexto         VARCHAR2(100);
   BEGIN
      -- Control parametros entrada
      IF pfperini IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_rea.f_inicializa_liquida_rea(pfperini, pcempres, 'LIQUIDACION REA',
                                                  pac_md_common.f_get_cxtidioma, pnproceso);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_registra_proceso;

   -- Bug 26444 - ETM - 31/07/2012 - se crea la funcion -INI
   FUNCTION f_get_movmanual_rea(
      pscontra IN NUMBER,
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      ptdescrip IN VARCHAR2,
      pnidentif IN VARCHAR2,
      pcconcep IN NUMBER,
      pcdebhab IN NUMBER,
      piimport IN NUMBER,
      pnsinies IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcevento IN VARCHAR2,
      pcgarant IN NUMBER DEFAULT 0,
      pnidout OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_movmanual_rea';
      v_param        VARCHAR2(800)
         := 'params :   pscontra:' || pscontra || ' - pcempres:' || pcempres || ' - pnversio:'
            || pnversio || ' - pctramo:' || pctramo || ' - pfcierre:' || pfcierre
            || ' - ptdescrip:' || ptdescrip || ' - pnidentif:' || pnidentif || ' - pcconcep:'
            || pcconcep || ' - pcdebhab:' || pcdebhab || ' - piimport:' || piimport
            || ' - pnsinies:' || pnsinies || ' - pnpoliza:' || pnpoliza || ' - pncertif:'
            || pncertif || ' - pcevento:' || pcevento || ' - pcgarant:' || pcgarant
            || ' - pnidout:' || pnidout;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      vnumerr        NUMBER := 0;
      v_where        VARCHAR2(4000);
      v_sproces      cierres.sproces%TYPE;
      v_ctipo        cierres.ctipo%TYPE;
      v_tipo         codicontratos.ctiprea%TYPE;
      vpasexec       NUMBER := 0;
      v_tmp_evento   NUMBER;
   BEGIN
      IF pcconcep IN(1, 2, 9)
         AND pnpoliza IS NULL THEN
         vnumerr := 140896;   --POLIZA OBLIGATORIA
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 1;

      -- 54.0 - 22/09/2014 - MMM - 0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales - Inicio
      -- Modificaciones en la lógica de validación

      -- Para los conceptos 5 y 25 los campos obligatorios son:
      -- 1. Evento/Siniestro si el contrato es de EVENTOS (CDEVENTO <> 0 en CODICONTRATOS)
      -- 2- En caso contrario Siniestro

      -- IF pcconcep IN(25, 5)
       --    AND(pnsinies IS NULL
       --        AND pcevento IS NULL) THEN
       --    vnumerr := 9905814;   --Los campos Siniestro o Evento deben estar informados
       --    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
       --    RAISE e_object_error;
       -- END IF;
      BEGIN
         SELECT cdevento
           INTO v_tmp_evento
           FROM codicontratos
          WHERE scontra = pscontra;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_tmp_evento := 0;
      END;

      -- Opción 1, si CDEVENTO es <> 0
      IF NVL(v_tmp_evento, 0) <> 0 THEN
         IF pcconcep IN(25, 5)
            AND(pnsinies IS NULL
                AND pcevento IS NULL) THEN
            vnumerr := 9905814;   --Los campos Siniestro o Evento deben estar informados
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      -- Opción 2, si CDEVENTO es = 0
      ELSE
         IF pcconcep IN(25, 5)
            AND pnsinies IS NULL THEN
            --vnumerr := 9905814;
            vnumerr := 9903679;   -- No ha seleccionado ningún siniestro
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END IF;   -- Del IF que mira el CDEVENTO

      -- 54.0 - 22/09/2014 - MMM - 0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales - Fin
      vpasexec := 2;

      IF pcconcep NOT IN(1, 2, 9, 25, 5)
         AND(pnpoliza IS NOT NULL
             OR pnsinies IS NOT NULL
             OR pcevento IS NOT NULL) THEN
         vnumerr := 9905816;   --Para este concepto los campos Póliza,Siniestro y Evento no han de estar informados
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;

      --lamar a la md para hacer un max de la temporal -->pnidout
      SELECT NVL(MAX(nid), 0) + 1
        INTO pnidout
        FROM mov_manual_prev
       WHERE cempres = pcempres;

      BEGIN
         SELECT ctiprea   --DETVALORES
           INTO v_tipo
           FROM codicontratos
          WHERE scontra = pscontra;

         IF v_tipo = 3 THEN
            v_ctipo := 15;
         ELSE
            v_ctipo := 4;
         END IF;

         vpasexec := 4;

         BEGIN
            SELECT sproces
              INTO v_sproces
              FROM cierres
             WHERE cempres = pcempres
               AND ctipo = v_ctipo   --detvaloRes 167
               AND fcierre = pfcierre
               AND cestado <> 1;   --detvalores 168
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_sproces := 0;
            WHEN OTHERS THEN
               vpasexec := 5;
               vnumerr := 9905818;   --El cierre esta cerrado o no existe.
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
         END;

         --llamo para INSERTAR EL movprevio
         vpasexec := 6;
         vnumerr := pac_md_rea.f_insertar_movprevio(v_sproces, pscontra, pcempres, pnversio,
                                                    pctramo, pfcierre, ptdescrip, pnidentif,
                                                    pcconcep, pcdebhab, piimport, pnsinies,
                                                    pnpoliza, pncertif, pcevento,
                                                    NVL(pcgarant, 0), pnidout, mensajes);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vpasexec := 7;
            ROLLBACK;
            vnumerr := 9905818;   --El cierre esta cerrado o no existe.
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
      END;

      IF vnumerr <> 0 THEN
         vpasexec := 8;
         vnumerr := 140999;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
         ROLLBACK;
         RAISE e_object_error;
      ELSE
         COMMIT;
      END IF;

      vpasexec := 9;
      vsquery := ' SELECT pa.tcompani, (SELECT cc.scontra || '' - '' || cc.tcontra '
                 || '  FROM contratos cc  WHERE cc.scontra = m.scontra '
                 || ' AND cc.nversio = m.nversio) tcontra, nversio, '
                 || '  ff_desvalorfijo(105, ' || vidioma || ', m.ctramo) ttramo, m.fcierre, '
                 || '  ff_desvalorfijo(19,' || vidioma || ', m.cdebhab) tdebhab, '
                 || ' ff_desvalorfijo(124,' || vidioma || ', m.cconcep) tconcep, m.iimport'
                 || ' FROM movctaaux m, companias pa ';
      p_agrega_where(v_where, ' WHERE m.ccompani = pa.ccompani  AND m.nid =' || pnidout);
      /*
         IF pscontra IS NOT NULL THEN
           p_agrega_where(v_where, ' m.scontra = ' || pscontra);
        END IF;

        IF pcempres IS NOT NULL THEN
           p_agrega_where(v_where, ' m.cempres = ' || pcempres);
        END IF;

        IF pnversio IS NOT NULL THEN
           p_agrega_where(v_where, ' m.nversio = ' || pnversio);
        END IF ;

        IF pctramo IS NOT NULL THEN
           p_agrega_where(v_where, ' m.ctramo = ' || pctramo);
        END IF ;

        IF pfcierre IS NOT NULL THEN
           p_agrega_where(v_where, ' m.fcierre =  ' || 'to_date('''
                      || TO_CHAR(pfcierre, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')');
        END IF ;
       */---------
      vsquery := vsquery || v_where;
      vpasexec := 10;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 11;

      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 12;
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, v_param);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, v_param);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_movmanual_rea;

   FUNCTION f_borrar_movprevio(
      pcempres IN NUMBER,
      pnid IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := ' pcempres=' || pcempres || 'pnid=' || pnid;
      vobject        VARCHAR2(200) := 'PAC_MD_REA.f_borrar_movprevio';
      vnumerr        NUMBER;
      vtexto         VARCHAR2(100);
   BEGIN
      -- Control parametros entrada
      IF pnid IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_rea.f_borrar_movprevio(pcempres, pnid);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_borrar_movprevio;

   FUNCTION f_insertar_movprevio(
      psproces IN NUMBER,
      pscontra IN NUMBER,
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      ptdescrip IN VARCHAR2,
      pnidentif IN VARCHAR2,
      pcconcep IN NUMBER,
      pcdebhab IN NUMBER,
      piimport IN NUMBER,
      pnsinies IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcevento IN VARCHAR2,
      pcgarant IN NUMBER DEFAULT 0,
      pnidout IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_MD_REA.f_insertar_movprevio';
      v_param        VARCHAR2(800)
         := 'params : psproces : ' || psproces || ' - pscontra:' || pscontra || ' - pcempres:'
            || pcempres || ' - pnversio:' || pnversio || ' - pctramo:' || pctramo
            || ' - pfcierre:' || pfcierre || ' - ptdescrip:' || ptdescrip || ' - pnidentif:'
            || pnidentif || ' - pcconcep:' || pcconcep || ' - pcdebhab:' || pcdebhab
            || ' - piimport:' || piimport || ' - pnsinies:' || pnsinies || ' - pnpoliza:'
            || pnpoliza || ' - pncertif:' || pncertif || ' - pcevento:' || pcevento
            || ' - pcgarant:' || pcgarant || ' - pnidout:' || pnidout;
      v_pasexec      NUMBER(5) := 0;
      v_importe      NUMBER;
      v_error        NUMBER;
   BEGIN
      v_pasexec := 1;

      -- Control parametros entrada
      IF pnidout IS NULL THEN
         v_error := 9001768;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RETURN v_error;
      END IF;

      v_pasexec := 2;
      v_error := pac_rea.f_insertar_movprevio(psproces, pscontra, pcempres, pnversio, pctramo,
                                              pfcierre, ptdescrip, pnidentif, pcconcep,
                                              pcdebhab, piimport, pnsinies, pnpoliza, pncertif,
                                              pcevento, pcgarant, pnidout);
      v_pasexec := 3;

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);   -- error interno.
         RAISE e_object_error;
      END IF;

      v_pasexec := 4;
      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_insertar_movprevio;

   FUNCTION f_graba_real_movmanual_rea(
      pcempres IN NUMBER,
      pnid IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_MD_REA.f_graba_real_movmanual_rea';
      v_param        VARCHAR2(800) := 'params : pcempres : ' || pcempres || ' - pnid:' || pnid;
      v_pasexec      NUMBER(5) := 0;
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_rea.f_graba_real_movmanual_rea(pcempres, pnid);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_graba_real_movmanual_rea;

-- FIN Bug 26444 - ETM - 31/07/2012 - se crea la funcion

   /*************************************************************************
*************************************************************************/
-- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_max_cod_reposicion(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200);
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_max_cod_reposicion';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
   BEGIN
      vsquery := 'select max(ccodigo) as max_codigo from cod_reposicion';
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_max_cod_reposicion;

   FUNCTION f_get_filtered_tramos(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      filter_tramos IN VARCHAR,
      --filter_companias   IN VARCHAR,
      not_in IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_tramos_rea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                         := 'par?metros - pscontra:' || pscontra || ' - pnversio:' || pnversio;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_Tramos_Rea';
      vsquery        VARCHAR2(9000);
      vtramos        t_iax_tramos_rea;
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      vobjtramos     ob_iax_tramos_rea;
      vcursor        sys_refcursor;
      i              NUMBER;
      --INI BUG CONF-250  Fecha (02/09/2016) - HRE - manejo de contratos Q1, Q2, Q3
      v_tiprea        codicontratos.ctiprea%TYPE;
      v_valor         detvalores.cvalor%TYPE;
      --FIN BUG CONF-250  - Fecha (02/09/2016) - HRE

   BEGIN
      IF pscontra IS NULL
         OR pnversio IS NULL
         OR not_in IS NULL THEN
         -- Error en los par?metros
         RAISE e_param_error;
      END IF;

      --INI BUG CONF-250  Fecha (02/09/2016) - HRE - manejo de contratos Q1, Q2, Q3
      SELECT ctiprea
        INTO v_tiprea
        FROM codicontratos
       WHERE scontra = pscontra;

      IF (v_tiprea = 5) THEN
         v_valor := 8002002;
      ELSE
         v_valor := 105;
      END IF;
      --FIN BUG CONF-250  - Fecha (02/09/2016) - HRE

      vpasexec := 2;
      -- Bug 18319 - APD - 06/07/2011 - se a?aden los campos
      -- IDAA, ILAA, CTPRIMAXL, IPRIMAFIJAXL, IPRIMAESTIMADA, CAPLICTASAXL, '
      -- CTIPTASAXL, CTRAMOTASAXL, PCTPDXL, CFORPAGPDXL, PCTMINXL, PCTPB, '
      -- NANYOSLOSS, CLOSSCORRIDOR, CAPPEDRATIO, CREPOS, '
      -- IBONOREC, IMPAVISO, IMPCONTADO, PCTCONTADO, PCTDEP, CFORPAGDEP, '
      -- INTDEP, PCTGASTOS, PTASAAJUSTE, ICAPCOASEG
      -- 21829 04/04/2012 AVT es canvia el 113 de TFREPMD per VF=17

      --AGG 04/06/2014 Se añaden los campos ICOSTOFIJO, PCOMISINTERM
      vsquery :=
         'SELECT nversio, scontra, ctramo, ff_desvalorfijo ('||v_valor||', ' || vidioma--BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
         || ', ctramo) ttramo,
                         itottra, nplenos, cfrebor, plocal, ixlprio, ixlexce, pslprio,
                         pslexce, ncesion, fultbor, imaxplo, norden, nsegcon, nsegver, iminxl, idepxl, nctrxl,
                         nverxl, ptasaxl, ipmd, cfrepmd, ff_desvalorfijo (17, '
         || vidioma || ', cfrepmd) tfrepmd, caplixl, plimgas, pliminx, ff_desvalorfijo (113, '
         || vidioma || ', cfrebor) tfrebor, '
         || ' IDAA, ILAA, CTPRIMAXL, ff_desvalorfijo (342, ' || vidioma
         || ', ctprimaxl) ttprimaxl, IPRIMAFIJAXL, IPRIMAESTIMADA, CAPLICTASAXL, ff_desvalorfijo (343, '
         || vidioma || ', caplictasaxl) taplictasaxl, '
         || ' CTIPTASAXL, ff_desvalorfijo (344, ' || vidioma
         || ', ctiptasaxl) ttiptasaxl, CTRAMOTASAXL, (SELECT tdescripcion FROM clausulas_reas WHERE ccodigo = CTRAMOTASAXL and cidioma= '
         || vidioma || ') ttramotasaxl, PCTPDXL, ' || ' CFORPAGPDXL, ff_desvalorfijo (113, '
         || vidioma || ', CFORPAGPDXL) tforpagpdxl, PCTMINXL, PCTPB, '
         || ' NANYOSLOSS, CLOSSCORRIDOR, (SELECT tdescripcion FROM clausulas_reas WHERE ccodigo = CLOSSCORRIDOR and cidioma= '
         || vidioma || ') tlosscorridor, '
         || ' cCAPPEDRATIO, (SELECT tdescripcion FROM clausulas_reas WHERE ccodigo = cCAPPEDRATIO and cidioma= '
         || vidioma
         || ') tcappedratio, CREPOS, (SELECT tdescripcion FROM reposiciones WHERE ccodigo = CREPOS and cidioma= '
         || vidioma || ') trepos, '
         || ' IBONOREC, IMPAVISO, IMPCONTADO, PCTCONTADO, PCTGASTOS, PTASAAJUSTE, ICAPCOASEG, ICOSTOFIJO, PCOMISINTERM,IPRIO
                  FROM tramos
                  WHERE scontra = '
         || pscontra || ' AND nversio = ' || pnversio;

      IF filter_tramos IS NOT NULL
         AND LENGTH(filter_tramos) > 0 THEN
         IF not_in = 1 THEN
            vsquery := vsquery || ' and ctramo not in (' || filter_tramos || ')';
         ELSE
            IF not_in = 0 THEN
               vsquery := vsquery || ' and ctramo in (' || filter_tramos || ')';
            END IF;
         END IF;
      END IF;

      -- fIN Bug 18319 - APD - 06/07/2011
      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         -- Se ha producido un error en PAC_MD_LOG.F_LOG_CONSULTAS
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      IF NOT vcursor%ISOPEN THEN
         -- Se ha producido un error en  PAC_IAX_LISTVALORES.F_Opencursor
         RAISE e_object_error;
      ELSE
         vtramos := t_iax_tramos_rea();
         vpasexec := 6;

         LOOP
            vobjtramos := ob_iax_tramos_rea();
            vpasexec := 6.1;

            -- Bug 18319 - APD - 06/07/2011 - se a?aden los campos
            -- IDAA, ILAA, CTPRIMAXL, IPRIMAFIJAXL, IPRIMAESTIMADA, CAPLICTASAXL, '
            -- CTIPTASAXL, CTRAMOTASAXL, PCTPDXL, CFORPAGPDXL, PCTMINXL, PCTPB, '
            -- NANYOSLOSS, CLOSSCORRIDOR, CAPPEDRATIO, CREPOS, '
            -- IBONOREC, IMPAVISO, IMPCONTADO, PCTCONTADO, PCTDEP, CFORPAGDEP, '
            -- INTDEP, PCTGASTOS, PTASAAJUSTE, ICAPCOASEG
            FETCH vcursor
             INTO vobjtramos.nversio, vobjtramos.scontra, vobjtramos.ctramo,
                  vobjtramos.ttramo, vobjtramos.itottra, vobjtramos.nplenos,
                  vobjtramos.cfrebor, vobjtramos.plocal, vobjtramos.ixlprio,
                  vobjtramos.ixlexce, vobjtramos.pslprio, vobjtramos.pslexce,
                  vobjtramos.ncesion, vobjtramos.fultbor, vobjtramos.imaxplo,
                  vobjtramos.norden, vobjtramos.nsegcon, vobjtramos.nsegver,
                  vobjtramos.iminxl, vobjtramos.idepxl, vobjtramos.nctrxl, vobjtramos.nverxl,
                  vobjtramos.ptasaxl, vobjtramos.ipmd, vobjtramos.cfrepmd, vobjtramos.tfrepmd,
                  vobjtramos.caplixl, vobjtramos.plimgas, vobjtramos.pliminx,
                  vobjtramos.tfrebor, vobjtramos.idaa, vobjtramos.ilaa, vobjtramos.ctprimaxl,
                  vobjtramos.ttprimaxl, vobjtramos.iprimafijaxl, vobjtramos.iprimaestimada,
                  vobjtramos.caplictasaxl, vobjtramos.taplictasaxl, vobjtramos.ctiptasaxl,
                  vobjtramos.ttiptasaxl, vobjtramos.ctramotasaxl, vobjtramos.ttramotasaxl,
                  vobjtramos.pctpdxl, vobjtramos.cforpagpdxl, vobjtramos.tforpagpdxl,
                  vobjtramos.pctminxl, vobjtramos.pctpb, vobjtramos.nanyosloss,
                  vobjtramos.closscorridor, vobjtramos.tlosscorridor, vobjtramos.ccappedratio,
                  vobjtramos.tcappedratio, vobjtramos.crepos, vobjtramos.trepos,
                  vobjtramos.ibonorec, vobjtramos.impaviso, vobjtramos.impcontado,
                  vobjtramos.pctcontado, vobjtramos.pctgastos, vobjtramos.ptasaajuste,
                  vobjtramos.icapcoaseg, vobjtramos.icostofijo, vobjtramos.pcomisinterm,vobjtramos.iprio;

            -- fIN Bug 18319 - APD - 06/07/2011
            vpasexec := 6.2;

            IF vcursor%NOTFOUND THEN
               EXIT;
            END IF;

            vpasexec := 6.3;
            vobjtramos.cuadroces := f_get_cuadroces_rea(vobjtramos.scontra, vobjtramos.nversio,
                                                        vobjtramos.ctramo, mensajes);
            vpasexec := 6.4;
            vobjtramos.tramosinbono := f_get_tramo_sin_bono(vobjtramos.scontra,
                                                            vobjtramos.nversio,
                                                            vobjtramos.ctramo, mensajes);
            vpasexec := 7;
            vtramos.EXTEND;
            vtramos(vtramos.LAST) := vobjtramos;
            vpasexec := 8;
         END LOOP;

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
      END IF;

      vpasexec := 7;
      RETURN vtramos;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RAISE;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RAISE;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RAISE;
   END f_get_filtered_tramos;

   FUNCTION f_del_contrato_rea(pscontra IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800);
      vobject        VARCHAR2(50) := 'pac_md_rea.f_del_contrato_rea';
   BEGIN
      vnumerr := pac_rea.f_del_contrato_rea(pscontra);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_contrato_rea;

   FUNCTION f_get_reposiciones_contrato(
      pccodigo IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pccodigo = ' || pccodigo;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_reposiciones_contrato';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
   BEGIN
      vsquery :=
         'select r.ccodigo, r.tdescripcion as trepo, t.nversio, t.scontra, cc.tdescripcion as tcontra, t.ctramo, d.tatribu as ttramo from '
         || ' reposiciones r, tramos t, contratos c, codicontratos cc, detvalores d '
         || 'where c.scontra = t.scontra and c.nversio = t.nversio and t.crepos = r.ccodigo and c.scontra = cc.scontra '
         || 'and r.cidioma = ' || vidioma || ' and '
         || ' d.CATRIBU = t.CTRAMO and d.cvalor =105 and d.cidioma = NVL('
         || NVL(TO_CHAR(vidioma), 'NULL') || ',d.cidioma)';

      IF pccodigo IS NOT NULL THEN
         vsquery := vsquery || ' and r.ccodigo = ' || pccodigo;
      END IF;

      IF pscontra IS NOT NULL THEN
         vsquery := vsquery || ' and c.scontra = ' || pscontra;
      END IF;

      IF pnversio IS NOT NULL THEN
         vsquery := vsquery || ' and t.nversio = ' || pnversio;
      END IF;

      IF pctramo IS NOT NULL THEN
         vsquery := vsquery || ' and t.ctramo = ' || pctramo;
      END IF;

      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_reposiciones_contrato;

   FUNCTION f_get_liquida(pspagrea IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800) := 'parametros - pspagrea :' || pspagrea;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_liquida';
      v_num          NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO v_num
        FROM pagos_ctatec_rea
       WHERE spagrea = pspagrea;

      IF (v_num < 1) THEN
         vnumerr := 9904133;   -->> Error en la liquidación de reaseguro
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_liquida;

   FUNCTION f_val_liquida(
      pspagrea IN NUMBER,
      pfcambio IN DATE,
      pitotal IN NUMBER,
      pmoneda IN VARCHAR2,
      pcestpag IN NUMBER,
      piimporte OUT pagos_ctatec_rea.iimporte%TYPE,
      piimporte_moncon OUT pagos_ctatec_rea.iimporte_moncon%TYPE,
      pctipopag OUT pagos_ctatec_rea.ctipopag%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      v_pasexec      NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parametros - pspagrea :' || pspagrea || ' pfcambio : ' || pfcambio
            || ' pitotal : ' || pitotal || ' pmoneda : ' || pmoneda || ' pcestpag : '
            || pcestpag;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_val_liquida';
      v_cestado      pagos_ctatec_rea.cestado%TYPE;
      v_cempres      pagos_ctatec_rea.cempres%TYPE;
      v_scontra      movctatecnica.scontra%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      v_cmoncontab   parempresas.nvalpar%TYPE;
      v_fcambio      DATE;
      v_itasa        NUMBER;
   BEGIN
      -- Se validan algunos parámetros de entrada
      IF pfcambio IS NULL THEN
         v_pasexec := 20;
         vnumerr := 9001248;   -->> La fecha contable de la empresa no está informada
      ELSIF NVL(pitotal, 0) = 0 THEN
         v_pasexec := 30;
         vnumerr := 9002227;   -->> Error al obtener el importe del recibo
      END IF;

      v_pasexec := 40;

      SELECT cestado, cempres
        INTO v_cestado, v_cempres
        FROM pagos_ctatec_rea
       WHERE spagrea = pspagrea;

      v_pasexec := 50;

      IF v_cestado = 0 THEN
         -- COMPROBAR ESTADO LIQUIDACION
         v_pasexec := 60;
         vnumerr := 9902071;   -->> ya liquidado
      ELSE
         -- IMPORTES CONTABLES:
         v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

         IF v_cmultimon = 1 THEN
            v_pasexec := 70;

            SELECT DISTINCT scontra
                       INTO v_scontra
                       FROM movctatecnica
                      WHERE spagrea = pspagrea;

            v_fcambio := pfcambio;
            vnumerr := pac_oper_monedas.f_datos_contraval(NULL, NULL, v_scontra, pfcambio, 3,
                                                          v_itasa, v_fcambio);

            IF vnumerr = 0 THEN
               v_pasexec := 80;

               IF (NVL(pitotal, 0) <> 0) THEN
                  v_pasexec := 90;
                  v_cmoncontab := pac_parametros.f_parempresa_n(v_cempres, 'MONEDACONTAB');
                  piimporte_moncon := f_round(NVL(pitotal, 0) * v_itasa, v_cmoncontab);

                  IF piimporte_moncon > 0 THEN
                     v_pasexec := 100;
                     pctipopag := 1;
                     piimporte := pitotal;
                  ELSE
                     v_pasexec := 110;
                     pctipopag := 2;
                     piimporte := -pitotal;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      v_pasexec := 120;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, v_pasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, v_pasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, v_pasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_val_liquida;

   FUNCTION f_set_liquida(
      pspagrea IN NUMBER,
      pfcambio IN DATE,
      pitotal IN NUMBER,
      pmoneda IN VARCHAR2,
      pcestpag IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      v_pasexec      NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parametros - pspagrea :' || pspagrea || ' pfcambio : ' || pfcambio
            || ' pitotal : ' || pitotal || ' pmoneda : ' || pmoneda || ' pcestpag : '
            || pcestpag;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_liquida';
      piimporte      pagos_ctatec_rea.iimporte%TYPE;
      piimporte_moncon pagos_ctatec_rea.iimporte_moncon%TYPE;
      pctipopag      pagos_ctatec_rea.ctipopag%TYPE;
   BEGIN
      vnumerr := f_get_liquida(pspagrea, mensajes);
      v_pasexec := 10;

      IF (vnumerr = 0) THEN
         v_pasexec := 20;
         vnumerr := f_val_liquida(pspagrea, pfcambio, pitotal, pmoneda, pcestpag, piimporte,
                                  piimporte_moncon, pctipopag, mensajes);

         IF (vnumerr = 0) THEN
            v_pasexec := 30;
            vnumerr := pac_rea.f_set_liquida(pspagrea, pfcambio, pcestpag, piimporte,
                                             piimporte_moncon, pctipopag, mensajes);
         END IF;
      END IF;

      v_pasexec := 40;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, v_pasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, v_pasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, v_pasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_liquida;

   -- INI - EDBR - 13/06/2019 -  IAXIS4330
/*************************************************************************
      Recupera los trimestres de los dos últimos años
      param in pfinitrim   :  fecha de inicio de trimestre 
      param in pffintrim   :  fecha de fin de trimestre
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
    *************************************************************************/
	FUNCTION f_get_trimestres(
      pfinitrim IN DATE,
      pffintrim IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_REA.f_get_trimestres';
      vparam         VARCHAR2(500)
                       := 'parámetros - pfinitrim: ' || pfinitrim || ', pffintrim: ' || pffintrim;
      vpasexec       NUMBER(5) := 1;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(4000);
   BEGIN
      vpasexec := 1;
      vsquery  :=
         'SELECT r1.*, e.tmoneda AS tmoneda
            FROM (SELECT ntrim, MAX(nmovimi) AS nmovimi
                    FROM reapattec
                   WHERE fmovfin IS NULL
                   GROUP BY ntrim) r
           INNER JOIN reapattec r1
              ON r1.ntrim = r.ntrim
             AND r1.nmovimi = r.nmovimi';

      IF pfinitrim IS NOT NULL AND pffintrim IS NOT NULL THEN
         vsquery := vsquery || ' AND r1.finitrim = to_date(''' || TO_CHAR(pfinitrim, 'dd/mm/yyyy')
                        || ''',''dd/mm/yyyy'')'|| ' AND r1.ffintrim = to_date(''' || TO_CHAR(pffintrim, 'dd/mm/yyyy')
                        || ''',''dd/mm/yyyy'')';
      END IF;

      vsquery :=
         vsquery
         || ' INNER JOIN eco_desmonedas e
                ON  e.cmoneda = r1.cmoneda
               AND  e.cidioma = '||pac_md_common.f_get_cxtidioma();

      vsquery :=
         vsquery
         || ' ORDER BY r1.nanio DESC, r1.ntrim ASC';

      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      p_control_error('dbCJ','testing SELECT', vsquery);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_trimestres;
-- FIN - EDBR - 13/06/2019 -  IAXIS4330

  -- INI - EDBR - 18/06/2019 -  IAXIS4330
    /*************************************************************************
    Funcion que inserta o modifica el registro de patrimoinio tecnico 
   *************************************************************************/
   FUNCTION f_set_patri_tec(
      panio NUMBER,   -- año parametrizado del patrimonio
      ptrimestre NUMBER,   -- trimestre
      pmoneda VARCHAR2,   -- moneda
      pvalor NUMBER,   -- valor   
      pmovimi number,   --numero de moviento NULL nuevo registro ELSE update
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_REA.f_set_patri_tec';

      vparam         VARCHAR2(500)
                        := 'parámetros - panio: '|| panio || ', ptrimestre: ' || ptrimestre || ', pmoneda: '|| pmoneda || ', pvalor: ' || pvalor;
      vpasexec       NUMBER(5) := 1;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vnumerr        NUMBER(8) := 0;
   BEGIN
       vnumerr := pac_rea.f_set_patri_tec(panio, ptrimestre, pmoneda, pvalor, pmovimi);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;

   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
    end f_set_patri_tec;
      -- FIN - EDBR - 18/06/2019 -  IAXIS4330

        -- INI - EDBR - 19/06/2019 -  IAXIS4330
/*************************************************************************
      Recupera los registros de todos los moviementos de los patrimonios segun los parametros de año y trimestre
      param in pnanio   :  año 
      param in pntrim   :  ftrimestre
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
    *************************************************************************/
    FUNCTION f_get_hist_pat_tec(
      pnanio IN NUMBER,
      pntrim IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_REA.f_get_hist_pat_tec';
      vparam         VARCHAR2(500)
                       := 'parámetros - pnanio: ' || pnanio || ', pntrim: ' || pntrim;
      vpasexec       NUMBER(5) := 1;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(4000);
   BEGIN
      vpasexec := 1;
      vsquery  := 'select r.*, E.TMONEDA from REAPATTEC r INNER JOIN eco_desmonedas e
ON  e.cmoneda = r.cmoneda WHERE r.NANIO = '|| pnanio ||' AND r.NTRIM = '|| pntrim ||' AND  e.cidioma = 8 ORDER BY r.NMOVIMI ASC';

      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      p_control_error('dbCJ','testing SELECT HISTORICO', vsquery);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;

      END f_get_hist_pat_tec;
-- FIN - EDBR - 19/06/2019 -  IAXIS4330

   FUNCTION f_get_tramo_sin_bono(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_tramo_sin_bono IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parametros - pscontra:' || pscontra || ' - pnversio:' || pnversio
            || ' - pctramo:' || pctramo;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_get_tramo_sin_bono';
      vsquery        VARCHAR2(9000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      --vretorno       ob_iax_tramo_sin_bono := ob_iax_tramo_sin_bono();
      vtramossb      t_iax_tramo_sin_bono;
      vtramosb       ob_iax_tramo_sin_bono;
      vcursor        sys_refcursor;
   BEGIN
      IF pscontra IS NULL
         OR pnversio IS NULL
         OR pctramo IS NULL THEN
         -- Error en los par?metros
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vsquery :=
         'select scontra, nversio, ctramo, psiniestra,pbonorec from tramo_siniestralidad_bono
                  WHERE scontra = '
         || pscontra || ' AND nversio = ' || pnversio || ' AND ctramo = ' || pctramo;
      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 4;

      -- Se guarda el log de la consulta.
      IF pac_md_log.f_log_consultas(vsquery, vobject, 1, 4, mensajes) <> 0 THEN
         -- Se ha producido un error al guardar el log de la consulta.
         RAISE e_object_error;
      END IF;

      IF NOT vcursor%ISOPEN THEN
         vpasexec := 5;
         -- Se ha producido un error en PAC_IAX_LISTVALORES.F_Opencursor
         RAISE e_object_error;
      ELSE
         vtramossb := t_iax_tramo_sin_bono();
         vpasexec := 6;

         LOOP
            vtramosb := ob_iax_tramo_sin_bono();
            vpasexec := 6.1;

            FETCH vcursor
             INTO vtramosb.scontra, vtramosb.nversio, vtramosb.ctramo, vtramosb.psiniestra,
                  vtramosb.pbonorec;

            vpasexec := 7;

            IF vcursor%NOTFOUND THEN
               EXIT;
            END IF;

            vpasexec := 6.3;
            vtramossb.EXTEND;
            vtramossb(vtramossb.LAST) := vtramosb;
            vpasexec := 6.4;
         END LOOP;
      END IF;

      vpasexec := 5;
      RETURN vtramossb;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RAISE;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RAISE;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RAISE;
   END f_get_tramo_sin_bono;

     /* INI - ML - 4549
    * f_activar_contrato: ACTIVA INDIVIDUALMENTE UN CONTRATO EN REASEGURO, TOMANDO LA ULTIMA VERSION VALIDA
    * RETORNA EL ESTADO DEL PROCESO, EN DONDE 0 SERIA CORRECTO Y ALGUN OTRO ES UN LITERAL DE ERROR O MENSAJE      
   */
   FUNCTION f_activar_contrato(pscontra IN NUMBER)
      RETURN NUMBER IS      
   BEGIN
	  RETURN PAC_REA.F_ACTIVAR_CONTRATO (PSCONTRA => pscontra);  	   
   EXCEPTION
      WHEN OTHERS THEN 	     
         RETURN 89907022; -- ERROR AL ACTIVAR EL CONTRATO
   END f_activar_contrato;

  FUNCTION f_get_compani_doc(
            pccompani IN NUMBER,
            mensajes  IN OUT t_iax_mensajes)
       RETURN SYS_REFCURSOR
  IS
       --
       v_cursor SYS_REFCURSOR;
       --
       e_object_error EXCEPTION;
       e_param_error  EXCEPTION;
       vpasexec       NUMBER;
       vobject        VARCHAR2(200) := 'pac_md_contragarantias.f_get_compani_doc';
       vparam         VARCHAR2(500) := 'pccompani: ' || pccompani;
       --
  BEGIN
       --
       OPEN v_cursor FOR SELECT pac_axisgedox.f_get_descdoc(iddocgdx) descripcion,
       SUBSTR(pac_axisgedox.f_get_filedoc(iddocgdx), INSTR(pac_axisgedox.f_get_filedoc(iddocgdx), '\'
       , -1) + 1, LENGTH(pac_axisgedox.f_get_filedoc(iddocgdx))) nombre,
       tobserv,
       falta,
       fcaduci FROM cmpani_doc WHERE ccompani = pccompani;
       --
       RETURN v_cursor;
       --
  EXCEPTION
  WHEN e_param_error THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
       RETURN NULL;
  WHEN e_object_error THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
       RETURN NULL;
  WHEN OTHERS THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode =>
       SQLCODE, psqerrm => SQLERRM);
       RETURN NULL;
  END f_get_compani_doc;
  FUNCTION f_edit_compani_doc(
            pccompani  IN NUMBER,
            piddocgdx  IN NUMBER,
            pctipo     IN NUMBER,
            ptobserv   IN VARCHAR2,
            ptfilename IN VARCHAR2,
            pfcaduci   IN DATE,
            pfalta     IN DATE,
            mensajes   IN OUT t_iax_mensajes)
       RETURN NUMBER
  IS
       --
       e_object_error EXCEPTION;
       e_param_error  EXCEPTION;
       vpasexec       NUMBER := 1;
       vobject        VARCHAR2(200) := 'PAC_MD_CONTRAGARANTIAS.f_edit_compani_doc';
       vparam         VARCHAR2(500) := 'pccompani: ' || pccompani || ' piddocgdx: ' || piddocgdx ||
       ' pctipo: ' || pctipo || ' ptobserv: ' || ptobserv || ' pfalta: ' || pfalta || ' pfcaduci: '
       || pfcaduci;
       --
       vnum_err NUMBER;
       --
  BEGIN
       --
       IF pccompani IS NULL OR piddocgdx IS NULL OR pctipo IS NULL OR ptobserv IS NULL THEN
            --
            RAISE e_param_error;
            --
       END IF;
       --
       IF piddocgdx IS NULL THEN
            --
            pac_axisgedox.actualiza_gedoxdb(ptfilename, piddocgdx, vnum_err);
            --
       END IF;
       --
       vnum_err := pac_rea.f_edit_compani_doc(pccompani => pccompani, piddocgdx => piddocgdx, pctipo
       => pctipo, ptobserv => ptobserv, pfcaduci => pfcaduci, pfalta => pfalta, mensajes => mensajes)
       ;
       --
       RETURN vnum_err;
       --
  EXCEPTION
  WHEN e_param_error THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
       RETURN 1;
  WHEN e_object_error THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
       RETURN 1;
  WHEN OTHERS THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode =>
       SQLCODE, psqerrm => SQLERRM);
       RETURN 1;
  END f_edit_compani_doc;
  FUNCTION f_ins_compani_doc(
            pccompani  IN NUMBER,
            piddocgdx  IN NUMBER,
            pctipo     IN NUMBER,
            ptobserv   IN VARCHAR2,
            ptfilename IN VARCHAR2,
            pfcaduci   IN DATE,
            pfalta     IN DATE,
            mensajes   IN OUT t_iax_mensajes)
       RETURN NUMBER
  IS
       --
       e_object_error EXCEPTION;
       e_param_error  EXCEPTION;
       vpasexec       NUMBER := 1;
       vobject        VARCHAR2(200) := 'PAC_MD_CONTRAGARANTIAS.f_ins_compani_doc';
       vparam         VARCHAR2(500) := 'pccompani: ' || pccompani || ' piddocgdx: ' || piddocgdx ||
       ' pctipo: ' || pctipo || ' ptobserv: ' || ptobserv || ' pfcaduci: ' || pfcaduci || ' pfalta: '
       || pfalta;
       --
       vnum_err NUMBER;
       vterror  VARCHAR2(200);
       viddoc   NUMBER(8) := 0;
       --
  BEGIN
       --
       IF pccompani IS NULL OR pctipo IS NULL THEN
            --
            RAISE e_param_error;
            --
       END IF;
       --
       IF piddocgdx IS NULL THEN
            --
            vpasexec := 2;
            pac_axisgedox.grabacabecera(f_user, ptfilename, ptobserv, 1, 1, pctipo, vterror, viddoc);
            --
            IF vterror IS NOT NULL OR NVL(viddoc, 0) = 0 THEN
                 vpasexec := 3;
                 pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
                 RAISE e_object_error;
            END IF;
            --
            pac_axisgedox.actualiza_gedoxdb(ptfilename, viddoc, vterror);
            --
       END IF;
       --
       vpasexec := 4;
       vnum_err := pac_rea.f_ins_compani_doc(pccompani => pccompani, piddocgdx => viddoc, pctipo =>
       pctipo, ptobserv => ptobserv, pfcaduci => pfcaduci, pfalta => pfalta, mensajes => mensajes);
       --
       RETURN vnum_err;
       --
  EXCEPTION
  WHEN e_param_error THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
       RETURN NULL;
  WHEN e_object_error THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
       RETURN NULL;
  WHEN OTHERS THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode =>
       SQLCODE, psqerrm => SQLERRM);
       RETURN NULL;
  END f_ins_compani_doc;
  FUNCTION f_get_compani_docs(
            pccompani IN NUMBER,
            mensajes  IN OUT t_iax_mensajes)
       RETURN SYS_REFCURSOR
  IS
       --
       v_cursor SYS_REFCURSOR;
       --
       vpasexec NUMBER;
       vobject  VARCHAR2(200) := 'pac_md_rea.f_get_compani_docs';
       vparam   VARCHAR2(500) := 'pccompani: ' || pccompani;
       --
  BEGIN
   --
   OPEN v_cursor FOR
      SELECT iddocgdx iddoc,
             pac_axisgedox.f_get_descdoc(iddocgdx) tdescrip,
             ctipo tipo,
             SUBSTR(pac_axisgedox.f_get_filedoc(iddocgdx),
                    INSTR(pac_axisgedox.f_get_filedoc(iddocgdx), '\', -1) + 1,
                    length(pac_axisgedox.f_get_filedoc(iddocgdx))) fichero,
             pac_axisgedox.f_get_farchiv(iddocgdx) farchiv,
             pac_axisgedox.f_get_fcaduci(iddocgdx) fcaduci,
             pac_axisgedox.f_get_felimin(iddocgdx) felimin
        FROM cmpani_doc
       WHERE ccompani = pccompani;
   --
   RETURN v_cursor;
   --
  EXCEPTION
  WHEN e_param_error THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
       RETURN NULL;
  WHEN e_object_error THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
       RETURN NULL;
  WHEN OTHERS THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode =>
       SQLCODE, psqerrm => SQLERRM);
       RETURN NULL;
  END f_get_compani_docs;

   FUNCTION f_get_reaseguro_x_garantia(
      ptabla IN VARCHAR2,
      ppoliza IN NUMBER,
      psseguro IN NUMBER,
      psproces IN NUMBER,
      pcgenera IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_MD_rea.f_get_reaseguro_x_garantia';
      vparam         VARCHAR2(500) := '';
   BEGIN
      v_cursor := pac_rea.f_get_reaseguro_x_garantia(ptabla,ppoliza, psseguro, psproces,pcgenera, mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_reaseguro_x_garantia;

   --CONF-910 Inicio

  /***********************************************************************************************
        Función que indica si una Compañía reaseguradora se encuentra en Cut-Off

  ********************************************************************************************  */
  FUNCTION f_compania_cutoff(p_ccompani     IN  NUMBER,
                             p_fecha        IN  DATE) RETURN VARCHAR2 IS

    v_fbaja  companias.fbaja%TYPE;
    v_res    VARCHAR2(20) := '';

  BEGIN

    BEGIN
      SELECT TRUNC(fbaja)
        INTO v_fbaja
        FROM companias
       WHERE ccompani =  p_ccompani
         AND TRUNC(fbaja) <= TRUNC(p_fecha);
    EXCEPTION WHEN OTHERS THEN
      v_fbaja := NULL;
    END;

    IF v_fbaja IS NOT NULL THEN
      v_res := ' - Cut-Off';
    END IF;

    RETURN v_res;

  END f_compania_cutoff;

  --CONF-910 Fin

 END pac_md_rea;

/
