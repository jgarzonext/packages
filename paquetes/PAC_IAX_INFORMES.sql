--------------------------------------------------------
--  DDL for Package PAC_IAX_INFORMES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_INFORMES" 
AS
/******************************************************************************
   NOMBRE:      PAC_IAX_INFORMES


   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/12/2008   XPL               1. Creaci¿n del package.
   2.0        17/02/2010   JMF               2. 0013247 Registro de Asegurados de Fallecimiento link de output de datos
   3.0        22/07/2010   SRA               3. 0015489: CEM - LListat de traspassos
   4.0        29/11/2010   JMF               4. 0016529 CRT003 - An¿lisis listados

******************************************************************************/

   /******************************************************************************************
     Descripci¿: Funci¿ que genera els registres de cobertura de mort
      Par¿metres entrada: - PINICOBERTURA -> data inicial
                          - PFINCOBERTURA -> data fitxer
                          - PFICHERO      -> nom fitxer on es grabar¿ la informaci¿
                          - ptipoEnvio    -> Tipo 0-Inicial, 1-Periodico.
      Par¿metres sortida: - PFGENERADO    -> Nombre/patch completo del fichero generado
                          - mensajes      -> Missatges d'error
     return:             retorna 0 si va tot b¿, sino el codi de l'error
   ******************************************************************************************/

   -- Bug 0013247 - 17/02/2010 - JMF: Afegir param pfgenerado
   -- Bug 0014113 - 14/04/2010 - JMF: Afegir param p_tipoEnvio
   FUNCTION f_lanzar_cobfallecimiento(
      pinicobertura   IN       DATE,
      pfincobertura   IN       DATE,
      pfichero        IN       VARCHAR2,
      ptipoenvio      IN       NUMBER DEFAULT 1,
      pfgenerado      OUT      VARCHAR2,
      mensajes        OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   -- BUG 15296 - 06/07/2010 - SRA: funci¿n para obtener el listado de traspasos
   FUNCTION f_obtener_traspasos(
      pfdesde    IN       DATE,
      pfhasta    IN       DATE,
      pcempres   IN       NUMBER,
      pfichero   OUT      VARCHAR2,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   /******************************************************************************************
     Descripci¿: Funci¿ que genera els informes de la pantalla de llistats 001
     Par¿metres entrada: - p_cinforme    -> codigo informe (detvalor 1021)
                         - p_cidioma     -> codigo idioma
                         - p_cempres     -> codigo empresa
                         - p_finiefe     -> fecha inicio
                         - p_ffinefe     -> fecha final
                         - p_ctipage     -> Tipo (detvalor 1022) (tipo agente)
                         - p_cagente     -> codigo en funcion del tipo (zona, oficina, agente)
                         - p_sperson     -> codigo cliente
                         - p_cnegocio    -> Negocio (detvalor 1023)
                         - p_codigosn    -> Codigos (separados por comas)
                         - p_sproduc     -> Producto de la actividad
     Par¿metres sortida: - p_fgenerado   -> Nombre/patch completo del fichero generado
                         - mensajes      -> Missatges d'error
     return:             retorna 0 si va tot b¿, sino el codi de l'error
   ******************************************************************************************/

   -- Bug 0016529 - 29/11/2010 - JMF
   FUNCTION f_lanzar_list001(
      p_cinforme    IN       NUMBER,
      p_cidioma     IN       NUMBER DEFAULT NULL,
      p_cempres     IN       NUMBER DEFAULT NULL,
      p_finiefe     IN       DATE DEFAULT NULL,
      p_ffinefe     IN       DATE DEFAULT NULL,
--
      p_ctipage     IN       NUMBER DEFAULT NULL,
      p_cagente     IN       NUMBER DEFAULT NULL,
      p_sperson     IN       NUMBER DEFAULT NULL,
--
      p_cnegocio    IN       NUMBER DEFAULT NULL,
      p_codigosn    IN       VARCHAR2 DEFAULT NULL,
      p_sproduc     IN       VARCHAR2 DEFAULT NULL,
      p_fgenerado   OUT      VARCHAR2,
      mensajes      OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   /***********************************************************************
        Recupera los documentos de un seguro
        param in psseguro  : c¿digo de seguro
        param out mensajes : mensajes de error
        return             : ref cursor
     ***********************************************************************/
   FUNCTION f_get_documentacion(
      psseguro   IN       NUMBER,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN sys_refcursor;

   FUNCTION f_get_informes(
      pcempres         IN       NUMBER,
      pcform           IN       VARCHAR2,
      ptevento         IN       VARCHAR2,
      psproduc         IN       NUMBER,
      pstipo           IN       NUMBER DEFAULT NULL,
      pcarea           IN       NUMBER DEFAULT NULL,
      pcurconfigsinf   OUT      sys_refcursor,
      mensajes         OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_get_params(
      pcempres   IN       NUMBER,
      pcform     IN       VARCHAR2,
      ptevento   IN       VARCHAR2,
      psproduc   IN       NUMBER,
      pcmap      IN       VARCHAR2,
      oparams    OUT      sys_refcursor,
      ocexport   OUT      sys_refcursor,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_get_params_informe(
      pcempres    IN       cfg_lanzar_informes_params.cempres%TYPE,
      pcform      IN       cfg_lanzar_informes_params.cform%TYPE,
      ptevento    IN       cfg_lanzar_informes_params.tevento%TYPE,
      psproduc    IN       cfg_lanzar_informes_params.sproduc%TYPE,
      pcmap       IN       cfg_lanzar_informes_params.cmap%TYPE,
      pccfgform   IN       cfg_lanzar_informes_params.ccfgform%TYPE,
      oparams     OUT      sys_refcursor,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_get_parlist(
      pcempres   IN       NUMBER,
      pcform     IN       VARCHAR2,
      ptevento   IN       VARCHAR2,
      psproduc   IN       NUMBER,
      pcmap      IN       VARCHAR2,
      pcparam    IN       VARCHAR2,
      olist      OUT      sys_refcursor,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_ejecuta_informe(
      pcmap         IN       VARCHAR2,
      pcempres      IN       NUMBER,
      pcexport      IN       VARCHAR2,
      pparams       IN       t_iax_info,
      pcidioma      IN       det_lanzar_informes.cidioma%TYPE,
      pcbatch       IN       NUMBER DEFAULT '0',
      pemail        IN       VARCHAR2 DEFAULT NULL,
      onomfichero   OUT      VARCHAR2,
      ofichero      OUT      VARCHAR2,
      mensajes      OUT      t_iax_mensajes,
	  pcgenrec      IN       NUMBER DEFAULT 0
   )
      RETURN NUMBER;

   /*FUNCTION f_set_codiplantillas(
      pccodplan IN codiplantillas.ccodplan%TYPE,
      pidconsulta IN codiplantillas.idconsulta%TYPE,
      pgedox IN codiplantillas.gedox%TYPE,
      pidcat IN codiplantillas.idcat%TYPE,
      pcgenfich IN codiplantillas.cgenfich%TYPE DEFAULT NULL,
      pcgenpdf IN codiplantillas.cgenpdf%TYPE DEFAULT NULL,
      pcgenrep IN codiplantillas.cgenrep%TYPE DEFAULT NULL,
      pctipodoc IN codiplantillas.ctipodoc%TYPE DEFAULT NULL,
      pcfdigital IN codiplantillas.cfdigital%TYPE DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;*/
   FUNCTION f_set_detlanzarinformes(
      pcempres    IN       det_lanzar_informes.cempres%TYPE,
      pcmap       IN       det_lanzar_informes.cmap%TYPE,
      pcidioma    IN       det_lanzar_informes.cidioma%TYPE,
      ptdescrip   IN       det_lanzar_informes.tdescrip%TYPE,
      pcinforme   IN       det_lanzar_informes.cinforme%TYPE,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_set_cfglanzarinformes(
      pcempres        IN       cfg_lanzar_informes.cempres%TYPE,
      pcform          IN       cfg_lanzar_informes.cform%TYPE,
      pcmap           IN       cfg_lanzar_informes.cmap%TYPE,
      ptevento        IN       cfg_lanzar_informes.tevento%TYPE,
      psproduc        IN       cfg_lanzar_informes.sproduc%TYPE,
      pslitera        IN       cfg_lanzar_informes.slitera%TYPE,
      plparams        IN       cfg_lanzar_informes.lparams%TYPE,
      pgenerareport   IN       cfg_lanzar_informes.genera_report%TYPE,
      pccfgform       IN       cfg_lanzar_informes.ccfgform%TYPE,
      plexport        IN       cfg_lanzar_informes.lexport%TYPE,
      pctipo          IN       cfg_lanzar_informes.ctipo%TYPE,
      mensajes        OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_upd_cfglanzarinformes(
      pcempres    IN       cfg_lanzar_informes.cempres%TYPE,
      pcmap       IN       cfg_lanzar_informes.cmap%TYPE,
      ptevento    IN       cfg_lanzar_informes.tevento%TYPE,
      psproduc    IN       cfg_lanzar_informes.sproduc%TYPE,
      pccfgform   IN       cfg_lanzar_informes.ccfgform%TYPE,
      plexport    IN       cfg_lanzar_informes.lexport%TYPE,
      pslitera    IN       cfg_lanzar_informes.slitera%TYPE,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_del_detlanzarinformes(
      pcempres   IN       det_lanzar_informes.cempres%TYPE,
      pcmap      IN       det_lanzar_informes.cmap%TYPE,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_ins_cfglanzarinformesparams(
      pcempres    IN       cfg_lanzar_informes_params.cempres%TYPE,
      pcform      IN       cfg_lanzar_informes_params.cform%TYPE,
      pcmap       IN       cfg_lanzar_informes_params.cmap%TYPE,
      ptevento    IN       cfg_lanzar_informes_params.tevento%TYPE,
      psproduc    IN       cfg_lanzar_informes_params.sproduc%TYPE,
      pccfgform   IN       cfg_lanzar_informes_params.ccfgform%TYPE,
      ptparam     IN       cfg_lanzar_informes_params.tparam%TYPE,
      pctipo      IN       cfg_lanzar_informes_params.ctipo%TYPE,
      pnorder     IN       cfg_lanzar_informes_params.norder%TYPE
            DEFAULT NULL,
      pslitera    IN       cfg_lanzar_informes_params.slitera%TYPE
            DEFAULT NULL,
      pnotnull    IN       cfg_lanzar_informes_params.notnull%TYPE
            DEFAULT NULL,
      PLValor     IN       cfg_lanzar_informes_params.lvalor%TYPE
            DEFAULT NULL,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_del_cfglanzarinformesparams(
      pcempres    IN       cfg_lanzar_informes_params.cempres%TYPE,
      pcform      IN       cfg_lanzar_informes_params.cform%TYPE,
      pcmap       IN       cfg_lanzar_informes_params.cmap%TYPE,
      ptevento    IN       cfg_lanzar_informes_params.tevento%TYPE,
      psproduc    IN       cfg_lanzar_informes_params.sproduc%TYPE,
      pccfgform   IN       cfg_lanzar_informes_params.ccfgform%TYPE,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_get_listainformesreports(
      pcempres   IN       cfg_lanzar_informes.cempres%TYPE,
      pidioma    IN       axis_literales.cidioma%TYPE,
      pcform     IN       cfg_lanzar_informes.cform%TYPE,
      pcmap      IN       cfg_lanzar_informes_params.cmap%TYPE DEFAULT NULL,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN sys_refcursor;

   FUNCTION f_get_cfginforme(
      pcempres         IN       NUMBER,
      pcform           IN       VARCHAR2,
      ptevento         IN       VARCHAR2,
      psproduc         IN       NUMBER,
      pcmap            IN       VARCHAR2,
      pcurconfigsinf   OUT      sys_refcursor,
      mensajes         OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_get_detlanzarinformes(
      pcempresa        IN       det_lanzar_informes.cempres%TYPE,
      pcmap            IN       det_lanzar_informes.cmap%TYPE,
      pcidioma         IN       det_lanzar_informes.cidioma%TYPE DEFAULT NULL,
      ptdescrip        IN       det_lanzar_informes.tdescrip%TYPE
            DEFAULT NULL,
      pcinforme        IN       det_lanzar_informes.cinforme%TYPE
            DEFAULT NULL,
      odetplantillas   OUT      sys_refcursor,
      mensajes         OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_upd_inf_batch(
      pcestado    IN       lanzar_informes.cestado%TYPE,
      pterror     IN       lanzar_informes.terror%TYPE,
      ptfichero   IN       lanzar_informes.tfichero%TYPE,
      psinterf    IN       lanzar_informes.sinterf%TYPE,
      mensajes    OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_get_listainformes(
      pcempres          IN       lanzar_informes.cempres%TYPE,
      pcmap             IN       lanzar_informes.cmap%TYPE DEFAULT NULL,
      pcestado          IN       lanzar_informes.cestado%TYPE DEFAULT NULL,
      pcuser            IN       lanzar_informes.cuser%TYPE DEFAULT NULL,
      pfini             IN       lanzar_informes.fini%TYPE DEFAULT NULL,
      pffin             IN       lanzar_informes.ffin%TYPE DEFAULT NULL,
      pcbatch           IN       lanzar_informes.cbatch%TYPE DEFAULT NULL,
      pcursoninformes   OUT      sys_refcursor,
      mensajes          OUT      t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_get_idiomasinforme(
      pcempres         IN       cfg_lanzar_informes.cempres%TYPE,
      pcmap            IN       detplantillas.ccodplan%TYPE,
      pcform           IN       cfg_lanzar_informes.cform%TYPE,
      pcursoridiomas   OUT      sys_refcursor,
      mensajes         OUT      t_iax_mensajes
   )
      RETURN NUMBER;
    ----PAC_IAX_Informe Informe tecnico IAXIS 3602 Shubhendu----
    --inserting the data into the table for informe technica
    -- RECLAMO 
	--DEPLAZO 
	--Interventor 
    --Supervisor 
    --FUENTEDEINFO 
    --FELABORACION 
     FUNCTION f_inforeme_technico(
      preclamo   IN       VARCHAR2,
      pdeplazo   IN       VARCHAR2,
      pinterventor   IN       VARCHAR2,
      psupervisor  IN      VARCHAR2,
      pfuentedeinfo  IN       VARCHAR2,
      pfelaboracion   IN     Date,
      mensajes   OUT      t_iax_mensajes
   )
      RETURN NUMBER;	  

   FUNCTION f_get_usuarios(
      pcempres          IN       NUMBER,
      pcursorusuarios   OUT      sys_refcursor,
      mensajes          OUT      t_iax_mensajes
   )
      RETURN NUMBER;

  --kaio 04/06/2019 IAXIS-4113	
	  FUNCTION  f_valida_fecha_madurez(
           pnumeropoliza IN NUMBER,
             pcidioma IN NUMBER
    ) 
          RETURN VARCHAR ;	
	--kaio 04/06/2019 IAXIS-4113


      --Inicio Tarea 4136 Kaio
     FUNCTION F_LISTA_POLIZAS_PENDIENTES(
       pnumerotomador IN NUMBER,
       pnumerointermedirario IN NUMBER,
       pcursor OUT sys_refcursor,
       mensajes IN OUT t_iax_mensajes)
       RETURN NUMBER;

      --INI IAXIS-4136 JRVG  23/04/2020
       function f_ins_obs_cuentacobro(
        pobservacion IN obs_cuentacobro.observacion%TYPE,
        psseguro IN obs_cuentacobro.sseguro%TYPE,
        pnrecibo IN obs_cuentacobro.nrecibo%TYPE,
        pmarca  IN  obs_cuentacobro.cmarca%TYPE,
        mensajes IN OUT t_iax_mensajes)
     
      RETURN NUMBER;
      -- Fin Tarea 4136 Kaio
      -- FIN IAXIS-4136 JRVG  23/04/2020


	   --Andres 04/07/2019 IAXIS-2485
	  FUNCTION  f_tipo_reporte_pagare(
          pnsinies   IN       VARCHAR2  )
          RETURN VARCHAR ;
	--Andres 04/07/2019 IAXIS-2485
		  
END pac_iax_informes;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_INFORMES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_INFORMES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_INFORMES" TO "PROGRAMADORESCSI";
