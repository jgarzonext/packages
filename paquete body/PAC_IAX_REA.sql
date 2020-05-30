--------------------------------------------------------
--  DDL for Package Body PAC_IAX_REA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "AXIS"."PAC_IAX_REA" IS
/******************************************************************************
    NAME:       pac_iax_rea
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/06/2009                    1. Created this package body.
   2.0        17/06/2009    ETM             2. Se a?aden nuevas funciones--0010471: IAX - REA: Desarrollo PL de la consulta de cesiones
   3.0        18/06/2009    ETM             3. 0010487: IAX - REA: Desarrollo PL del mantenimiento de Facultativo
   4.0        02/09/2009    ICV             4. 0010487: IAX - REA: Desarrollo PL del mantenimiento de Facultativo
   5.0        07/09/2009    ICV             5. 0010990: IAX - REA: Desarrollo PL del mantenimiento de contratos
   6.0        29/10/2009    AMC             6. 0011605: CRE - Adaptar consulta de cessions als reemborsaments.
   7.0        30/10/2009    ICV             7. 0011353: CEM - Parametrizacion mantenimiento de contratos Reaseguro
   8.0        04/07/2011    APD             8. 0018319: LCOL003 - Pantalla de mantenimiento del contrato de reaseguro
   9.0        23/05/2012    AVT             9. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
  10.0        20/08/2012    AVT             10.0022374: LCOL_A004-Mantenimiento de facultativo - Fase 2
  11.0        18/01/2013    AEG             11.0025502: LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos
  12.0        12/07/2013    KBR             12.0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 23830/0140221)
  13.0        23/07/2013    JDS             13.0025502: LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos
  14.0        06/08/2013    AVT             14. 23830/0150483 se ajustan variables vparam
  15.0        31/07/2013    ETM             15.0026444: (POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 150 -entidad economica de las agrupaciones (Fase3)
  16.0        23/08/2013    KBR             16.0027911: LCOL_A004-Qtracker: 6163: Validacion campos pantalla mantenimiento cuentas reaseguro (Liquidaciones)
  17.0        30/09/2013    RCL             17. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
  18.0        09/10/2013    SHA             18.0028454: LCOL895-A¿¿adir la compa¿¿?a propia en la consulta y en el mantenimiento de las cuentas t?cnicas de reaseguro
  19.0        05/11/2013    RCL             19. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
  20.0        11/11/2013    SHA             20.0028083: LCOL_A004-0008945: Error en pantalla consulta de reposiciones
  21.0        14/11/2013    DCT             21.0028492: LCOLF3BREA-Revisi?n de los contratos de REASEGURO F3B
  22.0        19/11/2013    JDS             22.0028493: LCOLF3BREA-Revisi?n interfaces Liquidaci?n Reaseguro F3B
  23.0        21/01/2014    JAM             23.0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca
  24.0        02/05/2014    KBR             24. 0025860: (POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 81 - Monitorizacion tasas variables/comisiones
  25.0        14/05/2014    AGG             23.0026622: POSND100-(POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 97 - Comisiones calculadas solo sobre extraprima
  26.0        18/07/2014    KBR             26. 0030203: LCOL_A004-Qtracker: 8993, 8995, 9865, 8987, 8991 Liquidaci?n de saldos
  27.0        22/09/2014    MMM             27. 0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales
  28.0        19/11/2015    DCT             28. 0038692   0038692: POSPT500-POS REASEGUROS CESI¿N DE VIDA INDIVIDUAL Y COMISIONES SOBRE EXTRA PRIMAS
  29.0        02/09/2016    HRE             27. CONF-250: Se incluye manejo de contratos Q1, Q2, Q3
  30.0        15/07/2019    FEPP            30 IAXIS-4611:Campo para grabar la prioridad por tramo y el limite por tramo. 
  31.0        26/01/2020    INFORCOL        31 Reaseguro facultativo - ajuste para deposito en prima retenida
  32.0        26/05/2020    DFRP            32.IAXIS-5361: Modificar el facultativo antes de la emisión
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800)   -- 23830/0150483 AVT 06/08/2013  VARCHAR2(200)
         := 'parametros - pscontra:' || pscontra || ' - pcempres:' || pcempres || ' - pcramo:'
            || pcramo || ' - pcmodali:' || pcmodali || ' - pctipseg:' || pctipseg
            || ' - pccolect:' || pccolect || ' - pcactivi:' || pcactivi || ' - pcgarant:'
            || pcgarant || ' - pctiprea:' || pctiprea || ' - psconagr:' || psconagr
            || ' - pccompani:' || pccompani;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_Contratos_Rea';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_contratos_rea(pscontra, pcempres, pcramo, pcmodali,
                                                pctipseg, pccolect, pcactivi, pcgarant,
                                                pctiprea, psconagr, pccompani, NULL, mensajes);
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
   FUNCTION f_get_contratos_rea_prod(
      pscontra IN NUMBER,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pctiprea IN NUMBER,
      psconagr IN NUMBER,
      pccompani IN NUMBER,
      pcdevento IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800)   -- 23830/0150483 AVT 06/08/2013  VARCHAR2(200)
         := 'parametros - pscontra:' || pscontra || ' - pcempres:' || pcempres
            || ' - psproduc:' || psproduc || ' - pcactivi:' || pcactivi || ' - pcgarant:'
            || pcgarant || ' - pctiprea:' || pctiprea || ' - psconagr:' || psconagr
            || ' - pccompani:' || pccompani;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_Contratos_Rea_Prod';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_contratos_rea(pscontra, pcempres, psproduc, pcactivi,
                                                pcgarant, pctiprea, psconagr, pccompani,
                                                pcdevento, mensajes);
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
   END f_get_contratos_rea_prod;

---------------------------------------------------------------------------------------------------------------------------------
   FUNCTION f_get_version_rea(pscontra IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'parametros - pscontra:' || pscontra;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_Version_Rea';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_version_rea(pscontra, mensajes);
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
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_codicontrato_rea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                          := 'parametros - pscontra:' || pscontra || ' pnversio: ' || pnversio;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_DetalleCab_Rea';
   BEGIN
      RETURN pac_md_rea.f_get_detallecab_rea(pscontra, pnversio, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_detallecab_rea;

---------------------------------------------------------------------------------------------------------------------------------
   FUNCTION f_get_contratosvers_rea(pscontra IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_contrato_rea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'parametros - pscontra:' || pscontra;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_ContratosVers_Rea';
   BEGIN
      RETURN pac_md_rea.f_get_contratos_rea(pscontra, NULL, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_contratosvers_rea;

---------------------------------------------------------------------------------------------------------------------------------
   FUNCTION f_get_detalle_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_contrato_rea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                         := 'parametros - pscontra:' || pscontra || ' - pnversio:' || pnversio;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_Detalle_Rea';
   BEGIN
      RETURN pac_md_rea.f_get_detalle_rea(pscontra, pnversio, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_detalle_rea;

---------------------------------------------------------------------------------------------------------------------------------
   FUNCTION f_get_tramos_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_tramos_rea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                         := 'parametros - pscontra:' || pscontra || ' - pnversio:' || pnversio;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_Tramos_Rea';
   BEGIN
      RETURN pac_md_rea.f_get_tramos_rea(pscontra, pnversio, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_tramos_rea;

---------------------------------------------------------------------------------------------------------------------------------
   FUNCTION f_get_dettramo_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_tramos_rea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parametros - pscontra:' || pscontra || ' - pnversio:' || pnversio
            || ' - pctramo:' || pctramo;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_DetTramo_Rea';
   BEGIN
      RETURN pac_md_rea.f_get_dettramo_rea(pscontra, pnversio, pctramo, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_dettramo_rea;

---------------------------------------------------------------------------------------------------------------------------------
   FUNCTION f_get_cuadroces_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_cuadroces_rea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parametros - pscontra:' || pscontra || ' - pnversio:' || pnversio
            || ' - pctramo:' || pctramo;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_Cuadroces_Rea';
   BEGIN
      RETURN pac_md_rea.f_get_cuadroces_rea(pscontra, pnversio, pctramo, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cuadroces_rea;

---------------------------------------------------------------------------------------------------------------------------------
   FUNCTION f_get_detcuadro_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pccompani IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_cuadroces_rea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parametros - pscontra:' || pscontra || ' - pnversio:' || pnversio
            || ' - pctramo:' || pctramo || ' - pccompani:' || pccompani;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_DetCuadro_Rea';
   BEGIN
      RETURN pac_md_rea.f_get_detcuadro_rea(pscontra, pnversio, pctramo, pccompani, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_detcuadro_rea;

    /*************************************************************************
      Selecciona informacion sobre la cesiones
      param in pnpoliza   : numero de poliza
      param in pncertif  : numero de certificado
      param in pnsinies  : numero de sinietro
      param in pnrecibo : numero de recibo
      param in pfefeini : fecha inicio efecto(Inicio rango)
      param in pfefefin : fecha fin efecto(Fin rango)
      param out mensajes : mensajes de error

     BUG 10471 - 17/06/2009 - ETM - IAX : REA- Desarrollo PL de la consulta de cesiones
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
      vparam         VARCHAR2(800)   -- 23830/0150483 AVT 06/08/2013  VARCHAR2(200)
         := 'parametros - pnpoliza:' || pnpoliza || ' - pncertif:' || pncertif
            || ' - pnsinies:' || pnsinies || ' - pnrecibo:' || pnrecibo || ' - pfefeini:'
            || pfefeini || ' - pfefefin:' || pfefefin || ' - pnreemb:' || pnreemb
            || ' - pscumulo:' || pscumulo;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_Consulta_Cesiones';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_consulta_cesiones(pnpoliza, pncertif, pnsinies, pnrecibo,
                                                    pfefeini, pfefefin, pnreemb, pscumulo,
                                                    mensajes);
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
      Selecciona informacion sobre la cesiones de la poliza seleccionada
      param in psseguro   :  numero de seguro
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_consulta_det_cesiones(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200) := 'parametros- psseguro:' || psseguro;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_consulta_det_cesiones';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_consulta_det_cesiones(psseguro, mensajes);
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
      Recupera informacion de cabecera de la cesiones por recibo para uno en concreto o para un movimiento de cesion anulizada
      param in pnmovimi  : numero de movimiento
      param in pnrecibo : numero de recibo
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_recibos_ces(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200)
                          := 'parametros- psseguro:' || psseguro || ' - pnmovimi:' || pnmovimi;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_Recibos_Ces';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_recibos_ces(psseguro, pnmovimi, mensajes);
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
      Recupera informacion en detalle de la cesiones por recibo
      param in psreaemi  : numero de psreaemi
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_datosrecibo_ces(psreaemi IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200) := 'parametros - psreaemi:' || psreaemi;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_Datosrecibo_Ces';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_datosrecibo_ces(psreaemi, mensajes);
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

/*FIN BUG 10471 - 17/06/2009 - ETM */

   /*BUG 10487 - 18/06/2009 - ETM - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
   /*************************************************************************
        Selecciona las cabeceras de cuadros facultativos
        param in ptempres   : Codigo y descripcion de la empresa
        param in ptramo  : Codigo y descripcion del ramo
        param in ptsproduc  : Descripcion del producto
        param in pnpoliza  : numero de poliza
        param in pncertif  : Certificado
        param in psfacult  :  Codigo cuadro facultativo
        param in tcestado : Codigo y descripcion del estado del cuadro
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
      pnsolici IN NUMBER,   -- 22374 AVT 22/08/2012
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parametros- ptempres:' || ptempres || ' - ptramo:' || ptramo || ' - ptsproduc:'
            || ptsproduc || ' - pnpoliza:' || pnpoliza || ' - pncertif:' || pncertif
            || ' - psfacult:' || psfacult || ' - tcestado:' || tcestado || ' - pfefeini:'
            || pfefeini || ' - pfefefin:' || pfefefin || ' - pscumulo:' || pscumulo
            || ' - pnsolici:' || pnsolici;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_cuafacul_rea';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_cuafacul_rea(ptempres, ptramo, ptsproduc, pnpoliza,
                                               pncertif, psfacult, tcestado, pfefeini,
                                               pfefefin, pscumulo, pnsolici, mensajes);
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
      Recupera la informacion en detalle para un cuadro
      param in psfacult   : Codigo de cuadro facultativo
      param in psseguro  : Codigo del Seguro
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_cuafacul_det_rea(
      psfacult IN NUMBER,
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_cuafacul IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800) := 'parametros- psfacult:' || psfacult;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_cuafacul_det_rea';
   BEGIN
      RETURN pac_md_rea.f_get_cuafacul_det_rea(psfacult, psseguro, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cuafacul_det_rea;

/*************************************************************************
      Recupera la informacion en detalle del cuadro de compa?ias que se reparten el riesgo
      param in psfacult   : Codigo de cuadro facultativo
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_cuacesfac_rea(psfacult IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800) := 'parametros- psfacult:' || psfacult;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_cuacesfac_rea';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_cuacesfac_rea(psfacult, mensajes);
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
      param in psfacult   : Codigo de cuadro facultativo
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
                        := 'parametros- psfacult:' || psfacult || ' - pccompani:' || pccompani;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_cuacesfac_det_rea';
   BEGIN
      RETURN pac_md_rea.f_get_cuacesfac_det_rea(psfacult, pccompani, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cuacesfac_det_rea;

       /*************************************************************************
           funcion que se encargara de guardar la informacion del detalle del cuadro de facultativo introducido.
           PSFACULT in NUMBER
           PCESTADO in NUMBER
           PFINCUF in DATE
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
           param out mensajes : mensajes de error
   cuacesfac
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
      pccorred IN NUMBER,   -- 20/08/2012 AVT 22374 CUACESFAC
      pcfreres IN NUMBER,
      pcresrea IN NUMBER,
      pcconrec IN NUMBER,
      pfgarpri IN DATE,
      pfgardep IN DATE,
      ppimpint IN NUMBER,   -- 17-01-2013 AEG 25502
      ptidfcom IN VARCHAR2,
      psseguro IN NUMBER,   --BUG38692 19/11/2015 DCT
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parametros- psfacult :' || psfacult || ' pcestado : ' || pcestado
            || ' pfincuf : ' || pfincuf || ' pplocal :' || pplocal || ' pccompani : '
            || pccompani || ' ppcesion : ' || ppcesion || ' picesfij : ' || picesfij
            || ' pccomrea : ' || pccomrea || ' ppcomisi : ' || ppcomisi || ' picomfij : '
            || picomfij || ' pisconta : ' || pisconta || ' ppreserv : ' || ppreserv
            || ' pcintres : ' || pcintres || ' pintres : ' || pintres|| ' pifacced : ' || pifacced; -- IAXIS-5361 26/05/2020
      vobject        VARCHAR2(50) := 'pac_iax_rea.F_SET_CUADRO_FAC';
      vnumerr        NUMBER := 0;
   BEGIN
      IF (pplocal <> 100
          AND pccompani IS NULL) THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_rea.f_set_cuadro_fac(psfacult, pcestado, pfincuf, pplocal, pifacced, pccompani, -- IAXIS-5361 26/05/2020
                                             ppcesion, picesfij, pccomrea, ppcomisi, picomfij,
                                             -- INICIO INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
                                             pisconta, ppreserv, ppresrea, pcintres, pintres, pctipfac,
                                             -- FIN INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
                                             pptasaxl, pccorred, pcfreres, pcresrea, pcconrec,
                                             pfgarpri, pfgardep, ppimpint, ptidfcom, psseguro,
                                             mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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
   END f_set_cuadro_fac;

/*FIN BUG 10487 - 18/06/2009 - ETM */

   /*BUG 10487 - 02/09/2009 - ICV - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
   /*************************************************************************
          funcion que se encargara de borrar un registro de compa?ia participante en el cuadro.
          PSFACULT in NUMBER
          PCESTADO in NUMBER
          PCCOMPANI in NUMBER
          param out mensajes : mensajes de error

     *************************************************************************/
   FUNCTION f_anula_cia_fac(
      psfacult IN NUMBER,
      pcestado IN NUMBER,
      pccompani IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parametros- psfacult: ' || psfacult || ' pcestado : ' || pcestado
            || ' pccompani : ' || pccompani;
      vobject        VARCHAR2(50) := 'pac_iax_rea.F_ANULA_CIA_FAC';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_rea.f_anula_cia_fac(psfacult, pcestado, pccompani, mensajes);
      vpasexec := 2;

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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

/*FIN BUG 10487 : 02/09/2009 : ICV */

   /*BUG 10990 - 07/09/2009 - 0010990: IAX - REA: Desarrollo PL del mantenimiento de contratos*/
   /*************************************************************************
         funcion que inserta o actualiza informacion en cuadroces.
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
           CTIPCOMIS in number,              Tipo Comision
           PCTCOMIS in number,            % Comision fija / provisional
           CTRAMOCOMISION in number,            Tramo comision variable
           -- fin Bug 18319 - APD - 05/07/2011
         mensajes OUT t_iax_mensajes
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
      pctipcomis IN NUMBER,   -- Tipo Comision
      ppctcomis IN NUMBER,   -- % Comision fija / provisional
      pctramocomision IN NUMBER,   --Tramo comision variable
      pctgastosrea    IN NUMBER,   --% Gastos Reasegurador (CONF-587)
      -- Fin Bug 18319 - APD - 05/07/2011
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parametros- pccompani: ' || pccompani || ' pnversio : ' || pnversio
            || ' pscontra : ' || pscontra || ' pctramo : ' || pctramo;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_set_cuadroces';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Bug 18319 - APD - 05/07/2011 - se a?aden los campos pctipcomis,
      -- ppctcomis, pctramocomision
      vnumerr := pac_md_rea.f_set_cuadroces(pccompani, pnversio, pscontra, pctramo, pccomrea,
                                            ppcesion, pnplenos, picesfij, picomfij, pisconta,
                                            ppreserv, ppintres, piliacde, pppagosl, pccorred,
                                            pcintres, pcintref, pcresref, pireserv, pptasaj,
                                            pfutliq, piagrega, pimaxagr, pctipcomis,
                                            ppctcomis, pctramocomision, pctgastosrea, mensajes);

      -- fin Bug 18319 - APD - 05/07/2011
      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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
         funcion que inserta o actualiza informacion en tramos.
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
      pilaa IN NUMBER,   -- Limite agregado anual
      pctprimaxl IN NUMBER,   -- Tipo Prima XL
      piprimafijaxl IN NUMBER,   -- Prima fija XL
      piprimaestimada IN NUMBER,   -- Prima Estimada para el tramo
      pcaplictasaxl IN NUMBER,   -- Campo aplicacion tasa XL
      pctiptasaxl IN NUMBER,   -- Tipo tasa XL
      pctramotasaxl IN NUMBER,   -- Tramo de tasa variable XL
      ppctpdxl IN NUMBER,   -- % Prima Deposito
      pcforpagpdxl IN NUMBER,   -- Forma pago prima de deposito XL
      ppctminxl IN NUMBER,   -- % Prima Minima XL
      ppctpb IN NUMBER,   -- % PB
      pnanyosloss IN NUMBER,   -- A?os Loss Corridor
      pclosscorridor IN NUMBER,   -- Codigo clausula Loss Corridor
      pcappedratio IN NUMBER,   -- Codigo clausula Capped Ratio
      pcrepos IN NUMBER,   -- Codigo Reposicion Xl
      pibonorec IN NUMBER,   -- Bono Reclamacion
      pimpaviso IN NUMBER,   -- Importe Avisos Siniestro
      pimpcontado IN NUMBER,   -- Importe pagos contado
      ppctcontado IN NUMBER,   -- % Pagos Contado
      ppctdep IN NUMBER,   -- % Deposito de primas
      pcforpagdep IN NUMBER,   -- Periodo devolucion de. primas
      pintdep IN NUMBER,   -- Intereses sobre deposito de primas
      ppctgastos IN NUMBER,   -- Gastos
      pptasaajuste IN NUMBER,   -- Tasa ajuste
      picapcoaseg IN NUMBER,   -- Capacidad segun coaseguro
      -- Fin Bug 18319 - APD - 04/04/2011
        mensajes OUT t_iax_mensajes
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
      pilaa IN NUMBER,   -- Limite agregado anual
      pctprimaxl IN NUMBER,   -- Tipo Prima XL
      piprimafijaxl IN NUMBER,   -- Prima fija XL
      piprimaestimada IN NUMBER,   -- Prima Estimada para el tramo
      pcaplictasaxl IN NUMBER,   -- Campo aplicacion tasa XL
      pctiptasaxl IN NUMBER,   -- Tipo tasa XL
      pctramotasaxl IN NUMBER,   -- Tramo de tasa variable XL
      ppctpdxl IN NUMBER,   -- % Prima Deposito
      pcforpagpdxl IN NUMBER,   -- Forma pago prima de deposito XL
      ppctminxl IN NUMBER,   -- % Prima Minima XL
      ppctpb IN NUMBER,   -- % PB
      pnanyosloss IN NUMBER,   -- A?os Loss Corridor
      pclosscorridor IN NUMBER,   -- Codigo clausula Loss Corridor
      pccappedratio IN NUMBER,   -- Codigo clausula Capped Ratio
      pcrepos IN NUMBER,   -- Codigo Reposicion Xl
      pibonorec IN NUMBER,   -- Bono Reclamacion
      pimpaviso IN NUMBER,   -- Importe Avisos Siniestro
      pimpcontado IN NUMBER,   -- Importe pagos contado
      ppctcontado IN NUMBER,   -- % Pagos Contado
      ppctgastos IN NUMBER,   -- Gastos
      pptasaajuste IN NUMBER,   -- Tasa ajuste
      picapcoaseg IN NUMBER,   -- Capacidad segun coaseguro
      picostofijo IN NUMBER,   --Costo Fijo de la capa
      ppcomisinterm IN NUMBER,   --% de comisi??e intermediaci??      -- Fin Bug 18319 - APD - 04/04/2011
      pptramo      IN NUMBER,--BUG CONF-250  Fecha (02/09/2016) - HRE - se adiciona pptramo
      ppreest      IN NUMBER,--BUG CONF-1048  Fecha (29/08/2017) - HRE - se adiciona ppreest
      ppiprio IN NUMBER,--Agregar campo prioridad tramo IAXIS-4611
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parametros- pnversio : ' || pnversio || ' pscontra : ' || pscontra
            || ' pctramo : ' || pctramo;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_set_tramos';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Bug 18319 - APD - 04/07/2011 - se a?aden los campos pidaa, pilaa, pctprimaxl,
      -- piprimafijaxl, piprimaestimada, pcaplictasaxl, pctiptasaxl, pctramotasaxl, ppctpdxl, pcforpagpdxl,
      -- ppctminxl, ppctpb, pnanyosloss, pclosscorridor, pcappedratio, pcrepos, pibonorec, pimpaviso,
      -- pimpcontado, ppctcontado, ppctdep, pcforpagdep, pintdep, ppctgastos, pptasaajuste, picapcoaseg
      --
      p_tab_error(f_sysdate, f_user, 'f_set_tramos', 66, 'entra', NULL);
      vnumerr := pac_md_rea.f_set_tramos(pnversio, pscontra, pctramo, pitottra, pnplenos,
                                         pcfrebor, pplocal, pixlprio, pixlexce, ppslprio,
                                         ppslexce, pncesion, pfultbor, pimaxplo, pnorden,
                                         pnsegcon, pnsegver, piminxl, pidepxl, pnctrxl,
                                         pnverxl, pptasaxl, pipmd, pcfrepmd, pcaplixl,
                                         pplimgas, ppliminx, pidaa, pilaa, pctprimaxl,
                                         piprimafijaxl, piprimaestimada, pcaplictasaxl,
                                         pctiptasaxl, pctramotasaxl, ppctpdxl, pcforpagpdxl,
                                         ppctminxl, ppctpb, pnanyosloss, pclosscorridor,
                                         pccappedratio, pcrepos, pibonorec, pimpaviso,
                                         pimpcontado, ppctcontado, ppctgastos, pptasaajuste,
                                         picapcoaseg, picostofijo, ppcomisinterm, pptramo, ppreest,ppiprio,mensajes);--BUG CONF-250  Fecha (02/09/2016) - HRE - se adiciona pptramo

      -- fin Bug 18319 - APD - 04/07/2011
      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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
       funcion que inserta o actualiza informacion en contratos.
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
      pclavecbr NUMBER,   -- Formula para el CBR
      pcercartera NUMBER,   -- Tipo E/R cartera
      piprimaesperadas NUMBER,   -- Primas esperadas totales para la version
      pnanyosloss NUMBER,   -- A?os Loss-Corridos
      pcbasexl NUMBER,   -- Base para el calculo XL
      pclosscorridor NUMBER,   -- Codigo clausula Loss Corridor
      pccappedratio NUMBER,   -- Codigo clausula Capped Ratio
      pscontraprot NUMBER,   -- Contrato XL proteccion
      pcestado NUMBER,   --Estado de la version
      -- Fin Bug 18319 - APD - 04/07/2011
       mensajes OUT t_iax_mensajes
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
      pclavecbr NUMBER,   -- Formula para el CBR
      pcercartera NUMBER,   -- Tipo E/R cartera
      piprimaesperadas NUMBER,   -- Primas esperadas totales para la version
      pnanyosloss NUMBER,   -- A?os Loss-Corridos
      pcbasexl NUMBER,   -- Base para el calculo XL
      pclosscorridor NUMBER,   -- Codigo clausula Loss Corridor
      pccappedratio NUMBER,   -- Codigo clausula Capped Ratio
      pscontraprot NUMBER,   -- Contrato XL proteccion
      pcestado NUMBER,   --Estado de la version
      pnversioprot NUMBER,   -- Version del Contrato XL proteccion
      -- Fin Bug 18319 - APD - 04/07/2011
      pncomext NUMBER,   --% Comisi??xtra prima (solo para POSITIVA)
      pnretpol NUMBER, -- EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por poliza NRETPOL
      pnretcul NUMBER, -- EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por Cumulo NRETCUL
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parametros- pnversio : ' || pnversio || ' pscontra : ' || pscontra
            || ' pnversio : ' || pnversio;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_contratos';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Bug 18319 - APD - 04/07/2011 - se a?aden los campos pclavecbr,
      -- pcercartera, piprimaesperadas, pnanyosloss, pcbasexl, pclosscorridor, pccappedratio,
      -- pscontraprot, pcestado
      vnumerr := pac_md_rea.f_set_contratos(pscontra, pnversio, pnpriori, pfconini, pnconrel,
                                            pfconfin, piautori, piretenc, piminces, picapaci,
                                            piprioxl, pppriosl, ptcontra, ptobserv, ppcedido,
                                            ppriesgos, ppdescuento, ppgastos, pppartbene,
                                            pcreafac, ppcesext, pcgarrel, pcfrecul, psconqp,
                                            pnverqp, piagrega, pimaxagr, pclavecbr,
                                            pcercartera, piprimaesperadas, pnanyosloss,
                                            pcbasexl, pclosscorridor, pccappedratio,
                                            pscontraprot, pcestado, pnversioprot, pncomext,
                                            pnretpol, pnretcul,
                                            mensajes);-- EDBR - 11/06/2019 - IAXIS3338 - se agregan parametros de Retencion por poliza NRETPOL y Retencion por Cumulo NRETCUL
      -- Fin Bug 18319 - APD - 04/07/2011
      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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
       funcion que inserta o actualiza informacion en codicontratos.
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
       mensajes OUT t_iax_mensajes
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
      pcdevento IN VARCHAR,
      pnversio IN NUMBER,   -- INI - AXIS 4853 - 26/07/2019 - AABG - SE AGREGA ATRIBUTO PNVERSIO PARA AGR_CONTRATOS
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800) := 'parametros- pscontra : ' || pscontra;
      vobject        VARCHAR2(50) := 'pac_md_rea.f_set_codicontratos';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Bug 18319 - APD - 04/07/2011 - se a?aden los parametros pcmoneda y ptdescripcion
      vnumerr := pac_md_rea.f_set_codicontratos(pscontra, pspleno, pcempres, pctiprea,
                                                pfinictr, pcramo, pcactivi, pcmodali,
                                                pccolect, pctipseg, pcgarant, pffinctr,
                                                pnconrel, psconagr, pcvidaga, pcvidair,
                                                pctipcum, pcvalid, pcmoneda, ptdescripcion,
                                                pcdevento, pnversio, mensajes);
    -- FIN - AXIS 4853 - 26/07/2019 - AABG - SE AGREGA ATRIBUTO PNVERSIO PARA AGR_CONTRATOS                                                

      -- Fin Bug 18319 - APD - 04/07/2011
      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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
      Funcio per consultar els riscs que formen part d'un cumul quan el SCUMULO del quadre estigui informat
      pscumulo in number
      mensajes out t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_reariesgos(pscumulo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'parametros - PSCUMULO:' || pscumulo;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_REARIESGOS';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_reariesgos(pscumulo, mensajes);
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

   /*BUG 11353 - 30/10/2009 - ICV - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
     /*************************************************************************
      funcion graba en una variable global de la capa IAX los valores del objeto
      tramos_rea

     *************************************************************************/
   FUNCTION f_set_objetotramosrea(
      pnversio NUMBER,   -- Numero version contrato reas.
      pscontra NUMBER,   -- Secuencia del contrato
      pctramo NUMBER,   -- Codigo tramo
      pitottra NUMBER,   -- Importe total tramo
      pnplenos NUMBER,   -- Numero de plenos
      pcfrebor NUMBER,   -- Codigo frecuencia bordero
      pplocal NUMBER,   -- Porcentaje retencion local
      pixlprio NUMBER,   -- Importe prioridad XL
      pixlexce NUMBER,   -- Importe excedente XL
      ppslprio NUMBER,   -- Porcentaje prioridad SL
      ppslexce NUMBER,   -- Porcentaje excedente SL
      pncesion NUMBER,   -- Numero cesion
      pfultbor DATE,   -- Fecha ultimo bordero (cierre mensual)
      pimaxplo NUMBER,   -- Importe maximo retencion propia
      pnorden NUMBER,   -- orden de aplicacion de los tramos
      pnsegcon NUMBER,   -- Segundo contrato de proteccion
      piminxl NUMBER,   -- Prima minima para contratos XL
      pidepxl NUMBER,   -- Prima de deposito para contratos XL
      pnsegver NUMBER,   -- Version del segundo contrato de proteccion.
      pptasaxl NUMBER,   -- Porcentaje de l tasa aplicable para contratos XL
      pnctrxl NUMBER,   -- Contrato XL de preoteccion
      pnverxl NUMBER,   -- Version CTR. XL de proteccion
      pipmd NUMBER,   -- Importe Prima Minima Deposito XL
      pcfrepmd NUMBER,   -- Codigo frecuencia pago PMD
      pcaplixl NUMBER,   -- Aplica o no el limite por contrato del XL (0-Si, 1-No)
      pplimgas NUMBER,   -- Porcentaje de aumento del limite XL por gastos
      ppliminx NUMBER,   -- Porcentaje limite de aplicacion de la indexacion
      -- Bug 18319 - APD - 04/07/2011
      pidaa NUMBER,   -- Deducible anual
      pilaa NUMBER,   -- Limite agregado anual
      pctprimaxl NUMBER,   -- Tipo Prima XL
      piprimafijaxl NUMBER,   -- Prima fija XL
      piprimaestimada NUMBER,   -- Prima Estimada para el tramo
      pcaplictasaxl NUMBER,   -- Campo aplicacion tasa XL
      pctiptasaxl NUMBER,   -- Tipo tasa XL
      pctramotasaxl NUMBER,   -- Tramo de tasa variable XL
      ppctpdxl NUMBER,   -- % Prima Deposito
      pcforpagpdxl NUMBER,   -- Forma pago prima de deposito XL
      ppctminxl NUMBER,   -- % Prima Minima XL
      ppctpb NUMBER,   -- % PB
      pnanyosloss NUMBER,   -- A?os Loss Corridor
      pclosscorridor NUMBER,   -- Codigo clausula Loss Corridor
      pccappedratio NUMBER,   -- Codigo clausula Capped Ratio
      pcrepos NUMBER,   -- Codigo Reposicion Xl
      pibonorec NUMBER,   -- Bono Reclamacion
      pimpaviso NUMBER,   -- Importe Avisos Siniestro
      pimpcontado NUMBER,   -- Importe pagos contado
      ppctcontado NUMBER,   -- % Pagos Contado
      ppctgastos NUMBER,   -- Gastos
      pptasaajuste NUMBER,   -- Tasa ajuste
      picapcoaseg NUMBER,   -- Capacidad segun coaseguro
      picostofijo IN NUMBER,   --Costo Fijo de la capa
      ppcomisinterm IN NUMBER,   --% de comisi??e intermediaci??      -- fin Bug 18319 - APD - 04/07/2011
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
               := 'pNVERSIO=' || pnversio || ' pSCONTRA=' || pscontra || 'pCTRAMO=' || pctramo;
      vobject        VARCHAR2(200) := 'PAC_IAX_REA.f_set_objetotramosrea';
      v_index        NUMBER(2);
      i              NUMBER := 0;
      vnorden        NUMBER;
      v_vacio        NUMBER := 0;
      v_trobat       NUMBER := 0;
   BEGIN
      --p_tab_error(f_sysdate, f_user, 'PAC_AXIS_REA', 1, 'Entro', SQLERRM);

      --Comprovacio de parametres
      IF pnversio IS NULL
         OR pctramo IS NULL
         OR pcfrebor IS NULL
         OR pnorden IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      /*IF pnorden IS NULL THEN
         vnorden := v_tobtramos.COUNT + 1;
      END IF;*/
      --p_tab_error(f_sysdate, f_user, 'PAC_AXIS_REA', 1, 'vnorden :' || vnorden, SQLERRM);

      /*IF V_TOBTRAMOS IS NULL THEN
        p_tab_error (f_sysdate,f_USER,'PAC_AXIS_REA', 1,  'v_tobrtramos NULO :',sqlerrm);
      END IF;

      IF V_TOBTRAMOS IS not NULL THEN
          FOR i IN v_tobtramos.FIRST .. v_tobtramos.LAST LOOP
            p_tab_error (f_sysdate,f_USER,'PAC_AXIS_REA', 1,  'v_tobtramos(i).ctramo :'||v_tobtramos(i).ctramo,sqlerrm);
        END LOOP;
      END IF;*/
      IF v_tobtramos IS NULL THEN
         v_vacio := 1;
      ELSE   -- v_tobtramos IS NOT NULL THEN
         IF v_tobtramos.COUNT = 0 THEN
            v_vacio := 1;
         END IF;
      END IF;

      IF v_vacio = 0 THEN   --Si no esta vacio buscamos para modificarlo
         -- p_tab_error(f_sysdate, f_user, 'PAC_AXIS_REA', 1, 'v_tobtramos is not null', SQLERRM);
         FOR i IN v_tobtramos.FIRST .. v_tobtramos.LAST LOOP
            IF v_tobtramos(i).nversio = pnversio
               AND v_tobtramos(i).ctramo = pctramo
               AND NVL(v_tobtramos(i).scontra, -1) = NVL(pscontra, -1) THEN   -- Si el trobem, el modifiquem
               --p_tab_error(f_sysdate, f_user, 'PAC_AXIS_REA', 1, 'entro en el if', SQLERRM);
               v_tobtramos(i).ctramo := pctramo;
               v_tobtramos(i).ttramo := ff_desvalorfijo(105, pac_md_common.f_get_cxtidioma,
                                                        pctramo);
               v_tobtramos(i).itottra := pitottra;
               v_tobtramos(i).nplenos := pnplenos;
               v_tobtramos(i).cfrebor := pcfrebor;
               v_tobtramos(i).tfrebor := ff_desvalorfijo(113, pac_md_common.f_get_cxtidioma,
                                                         pcfrebor);
               v_tobtramos(i).plocal := pplocal;
               v_tobtramos(i).ixlprio := pixlprio;
               v_tobtramos(i).ixlexce := pixlexce;
               v_tobtramos(i).pslprio := ppslprio;
               v_tobtramos(i).pslexce := ppslexce;
               v_tobtramos(i).ncesion := pncesion;
               v_tobtramos(i).fultbor := pfultbor;
               v_tobtramos(i).imaxplo := pimaxplo;
               v_tobtramos(i).norden := pnorden;
               v_tobtramos(i).nsegcon := pnsegcon;
               v_tobtramos(i).iminxl := piminxl;
               v_tobtramos(i).idepxl := pidepxl;
               v_tobtramos(i).nsegver := pnsegver;
               v_tobtramos(i).ptasaxl := pptasaxl;
               v_tobtramos(i).nctrxl := pnctrxl;
               v_tobtramos(i).nverxl := pnverxl;
               v_tobtramos(i).ipmd := pipmd;
               v_tobtramos(i).cfrepmd := pcfrepmd;
               v_tobtramos(i).tfrepmd := ff_desvalorfijo(17, pac_md_common.f_get_cxtidioma,
                                                         pcfrepmd);
               v_tobtramos(i).caplixl := pcaplixl;
               v_tobtramos(i).pliminx := ppliminx;
               v_tobtramos(i).plimgas := pplimgas;
               -- Bug 18319 - APD - 04/07/2011
               v_tobtramos(i).idaa := pidaa;
               v_tobtramos(i).ilaa := pilaa;
               v_tobtramos(i).ctprimaxl := pctprimaxl;
               v_tobtramos(i).iprimafijaxl := piprimafijaxl;
               v_tobtramos(i).iprimaestimada := piprimaestimada;
               v_tobtramos(i).caplictasaxl := pcaplictasaxl;
               v_tobtramos(i).ctiptasaxl := pctiptasaxl;
               v_tobtramos(i).ctramotasaxl := pctramotasaxl;
               v_tobtramos(i).pctpdxl := ppctpdxl;
               v_tobtramos(i).cforpagpdxl := pcforpagpdxl;
               v_tobtramos(i).pctminxl := ppctminxl;
               v_tobtramos(i).pctpb := ppctpb;
               v_tobtramos(i).nanyosloss := pnanyosloss;
               v_tobtramos(i).closscorridor := pclosscorridor;
               v_tobtramos(i).ccappedratio := pccappedratio;
               v_tobtramos(i).crepos := pcrepos;
               v_tobtramos(i).ibonorec := pibonorec;
               v_tobtramos(i).impaviso := pimpaviso;
               v_tobtramos(i).impcontado := pimpcontado;
               v_tobtramos(i).pctcontado := ppctcontado;
               v_tobtramos(i).pctgastos := ppctgastos;
               v_tobtramos(i).ptasaajuste := pptasaajuste;
               v_tobtramos(i).icapcoaseg := picapcoaseg;
               v_tobtramos(i).icostofijo := picostofijo;
               v_tobtramos(i).pcomisinterm := ppcomisinterm;
               -- fin Bug 18319 - APD - 04/07/2011

               /*p_tab_error(f_sysdate, f_user, 'PAC_AXIS_REA', 1,
                           'entro todos los campos del if', SQLERRM);*/
               v_trobat := 1;   --Si lo encontramos no lo damos de alta de nuevo.
            END IF;
         END LOOP;
      END IF;

      IF v_vacio = 1
         OR v_trobat = 0 THEN   --Si esta vacio o no lo hemos encontrado lo creamos.
         --p_tab_error(f_sysdate, f_user, 'PAC_AXIS_REA', 1, 'ENTRO ELSE :', SQLERRM);
         IF v_tobtramos IS NULL THEN
            v_tobtramos := t_iax_tramos_rea();
         END IF;

         vpasexec := 3;
         v_tobtramos.EXTEND;
         v_index := v_tobtramos.LAST;
         v_tobtramos(v_index) := ob_iax_tramos_rea();
         v_tobtramos(v_index).nversio := pnversio;
         v_tobtramos(v_index).scontra := pscontra;
         v_tobtramos(v_index).ctramo := pctramo;
         v_tobtramos(v_index).ttramo := ff_desvalorfijo(105, pac_md_common.f_get_cxtidioma,
                                                        pctramo);
         v_tobtramos(v_index).itottra := pitottra;
         v_tobtramos(v_index).nplenos := pnplenos;
         v_tobtramos(v_index).cfrebor := pcfrebor;
         v_tobtramos(v_index).tfrebor := ff_desvalorfijo(113, pac_md_common.f_get_cxtidioma,
                                                         pcfrebor);
         v_tobtramos(v_index).plocal := pplocal;
         v_tobtramos(v_index).ixlprio := pixlprio;
         v_tobtramos(v_index).ixlexce := pixlexce;
         v_tobtramos(v_index).pslprio := ppslprio;
         v_tobtramos(v_index).pslexce := ppslexce;
         v_tobtramos(v_index).ncesion := pncesion;
         v_tobtramos(v_index).fultbor := pfultbor;
         v_tobtramos(v_index).imaxplo := pimaxplo;
         v_tobtramos(v_index).norden := pnorden;
         v_tobtramos(v_index).nsegcon := pnsegcon;
         v_tobtramos(v_index).iminxl := piminxl;
         v_tobtramos(v_index).idepxl := pidepxl;
         v_tobtramos(v_index).nsegver := pnsegver;
         v_tobtramos(v_index).ptasaxl := pptasaxl;
         v_tobtramos(v_index).nctrxl := pnctrxl;
         v_tobtramos(v_index).nverxl := pnverxl;
         v_tobtramos(v_index).ipmd := pipmd;
         v_tobtramos(v_index).cfrepmd := pcfrepmd;
         v_tobtramos(v_index).tfrepmd := ff_desvalorfijo(17, pac_md_common.f_get_cxtidioma,
                                                         pcfrepmd);
         v_tobtramos(v_index).caplixl := pcaplixl;
         v_tobtramos(v_index).pliminx := ppliminx;
         v_tobtramos(v_index).plimgas := pplimgas;
         -- Bug 18319 - APD - 04/07/2011
         v_tobtramos(v_index).idaa := pidaa;
         v_tobtramos(v_index).ilaa := pilaa;
         v_tobtramos(v_index).ctprimaxl := pctprimaxl;
         v_tobtramos(v_index).iprimafijaxl := piprimafijaxl;
         v_tobtramos(v_index).iprimaestimada := piprimaestimada;
         v_tobtramos(v_index).caplictasaxl := pcaplictasaxl;
         v_tobtramos(v_index).ctiptasaxl := pctiptasaxl;
         v_tobtramos(v_index).ctramotasaxl := pctramotasaxl;
         v_tobtramos(v_index).pctpdxl := ppctpdxl;
         v_tobtramos(v_index).cforpagpdxl := pcforpagpdxl;
         v_tobtramos(v_index).pctminxl := ppctminxl;
         v_tobtramos(v_index).pctpb := ppctpb;
         v_tobtramos(v_index).nanyosloss := pnanyosloss;
         v_tobtramos(v_index).closscorridor := pclosscorridor;
         v_tobtramos(v_index).ccappedratio := pccappedratio;
         v_tobtramos(v_index).crepos := pcrepos;
         v_tobtramos(v_index).ibonorec := pibonorec;
         v_tobtramos(v_index).impaviso := pimpaviso;
         v_tobtramos(v_index).impcontado := pimpcontado;
         v_tobtramos(v_index).pctcontado := ppctcontado;
         v_tobtramos(v_index).pctgastos := ppctgastos;
         v_tobtramos(v_index).ptasaajuste := pptasaajuste;
         v_tobtramos(v_index).icapcoaseg := picapcoaseg;
         v_tobtramos(v_index).icostofijo := picostofijo;
         v_tobtramos(v_index).pcomisinterm := ppcomisinterm;
         -- fin Bug 18319 - APD - 04/07/2011
      -- v_tobtramos(v_index).cuadroces := t_iax_cuadroces_rea();
      END IF;

      --p_tab_error(f_sysdate, f_user, 'PAC_AXIS_REA', 1, 'salgo', SQLERRM);
      vpasexec := 4;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_objetotramosrea;

/**************************************************************************/
   FUNCTION f_set_objetocuadrorea(
      pccompani NUMBER,   -- Codigo de la compa?ia
      pnversio NUMBER,   -- Numero de version contrato reas.
      pscontra NUMBER,   -- Secuencia de contrato
      pctramo NUMBER,   -- Codigo de tramo
      pccomrea NUMBER,   -- Codigo de comision en contratos de reaseguro.
      ppcesion NUMBER,   -- Porcentaje de cesion
      pnplenos NUMBER,   -- Numero de plenos
      picesfij NUMBER,   -- Importe de cesion fijo
      picomfij NUMBER,   -- Importe de comision dijo
      pisconta NUMBER,   -- Importe limite pago siniestros al contado
      ppreserv NUMBER,   -- Porcentaje de reserva sobre cesion
      ppintres NUMBER,   -- Porcentaje de interes sobre reserva
      piliacde NUMBER,   -- Importe limite acumulacion deducible(XLoss)
      pppagosl NUMBER,   -- Porcentaje a pagar por el reasegurador sobre el porcentaje que ha asumido
      pccorred NUMBER,   -- Indicador corredor ( Cia que agrupamos )
      pcintref NUMBER,   -- Codigo de interes referenciado
      pcresref NUMBER,   -- Codigo de reserva referenciada
      pcintres NUMBER,   -- Codigo de interes de reaseguro
      pireserv NUMBER,   -- Importe fijo de reserva
      pptasaj NUMBER,   -- Tasa de ajuste de la reserva
      pfultliq DATE,   -- Ultima liquidacion reservas
      piagrega NUMBER,   -- Importe Agregado XL
      pimaxagr NUMBER,   -- Importe Agregado Maximo XL ( L.A.A )
      -- Bug 18319 - APD - 05/07/2011
      pctipcomis IN NUMBER,   -- Tipo Comision
      ppctcomis IN NUMBER,   -- % Comision fija / provisional
      pctramocomision IN NUMBER,   --Tramo comision variable
      -- Fin Bug 18319 - APD - 05/07/2011
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pNVERSIO=' || pnversio || ' pSCONTRA=' || pscontra || 'pCTRAMO=' || pctramo
            || 'pCCOMPANI=' || pccompani;
      vobject        VARCHAR2(200) := 'PAC_IAX_REA.f_set_objetocuadrorea';
      v_index        NUMBER(2);
      i              NUMBER := 0;
      cont           NUMBER := 0;
      vnorden        NUMBER;
      v_encontrado   NUMBER := 0;
      v_vacio        NUMBER := 0;
      v_tcompani     companias.tcompani%TYPE;
      v_descri       descomisioncontra.tdescri%TYPE;
   BEGIN
      --p_tab_error(f_sysdate, f_user, 'PAC_AXIS_REA', 1, 'Entro set cuadroces', SQLERRM);
      --Comprovacio de parametres
      IF pccompani IS NULL
         OR pnversio IS NULL
         OR pctramo IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF (pireserv IS NOT NULL
          AND pcresref IS NOT NULL)
         OR(pireserv IS NOT NULL
            AND ppreserv IS NOT NULL)
         OR(ppreserv IS NOT NULL
            AND pcresref IS NOT NULL) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9900739);
         RETURN 1;
      END IF;

      vpasexec := 2;

      IF v_tobtramos IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000626);
         RETURN 1;   --Debe existir un tramo donde meter el cuadro del tramo
      END IF;

      /*
      IF V_TOBTRAMOS IS not NULL THEN
          FOR i IN v_tobtramos.FIRST .. v_tobtramos.LAST LOOP
            p_tab_error (f_sysdate,f_USER,'PAC_AXIS_REA', 1,  'v_tobtramos(i).ctramo :'||v_tobtramos(i).ctramo,sqlerrm);
        END LOOP;
      END IF;*/
      FOR i IN v_tobtramos.FIRST .. v_tobtramos.LAST LOOP
         --p_tab_error(f_sysdate, f_user, 'PAC_AXIS_REA', 2, 'Entro set cuadroces - 2', SQLERRM);
         IF v_tobtramos(i).nversio = pnversio
            AND v_tobtramos(i).ctramo = pctramo
            AND NVL(v_tobtramos(i).scontra, -1) = NVL(pscontra, -1) THEN   -- Localizamos el tramo sobre el que se a?aden compa?ias
            /*p_tab_error(f_sysdate, f_user, 'PAC_AXIS_REA', 3, 'Entro set cuadroces - 3',
                        SQLERRM);*/
            --buscamos la compa?ia o la creamos
            IF v_tobtramos(i).cuadroces IS NULL THEN
               /*p_tab_error(f_sysdate, f_user, 'PAC_AXIS_REA', 3, 'Si esta nulo lo creamos',
                           SQLERRM);*/
               v_tobtramos(i).cuadroces := t_iax_cuadroces_rea();
               v_vacio := 1;
            ELSE   -- v_tobtramos(i).cuadroces IS NOT NULL THEN
               IF v_tobtramos(i).cuadroces.COUNT = 0 THEN
                  v_vacio := 1;
               END IF;
            END IF;

            vpasexec := 3;

            IF v_vacio = 0 THEN
               FOR cont IN v_tobtramos(i).cuadroces.FIRST .. v_tobtramos(i).cuadroces.LAST LOOP
                  /*p_tab_error(f_sysdate, f_user, 'PAC_AXIS_REA', 3,
                              'Entro set cuadroces - 32', SQLERRM);*/
                  IF v_tobtramos(i).cuadroces(cont).ccompani = pccompani
                     AND v_tobtramos(i).cuadroces(cont).nversio = pnversio
                     AND v_tobtramos(i).cuadroces(cont).ctramo = pctramo
                     AND NVL(v_tobtramos(i).cuadroces(cont).scontra, -1) = NVL(pscontra, -1) THEN
                     /*p_tab_error(f_sysdate, f_user, 'PAC_AXIS_REA', 4,
                                 'Entro set cuadroces - 4', SQLERRM);*/
                     --Si lo encontramos lo modificamos
                     v_tobtramos(i).cuadroces(cont).ctramo := pctramo;
                     v_tobtramos(i).cuadroces(cont).ttramo :=
                                  ff_desvalorfijo(105, pac_md_common.f_get_cxtidioma, pctramo);
                     v_tobtramos(i).cuadroces(cont).ccomrea := pccomrea;

                     BEGIN
                        SELECT tdescri
                          INTO v_descri
                          FROM descomisioncontra
                         WHERE ccomrea = pccomrea
                           AND cidioma = pac_md_common.f_get_cxtidioma;
                     EXCEPTION
                        WHEN OTHERS THEN
                           v_descri := NULL;
                     END;

                     v_tobtramos(i).cuadroces(cont).tcomrea := v_descri;
                     v_tobtramos(i).cuadroces(cont).pcesion := ppcesion;
                     v_tobtramos(i).cuadroces(cont).icesfij := picesfij;
                     v_tobtramos(i).cuadroces(cont).icomfij := picomfij;
                     v_tobtramos(i).cuadroces(cont).isconta := pisconta;
                     v_tobtramos(i).cuadroces(cont).preserv := ppreserv;
                     v_tobtramos(i).cuadroces(cont).pintres := ppintres;
                     v_tobtramos(i).cuadroces(cont).iliacde := piliacde;
                     v_tobtramos(i).cuadroces(cont).ppagosl := pppagosl;
                     v_tobtramos(i).cuadroces(cont).ccorred := pccorred;

                     BEGIN
                        SELECT tcompani
                          INTO v_tcompani
                          FROM companias
                         WHERE ccompani = pccorred;
                     EXCEPTION
                        WHEN OTHERS THEN
                           v_tcompani := '**';
                     END;

                     v_tobtramos(i).cuadroces(cont).descorred := v_tcompani;
                     v_tobtramos(i).cuadroces(cont).cintref := pcintref;
                     v_tobtramos(i).cuadroces(cont).cresref := pcresref;
                     v_tobtramos(i).cuadroces(cont).cintres := pcintres;
                     v_tobtramos(i).cuadroces(cont).ireserv := pireserv;
                     v_tobtramos(i).cuadroces(cont).ptasaj := pptasaj;
                     v_tobtramos(i).cuadroces(cont).fultliq := pfultliq;
                     v_tobtramos(i).cuadroces(cont).iagrega := piagrega;
                     v_tobtramos(i).cuadroces(cont).imaxagr := pimaxagr;
                     -- Bug 18319 - APD - 05/07/2011
                     v_tobtramos(i).cuadroces(cont).ctipcomis := pctipcomis;
                     --v_tobtramos(i).cuadroces(cont).ttipcomis := ??????;
                     v_tobtramos(i).cuadroces(cont).pctcomis := ppctcomis;
                     v_tobtramos(i).cuadroces(cont).ctramocomision := pctramocomision;
                     --v_tobtramos(i).cuadroces(cont).ttramocomision := ????;
                     -- Fin Bug 18319 - APD - 05/07/2011
                     vpasexec := 4;
                     v_encontrado := 1;
                  END IF;
               END LOOP;
            END IF;

            /*p_tab_error(f_sysdate, f_user, 'PAC_AXIS_REA', 3,
                        'Entro set cuadroces - 35||v_ecnotrado: ' || v_encontrado
                        || ' v_vacio ' || v_vacio,
                        SQLERRM);*/
            IF v_encontrado = 0
               OR v_vacio = 1 THEN
               /*p_tab_error(f_sysdate, f_user, 'PAC_AXIS_REA', 5,
                           'Entro a crear uno nuevo - 5', SQLERRM);*/
               --Si no, lo creamos.
               vpasexec := 5;
               v_tobtramos(i).cuadroces.EXTEND;
               v_index := v_tobtramos(i).cuadroces.LAST;
               v_tobtramos(i).cuadroces(v_index) := ob_iax_cuadroces_rea();
               v_tobtramos(i).cuadroces(v_index).ccompani := pccompani;

               BEGIN
                  SELECT tcompani
                    INTO v_tcompani
                    FROM companias
                   WHERE ccompani = pccompani;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_tcompani := '**';
               END;

               v_tobtramos(i).cuadroces(v_index).tcompani := v_tcompani;
               v_tobtramos(i).cuadroces(v_index).nversio := pnversio;
               v_tobtramos(i).cuadroces(v_index).scontra := pscontra;
               v_tobtramos(i).cuadroces(v_index).ctramo := pctramo;
               v_tobtramos(i).cuadroces(v_index).ttramo :=
                                   ff_desvalorfijo(105, pac_md_common.f_get_cxtidioma, pctramo);
               v_tobtramos(i).cuadroces(v_index).ccomrea := pccomrea;

               BEGIN
                  SELECT tdescri
                    INTO v_descri
                    FROM descomisioncontra
                   WHERE ccomrea = pccomrea
                     AND cidioma = pac_md_common.f_get_cxtidioma;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_descri := NULL;
               END;

               v_tobtramos(i).cuadroces(v_index).tcomrea := v_descri;
               v_tobtramos(i).cuadroces(v_index).pcesion := ppcesion;
               v_tobtramos(i).cuadroces(v_index).icesfij := picesfij;
               v_tobtramos(i).cuadroces(v_index).icomfij := picomfij;
               v_tobtramos(i).cuadroces(v_index).isconta := pisconta;
               v_tobtramos(i).cuadroces(v_index).preserv := ppreserv;
               v_tobtramos(i).cuadroces(v_index).pintres := ppintres;
               v_tobtramos(i).cuadroces(v_index).iliacde := piliacde;
               v_tobtramos(i).cuadroces(v_index).ppagosl := pppagosl;
               v_tobtramos(i).cuadroces(v_index).ccorred := pccorred;

               BEGIN
                  SELECT tcompani
                    INTO v_tcompani
                    FROM companias
                   WHERE ccompani = pccorred;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_tcompani := '**';
               END;

               v_tobtramos(i).cuadroces(v_index).descorred := v_tcompani;
               v_tobtramos(i).cuadroces(v_index).cintref := pcintref;
               v_tobtramos(i).cuadroces(v_index).cresref := pcresref;
               v_tobtramos(i).cuadroces(v_index).cintres := pcintres;
               v_tobtramos(i).cuadroces(v_index).ireserv := pireserv;
               v_tobtramos(i).cuadroces(v_index).ptasaj := pptasaj;
               v_tobtramos(i).cuadroces(v_index).fultliq := pfultliq;
               v_tobtramos(i).cuadroces(v_index).iagrega := piagrega;
               v_tobtramos(i).cuadroces(v_index).imaxagr := pimaxagr;
               -- Bug 18319 - APD - 05/07/2011
               v_tobtramos(i).cuadroces(v_index).ctipcomis := pctipcomis;
               --v_tobtramos(i).cuadroces(v_index).ttipcomis := ??????;
               v_tobtramos(i).cuadroces(v_index).pctcomis := ppctcomis;
               v_tobtramos(i).cuadroces(v_index).ctramocomision := pctramocomision;
            --v_tobtramos(i).cuadroces(v_index).ttramocomision := ????;
            -- Fin Bug 18319 - APD - 05/07/2011
            END IF;
         END IF;
      END LOOP;

      --p_tab_error(f_sysdate, f_user, 'PAC_AXIS_REA', 6, 'Fin - 6', SQLERRM);
      vpasexec := 6;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_objetocuadrorea;

   /*************************************************************************
      funcion que recupera el objeto persistente ob_iax_tramos_rea
   *************************************************************************/
   FUNCTION f_get_objeto_tramos(ptramosrea OUT t_iax_tramos_rea, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      condicio       VARCHAR2(1000);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_REA.f_get_objeto_tramos';
      v_index        NUMBER;
   BEGIN
      ptramosrea := pac_iax_rea.v_tobtramos;
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
   END f_get_objeto_tramos;

   /*************************************************************************
    funcion que borra una tramo del objeto
   *************************************************************************/
   FUNCTION f_del_objetotramosrea(
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pscontra IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_REA.F_del_objetotramosrea';
      vparam         VARCHAR2(500)
         := 'parametros - pnversio: ' || pnversio || ' - pctramo: ' || pctramo
            || ' - pscontra: ' || pscontra;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      --Comprovacio dels parametres d'entrada
      IF pctramo IS NULL
         OR pnversio IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF v_tobtramos IS NOT NULL THEN
         FOR i IN v_tobtramos.FIRST .. v_tobtramos.LAST LOOP
            IF v_tobtramos(i).nversio = pnversio
               AND v_tobtramos(i).ctramo = pctramo
               AND NVL(v_tobtramos(i).scontra, -1) = NVL(pscontra, -1) THEN
               IF v_tobtramos(i).cuadroces IS NOT NULL THEN
                  IF v_tobtramos(i).cuadroces.COUNT > 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9900740);
                     RETURN 1;
                  END IF;
               END IF;

               v_tobtramos.DELETE(i);
               vnumerr := pac_md_rea.f_del_tramos(pnversio, pscontra, pctramo, mensajes);

               IF v_tobtramos.COUNT = 0 THEN
                  v_tobtramos := NULL;
               END IF;
            END IF;
         END LOOP;
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_del_objetotramosrea;

   /*************************************************************************
     funcion que borra un objeto cuadro dentro de la coleccion de objetos de tramos
    *************************************************************************/
   FUNCTION f_del_objetocuadrorea(
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pscontra IN NUMBER,
      pccompani IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_REA.F_del_objetocuadrorea';
      vparam         VARCHAR2(500)
         := 'parametros - pnversio: ' || pnversio || ' - pctramo: ' || pctramo
            || ' - pscontra: ' || pscontra || ' - pccompani:' || pccompani;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      --Comprovacio dels parametres d'entrada
      IF pctramo IS NULL
         OR pnversio IS NULL
         OR pccompani IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF v_tobtramos IS NOT NULL THEN
         FOR i IN v_tobtramos.FIRST .. v_tobtramos.LAST LOOP
            IF v_tobtramos(i).nversio = pnversio
               AND v_tobtramos(i).ctramo = pctramo
               AND NVL(v_tobtramos(i).scontra, -1) = NVL(pscontra, -1) THEN
               --Una vez encontrado el objeto tramos buscamos el objeto cuadroces a borrar
               IF v_tobtramos(i).cuadroces IS NOT NULL THEN
                  FOR n IN v_tobtramos(i).cuadroces.FIRST .. v_tobtramos(i).cuadroces.LAST LOOP
                     IF v_tobtramos(i).cuadroces(n).nversio = pnversio
                        AND v_tobtramos(i).cuadroces(n).ctramo = pctramo
                        AND v_tobtramos(i).cuadroces(n).ccompani = pccompani
                        AND NVL(v_tobtramos(i).cuadroces(n).scontra, -1) = NVL(pscontra, -1) THEN
                        v_tobtramos(i).cuadroces.DELETE(n);
                        vnumerr := pac_md_rea.f_del_cuadroces(pccompani, pnversio, pscontra,
                                                              pctramo, mensajes);

                        IF v_tobtramos(i).cuadroces.COUNT = 0 THEN
                           v_tobtramos(i).cuadroces := NULL;
                        END IF;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         END LOOP;
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_del_objetocuadrorea;

   /*************************************************************************
    Funcion que inserta o modifica un contrato incluyendo TRAMOS, CUADROS
   *************************************************************************/
   FUNCTION f_set_contrato_rea(
      pscontra NUMBER,   -- Secuencia del contrato
      pspleno NUMBER,   -- Identificador del pleno
      pcempres NUMBER,   -- Codigo de empresa
      pctiprea NUMBER,   -- Codigo tipo contrato
      pcramo NUMBER,   -- Codigo de ramo
      pcmodali NUMBER,   -- Codigo de modalidad
      pctipseg NUMBER,   -- Codigo de tipo de seguro
      pccolect NUMBER,   -- Codigo de colectivo
      pcactivi NUMBER,   -- Actividad
      pcgarant NUMBER,   -- Codigo de garantia
      pcvidaga NUMBER,   -- Codigo de forma de calculo
      psconagr NUMBER,
      pcvidair NUMBER,
      pctipcum NUMBER,
      pcvalid NUMBER,
      --CONTRATOS
      --SCONTRA      number(6),             -- Secuencia del contrato
      pnversio NUMBER,   -- Numero version contrato reas.
      pnpriori NUMBER,   -- Porcentaje local asumible
      pfconini DATE,   -- Fecha inicial de version
      pnconrel NUMBER,   -- Contrato relacionado
      pfconfin DATE,   -- Fecha final de version
      piautori NUMBER,   -- Importe con autorizacion
      piretenc NUMBER,   -- Importe pleno neto de retencion
      piminces NUMBER,   -- Importe minimo cesion (Pleno neto de retencion)
      picapaci NUMBER,   -- Importe de capacidad maxima
      piprioxl NUMBER,   -- Importe prioridad XL
      pppriosl NUMBER,   -- Prioridad SL
      ptobserv VARCHAR2,   -- Observaciones varias
      ppcedido NUMBER,   -- Porcentaje cedido
      ppriesgos NUMBER,   -- Porcentaje riesgos agravados
      ppdescuento NUMBER,   -- Porcentaje de descuenctros de seleccion
      ppgastos NUMBER,   -- Porcentaje de gastos (PB)
      pppartbene NUMBER,   -- Porcentaje de participacion en beneficios (PB)
      pcreafac NUMBER,   -- Codigo de facultativo
      ppcesext NUMBER,   -- Porcentaje de cesion sobre la extraprima
      pcgarrel NUMBER,   -- Codigo de la garantia relacionada
      pcfrecul NUMBER,   -- Frecuencia de liquidacion con cia
      psconqp NUMBER,   -- Contrato CP relacionado
      pnverqp NUMBER,   -- Version CP relacionado
      piagrega NUMBER,   -- Importe agregado XL
      pimaxagr NUMBER,   -- Importe agregado maximo XL (L.A.A.)
      ptcontra VARCHAR2,
      -- Bug 18319 - APD - 04/07/2011
      pcmoneda IN VARCHAR,   -- Codigo de la moneda
      ptdescripcion IN VARCHAR,   -- Descripcion del contrato
      pclavecbr NUMBER,   -- Formula para el CBR
      pcercartera NUMBER,   -- Tipo E/R cartera
      piprimaesperadas NUMBER,   -- Primas esperadas totales para la version
      pnanyosloss NUMBER,   -- A?os Loss-Corridos
      pcbasexl NUMBER,   -- Base para el calculo XL
      pclosscorridor NUMBER,   -- Codigo clausula Loss Corridor
      pccappedratio NUMBER,   -- Codigo clausula Capped Ratio
      pscontraprot NUMBER,   -- Contrato XL proteccion
      pcestado NUMBER,   --Estado de la version
      pnversioprot NUMBER,   -- Version del Contrato XL proteccion
      pcdevento NUMBER,
      -- Fin Bug 18319 - APD - 04/07/2011
      pncomext NUMBER,   --% Comisi??xtra prima (solo para POSITIVA)
	  pnretpol NUMBER, -- EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por poliza NRETPOL
      pnretcul NUMBER, -- EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por Cumulo NRETCUL
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_REA.f_set_contrato_rea';
      vparam         VARCHAR2(500)
                       := 'parametros - pnversio: ' || pnversio || ' - pscontra: ' || pscontra;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_tobtramos_aux t_iax_tramos_rea;
   BEGIN
      --Comprobamos si estamos insertando o actualizando.
          --En el primer caso enviamos la coleccion en memoria.
          --En el segundo caso recuperamos la coleccion de BD.
--      IF pscontra IS NULL THEN   -- Nuevo
      IF pscontra IS NOT NULL THEN
         v_tobtramos_aux := pac_md_rea.f_get_tramos_rea(pscontra, pnversio, mensajes);
      END IF;

--      ELSE
--         v_tobtramos_aux := pac_md_rea.f_get_tramos_rea(pscontra, pnversio, mensajes);
      /*if v_tobtramos_aux is null then
          return 1;
      end if;*/
--      END IF;

      /*vnumerr := pac_md_rea.f_valida_contrato_rea(v_tobtramos_aux, pctiprea, piretenc, picapaci, mensajes);
      if vnumerr <> 0 then
          return 1;
      end if;*/

      -- Bug 18319 - APD - 04/07/2011 - se a?aden los campos pcmoneda, ptdescripcion, pclavecbr,
      -- pcercartera, piprimaesperadas, pnanyosloss, pcbasexl, pclosscorridor, pccappedratio,
      -- pscontraprot, pcestado
      vnumerr := pac_md_rea.f_set_contrato_rea(pscontra, pspleno, pcempres, pctiprea, pcramo,
                                               pcmodali, pctipseg, pccolect, pcactivi,
                                               pcgarant, pcvidaga, psconagr, pcvidair,
                                               pctipcum, pcvalid, pnversio, pnpriori, pfconini,
                                               pnconrel, pfconfin, piautori, piretenc,
                                               piminces, picapaci, piprioxl, pppriosl,
                                               ptobserv, ppcedido, ppriesgos, ppdescuento,
                                               ppgastos, pppartbene, pcreafac, ppcesext,
                                               pcgarrel, pcfrecul, psconqp, pnverqp, piagrega,
                                               pimaxagr, ptcontra, v_tobtramos_aux, pcmoneda,
                                               ptdescripcion, pclavecbr, pcercartera,
                                               piprimaesperadas, pnanyosloss, pcbasexl,
                                               pclosscorridor, pccappedratio, pscontraprot,
                                               pcestado, pnversioprot, pcdevento, pncomext, 
                                               pnretpol, pnretcul,
                                               mensajes);-- EDBR - 11/06/2019 - IAXIS3338 - se agregan parametros de Retencion por poliza NRETPOL y Retencion por Cumulo NRETCUL
      -- Bug 18319 - APD - 04/07/2011
      IF vnumerr = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 101625);
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_contrato_rea;

   FUNCTION f_set_t_tramo_mem(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                         := 'parametros - pscontra:' || pscontra || ' - pnversio:' || pnversio;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_set_t_tramo_mem';
      vnumerr        NUMBER;
   BEGIN
      v_tobtramos := pac_md_rea.f_set_t_tramo_mem(pscontra, pnversio, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_set_t_tramo_mem;

   /*************************************************************************
    Funcion que devuelve la ultima version de un contrato.
   ************************************************************************/
   FUNCTION f_get_nversio(
      pscontra IN NUMBER,
      pnversio_datos OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'parametros - pscontra:' || pscontra;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_nversio';
      vcursor        sys_refcursor;
   BEGIN
      RETURN pac_md_rea.f_get_nversio(pscontra, pnversio_datos, mensajes);
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
   END f_get_nversio;

   /*************************************************************************
   Funcion que inicializa el objeto para evitar problemas de cache
   *************************************************************************/
   FUNCTION f_ini_obj_tramos(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := '';
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_ini_obj_tramos';
      vcursor        sys_refcursor;
   BEGIN
      v_tobtramos := NULL;
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
   END f_ini_obj_tramos;

/*FIN BUG 11353 : 30/10/2009 : ICV */

   /*************************************************************************
   Funcion que selecciona todas las clausulas de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_cod_clausulas_reas(
      pccodigo IN NUMBER,
      pctipo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pccodigo = ' || pccodigo || ';pctipo = ' || pctipo;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_cod_clausulas_reas';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_cod_clausulas_reas(pccodigo, pctipo, mensajes);
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
   Funcion que dada una clausula de reaseguro, devuelve su descripcion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_clausulas_reas(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pccodigo = ' || pccodigo || ';pcidioma = ' || pcidioma;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_clausulas_reas';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_clausulas_reas(pccodigo, pcidioma, mensajes);
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
   Funcion que dada una clausula de reaseguro, devuelve sus tramos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_clausulas_reas_det(
      pccodigo IN NUMBER,
      pctramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pccodigo = ' || pccodigo || ';pctramo = ' || pctramo;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_clausulas_reas_det';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_clausulas_reas_det(pccodigo, pctramo, mensajes);
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
   Funcion que graba una clausula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_cod_clausulas_reas(
      pcmodo IN NUMBER,
      pccodigo IN NUMBER,
      pctipo IN NUMBER,
      pfefecto IN DATE,
      pfvencim IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parametros- pcmodo : ' || pcmodo || '; pccodigo : ' || pccodigo || '; pctipo : '
            || pctipo || '; pfefecto : ' || pfefecto || '; pfvencim : ' || pfvencim;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_set_cod_clausulas_reas';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Bug 18319 - APD - 04/07/2011 - se a?aden los parametros pcmoneda y ptdescripcion
      vnumerr := pac_md_rea.f_set_cod_clausulas_reas(pcmodo, pccodigo, pctipo, pfefecto,
                                                     pfvencim, mensajes);

      -- Fin Bug 18319 - APD - 04/07/2011
      IF vnumerr = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180121);   -- El registro se ha guardado correctamente
         COMMIT;
      ELSE
         ROLLBACK;
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
   Funcion que guarda una descripcion de una clausula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_clausulas_reas(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      ptdescripcion IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parametros- pccodigo : ' || pccodigo || '; pcidioma : ' || pcidioma
            || '; ptdescripcion : ' || ptdescripcion;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_set_clausulas_reas';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Bug 18319 - APD - 04/07/2011 - se a?aden los parametros pcmoneda y ptdescripcion
      vnumerr := pac_md_rea.f_set_clausulas_reas(pccodigo, pcidioma, ptdescripcion, mensajes);

      -- Fin Bug 18319 - APD - 04/07/2011
      IF vnumerr = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180121);   -- El registro se ha guardado correctamente
         COMMIT;
      ELSE
         ROLLBACK;
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
   Funcion que guarda un tramo de una clausula de reaseguro
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parametros- pcmodo : ' || pcmodo || '; pccodigo : ' || pccodigo || '; pctramo : '
            || pctramo || '; plim_inf : ' || plim_inf || '; plim_sup : ' || plim_sup
            || '; ppctpart : ' || ppctpart || '; ppctmin : ' || ppctmin || '; ppctmax : '
            || ppctmax;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_set_clausulas_reas_det';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Bug 18319 - APD - 04/07/2011 - se a?aden los parametros pcmoneda y ptdescripcion
      vnumerr := pac_md_rea.f_set_clausulas_reas_det(pcmodo, pccodigo, pctramo, plim_inf,
                                                     plim_sup, ppctpart, ppctmin, ppctmax,
                                                     mensajes);

      -- Fin Bug 18319 - APD - 04/07/2011
      IF vnumerr = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180121);   -- El registro se ha guardado correctamente
         COMMIT;
      ELSE
         ROLLBACK;
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
   Funcion que elimina una descripcion una clausula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_clausulas_reas(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
                       := 'parametros- pccodigo : ' || pccodigo || '; pcidioma : ' || pcidioma;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_del_clausulas_reas';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Bug 18319 - APD - 04/07/2011 - se a?aden los parametros pcmoneda y ptdescripcion
      vnumerr := pac_md_rea.f_del_clausulas_reas(pccodigo, pcidioma, mensajes);

      -- Fin Bug 18319 - APD - 04/07/2011
      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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
   Funcion que elimina un tramo una clausula de reaseguro o un tramo escalonado
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_clausulas_reas_det(
      pccodigo IN NUMBER,
      pctramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
                         := 'parametros- pccodigo : ' || pccodigo || '; pctramo : ' || pctramo;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_del_clausulas_reas_det';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Bug 18319 - APD - 04/07/2011 - se a?aden los parametros pcmoneda y ptdescripcion
      vnumerr := pac_md_rea.f_del_clausulas_reas_det(pccodigo, pctramo, mensajes);

      -- Fin Bug 18319 - APD - 04/07/2011
      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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
   Funcion que selecciona todas las reposiciones
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_cod_reposicion(pccodigo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pccodigo = ' || pccodigo;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_cod_reposicion';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_cod_reposicion(pccodigo, mensajes);
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
   Funcion que dada una reposicion, devuelve su descripcion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_reposiciones(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pccodigo = ' || pccodigo || ';pcidioma = ' || pcidioma;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_reposiciones';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_reposiciones(pccodigo, pcidioma, mensajes);
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
   Funcion que dada una reposicion, devuelve sus tramos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_reposiciones_det(
      pccodigo IN NUMBER,
      pnorden IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pccodigo = ' || pccodigo || ';pnorden = ' || pnorden;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_reposiciones_det';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_reposiciones_det(pccodigo, pnorden, mensajes);
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
Funcion que graba una reposicion
*************************************************************************/
-- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_cod_reposicion(pccodigo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800) := 'parametros- pccodigo : ' || pccodigo;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_set_cod_reposicion';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_rea.f_set_cod_reposicion(pccodigo, mensajes);

      IF vnumerr = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 180121);   -- El registro se ha guardado correctamente
         COMMIT;
      ELSE
         ROLLBACK;
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
   Funcion que guarda una descripcion de una reposicion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_reposiciones(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      ptdescripcion IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parametros- pccodigo : ' || pccodigo || '; pcidioma : ' || pcidioma
            || '; ptdescripcion : ' || ptdescripcion;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_set_reposiciones';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Bug 18319 - APD - 04/07/2011 - se a?aden los parametros pcmoneda y ptdescripcion
      vnumerr := pac_md_rea.f_set_reposiciones(pccodigo, pcidioma, ptdescripcion, mensajes);

      -- Fin Bug 18319 - APD - 04/07/2011
      IF vnumerr = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 180121);   -- El registro se ha guardado correctamente
         COMMIT;
      ELSE
         ROLLBACK;
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
   Funcion que guarda un tramo de una reposicion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_reposiciones_det(
      pcmodo IN NUMBER,
      pccodigo IN NUMBER,
      pnorden IN NUMBER,
      picapacidad IN NUMBER,
      pptasa IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parametros- pcmodo : ' || pcmodo || '; pccodigo : ' || pccodigo || '; pnorden : '
            || pnorden || '; picapacidad : ' || picapacidad || '; pptasa : ' || pptasa;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_set_reposiciones_det';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Bug 18319 - APD - 04/07/2011 - se a?aden los parametros pcmoneda y ptdescripcion
      vnumerr := pac_md_rea.f_set_reposiciones_det(pcmodo, pccodigo, pnorden, picapacidad,
                                                   pptasa, mensajes);

      -- Fin Bug 18319 - APD - 04/07/2011
      IF vnumerr = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 180121);   -- El registro se ha guardado correctamente
         COMMIT;
      ELSE
         ROLLBACK;
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
   Funcion que elimina una reposicion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_cod_reposicion(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
                       := 'parametros- pccodigo : ' || pccodigo || '; pcidioma : ' || pcidioma;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_del_cod_reposicion';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_rea.f_del_cod_reposicion(pccodigo, pcidioma, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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
   Funcion que elimina un detalle de una reposicion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_reposiciones_det(
      pccodigo IN NUMBER,
      pnorden IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
                         := 'parametros- pccodigo : ' || pccodigo || '; pnorden : ' || pnorden;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_del_reposiciones_det';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_rea.f_del_reposiciones_det(pccodigo, pnorden, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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
   Funcion que guarda una agrupacion de contrato
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_agrupcontrato(psconagr IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800) := 'parametros- psconagr : ' || psconagr;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_set_agrupcontrato';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_rea.f_set_agrupcontrato(psconagr, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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
   Funcion que guarda una descripcion de una agrupacion de contrato
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_desagrupcontrato(
      psconagr IN NUMBER,
      pcidioma IN NUMBER,
      ptconagr IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parametros- psconagr : ' || psconagr || '; pcidioma : ' || pcidioma
            || '; ptconagr = ' || ptconagr;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_set_desagrupcontrato';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_rea.f_set_desagrupcontrato(psconagr, pcidioma, ptconagr, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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
   Funcion que selecciona todas las asociaciones de productos a contratos
   *************************************************************************/
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800)   -- 23830/0150483 AVT 06/08/2013  VARCHAR2(200)
         := 'pscontra = ' || pscontra || '; psversion = ' || psversion || '; pcramo = '
            || pcramo || '; pcmodali = ' || pcmodali || '; pccolect = ' || pccolect
            || '; pctipseg = ' || pctipseg || '; psproduc = ' || psproduc || '; pcactivi = '
            || pcactivi || '; pcgarant = ' || pcgarant;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_agr_contratos';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_agr_contratos(pscontra, psversion, pcramo, pcmodali,
                                                pccolect, pctipseg, psproduc, pcactivi,
                                                pcgarant, mensajes);
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
Funcion que graba una asociacion
*************************************************************************/
-- BUG 28492 - INICIO - DCT - 11/10/2013 - A¿¿adir pilimsub
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'pscontra = ' || pscontra || '; psversion = ' || psversion || '; pcramo = '
            || pcramo || '; pcmodali = ' || pcmodali || '; pccolect = ' || pccolect
            || '; pctipseg = ' || pctipseg || '; psproduc = ' || psproduc || '; pcactivi = '
            || pcactivi || '; pcgarant = ' || pcgarant || '; pilimsub  = ' || pilimsub;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_set_agr_contratos';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_rea.f_set_agr_contratos(pscontra, psversion, pcramo, pcmodali,
                                                pccolect, pctipseg, psproduc, pcactivi,
                                                pcgarant, pilimsub, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_agr_contratos;

   -- BUG 28492 - INICIO - DCT - 11/10/2013 - A¿¿adir pilimsub

   /*************************************************************************
Funcion que elimina una asociacion
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'pscontra = ' || pscontra || '; psversion = ' || psversion || '; pcramo = '
            || pcramo || '; pcmodali = ' || pcmodali || '; pccolect = ' || pccolect
            || '; pctipseg = ' || pctipseg || '; psproduc = ' || psproduc || '; pcactivi = '
            || pcactivi || '; pcgarant = ' || pcgarant;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_del_agr_contratos';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_rea.f_del_agr_contratos(pscontra, psversion, pcramo, pcmodali,
                                                pccolect, pctipseg, psproduc, pcactivi,
                                                pcgarant, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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
   Funcion que selecciona todas las asociaciones de formulas a garantias
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_reaformula(
      pscontra IN NUMBER,
      pnversion IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800)
         := 'pscontra = ' || pscontra || '; pnversion = ' || pnversion || '; psproduc = '
            || psproduc || '; pcactivi = ' || pcactivi || '; pcgarant = ' || pcgarant
            || '; pccampo = ' || pccampo || '; pclave = ' || pclave;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_reaformula';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_reaformula(pscontra, pnversion, psproduc, pcactivi,
                                             pcgarant, pccampo, pclave, mensajes);
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
   Funcion que graba una asociacion de formulas a garantias
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_reaformula(
      pscontra IN NUMBER,
      pnversion IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'pscontra = ' || pscontra || '; pnversion = ' || pnversion || '; psproduc = '
            || psproduc || '; pcactivi = ' || pcactivi || '; pcgarant = ' || pcgarant
            || '; pccampo = ' || pccampo || '; pclave = ' || pclave;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_set_reaformula';
      vnumerr        NUMBER := 0;
   BEGIN
   -- 20/09/2011 - de momento no se crea esta funcion y se utiliza la funcion
   -- f_set_reaformula ya existente
/*
      vnumerr := pac_md_rea.f_set_reaformula(pscontra, pnversion, psproduc, pcactivi,
                                             pcgarant, pccampo, pclave, mensajes);
*/
      vnumerr := pac_md_rea.f_set_reaformula(pscontra, pnversion, pcgarant, pccampo, pclave,
                                             psproduc, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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

   /*************************************************************************
   Funcion que elimina una asociacion de formulas a garantias
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_reaformula(
      pscontra IN NUMBER,
      pnversion IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'pscontra = ' || pscontra || '; pnversion = ' || pnversion || '; psproduc = '
            || psproduc || '; pcactivi = ' || pcactivi || '; pcgarant = ' || pcgarant
            || '; pccampo = ' || pccampo || '; pclave = ' || pclave;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_del_reaformula';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_rea.f_del_reaformula(pscontra, pnversion, psproduc, pcactivi,
                                             pcgarant, pccampo, pclave, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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
   Funcion que selecciona todas las agrupaciones de contratos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_contratosagr(
      psconagr IN NUMBER,
      pcidioma IN NUMBER,
      ptconagr IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800)
         := 'psconagr = ' || psconagr || '; pcidioma = ' || pcidioma || '; ptconagr = '
            || ptconagr;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_contratosagr';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_contratosagr(psconagr, pcidioma, ptconagr, mensajes);
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
   Funcion que graba una agrupacion de contratos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_contratosagr(
      psconagr IN NUMBER,
      pcidioma IN NUMBER,
      ptconagr IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'psconagr = ' || psconagr || '; pcidioma = ' || pcidioma || '; ptconagr = '
            || ptconagr;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_set_contratosagr';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_rea.f_set_contratosagr(psconagr, pcidioma, ptconagr, mensajes);

      IF vnumerr = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180121);   -- El registro se ha guardado correctamente
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_contratosagr;

   /*************************************************************************
   Funcion que elimina una agrupacion de contratos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_contratosagr(
      psconagr IN NUMBER,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800) := 'psconagr = ' || psconagr || '; pcidioma = ' || pcidioma;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_del_contratosagr';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_rea.f_del_contratosagr(psconagr, pcidioma, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_contratosagr;

   /*************************************************************************
   Funcion que devuelve el siguiente codigo de agrupacion de contrato
   *************************************************************************/
   -- Bug 19724 - APD - 10/10/2011 - se crea la funcion
   FUNCTION f_get_sconagr_next(psmaxconagr OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800) := NULL;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_sconagr_next';
      vnumerr        NUMBER := 0;
      vsmaxconagr    NUMBER;
   BEGIN
      vnumerr := pac_md_rea.f_get_sconagr_next(vsmaxconagr, mensajes);
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
   Funcion que recupera el objeto ob_iax_clausulas_reas.
   *************************************************************************/
   -- Bug 19724 - APD - 10/10/2011 - se crea la funcion
   FUNCTION f_get_objeto_clausulas_reas(
      pccodigo IN NUMBER,   -- Codigo de la clausula
      pobj_clausulas_reas OUT ob_iax_clausulas_reas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800) := 'pccodigo = ' || pccodigo;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_objeto_clausulas_reas';
      vob_clausulas_reas ob_iax_clausulas_reas;
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_rea.f_get_objeto_clausulas_reas(pccodigo, vob_clausulas_reas,
                                                        mensajes);
      pobj_clausulas_reas := vob_clausulas_reas;
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
   END f_get_objeto_clausulas_reas;

   /*************************************************************************
   Funcion que recupera el objeto ob_iax_reposicion.
   *************************************************************************/
   -- Bug 19724 - APD - 10/10/2011 - se crea la funcion
   FUNCTION f_get_objeto_reposicion(
      pccodigo IN NUMBER,   -- Codigo de la clausula
      pobj_reposicion OUT ob_iax_reposicion,
      mensajes OUT t_iax_mensajes,
      filtro_norden IN VARCHAR)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800) := 'pccodigo = ' || pccodigo;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_objeto_reposicion';
      vob_reposicion ob_iax_reposicion;
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_rea.f_get_objeto_reposicion(pccodigo, vob_reposicion, mensajes,
                                                    filtro_norden);
      pobj_reposicion := vob_reposicion;
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
   END f_get_objeto_reposicion;

   /*************************************************************************
   Funcion que obtiene la lista de cuentas
   *************************************************************************/
   -- Bug 22076 - AVT - 22/05/2012 - se crea la funcion
   FUNCTION f_get_ctatecnica(
      pcempres IN NUMBER,
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
      pnsinies IN NUMBER,   -- no afegit per ara a la pantalla....
      pcestado IN NUMBER,
      pciaprop IN NUMBER DEFAULT NULL,
      psproces IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800)   -- 23830/0150483 AVT 06/08/2013  VARCHAR2(200)
         := 'parametros - pcempres:' || pcempres || ' - pcramo:' || pcramo || ' - psproduc:'
            || psproduc || ' - pccorred:' || pccorred || ' - pccompani:' || pccompani
            || ' - pscontra:' || pscontra || ' - pnversio:' || pnversio || ' - pctramo:'
            || pctramo || ' - pfcierre:' || pfcierre || ' - pnpoliza:' || pnpoliza
            || ' - pncertif:' || pncertif || ' - pnsinies:' || pnsinies || ' - pcestado:'
            || pcestado || ' - pciaprop:' || pciaprop || ' - psproces:' || psproces;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_ctatecnica';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_ctatecnica(pcempres, pcramo, psproduc, pccorred, pccompani,
                                             pscontra, pnversio, pctramo, pfcierre, pnpoliza,
                                             pncertif, pnsinies, pcestado, pciaprop, psproces,
                                             mensajes);
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
   END f_get_ctatecnica;

   /*************************************************************************
   Funcion que devuelve la cabecera de la cuenta tecnica de reaseguro consultada
   *************************************************************************/
   -- Bug 22076 - AVT - 22/05/2012 - se crea la funcion
   FUNCTION f_get_cab_movcta(
      pcempres IN NUMBER,
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800)   -- 23830/0150483 AVT 06/08/2013  VARCHAR2(200)
         := 'parametros - pcempres:' || pcempres || ' - psproduc:' || psproduc
            || ' - pccompani:' || pccompani || ' - pscontra:' || pscontra || ' - pnversio:'
            || pnversio || ' - pctramo:' || pctramo || ' - pfcierre:' || pfcierre
            || ' - pcestado:' || pcestado || ' - pnpoliza:' || pnpoliza || ' - pciaprop:'
            || pciaprop || ' - pspagrea:' || pspagrea;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_cab_movcta';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_cab_movcta(pcempres, psproduc, pccompani, pscontra,
                                             pnversio, pctramo, pfcierre, pcestado, pnpoliza,
                                             pciaprop, pspagrea, mensajes);
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
   Funcion que devuelve las cuentas tecnicas de la reaseguradora consultada
   *************************************************************************/
   -- Bug 22076 - AVT - 22/05/2012 - se crea la funcion
   FUNCTION f_get_movctatecnica(
      pcempres IN NUMBER,
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800)   -- 23830/0150483 AVT 06/08/2013  VARCHAR2(200)
         := 'parametros - pcempres:' || pcempres || ' - psproduc:' || psproduc
            || ' - pccompani:' || pccompani || ' - pscontra:' || pscontra || ' - pnversio:'
            || pnversio || ' - pctramo:' || pctramo || ' - pfcierre:' || pfcierre
            || ' - pcestado:' || pcestado || ' - pnpoliza:' || pnpoliza || ' - pciaprop:'
            || pciaprop || ' - pspagrea:' || pspagrea || ' - pcheckall:' || pcheckall;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_movctatecnica';
      vcursor        sys_refcursor;
   BEGIN
      --KBR A¿¿adimos el nuevo par¿¿metro "pcheckall"
      vcursor := pac_md_rea.f_get_movctatecnica(pcempres, psproduc, pccompani, pscontra,
                                                pnversio, pctramo, pfcierre, pcestado,
                                                pnpoliza, pciaprop, pspagrea, pcheckall,
                                                mensajes);
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
   END f_get_movctatecnica;

   /*************************************************************************
   Funcion que elimina un movimiento manual de la cuenta tecnica del reaseguro
   *************************************************************************/
   -- Bug 22076 - AVT - 22/05/2012 - se crea la funcion
   FUNCTION f_del_movctatecnica(
      pcempres IN NUMBER,
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := ' pcempres:' || pcempres || ' - psproduc:' || psproduc || ' - pccompani:'
            || pccompani || ' - pscontra:' || pscontra || ' - pnversio:' || pnversio
            || ' - pctramo:' || pctramo || ' - pfcierre:' || pfcierre || ' - pcconcep:'
            || pcconcep || ' - pnnumlin:' || pnnumlin || ' - pnpoliza:' || pnpoliza
            || ' - pncertif:' || pncertif || ' - pnsinies:' || pnsinies || ' - pciaprop:'
            || pciaprop;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_del_movctatecnica';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_rea.f_del_movctatecnica(pcempres, psproduc, pccompani, pscontra,
                                                pnversio, pctramo, pfcierre, pcconcep,
                                                pnnumlin, pnpoliza, pncertif, pnsinies,
                                                pciaprop, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_movctatecnica;

   /*************************************************************************
   Funcion que apunta en la tabla de liquidacion los importes pendientes de la cuenta tecnica del reaseguro.
   *************************************************************************/
   FUNCTION f_liquida_ctatec_rea(
      pcempres IN NUMBER,
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := ' pcempres:' || pcempres || ' - psproduc:' || psproduc || ' - pccorred:'
            || pccorred || ' - pccompani:' || pccompani || ' - pscontra:' || pscontra
            || ' - pnversio:' || pnversio || ' - pctramo:' || pctramo || ' - pfcierre:'
            || pfcierre || ' - psproces:' || psproces || ' - pciaprop:' || pciaprop;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_liquida_ctatec_rea';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Control parametros entrada
      IF psproces IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- KBR 27911/150911 - Se a¿¿¿¿ade param. "pcliquidar"
      -- KBR 18/07/2014 - se agrega el parametro pultimoreg 0-No 1-Si
      vnumerr := pac_md_rea.f_liquida_ctatec_rea(pcempres, psproduc, pccorred, pccompani,
                                                 pscontra, pnversio, pctramo, pfcierre,
                                                 psproces, pcliquidar, pciaprop, pultimoreg,
                                                 mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         --ROLLBACK;
         COMMIT;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_liquida_ctatec_rea;

   /*************************************************************************
       Funcion que insertara o modificara un movimiento de cuenta tecnica en funcion del pmodo
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
      pcempres IN NUMBER,
      pdescrip IN VARCHAR2,
      pdocumen IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnsinies IN NUMBER,
      psproduc IN NUMBER,
      pmodo IN NUMBER,
      mensajes OUT t_iax_mensajes,
      psidepag IN NUMBER DEFAULT NULL,
      pciaprop IN NUMBER DEFAULT NULL)   --23830 DCT /AVT 27/12/2013)
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
            || pdescrip || ', pdocumen : ' || pdocumen || ' pmodo:' || pmodo || ', pnpoliza:'
            || pnpoliza || ', pncertif:' || pncertif || ', pnsinies:' || pnsinies
            || ' psproduc:' || psproduc || ' pmodo:' || pmodo || ' pciaprop:' || pciaprop;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_set_movctatecnica';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_rea.f_set_movctatecnica(pccompani, pnversio, pscontra, pctramo,
                                                pnnumlin, pfmovimi, pfefecto, pcconcep,
                                                pcdebhab, piimport, pcestado, psproces,
                                                pscesrea, piimport_moncon, pfcambio, pcempres,
                                                pdescrip, pdocumen, pnpoliza, pncertif,
                                                pnsinies, psproduc, pmodo, psidepag, pciaprop,
                                                mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'params : pccompani : ' || pccompani || ', pnversio : ' || pnversio
            || ', pscontra : ' || pscontra || ' , pctramo : ' || pctramo || ', pnnumlin : '
            || pnnumlin || ' , pestadoNew : ' || pestadonew || ' , pestadoOld : '
            || pestadoold || ' , pccorred : ' || pccorred || ' , pcempres : ' || pcempres
            || ' , psproduc : ' || psproduc || ' , pfcierre : ' || pfcierre;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_set_reten_liquida';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_rea.f_set_reten_liquida(pccompani, pnversio, pscontra, pctramo,
                                                pnnumlin, pccorred, pcempres, psproduc,
                                                pfcierre, pestadonew, pestadoold, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_reten_liquida;

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
   /*******************************************************************************
   FUNCION F_REGISTRA_PROCESO
   Esta funci??os devolver?l c??o de proceso real para la liquidaci??el reaseguro
    Par?tros:
     Entrada :
       Pfperini NUMBER  : Fecha Inicio
       Pcempres NUMBER  : Empresa
     Salida :
       Mensajes   T_IAX_MENSAJES
   Retorna : NUMBER con el n??o de proceso.
   ********************************************************************************/
   FUNCTION f_registra_proceso(
      pfperini IN DATE,
      pcempres IN NUMBER,
      pnproceso OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pfperini = ' || pfperini || 'pcempres=' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_IAX_REA.F_REGISTRA_PROCESO';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Control parametros entrada
      IF pfperini IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      /*Deber?lamar a la funci??e la capa MD, pac_md_rea.f_registra_proceso
      Esta funci??os devolver?l c??o de proceso real para la liquidaci??easeguro
      Este proceso solo se obtendr?n el momento lanzar el previo de cartera o cartera.
      */
      vnumerr := pac_md_rea.f_registra_proceso(pfperini, pcempres, pnproceso, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      --Retorna : un NUMBER.
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_registra_proceso;

---------------------------------------------------------------------------------------------------------------------------------
   -- Bug 26444 - ETM - 31/07/2012 - se crea la funcion -INI
  /*******************************************************************************
   FUNCION f_get_movmanual_rea
   Esta funcion permite crear movimientos manuales de cesiones de reaseguro
    Par?tros:

     Entrada :
      pscontra : NUMBER
      pcempres : NUMBER
      pnversio : NUMBER
      pctramo  : NUMBER
      pfcierre   :    DATE
      ptdescrip    :  VARCHAR2(500)
      pnidentif    :  VARCHAR2(100)
      pcconcep  : NUMBER(2)
      pcdebhab  : NUMBER(1)
      piimport  : NUMBER(13,2)
      pnsinies  : NUMBER(8)
      pnpoliza  : NUMBER(8)
      pncertif  : NUMBER(6)
      pcevento  : VARCHAR2(20 BYTE)
      pcgarant  : NUMBER(4) garantia
      pnid      : NUMBER(6) numerdo de id

     Salida :
       Mensajes   T_IAX_MENSAJES
   Retorna : cursor
   ********************************************************************************/
   FUNCTION f_get_movmanual_rea(
      pscontra IN NUMBER,
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
      pnid IN NUMBER,
      pnidout OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(800)
         := 'parametros - pscontra:' || pscontra || ' - pnversio:' || pnversio
            || ' - pctramo:' || pctramo || ' - pfcierre:' || pfcierre || ' - ptdescrip:'
            || ptdescrip || ' - pnidentif:' || pnidentif || ' - pcconcep:' || pcconcep
            || ' - pcdebhab:' || pcdebhab || ' - piimport:' || piimport || ' - pnsinies:'
            || pnsinies || ' - pnpoliza:' || pnpoliza || ' - pncertif:' || pncertif
            || ' - pcevento:' || pcevento || ' - pcgarant:' || pcgarant || ' - pnid:' || pnid;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_movmanual_rea';
      vnumerr        NUMBER := 0;
      v_error        NUMBER;
      v_cempres      empresas.cempres%TYPE;
      v_cidioma      idiomas.cidioma%TYPE;
      vcursor        sys_refcursor;
   BEGIN
      IF pscontra IS NULL
         OR pnversio IS NULL
         OR pctramo IS NULL
         OR pfcierre IS NULL
         OR pcconcep IS NULL
         OR pcdebhab IS NULL
         OR piimport IS NULL THEN
         v_error := 9001768;   --falta campos obligatorios por entrar
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RETURN NULL;
      END IF;

      -- 27.0 - 22/09/2014 - MMM -0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales - Inicio

      -- vpasexec := 2;
      --
      -- IF pcevento IS NOT NULL
      --    AND pnsinies IS NOT NULL THEN
      --    v_error := 9905813;   --Si informa el evento no ha de informar el siniestro
      --    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
      --    RETURN NULL;
      -- END IF;

      -- Se elimina la validaci¿¿n

      -- 27.0 - 22/09/2014 - MMM -0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales - Fin
      vpasexec := 3;
      v_cidioma := pac_md_common.f_get_cxtidioma;
      v_cempres := pac_md_common.f_get_cxtempresa;

      IF pnid IS NOT NULL THEN
         --borro
         vnumerr := pac_md_rea.f_borrar_movprevio(v_cempres, pnid, mensajes);
         vpasexec := 4;

         IF vnumerr <> 0 THEN
            v_error := 140999;   --Error no controlado
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
            RETURN NULL;
         END IF;
      END IF;

      vpasexec := 5;
      vcursor := pac_md_rea.f_get_movmanual_rea(pscontra, v_cempres, pnversio, pctramo,
                                                pfcierre, ptdescrip, pnidentif, pcconcep,
                                                pcdebhab, piimport, pnsinies, pnpoliza,
                                                pncertif, pcevento, pcgarant, pnidout,
                                                mensajes);
      vpasexec := 6;
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_movmanual_rea;

   FUNCTION f_set_movmanual_rea(pnid IN NUMBER, paccion IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'parametros - pnid:' || pnid || ' ,paccion:' || paccion;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_set_movmanual_rea';
      vcursor        sys_refcursor;
      vnumerr        NUMBER := 0;
      v_cempres      empresas.cempres%TYPE;
   BEGIN
      v_cempres := pac_md_common.f_get_cxtempresa;

      IF paccion = 0 THEN
         --borro
         vnumerr := pac_md_rea.f_borrar_movprevio(v_cempres, pnid, mensajes);
      ELSE
         --graba en todas las tablas reales
         vnumerr := pac_md_rea.f_graba_real_movmanual_rea(v_cempres, pnid, mensajes);
      END IF;

      IF vnumerr = 0 THEN
         COMMIT;

         IF paccion <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 180121);   ---  El registro se ha guardado correctamente
         ELSE
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9905821);   --el apunte manual se ha borrado corectamente
         END IF;
      ELSE
         ROLLBACK;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_movmanual_rea;

-- FIN Bug 26444 - ETM - 31/07/2012 - se crea la funcion

   /*************************************************************************

*************************************************************************/
-- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_max_cod_reposicion(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200);
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_max_cod_reposicion';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_max_cod_reposicion(mensajes);
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
      not_in IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_tramos_rea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                         := 'parametros - pscontra:' || pscontra || ' - pnversio:' || pnversio;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_filtered_tramos';
   BEGIN
      RETURN pac_md_rea.f_get_filtered_tramos(pscontra, pnversio, filter_tramos, not_in,
                                              mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_filtered_tramos;

   /*************************************************************************
   Funcion que elimina un tramo y sus dependencias
   *************************************************************************/
   FUNCTION f_del_filtered_tramos(
      pnversio IN NUMBER,
      filtert IN VARCHAR,
      pscontra IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parametros- pnversio : ' || pnversio || '; filtert : ' || filtert
            || '; pscontra : ' || pscontra;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_del_reposiciones_det';
      vnumerr        NUMBER := 0;
      i              NUMBER := 0;
      v_idioma       NUMBER := pac_md_common.f_get_cxtidioma();
      v_crepos       NUMBER;
      v_tramos       t_iax_tramos_rea;
      cur            sys_refcursor;
      v_norden       reposiciones_det.norden%TYPE;
      v_icapacidad   reposiciones_det.icapacidad%TYPE;
      v_ptasa        reposiciones_det.ptasa%TYPE;
   BEGIN
      v_tramos := pac_md_rea.f_get_filtered_tramos(pscontra, pnversio, filtert, 0, mensajes);

      --Para cada tramo de los que estan para eliminar
      FOR i IN v_tramos.FIRST .. v_tramos.LAST LOOP
         v_crepos := v_tramos(i).crepos;

         --Si hay reposicion en el tramo
         IF v_crepos IS NOT NULL THEN
            --Para todas sus reposiciones
            cur := pac_md_rea.f_get_reposiciones_det(v_crepos, NULL, mensajes);

            FETCH cur
             INTO v_norden, v_icapacidad, v_ptasa;

            --Eliminamos los detalles de la reposicion
            WHILE cur%FOUND LOOP
               vnumerr := pac_md_rea.f_del_reposiciones_det(v_crepos, v_norden, mensajes);

               FETCH cur
                INTO v_norden, v_icapacidad, v_ptasa;
            END LOOP;

            CLOSE cur;

            --Si ha ido bien, eliminamos la reposicion
            IF vnumerr = 0 THEN
               vnumerr := pac_md_rea.f_del_cod_reposicion(v_crepos, v_idioma, mensajes);
            END IF;
         END IF;

         --Si ha ido bien, eliminamos el tramo
         IF vnumerr = 0 THEN
            vnumerr := pac_md_rea.f_del_tramos(pnversio, pscontra, v_tramos(i).ctramo,
                                               mensajes);
         END IF;
      END LOOP;

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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
   END f_del_filtered_tramos;

   /*************************************************************************
   Funcion que elimina un tramo y sus dependencias
   *************************************************************************/
   FUNCTION f_get_new_scontra(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800);
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_new_scontra';
   BEGIN
      RETURN v_new_scontra;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_new_scontra;

   FUNCTION f_del_contrato_rea(pscontra IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vnumerr        NUMBER := 0;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800);
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_del_contrato_rea';
   BEGIN
      vnumerr := pac_md_rea.f_del_contrato_rea(pscontra, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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

   FUNCTION f_del_cuadroces(
      pccompani IN NUMBER,   --ob
      pnversio IN NUMBER,   --ob
      pscontra IN NUMBER,   --ob
      pctramo IN NUMBER,   --ob
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'par?metros- pccompani :' || pccompani || ' pscontra :' || pscontra
            || ' pnversio : ' || pnversio || ' pctramo : ' || pctramo;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_del_cuadroces';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_rea.f_del_cuadroces(pccompani, pnversio, pscontra, pctramo, mensajes);

      IF vnumerr = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
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
   END f_del_cuadroces;

   FUNCTION f_get_reposiciones_contrato(
      pccodigo IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pccodigo = ' || pccodigo;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_reposiciones_contrato';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_rea.f_get_reposiciones_contrato(pccodigo, pscontra, pnversio, pctramo,
                                                        mensajes);
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

   FUNCTION f_del_tramos(
      pnversio IN NUMBER,
      pscontra IN NUMBER,
      pctramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'par?metros- pscontra :' || pscontra || ' pnversio : ' || pnversio
            || ' pctramo : ' || pctramo;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_del_tramos';
      v_error        NUMBER := 0;
   BEGIN
      v_error := pac_md_rea.f_del_tramos(pnversio, pscontra, pctramo, mensajes);

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

   FUNCTION f_set_liquida(
      pspagrea IN NUMBER,
      pfcambio IN DATE,
      pitotal IN NUMBER,
      pmoneda IN VARCHAR2,
      pcestpag IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parametros - pspagrea :' || pspagrea || ' pfcambio : ' || pfcambio
            || ' pitotal : ' || pitotal || ' pmoneda : ' || pmoneda || ' pcestpag : '
            || pcestpag;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_set_liquida';
      v_error        NUMBER := 0;
   BEGIN
      v_error := pac_md_rea.f_set_liquida(pspagrea, pfcambio, pitotal, pmoneda, pcestpag,
                                          mensajes);

      IF v_error = 0 THEN
         vpasexec := 10;
         COMMIT;
      ELSE
         vpasexec := 20;
         ROLLBACK;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
      END IF;

      vpasexec := 30;
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
   END f_set_liquida;

   FUNCTION f_get_tramo_sin_bono(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_tramo_sin_bono IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parametros - pscontra:' || pscontra || ' - pnversio:' || pnversio
            || ' - pctramo:' || pctramo;
      vobject        VARCHAR2(50) := 'pac_iax_rea.f_get_tramo_sin_bono';
   BEGIN
      RETURN pac_md_rea.f_get_tramo_sin_bono(pscontra, pnversio, pctramo, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_tramo_sin_bono;

  FUNCTION f_get_compani_doc(
            pccompani IN NUMBER,
            mensajes OUT t_iax_mensajes)
       RETURN SYS_REFCURSOR
  IS
       --
       v_cursor SYS_REFCURSOR;
       --
       e_object_error EXCEPTION;
       e_param_error  EXCEPTION;
       vpasexec       NUMBER;
       vobject        VARCHAR2(200) := 'pac_iax_contragarantias.f_get_compani_doc';
       vparam         VARCHAR2(500) := 'pccompani: ' || pccompani;
       --
  BEGIN
       --
       v_cursor := pac_md_rea.f_get_compani_doc(pccompani => pccompani, mensajes => mensajes);
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
            mensajes OUT t_iax_mensajes)
       RETURN NUMBER
  IS
       --
       e_object_error EXCEPTION;
       e_param_error  EXCEPTION;
       vpasexec       NUMBER := 1;
       vobject        VARCHAR2(200) := 'pac_iax_contragarantias.f_edit_compani_doc';
       vparam         VARCHAR2(500) := 'pccompani: ' || pccompani || ' pfalta: ' || pfalta ||
       ' piddocgdx: ' || piddocgdx || ' pctipo: ' || pctipo || ' ptobserv: ' || ptobserv ||
       ' pfcaduci: ' || pfcaduci;
       --
       vnum_err NUMBER;
       --
  BEGIN
       --
       vnum_err := pac_md_rea.f_edit_compani_doc(pccompani => pccompani, piddocgdx => piddocgdx,
       pctipo => pctipo, ptobserv => ptobserv, ptfilename => ptfilename, pfcaduci => pfcaduci, pfalta
       => pfalta, mensajes => mensajes);
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
            mensajes OUT t_iax_mensajes)
       RETURN NUMBER
  IS
       --
       e_object_error EXCEPTION;
       e_param_error  EXCEPTION;
       vpasexec       NUMBER := 1;
       vobject        VARCHAR2(200) := 'pac_iax_contragarantias.f_ins_compani_doc';
       vparam         VARCHAR2(500) := 'pccompani: ' || pccompani || ' pfalta: ' || pfalta ||
       ' piddocgdx: ' || piddocgdx || ' pctipo: ' || pctipo || ' ptobserv: ' || ptobserv ||
       ' pfcaduci: ' || pfcaduci || ' pfalta: ' || pfalta;
       --
       vnum_err NUMBER;
       --
  BEGIN
       --
       vnum_err := pac_md_rea.f_ins_compani_doc(pccompani => pccompani, piddocgdx => piddocgdx,
       pctipo => pctipo, ptobserv => ptobserv, ptfilename => ptfilename, pfcaduci => pfcaduci, pfalta
       => pfalta, mensajes => mensajes);
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
            mensajes OUT t_iax_mensajes)
       RETURN SYS_REFCURSOR
  IS
       --
       v_cursor SYS_REFCURSOR;
       --
       vpasexec NUMBER;
       vobject  VARCHAR2(200) := 'pac_iax_rea.f_get_compani_docs';
       vparam   VARCHAR2(500) := 'pccompani: ' || pccompani;
       --
  BEGIN
       --
       v_cursor := pac_md_rea.f_get_compani_docs(pccompani => pccompani, mensajes => mensajes);
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_rea.f_set_reaseguro_x_garantia';
   BEGIN
      v_cursor := pac_md_rea.f_get_reaseguro_x_garantia(ptabla,ppoliza, psseguro, psproces,pcgenera, mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_reaseguro_x_garantia;

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
      vobjectname    VARCHAR2(500) := 'PAC_IAX_REA.f_get_trimestres';
      vparam         VARCHAR2(500)
                        := 'parámetros - pfinitrim: ' || pfinitrim || ', pffintrim: ' || pffintrim;
      vpasexec       NUMBER(5) := 1;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
   BEGIN
      vpasexec := 1;
      vcursor := pac_md_rea.f_get_trimestres(pfinitrim, pffintrim, mensajes);
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_REA.f_set_patri_tec';
      vparam         VARCHAR2(500)
                        := 'parámetros - panio: '|| panio || ', ptrimestre: ' || ptrimestre || ', pmoneda: '|| pmoneda || ', pvalor: ' || pvalor;
      vpasexec       NUMBER(5) := 1;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
      vnumerr        NUMBER(8) := 0;
   BEGIN
       vnumerr := pac_md_rea.f_set_patri_tec(panio, ptrimestre, pmoneda, pvalor, pmovimi, mensajes);

      IF vnumerr = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 101625);
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN vnumerr;

   EXCEPTION
      WHEN OTHERS THEN 
        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
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
      vobjectname    VARCHAR2(500) := 'PAC_IAX_REA.f_get_hist_pat_tec';
      vparam         VARCHAR2(500)
                        := 'parámetros - pnanio: ' || pnanio || ', pntrim: ' || pntrim;
      vpasexec       NUMBER(5) := 1;
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(9000);
   BEGIN
      vpasexec := 1;
      vcursor := pac_md_rea.f_get_hist_pat_tec(pnanio, pntrim, mensajes);
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

   /* INI - ML - 4549
    * f_activar_contrato: ACTIVA INDIVIDUALMENTE UN CONTRATO EN REASEGURO, TOMANDO LA ULTIMA VERSION VALIDA
   */
   FUNCTION f_activar_contrato(
	   pscontra IN NUMBER,
       mensajes OUT t_iax_mensajes)
       RETURN NUMBER IS       
       vpasexec       NUMBER := 1;       
       vparam         VARCHAR2(500) := 'pscontra: ' || pscontra;
       vnumerr        NUMBER;
  BEGIN
	  vnumerr := PAC_MD_REA.F_ACTIVAR_CONTRATO (PSCONTRA => pscontra);	  
	  IF vnumerr = 0 THEN		 	  
		 pac_iobj_mensajes.Crea_Nuevo_Mensaje(mensajes, 2, 0, pac_iobj_mensajes.f_get_descmensaje(89907023, pac_md_common.f_get_cxtidioma));
	     RETURN vnumerr;	  	      
	  END IF; 
	  RAISE PROGRAM_ERROR;
  EXCEPTION
      WHEN OTHERS THEN 
       pac_iobj_mensajes.Crea_Nuevo_Mensaje(mensajes, 1, 0, pac_iobj_mensajes.f_get_descmensaje(vnumerr,  pac_md_common.f_get_cxtidioma));
       RETURN 1;
  END f_activar_contrato;
   
END pac_iax_rea;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_REA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_REA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_REA" TO "PROGRAMADORESCSI";
