
  CREATE OR REPLACE PACKAGE "PAC_IAX_PERSONA" IS
   /******************************************************************************
      NOMBRE:       PAC_IAX_PERSONA
      PROPÓSITO: Funciones para gestionar personas

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        04/04/2008   JRH                1. Creación del package.
      2.0        18/05/2009   JTS                2. 10074: Modificaciones en el Mantenimiento de Personas
      3.0        09/06/2009   JTS                3. 10371: APR - tipo de empresa
      4.0        02/07/2009   XPL                4. 10339 i 9227, APR - Campos extra en la búsqueda de personas
                                                                        i APR - Error al crear un agente
      5.0        16/09/2009   AMC                5. 11165: Se sustituñe  T_iax_saldodeutorseg por t_iax_prestamoseg
      6.0        16/11/2009   NMM                6. 11948: CEM - Alta de destinatatios.
      7.0        09/02/2010   DRA                7. 0011171: APR - campos de búsqueda en el mto. de personas
      8.0        22/11/2010   XPL                8. 16753: CRE - Pantalla destinatarios - 22/11/2010 - XPL
      9.0        27/07/2011   ICV                9. 0018941: LCOL_P001 - PER - Personas relacionadas. Representante legal
     10.0        23/09/2011   MDS               10. 0018943  Modulo SARLAFT en el mantenimiento de personas
     11.0        04/10/2011   MDS               11. 0018947: LCOL_P001 - PER - Posición global
     12.0        08/11/2011   JGR               12. 0019985 LCOL_A001-Control de las matriculas (prenotificaciones)
     13.0        08/11/2011   JGR               13. 0019985 LCOL_A001-Control de las matriculas (prenotificaciones)
     14.0        23/11/2011   APD               14. 0020126: LCOL_P001 - PER - Documentación en personas
     18.0        10/01/2012   JGR               18. 0020735/0103205 Modificaciones tarjetas y ctas.bancarias
     19.0        09/07/2012   ETM               19.0022263: LCOL_P001 - PER - Informaci?n relacionado con documentos identificativos.
     20.0        24/07/2012   ETM               20. 0022642: MDP - PER - Posici?lobal. Inquilinos, avalistas y gestor de cobro
     21.0        21/01/2013   APD               21. 0025542: LCOL_T031- LCOL - AUT - (id 431) Fecha de antig?edad en personas por agrupaci?n
     22.0        31/01/2013   JDS               22. 0025542: LCOL_T031- LCOL - AUT - (id 431) Fecha de antig?edad en personas por agrupaci?n
     23.0        08/07/2013   RCL               23. 0025599: LCOL - PER - Revision incidencias qtracker y Releases
     24.0        05/08/2013   RCL               24. 0027814: LCOL - PER - Nuevo contacto en el alta r?da de personas Fax.
     25.0        03/04/2014   FAL               25. 0030525: INT030-Prueba de concepto CONFIANZA
     26.0        27/07/2015   IGIL              28. 0036596  MSV - diferenciar opersonas juridicas Hospitales
 	 27.0        23/06/2016   ERH               27. CONF-52 Modificaci?e la funci?_set_persona_rel se adiciona al final el parametro ՉPTLIMIT VARCHAR2
     28.0        22/08/2016   HRE               28. CONF-186: Se incluyen procesos para gestion de marcas.
     29.0        25/08/2016   JGONZALEZ         29. CONF-1049: Llamado al web service de persona para dar de alta
	 30.0        23/11/2018   ACL               30. CP0727M_SYS_PERS_Val Se agrega en la función f_set_datsarlatf el parámetro pcorigenfon.
     31.0        18/12/2018   ACL               31. CP0416M_SYS_PERS Se agrega la función f_get_persona_sarlaf.
	 32.0 		 07/01/2019	  SWAPNIL 			33. Cambios para solicitudes múltiples
	 33.0        29/01/2019   WAJ               34. Se aidicona consulta para traer los indicadores de las personas
	 34.0        01/02/2019   ACL               33. TCS_1569B: Se agrega la función f_get_persona_publica_imp.
	 35.0		 12/02/2019	  AP				34. TCS-9: Se adiciona campos en la funcion f_set_datsarlatf para clausulas.
	 36.0        01/04/2019   DFRP              36. IAXIS-3287:FCC (Formulario de Conocimiento de Cliente).
	 37.0 	     27/06/2019	  KK				37. CAMBIOS De IAXIS-4538
	 38.0		 18/07/2019	  PK			38. Added function for IAXIS-4149 - Modificación Cuentas Bancarias
   ******************************************************************************/
   persona        ob_iax_personas;
   --Objeto persona
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma();
   --Código idioma
   v_obirpf       ob_iax_irpf;
   parpersonas    t_iax_par_personas;

   /*Limpia los objectos*/
   FUNCTION f_limpiar_objetos(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /* PERSONAS : PER_PERSONAS Y PER_DETPER *************************************/
   FUNCTION f_get_personas_agentes(
      numide IN VARCHAR2,
      nombre IN VARCHAR2,
      nsip IN VARCHAR2,
      psseguro IN NUMBER,
      --JRH 04/2008 Se pasa el seguro
      pnom IN VARCHAR2,
      pcognom1 IN VARCHAR2,
      pcognom2 IN VARCHAR2,
      pctipide IN NUMBER,
      pfnacimi IN DATE,
      ptdomici IN VARCHAR2,
      pcpostal IN VARCHAR2,
      phospital IN VARCHAR2 DEFAULT NULL,   -- Bug 36596 IGIL
      pfideico IN VARCHAR2 DEFAULT NULL,   --BUG 40927/228750 - 07/03/2016 - JAEG
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera la lista de personas que coinciden con los criterios de consulta
   param in numide    : número documento
   param in nombre    : texto que incluye nombre + apellidos
   param in nsip      : identificador externo de persona, puede ser nulo
   param out mensajes : mensajes de error
   return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_personas(
      numide IN VARCHAR2,
      nombre IN VARCHAR2,
      nsip IN VARCHAR2 DEFAULT NULL,
      mensajes OUT t_iax_mensajes,
      psseguro IN NUMBER DEFAULT NULL,
      --JRH 04/2008 Se pasa el seguro
      pnom IN VARCHAR2 DEFAULT NULL,
      pcognom1 IN VARCHAR2 DEFAULT NULL,
      pcognom2 IN VARCHAR2 DEFAULT NULL,
      pctipide IN NUMBER DEFAULT NULL)
      RETURN sys_refcursor;

   /*************************************************************************
   Obtiene los datos de una persona pasandole el nif, sexo y fecha nacimiento
   param out mensajes  : mensajes de error
   return              : El OB_IAX_PERSONA
   *************************************************************************/
   FUNCTION f_get_personaunica(
      pctipper IN NUMBER,
      pctipide IN NUMBER,
      pnnumnif IN VARCHAR2,
      pcsexper IN NUMBER,
      fnacimi IN DATE,   -- Fecha de nacimiento de la persona
      pmodo IN VARCHAR2,
      psseguro IN NUMBER,
      pcagente IN NUMBER,
      ppduplicada IN NUMBER,
      obpersona OUT ob_iax_personas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_persona_trecibido(
      psperson IN estper_personas.sperson%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Obtiene los datos de las EST en un objeto OB_IAX_PERSONA
   param out mensajes  : mensajes de error
   return              : El OB_IAX_PERSONA
   *************************************************************************/
   FUNCTION f_get_estpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      obpersona OUT ob_iax_personas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_busqueda_masdatos(mensajes OUT t_iax_mensajes, pomasdatos OUT NUMBER)
      RETURN sys_refcursor;

   /***********************************************************************
   Dado un identificativo de persona llena el objeto personas
   param in sperson       : código de persona
   param in cagente       : código del agente
   param out obpersona : objeto persona
   param out mensajes  : mensajes de error
   retorno : 0 - ok
   1 - error
   Bug 12761 - 19/01/2010 - AMC - Se cambian los parametros obpersona y mensajes a modo solo OUT
   ***********************************************************************/
   FUNCTION f_get_persona_agente(
      sperson IN NUMBER,
      pcagente IN NUMBER,
      pmode IN VARCHAR2,
      obpersona OUT ob_iax_personas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- svj BUG 5912
   /*************************************************************************
   Obtiene los datos de las EST en un objeto OB_IAX_PERSONA
   param out mensajes  : mensajes de error
   return              : El OB_IAX_PERSONA
   *************************************************************************/
   FUNCTION f_get_persona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      obpersona OUT ob_iax_personas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   función que recuperará todas la personas
   con sus detalles según el nivel de visión
   del usuario que este consultando.
   *************************************************************************/
   FUNCTION f_get_det_persona(
      numide IN VARCHAR2,
      nombre IN VARCHAR2,
      nsip IN VARCHAR2 DEFAULT NULL,
      mensajes OUT t_iax_mensajes,
      pnom IN VARCHAR2 DEFAULT NULL,
      pcognom1 IN VARCHAR2 DEFAULT NULL,
      pcognom2 IN VARCHAR2 DEFAULT NULL,
      pctipide IN NUMBER DEFAULT NULL,
      pfnacimi IN DATE,   -- BUG11171:DRA:24/11/2009
      ptdomici IN VARCHAR2,   -- BUG11171:DRA:24/11/2009
      pcpostal IN VARCHAR2,   -- BUG11171:DRA:24/11/2009
      pswpubli IN NUMBER,
      pestseguro IN NUMBER)
      RETURN sys_refcursor;

   -- JLB - I - 6044
   FUNCTION f_get_personas_host(
      numide IN VARCHAR2,
      nombre IN VARCHAR2,
      nsip IN VARCHAR2 DEFAULT NULL,
      mensajes OUT t_iax_mensajes,
      psseguro IN NUMBER DEFAULT NULL,
      --JRH 04/2008 Se pasa el seguro
      pnom IN VARCHAR2 DEFAULT NULL,
      pcognom1 IN VARCHAR2 DEFAULT NULL,
      pcognom2 IN VARCHAR2 DEFAULT NULL,
      pctipide IN NUMBER DEFAULT NULL,
      pomasdatos OUT NUMBER)
      RETURN sys_refcursor;

   /*************************************************************************
   Recupera las ccc en HOST que coinciden con los criterios de consulta.
   Solo personas que pertenecen a una póliza, es decir las personas no públicas no las devuelve
   param in nsip      : identificador externo de persona
   param out mensajes : mensajes de error
   return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_ccc_host(
      numide IN VARCHAR2,
      nsip IN VARCHAR2,
      porigen IN VARCHAR2 DEFAULT 'EST',
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- JLB - F - 6044
   /*************************************************************************
   Recupera la lista de domicilios de la persona
   param in sperson   : código de persona
   param out mensajes : mensajes de error
   return             : ref cursor
   *************************************************************************/
   /*************************************************************************
   Traspasa a las EST si es necesario desde las tablas reales
   param out mensajes  : mensajes de error
   return              : 0 o código error
   *************************************************************************/
   FUNCTION f_traspasapersonaest(
      psperson IN NUMBER,
      -- I - JLb -
      psnip IN VARCHAR2,
      -- F - JLb -
      pcagente IN NUMBER,
      pcoditabla IN VARCHAR2,
      psperson_out OUT NUMBER,
      psseguro IN NUMBER,
      pmensapotup OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Valida el nif
   param out mensajes  : mensajes de error
   return              : 0 o código error
   *************************************************************************/
   FUNCTION f_validanif(
      pnnumide IN per_personas.nnumide%TYPE,
      pctipide IN per_personas.ctipide%TYPE,
      csexper IN per_personas.csexper%TYPE,   -- -- sexo de la pesona.
      fnacimi IN per_personas.fnacimi%TYPE,   -- -- Fecha de nacimiento de la persona
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Graba los datos de  persona en las EST
   param out mensajes  : mensajes de error
   return              : 0 o código error
   *************************************************************************/
   FUNCTION f_set_estpersona(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pspersonout OUT NUMBER,
      pspereal IN NUMBER,
      pcagente IN NUMBER,
      ctipper IN NUMBER,   -- ¿ tipo de persona (física o jurídica)
      ctipide IN NUMBER,   -- ¿ tipo de identificación de persona
      nnumide IN VARCHAR2,
      --  -- Número identificativo de la persona.
      csexper IN NUMBER,   --     -- sexo de la pesona.
      fnacimi IN DATE,   --   -- Fecha de nacimiento de la persona
      snip IN VARCHAR2,   --  -- snip
      cestper IN NUMBER,
      fjubila IN DATE,
      cmutualista IN NUMBER,
      fdefunc IN DATE,
      nordide IN NUMBER,
      cidioma IN NUMBER,   ---      Código idioma
      tapelli1 IN VARCHAR2,   --      Primer apellido
      tapelli2 IN VARCHAR2,   --      Segundo apellido
      tnombre IN VARCHAR2,   --     Nombre de la persona
      tsiglas IN VARCHAR2,   --     Siglas persona jurídica
      cprofes IN VARCHAR2,   --     Código profesión
      cestciv IN NUMBER,   -- Código estado civil. VALOR FIJO = 12
      cpais IN NUMBER,   --     Código país de residencia
      ptnombre1 IN VARCHAR2,
      ptnombre2 IN VARCHAR2,
      pswrut IN NUMBER,
      pcocupacion IN VARCHAR2,   -- Bug 25456/133727 - 16/01/2013 - AMC
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- SVJ 07/2008 BUG 5912
   /*************************************************************************
   Valida y graba los datos en personas.
   param out mensajes  : mensajes de error
   return              : El OB_IAX_PERSONA
   *************************************************************************/
   FUNCTION f_set_persona(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pspersonout OUT NUMBER,
      pspereal IN NUMBER,
      pcagente IN NUMBER,
      ctipper IN NUMBER,   -- ¿ tipo de persona (física o jurídica)
      ctipide IN NUMBER,   -- ¿ tipo de identificación de persona
      nnumide IN VARCHAR2,
      --  -- Número identificativo de la persona.
      csexper IN NUMBER,   --     -- sexo de la pesona.
      fnacimi IN DATE,   --   -- Fecha de nacimiento de la persona
      snip IN VARCHAR2,   --  -- snip
      cestper IN NUMBER,
      fjubila IN DATE,
      cmutualista IN NUMBER,
      fdefunc IN DATE,
      nordide IN NUMBER,
      cidioma IN NUMBER,   ---      Código idioma
      tapelli1 IN VARCHAR2,   --      Primer apellido
      tapelli2 IN VARCHAR2,   --      Segundo apellido
      tnombre IN VARCHAR2,   --     Nombre de la persona
      tsiglas IN VARCHAR2,   --     Siglas persona jurídica
      cprofes IN VARCHAR2,   --     Código profesión
      cestciv IN NUMBER,   -- Código estado civil. VALOR FIJO = 12
      cpais IN NUMBER,   --     Código país de residencia
      pswpubli IN NUMBER,
      pduplicada IN NUMBER,
      ptnombre1 IN VARCHAR2,
      ptnombre2 IN VARCHAR2,
      pswrut IN NUMBER,
      pcocupacion IN VARCHAR2,   -- Bug 25456/133727 - 16/01/2013 - AMC
	  /* Cambios para solicitudes múltiples : Start */
      pTipoosc IN NUMBER,
      pCIIU IN NUMBER,
      pSFINANCI IN NUMBER,
      pFConsti IN DATE,
      pCONTACTOS_PER IN T_IAX_CONTACTOS_PER,
      pDIRECCIONS_PER IN T_IAX_DIRECCIONES,
      pNacionalidad IN NUMBER,
      pDigitoide IN NUMBER,
      /* Cambios para solicitudes múltiples : End */
      pcagenteout OUT NUMBER,
      mensajes OUT t_iax_mensajes
	  /* CAMBIOS De IAXIS-4538 : Start */
      ,pfefecto IN DATE, 
      pcregfiscal IN NUMBER, 
      pctipiva    IN NUMBER,  
      pIMPUETOS_PER IN T_IAX_PROF_IMPUESTOS  
      /* CAMBIOS De IAXIS-4538 : End */
)
      RETURN NUMBER;

   /*************************************************************************
   Nueva función que servirá para modificar los datos básicos de una persona
   *************************************************************************/
   FUNCTION f_set_basicos_persona(
      psperson IN NUMBER,
      pctipper IN NUMBER,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      pcsexper IN NUMBER,
      pfnacimi IN DATE,
      pswpubli IN NUMBER,
      pswrut IN NUMBER,
      pcpreaviso IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Obtiene  de parámetros de salida los datos principales del contacto tipo  teléfono fijo.
   param out mensajes  : mensajes de error
   return              : El OB_IAX_PERSONA
   *************************************************************************/
   /* CONTACTOS : PER_CONTACTOS************************************************/
   FUNCTION f_get_contactotlffijo(
      psperson IN NUMBER,
      cagente IN NUMBER,
      smodcon OUT NUMBER,
      tvalcon OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_estcontactotlffijo(
      psperson IN NUMBER,
      cagente IN NUMBER,
      smodcon OUT NUMBER,
      tvalcon OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Obtiene  de parámetros de salida los datos principales del contacto tipo  teléfono movil.
   param out mensajes  : mensajes de error
   return              : El OB_IAX_PERSONA
   *************************************************************************/
   FUNCTION f_get_contactotlfmovil(
      psperson IN NUMBER,
      cagente IN NUMBER,
      smodcon OUT NUMBER,
      tvalcon OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_estcontactotlfmovil(
      psperson IN NUMBER,
      cagente IN NUMBER,
      smodcon OUT NUMBER,
      tvalcon OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Obtiene  de parámetros de salida los datos principales del contacto tipo  mail.
   return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_contactomail(
      psperson IN NUMBER,
      cagente IN NUMBER,
      smodcon OUT NUMBER,
      tvalcon OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_estcontactomail(
      psperson IN NUMBER,
      cagente IN NUMBER,
      smodcon OUT NUMBER,
      tvalcon OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Obtiene  de parámetros de salida los datos principales del contacto tipo  FAX.
   return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_contactofax(
      psperson IN NUMBER,
      cagente IN NUMBER,
      smodcon OUT NUMBER,
      tvalcon OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_estcontactofax(
      psperson IN NUMBER,
      cagente IN NUMBER,
      smodcon OUT NUMBER,
      tvalcon OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Obtiene Los contactos de una persona
   return              : array contactos
   *************************************************************************/
   FUNCTION f_get_estcontactos(
      psperson IN NUMBER,
      cagente IN NUMBER,
      tcontactos OUT t_iax_contactos,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_contactos(
      psperson IN NUMBER,
      cagente IN NUMBER,
      tcontactos OUT t_iax_contactos,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Obtiene el contacto de una persona
   return              : ob_iax_contactos
   *************************************************************************/
   FUNCTION f_get_estcontacto(
      psperson IN NUMBER,
      cagente IN NUMBER,
      pcmodcon IN NUMBER,
      obcontacto OUT ob_iax_contactos,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_contacto(
      psperson IN NUMBER,
      cagente IN NUMBER,
      pcmodcon IN NUMBER,
      obcontacto OUT ob_iax_contactos,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Esta nueva función se encarga de grabar  un contacto
   return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_set_estcontacto(
      psperson IN NUMBER,
      cagente IN NUMBER,
      pctipcon IN NUMBER,
      ptcomcon IN VARCHAR2,
      tvalcon IN VARCHAR2,
      psmodcon IN NUMBER,
      pcdomici IN NUMBER,   --BUG 24806
      psmodconout OUT NUMBER,
      pcprefix IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_contacto(
      psperson IN NUMBER,
      cagente IN NUMBER,
      pctipcon IN NUMBER,
      ptcomcon IN VARCHAR2,
      tvalcon IN VARCHAR2,
      psmodcon IN NUMBER,
      pcdomici IN NUMBER,   --BUG 24806
      psmodconout OUT NUMBER,
      pcprefix IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_contacto(
      psperson IN NUMBER,
      psmodcon IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_estcontacto(
      psperson IN NUMBER,
      psmodcon IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /* NACIONALIDADES : PER_NACIONALIDADES  **********************************************************/
   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Obtiene el código del pais, nacionalidad por defecto de las tablas EST
   return              : Pais
   *************************************************************************/
   FUNCTION f_get_estnacionalidaddefecto(
      psperson IN NUMBER,
      cagente IN NUMBER,
      cpais OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Obtiene el código del pais, nacionalidad por defecto de las tablas.
   return              : Pais
   *************************************************************************/
   FUNCTION f_get_nacionalidaddefecto(
      psperson IN NUMBER,
      cagente IN NUMBER,
      cpais OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Obtiene las nacionalidades de una persona
   return              : Paises
   *************************************************************************/
   FUNCTION f_get_estnacionalidades(
      psperson IN NUMBER,
      cagente IN NUMBER,
      pnacionalidades OUT t_iax_nacionalidades,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_nacionalidades(
      psperson IN NUMBER,
      cagente IN NUMBER,
      pnacionalidades OUT t_iax_nacionalidades,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Obtiene las nacionalidad de una persona
   return              : Paises
   *************************************************************************/
   FUNCTION f_get_estnacionalidad(
      psperson IN NUMBER,
      pcpais IN NUMBER,
      pcagente IN NUMBER,
      nacionalidad OUT ob_iax_nacionalidades,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_nacionalidad(
      psperson IN NUMBER,
      pcpais IN NUMBER,
      pcagente IN NUMBER,
      nacionalidad OUT ob_iax_nacionalidades,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_estnacionalidad(
      psperson IN NUMBER,
      pcpais IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_nacionalidad(
      psperson IN NUMBER,
      pcpais IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_nacionalidad(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcpais IN NUMBER,
      pcdefecto IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_estnacionalidad(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcpais IN NUMBER,
      pcdefecto IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /* CUENTAS BANCARIAS  : PER_CCC    **********************************************************/
   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Nueva función que recupera la cuenta bancaria que tiene primero se mirará a nivel de póliza,
   si no hay definida se mira a nivel de persona
   return              : 0 si ha ido bien , 1 si ha ido mal
   *************************************************************************/
   FUNCTION f_get_cuentapoliza(
      psperson IN NUMBER,
      cagente IN NUMBER,
      psseguro IN NUMBER,
      pctipban OUT NUMBER,
      cbancar OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_estcuentapoliza(
      psperson IN NUMBER,
      cagente IN NUMBER,
      psseguro IN NUMBER,
      pctipban OUT NUMBER,
      cbancar OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Nueva función que da formato a la cuenta bancaria dependiendo del tipo.
   pcbancar es cbancar pero formateado.
   return              : 0 si ha ido bien , 1 si ha ido mal
   *************************************************************************/
   FUNCTION f_getformatoccc(
      pctipban IN NUMBER,
      cbancar IN VARCHAR2,
      pcbancar OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Nueva función que valida la cuenta bancaria dependiendo del tipo.
   pcbancar es cbancar pero formateado.
   return              : 0 si ha ido bien , 1 si ha ido mal
   *************************************************************************/
   FUNCTION f_validaccc(pctipban IN NUMBER, cbancar IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Esta nueva función se encarga de grabar  el contacto teléfono fijo  en estper_contactos.
   return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_set_contactotlffijo(
      psperson IN NUMBER,
      cagente IN NUMBER,
      tvalcon IN VARCHAR2,
      smodcon IN NUMBER,
      smodconout OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_estcontactotlffijo(
      psperson IN NUMBER,
      cagente IN NUMBER,
      tvalcon IN VARCHAR2,
      smodcon IN NUMBER,
      smodconout OUT NUMBER,
      pcprefix IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Esta nueva función se encarga de grabar  el contacto teléfono móvil  en estper_contactos.
   return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_set_contactotlfmovil(
      psperson IN NUMBER,
      cagente IN NUMBER,
      tvalcon IN VARCHAR2,
      smodcon IN NUMBER,
      smodconout OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_estcontactotlfmovil(
      psperson IN NUMBER,
      cagente IN NUMBER,
      tvalcon IN VARCHAR2,
      smodcon IN NUMBER,
      smodconout OUT NUMBER,
      pcprefix IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Esta nueva función se encarga de grabar  el contacto mail  en estper_contactos.
   return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_set_contactomail(
      psperson IN NUMBER,
      cagente IN NUMBER,
      tvalcon IN VARCHAR2,
      smodcon IN NUMBER,
      smodconout OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_estcontactomail(
      psperson IN NUMBER,
      cagente IN NUMBER,
      tvalcon IN VARCHAR2,
      smodcon IN NUMBER,
      smodconout OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Esta nueva función se encarga de grabar  la nacionalidad por defecto de una persona.
   return              : 0 si ha ido todo bien , 1 en caso contrario.
   *************************************************************************/
   FUNCTION f_set_nacionalidaddefecto(
      psperson IN NUMBER,
      cagente IN NUMBER,
      cpais IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_estnacionalidaddefecto(
      psperson IN NUMBER,
      cagente IN NUMBER,
      cpais IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Esta nueva función se encarga de grabar  la cuenta bancaria  de una persona, será la de por defecto
   si no existe hasta el momento si ya tiene una cuenta bancaria por defecto este campo no se modificará.
   return              : 0 si ha ido todo bien , 1 en caso contrario.
   *************************************************************************/
   FUNCTION f_set_ccc(
      psperson IN NUMBER,
      cagente IN NUMBER,
      cnordban IN NUMBER,
      cnordbanout OUT NUMBER,
      pctipban IN NUMBER,
      cbancar IN VARCHAR2,
      pcdefecto IN NUMBER,
      mensajes OUT t_iax_mensajes,
      pcpagsin IN NUMBER DEFAULT NULL,   -- 19985 LCOL_A001-Control de las matriculas (prenotificaciones)
      pfvencim IN DATE DEFAULT NULL,   -- 19985 LCOL_A001-Control de las matriculas (prenotificaciones)
      ptseguri IN VARCHAR2 DEFAULT NULL,   -- 19985 LCOL_A001-Control de las matriculas (prenotificaciones)
      pctipcc IN VARCHAR2 DEFAULT NULL   -- 20735/102170 Introduccion de cuenta bancaria
                                      )
      RETURN NUMBER;

   FUNCTION f_set_estccc(
      psperson IN NUMBER,
      cagente IN NUMBER,
      cnordban IN NUMBER,
      cnordbanout OUT NUMBER,
      pctipban IN NUMBER,
      cbancar IN VARCHAR2,
      pcdefecto IN NUMBER,
      mensajes OUT t_iax_mensajes,
      pcpagsin IN NUMBER DEFAULT NULL,   -- 19985 LCOL_A001-Control de las matriculas (prenotificaciones)
      pfvencim IN DATE DEFAULT NULL,   -- 19985 LCOL_A001-Control de las matriculas (prenotificaciones)
      ptseguri IN VARCHAR2 DEFAULT NULL,   -- 19985 LCOL_A001-Control de las matriculas (prenotificaciones)
      pctipcc IN VARCHAR2 DEFAULT NULL   -- 20735/102170 Introduccion de cuenta bancaria
                                      )
      RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Nueva función que se encarga de borrar una cuenta bancaria.
   return              : El T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_del_estccc(psperson IN NUMBER, cnordban IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_ccc(psperson IN NUMBER, cnordban IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Nueva función que se encarga de recuperar una cuenta bancaria de una persona.
   return              : El T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_estccc(
      psperson IN NUMBER,
      cnordban IN NUMBER,
      ccc OUT ob_iax_ccc,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_ccc(
      psperson IN NUMBER,
      cnordban IN NUMBER,
      ccc OUT ob_iax_ccc,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Nueva función que se encarga de recuperar las  cuentas bancarias de una persona.
   return              : El T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_estcuentasbancarias(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pccc OUT t_iax_ccc,
      mensajes OUT t_iax_mensajes,
      pctipcc IN NUMBER
            DEFAULT NULL   -- 08/11/2011 JGR 19985 LCOL_A001-Control de las matriculas (prenotificaciones)
                        )
      RETURN NUMBER;

   FUNCTION f_get_cuentasbancarias(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pccc OUT t_iax_ccc,
      mensajes OUT t_iax_mensajes,
      pctipcc IN NUMBER
            DEFAULT NULL   -- 08/11/2011 JGR 19985 LCOL_A001-Control de las matriculas (prenotificaciones)
                        )
      RETURN NUMBER;

   /*************************************************************************
   Obtiene los datos de las EST direcciones en un objeto T_IAX_DIRECCIONES
   param out mensajes  : pDirecciones que es t_iax_direcciones
   return              : El T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_estdirecciones(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pdirecciones OUT t_iax_direcciones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- svj. Bug 5912
   FUNCTION f_get_direcciones(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pdirecciones OUT t_iax_direcciones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Nueva función que se encarga de borrar una dirección.
   return              : El T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_del_estdirecciones(
      psperson IN NUMBER,
      cdomici IN NUMBER,
      ptablas IN VARCHAR2,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_direcciones(
      psperson IN NUMBER,
      cdomici IN NUMBER,
      ptablas IN VARCHAR2,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Obtiene los datos de las EST de una dirección en un objeto OB_IAX_DIRECCIONES
   param out mensajes  : pDirecciones que es t_iax_direcciones
   return              : El T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_estdireccion(
      psperson IN NUMBER,
      cdomici IN NUMBER,
      pdirecciones OUT ob_iax_direcciones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_direccion(
      psperson IN NUMBER,
      cdomici IN NUMBER,
      pdirecciones OUT ob_iax_direcciones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Nueva función que se encarga de realizar las validaciones en la introducción o modificación de una dirección
   return              : El T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_valida_direccion(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pctipdir IN NUMBER,   -- Código del tipo de dirección
      pcsiglas IN NUMBER,   -- Código del tipo de vía
      ptnomvia IN VARCHAR2,   -- Nombre de la vía.
      nnumvia IN NUMBER,
      ptcomple IN VARCHAR2,   -- Otros.
      pcpostal IN VARCHAR2,   --Código postal
      pcpobla IN NUMBER,   --Código población
      pcprovin IN NUMBER,   -- Código de la provincia.
      pcpais IN NUMBER   --Código del país
                      ,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Nueva función que inserta o modifica la dirección de una persona en estper_direcciones.
   return              : El T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_set_estdireccion(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcdomici IN NUMBER,
      pcdomiciout OUT NUMBER,
      pctipdir IN NUMBER,   -- Código del tipo de dirección
      pcsiglas IN NUMBER,   -- Código del tipo de vía
      ptnomvia IN VARCHAR2,   -- Nombre de la vía.
      pnnumvia IN NUMBER,
      ptcomple IN VARCHAR2,   -- Otros.
      pcpostal IN VARCHAR2,   --Código postal
      pcpoblac IN NUMBER,   --Código población
      pcprovin IN NUMBER,   -- Código de la provincia.
      pcpais IN NUMBER,   --Código del país
      -- Bug 18940/92686 - 27/09/2011 - AMC
      pcviavp IN estper_direcciones.cviavp%TYPE,
      pclitvp IN estper_direcciones.clitvp%TYPE,
      pcbisvp IN estper_direcciones.cbisvp%TYPE,
      pcorvp IN estper_direcciones.corvp%TYPE,
      pnviaadco IN estper_direcciones.nviaadco%TYPE,
      pclitco IN estper_direcciones.clitco%TYPE,
      pcorco IN estper_direcciones.corco%TYPE,
      pnplacaco IN estper_direcciones.nplacaco%TYPE,
      pcor2co IN estper_direcciones.cor2co%TYPE,
      pcdet1ia IN estper_direcciones.cdet1ia%TYPE,
      ptnum1ia IN estper_direcciones.tnum1ia%TYPE,
      pcdet2ia IN estper_direcciones.cdet2ia%TYPE,
      ptnum2ia IN estper_direcciones.tnum2ia%TYPE,
      pcdet3ia IN estper_direcciones.cdet3ia%TYPE,
      ptnum3ia IN estper_direcciones.tnum3ia%TYPE,
      -- Fi Bug 18940/92686 - 27/09/2011 - AMC
      plocalidad IN estper_direcciones.localidad%TYPE,   -- Bug 24780/130907 - 05/12/2012 - AMC
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_direccion(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcdomici IN NUMBER,
      pcdomiciout OUT NUMBER,
      pctipdir IN NUMBER,   -- Código del tipo de dirección
      pcsiglas IN NUMBER,   -- Código del tipo de vía
      ptnomvia IN VARCHAR2,   -- Nombre de la vía.
      pnnumvia IN NUMBER,
      ptcomple IN VARCHAR2,   -- Otros.
      pcpostal IN VARCHAR2,   --Código postal
      pcpoblac IN NUMBER,   --Código población
      pcprovin IN NUMBER,   -- Código de la provincia.
      pcpais IN NUMBER,   --Código del país
      -- Bug 18940/92686 - 27/09/2011 - AMC
      pcviavp IN estper_direcciones.cviavp%TYPE,
      pclitvp IN estper_direcciones.clitvp%TYPE,
      pcbisvp IN estper_direcciones.cbisvp%TYPE,
      pcorvp IN estper_direcciones.corvp%TYPE,
      pnviaadco IN estper_direcciones.nviaadco%TYPE,
      pclitco IN estper_direcciones.clitco%TYPE,
      pcorco IN estper_direcciones.corco%TYPE,
      pnplacaco IN estper_direcciones.nplacaco%TYPE,
      pcor2co IN estper_direcciones.cor2co%TYPE,
      pcdet1ia IN estper_direcciones.cdet1ia%TYPE,
      ptnum1ia IN estper_direcciones.tnum1ia%TYPE,
      pcdet2ia IN estper_direcciones.cdet2ia%TYPE,
      ptnum2ia IN estper_direcciones.tnum2ia%TYPE,
      pcdet3ia IN estper_direcciones.cdet3ia%TYPE,
      ptnum3ia IN estper_direcciones.tnum3ia%TYPE,
      -- Fi Bug 18940/92686 - 27/09/2011 - AMC
      plocalidad IN estper_direcciones.localidad%TYPE,   -- Bug 24780/130907 - 05/12/2012 - AMC
      ptalias IN estper_direcciones.talias%TYPE,      -- BUG CONF-441 - 14/12/2016 - JAEG
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Nueva función que se encarga de recuperar la povicincia y población a partir de un codigo postal
   A partir de un código postal obtenemos los codigos de pais, provincia, población y sus respectivas  descripciones.
   return              : 0 si ha ido todo bien 1 si ha ido mal
   bug 33977 mnustes 12-05-2015
   return : 0 si no ha encontrado coincidencias.
   1 si existe algun error.
   2 si existe mas de una provincia, pais o poblacion con el
   codigo postal relacionado.
   *************************************************************************/
   FUNCTION f_get_provinpobla(
      pcpostal IN VARCHAR2,
      cpais OUT NUMBER,
      tpais OUT VARCHAR2,
      cprovin OUT NUMBER,
      tprovin OUT VARCHAR2,
      cpoblac OUT NUMBER,
      tpoblac OUT VARCHAR2,
      pautocalle OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Esta nueva función se encarga de grabar  un identificador de la persona
   return              : 0 si ha ido todo bien , 1 en caso contrario.
   *************************************************************************/
   FUNCTION f_set_identificador(
      psperson IN NUMBER,
      cagente IN NUMBER,
      ctipide IN NUMBER,
      nnumide IN VARCHAR2,
      cdefecto IN NUMBER,
      mensajes OUT t_iax_mensajes,
      -- Bug 22263 - 11/07/2012 - ETM
      paisexp IN NUMBER DEFAULT NULL,
      cdepartexp IN NUMBER DEFAULT NULL,
      cciudadexp IN NUMBER DEFAULT NULL,
      fechaexp IN DATE DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
   Esta nueva función se encarga de modificar un identificador
   return              : 0 si ha ido todo bien , 1 en caso contrario.
   Bug 20441/101686 - 10/01/2012 - AMC
   *************************************************************************/
   FUNCTION f_mod_identificador(
      psperson IN NUMBER,
      cagente IN NUMBER,
      ctipide IN NUMBER,
      nnumide IN VARCHAR2,
      cdefecto IN NUMBER,
      mensajes OUT t_iax_mensajes,
      -- Bug 22263 - 11/07/2012 - ETM
      paisexp IN NUMBER DEFAULT NULL,
      cdepartexp IN NUMBER DEFAULT NULL,
      cciudadexp IN NUMBER DEFAULT NULL,
      fechaexp IN DATE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_set_estidentificador(
      psperson IN NUMBER,
      cagente IN NUMBER,
      ctipide IN NUMBER,
      nnumide IN VARCHAR2,
      cdefecto IN NUMBER,
      mensajes OUT t_iax_mensajes,
      -- Bug 22263 - 11/07/2012 - ETM
      paisexp IN NUMBER DEFAULT NULL,
      cdepartexp IN NUMBER DEFAULT NULL,
      cciudadexp IN NUMBER DEFAULT NULL,
      fechaexp IN DATE DEFAULT NULL)
      RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
   Esta nueva función se encarga de borrar  un identificador de la persona
   return              : 0 si ha ido todo bien , 1 en caso contrario.
   *************************************************************************/
   FUNCTION f_del_identificador(
      psperson IN NUMBER,
      cagente IN NUMBER,
      ctipide IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_estidentificador(
      psperson IN NUMBER,
      cagente IN NUMBER,
      ctipide IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Obtiene los datos de los identificadores en un T_IAX_IDENTIFICADORES
   param out mensajes  : pDirecciones que es t_iax_direcciones
   return              : 0 si ha ido todo bien , 1 en caso contrario.
   *************************************************************************/
   FUNCTION f_get_identificadores(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pidentificadores OUT t_iax_identificadores,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_estidentificadores(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pidentificadores OUT t_iax_identificadores,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Obtiene los datos de un tipo de identificador en un ob_iax_IDENTIFICADORES
   param out mensajes  : pIdentificadores que es ob_iax_IDENTIFICADORES
   return              : 0 si ha ido todo bien , 1 en caso contrario.
   Obtiene los datos de las EST de una dirección en un objeto OB_IAX_DIRECCIONES
   param out mensajes  : pDirecciones que es t_iax_direcciones
   return              : El T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_estidentificador(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      ctipide IN NUMBER,
      pidentificadores OUT ob_iax_identificadores,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_identificador(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      ctipide IN NUMBER,
      pidentificadores OUT ob_iax_identificadores,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_estcuentasvigentes(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfvigente IN DATE,
      pcc OUT t_iax_ccc,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_cuentasvigentes(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfvigente IN DATE,
      pcc OUT t_iax_ccc,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Recupera la lista de valores del desplegable TIPOS CONTACTOS
   param out mensajes : mensajes de error
   return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipcontactos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funció que recupera les pòlisses en el que la persona és prenedor
   return : cursor con el resultado
   *************************************************************************/
   FUNCTION f_get_poltom(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funció que recupera les pòlisses en el que la persona és assegurat
   return : cursor con el resultado
   *************************************************************************/
   FUNCTION f_get_polase(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Traspasa a las EST las cuentas banacarias de una persona
   param in: psperson real ,
   pficticia_sperson, persona de la tabla est
   param out: mensajes de error
   *************************************************************************/
   FUNCTION traspaso_ccc(
      psseguro IN NUMBER,
      psperson IN per_personas.sperson%TYPE,
      pficticia_sperson IN estper_personas.sperson%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- DRA 13-10-2008: bug mantis 7784
   FUNCTION f_get_cagente(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_persona_origen_int(
      psperson IN estper_personas.sperson%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_direccion_origen_int(
      psperson IN estper_direcciones.sperson%TYPE,
      pcdomici IN estper_direcciones.cdomici%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_direccion_trecibido(
      psperson IN estper_direcciones.sperson%TYPE,
      pcdomici IN estper_direcciones.cdomici%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   función que a partir de un sperson te devuelve los detalles
   de la persona, según el nivel de visión del usuario
   que esta consultando.
   *************************************************************************/
   FUNCTION f_get_agentes_vision(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   función que devuelve la colección de tipo t_iax_irpf
   *************************************************************************/
   FUNCTION f_get_irpfs(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pirpfs OUT t_iax_irpf,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   función que devuelve el objeto ob_iax_irpf a partir de BBDD
   *************************************************************************/
   FUNCTION f_get_irpf(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      pirpf OUT ob_iax_irpf,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   función que traspasa los datos del IRPF al objeto persistente
   *************************************************************************/
   FUNCTION f_inicializa_obirpf(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   función que devuelve el objeto ob_iax_irpf persistente en memoria
   *************************************************************************/
   FUNCTION f_get_objetoirpf(pirpf OUT ob_iax_irpf, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   función graba en una variable global de la capa IAX los valores del objeto
   irpfdescen
   bug 12716 - 25/03/2010 - AMC - Se añade el parametro pfadopcion
   *************************************************************************/
   FUNCTION f_set_objetoirpfdescen(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      pnorden IN NUMBER,
      pfnacimi IN DATE,
      pfadopcion IN DATE,
      pcgrado IN NUMBER,
      pcenter IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   función borra de l'objecte persistent un irpfdescen
   *************************************************************************/
   FUNCTION f_del_objetoirpfdescen(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      pnorden IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   función graba en una variable global de la capa IAX los valores del objeto
   irpfmayores
   *************************************************************************/
   FUNCTION f_set_objetoirpfmayores(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      pnorden IN NUMBER,
      pfnacimi IN DATE,
      pcgrado IN NUMBER,
      pnviven IN NUMBER,
      pcrenta IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   función borra de l'objecte persistent un irpfmayor
   *************************************************************************/
   FUNCTION f_del_objetoirpfmayor(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      pnorden IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   función borra todo el objeto irpf de bbdd
   *************************************************************************/
   FUNCTION f_del_irpf(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   función graba todo el objeto irpf a bbdd
   bug 12716 - 29/03/2010 - AMC - Se añaden los parametros pfmovgeo y pcpago
   *************************************************************************/
   FUNCTION f_set_irpf(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      pcsitfam IN NUMBER,
      pcnifcon IN VARCHAR2,
      pcgrado IN NUMBER,
      pcayuda IN NUMBER,
      pipension IN NUMBER,
      pianuhijos IN NUMBER,
      pprolon IN NUMBER,
      prmovgeo IN NUMBER,
      pfmovgeo IN DATE,
      pcpago IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   función que devuelve número de años para declarar el irpf de una persona,
   si la persona existe se le devolverá el máximo más uno sino existiera se
   le devolvería el actual año
   *************************************************************************/
   FUNCTION f_get_anysirpf(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnanos OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   función que recupera el objeto persistente ob_iax_irpf.mayores y ob_iax_irpf.descendientes
   *************************************************************************/
   FUNCTION f_get_objetos_asc_desc(
      pirpfmayores OUT t_iax_irpfmayores,
      pirpfdescen OUT t_iax_irpfdescen,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   función que recuperará todas la personas dependiendo del modo.
   publico o no. servirá para todas las pantallas donde quieran utilizar el
   buscador de personas.
   *************************************************************************/
   FUNCTION f_get_personas_generica(
      numide IN VARCHAR2,
      nombre IN VARCHAR2,
      nsip IN VARCHAR2 DEFAULT NULL,
      mensajes OUT t_iax_mensajes,
      pnom IN VARCHAR2 DEFAULT NULL,
      pcognom1 IN VARCHAR2 DEFAULT NULL,
      pcognom2 IN VARCHAR2 DEFAULT NULL,
      pctipide IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL,
      pmodo_swpubli IN VARCHAR2)
      RETURN sys_refcursor;

   /*************************************************************************
   Obtiene los datos de una persona pasandole el nif, sexo, fecha nacimiento y swipubli
   param out mensajes  : mensajes de error
   return              : El OB_IAX_PERSONA
   *************************************************************************/
   FUNCTION f_get_personaunica_generica(
      pctipper IN NUMBER,
      pctipide IN NUMBER,
      pnnumnif IN VARCHAR2,
      pcsexper IN NUMBER,
      fnacimi IN DATE,   -- Fecha de nacimiento de la persona
      pmodo IN VARCHAR2,
      psseguro IN NUMBER,
      pcagente IN NUMBER,
      pswpubli IN NUMBER,
      obpersona OUT ob_iax_personas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- ini t.8063
   /*************************************************************************
   función que recuperará todas la personas publicas
   con sus detalles según el nivel de visión
   del usuario que este consultando.
   *************************************************************************/
   FUNCTION f_get_personas_publicas(
      numide IN VARCHAR2,
      nombre IN VARCHAR2,
      nsip IN VARCHAR2 DEFAULT NULL,
      mensajes OUT t_iax_mensajes,
      pnom IN VARCHAR2 DEFAULT NULL,
      pcognom1 IN VARCHAR2 DEFAULT NULL,
      pcognom2 IN VARCHAR2 DEFAULT NULL,
      pctipide IN NUMBER DEFAULT NULL)
      RETURN sys_refcursor;

   /*************************************************************************
   Obtiene los datos de las EST en un objeto OB_IAX_PERSONA
   param out mensajes  : mensajes de error
   return              : El OB_IAX_PERSONA
   *************************************************************************/
   FUNCTION f_get_persona_publica(
      psperson IN NUMBER,
      obpersona OUT ob_iax_personas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- fin t.8063
   --BUG 10074 - JTS - 18/05/2009
   /*************************************************************************
   Obté els profesionals associats a una persona
   param in psperson   : Codi sperson
   param out pcur      : Cursor amb les dades
   param out mensajes  : mensajes de error
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_profesionales(
      psperson IN NUMBER,
      pcur OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Obté les companyies associades a una persona
   param in psperson   : Codi sperson
   param out pcur      : Cursor amb les dades
   param out mensajes  : mensajes de error
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_companias(
      psperson IN NUMBER,
      pcur OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Obté els agents associats a una persona
   param in psperson   : Codi sperson
   param out pcur      : Cursor amb les dades
   param out mensajes  : mensajes de error
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_agentes(
      psperson IN NUMBER,
      pcur OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Obté els sinistres associats a una persona
   param in psperson   : Codi sperson
   param out pcur      : Cursor amb les dades
   param out mensajes  : mensajes de error
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_siniestros(
      psperson IN NUMBER,
      pcur OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --Fi BUG 10074 - JTS - 18/05/2009
   /*************************************************************************
   Obté la select amb els paràmetres per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in ptots      : 0.- Només retorna els paràmetres contestats
   1.- Retorna tots els paràmetres
   param in pctipper   : Codi tipus persona
   param out pcur      : Cursor
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_estparpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcvisible IN NUMBER,
      ptots IN NUMBER,
      pctipper IN NUMBER,
      pparper OUT t_iax_par_personas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --BUG 10371 - JTS - 09/06/2009
   /*************************************************************************
   Obté la select amb els paràmetres per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in ptots      : 0.- Només retorna els paràmetres contestats
   1.- Retorna tots els paràmetres
   param out pcur      : Cursor
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_parpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcvisible IN NUMBER,
      ptots IN NUMBER,
      pcur OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Obté la select amb els paràmetres per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in ptots      : 0.- Només retorna els paràmetres contestats
   1.- Retorna tots els paràmetres
   param out pcur      : Cursor
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_parpersona_ob(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcvisible IN NUMBER,
      ptots IN NUMBER,
      ptablas IN VARCHAR2,
      pparper OUT t_iax_par_personas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Inserta el paràmetre per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in pcparam    : Codi parametre
   param in pnvalpar   : Resposta numérica
   param in ptvalpar   : Resposta text
   param in pfvalpar   : Resposta data
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_ins_parpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      pnvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Inserta el paràmetre per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in pcparam    : Codi parametre
   param in pnvalpar   : Resposta numérica
   param in ptvalpar   : Resposta text
   param in pfvalpar   : Resposta data
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_ins_estparpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      pnvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Esborra el paràmetre per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in pcparam    : Codi parametre
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_del_parpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Esborra el paràmetre per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in pcparam    : Codi parametre
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_del_estparpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Inserta el paràmetre per persona
   param in psperson   : Codi sperson
   param in pcagente   : Codi agent
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_grabar_parpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --Fi BUG 10371 - JTS - 09/06/2009
   -- Bug 11165 - 16/09/2009 - AMC - Se sustituñe  T_iax_saldodeutorseg por t_iax_prestamoseg
   -- Bug 11165 - 16/09/2009 - AMC - Se sustituñe  T_iax_saldodeutorseg por t_iax_prestamoseg
   FUNCTION f_get_ctr_prestamoseg_host(
      pnriesgo IN NUMBER,
      pmodo IN VARCHAR2,
      pt_prestamoseg OUT t_iax_prestamoseg,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Recupera los contratos en HOST para una persona
   param in psperson  : identificador de persona
   param in porigen   : identificador de origen
   param out mensajes : mensajes de error
   return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_contratos_host(
      pmodo IN VARCHAR2,
      pt_prestamo OUT t_iax_prestamoseg,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Recupera Sperson del últim prenedor
   param out mensajes : mensajes de error
   return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_spersoncontratos(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- bug 11948.16/11/2009.NMM.i.
   FUNCTION f_traspasapersonapol(
      psperson IN NUMBER,
      psnip IN VARCHAR2,
      pcagente_in IN NUMBER,
      pcagente OUT NUMBER,
      pcoditabla IN VARCHAR2,
      psperson_out OUT NUMBER,
      psseguro IN NUMBER,
      pmensapotup OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- bug 11948.16/11/2009.NMM.f.
   /*************************************************************************
   Recupera las ccc en HOST con las cuentas de axis si esa persona ya esta traspasada.
   Solo personas que pertenecen a una póliza, es decir las personas no públicas no las devuelve
   param in nsip      : identificador externo de persona
   param in psperson      : identificador interno de persona
   param in porigen      : De que tablas extraer la información
   param out mensajes : mensajes de error
   return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_ccc_host_axis(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      psnip IN VARCHAR2,
      porigen IN VARCHAR2,
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_existe_ccc(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcbancar IN VARCHAR2,
      pctipban IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_existe_persona(
      ppnnumide IN VARCHAR2,
      ppcsexper IN NUMBER,
      ppfnacimi IN DATE,
      psperson_new OUT NUMBER,
      ppsnip IN VARCHAR2,
      ppspereal IN NUMBER,
      ppcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION función que crea un detalle sinó existe la persona con el detalle del agente
   que le estamos pasando
   param in psperson    : Persona de la qual el detalle vamos a duplicar
   param in pcagente    : Agente del qual hemos obtenido el detalle
   param in pcagente_prod : Agente del siniestros que estamos trabajando
   return           : código de error
   ---- Bug 16753: CRE - Pantalla destinatarios - 22/11/2010 - XPL
   *************************************************************************/
   FUNCTION f_inserta_detalle_per(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcagente_prod IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION función que nos comprueba si la persona tiene el mismo nnumide
   param in pnnumide    : Nnumide que vamos a comprobar
   param out pduplicada : Miramos si esta duplicada
   return           : código de error
   ---- Bug 17563 : AGA800 - data naixement - 08/03/2011 - XPL
   *************************************************************************/
   FUNCTION f_persona_duplicada(
      psperson IN NUMBER,
      pnnumide IN VARCHAR2,
      pcsexper IN NUMBER,
      pfnacimi IN DATE,
      psnip IN VARCHAR2,
      pcagente IN NUMBER,
      pswpubli IN NUMBER,
      pctipide IN NUMBER,
      pduplicada OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION que devuelve el nif, en el caso que sea un identificador interno
   param in psperson    : código interno
   param in pctipide    : tipo documento
   param in pnnumide    : Nnumide que vamos a comprobar
   param in psnip    : SNIP
   param out  pnnumide_out : nif de salida
   return           : código de error
   ---- Bug 17563 : AGA800 - data naixement - 08/03/2011 - XPL
   *************************************************************************/
   FUNCTION f_get_nif(
      psperson IN NUMBER,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      psnip IN VARCHAR2,
      pnnumide_out OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Nueva función que se encarga de borrar una persona relacionada
   return              : 0 Ok. 1 Error
   Bug.: 18941
   *************************************************************************/
   FUNCTION f_del_persona_rel(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      psperson_rel IN NUMBER,
      pcagrupa IN NUMBER, --IAXIS-3670 16/04/2019 AP
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Nueva función que se encarga de insertar una persona relacionada
   return              : 0 Ok. 1 Error
   Bug.: 18941
   *************************************************************************/
   FUNCTION f_set_persona_rel(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      psperson_rel IN NUMBER,
      pctipper_rel IN NUMBER,
      ppparticipacion IN NUMBER,
      pislider IN NUMBER,   -- BUG 0030525 - FAL - 01/04/2014
	  ptlimit IN VARCHAR2 DEFAULT '',
	  pcagrupa IN NUMBER,
      pfagrupa IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Nueva función que se encarga de borrar un régimen fiscal
   return              : 0 Ok. 1 Error
   Bug.: 18942
   *************************************************************************/
   FUNCTION f_del_regimenfiscal(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfefecto IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Nueva función que se encarga de insertar el régimen fiscal
   return              : 0 Ok. 1 Error
   Bug.: 18942
   *************************************************************************/
   FUNCTION f_set_regimenfiscal(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfefecto IN DATE,
      pcregfiscal IN NUMBER,
      pcregfisexeiva IN NUMBER DEFAULT 0,   -- AP CONF-190
      pctipiva IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Nueva función que se encarga de insertar el régimen fiscal en las tablas est
   return              : 0 Ok. 1 Error
   Bug.: 20835 XPL#05012011
   *************************************************************************/
   FUNCTION f_set_estregimenfiscal(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfefecto IN DATE,
      pcregfiscal IN NUMBER,
      pctipiva IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Nueva funcion que se encarga de borrar un registro de SARLAFT
   return              : 0 Ok. 1 Error
   Bug.: 18943
   *************************************************************************/
   FUNCTION f_del_sarlaft(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfefecto IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Nueva funcion que se encarga de insertar un registro de SARLAFT
   return              : 0 Ok. 1 Error
   Bug.: 18943
   *************************************************************************/
   FUNCTION f_set_sarlaft(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfefecto IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Nueva funcion que obtiene información de los gestores/empleados de la persona
   param in psperson   : Codigo sperson
   param out pcur      : Cursor con la informacion
   param out mensajes  : mensajes de error
   return              : 0.- OK, 1.- KO
   Bug 18947
   *************************************************************************/
   FUNCTION f_get_gestores_empleados(
      psperson IN NUMBER,
      pcur OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Nueva funcion que obtiene información de los representantes/promotores de la persona
   param in psperson   : Codigo sperson
   param out pcur      : Cursor con la informacion
   param out mensajes  : mensajes de error
   return              : 0.- OK, 1.- KO
   Bug 18947
   *************************************************************************/
   FUNCTION f_get_represent_promotores(
      psperson IN NUMBER,
      pcur OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Nueva funcion que obtiene información de los representantes/promotores asociados a un coordinador
   param in psperson   : Codigo sperson
   param out pcur      : Cursor con la informacion
   param out mensajes  : mensajes de error
   return              : 0.- OK, 1.- KO
   Bug 18947
   *************************************************************************/
   FUNCTION f_get_coordinadores(
      psperson IN NUMBER,
      pcur OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Nueva funcion que obtiene información de las listas oficiales del estado de la persona
   param in psperson   : Codigo sperson
   param in pcclalis   : Identificador de clase de lista
   param out pcur      : Cursor con la informacion
   param out mensajes  : mensajes de error
   return              : 0.- OK, 1.- KO
   Bug 18947
   *************************************************************************/
   FUNCTION f_get_listas_oficiales(
      psperson IN NUMBER,
      pcclalis IN NUMBER,
      pcur OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Recupera lista tipos cuentas bancarias
   --------------------------------------------------------------------
   Versión duplicada de PAC_IAX_LISTVALORES.f_get_tipccc, por problemas
   de bloqueos de fuentes, la intención es que más adelante solo exista
   la función orginal de PAC_IAX_LISTVALORES y eliminar esta.
   --------------------------------------------------------------------
   param out mensajes : mensajes de error
   return             : ref cursor
   16.0  08/11/2011 0019985 LCOL_A001-Control de las matriculas (prenotificaciones)
   *************************************************************************/
   FUNCTION f_get_tipccc(mensajes OUT t_iax_mensajes, pctipocc NUMBER DEFAULT NULL)
      RETURN sys_refcursor;

   /*************************************************************************
   función que recuperará todas la personas dependiendo del modo.
   publico o no. servirá para todas las pantallas donde quieran utilizar el
   buscador de personas.
   Bug 20044/97773 - 12/11/2011 - AMC
   *************************************************************************/
   FUNCTION f_get_personas_generica_cond(
      numide IN VARCHAR2,
      nombre IN VARCHAR2,
      nsip IN VARCHAR2 DEFAULT NULL,
      mensajes OUT t_iax_mensajes,
      pnom IN VARCHAR2 DEFAULT NULL,
      pcognom1 IN VARCHAR2 DEFAULT NULL,
      pcognom2 IN VARCHAR2 DEFAULT NULL,
      pctipide IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL,
      pmodo_swpubli IN VARCHAR2,
      pccondicion IN VARCHAR2)
      RETURN sys_refcursor;

   /*************************************************************************
   Función que inserta o actualiza los datos de un documento asociado a la persona
   Bug 20126 - APD - 23/11/2011 - se crea la funcion
   *************************************************************************/
   FUNCTION f_set_docpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      ptfilename IN VARCHAR2,
      piddocgedox IN NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      ptdocumento IN NUMBER DEFAULT NULL,
      pedocumento IN NUMBER DEFAULT NULL,
      pfedo IN DATE DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Función que recupera los datos de un documento asociado a la persona
   Bug 20126 - APD - 23/11/2011 - se crea la funcion
   *************************************************************************/
   FUNCTION f_get_docpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      piddocgedox IN NUMBER,
      ptablas IN VARCHAR2,
      pobdocpersona OUT ob_iax_docpersona,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***************************************************************************
   Funcin para obtener el dgito de control del documento de identidad de Colombia
   Tipos de documento a los que puede aplicar calcular el dgito de control
   Tipo de Documento ------------------- Tipo -------- Regla de validacin - Tamao -----
   36 - Cdula ciudadana                Numrico      Nmeros               Entre 3 y 10
   *****************************************************************************/
   FUNCTION f_digito_nif_col(
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /**************************************************************
   Funci que valida que si hay una ccc con pagos de siniestros
   param in psperson : codigo de persona
   param in pcagente : codigo del agente
   param out pcodilit : codigo del literal a mostrar
   param out : mensajes de error
   return codigo error : 0 - ok ,codigo de error
   BUG 20958/104928 - 24/01/2012 - AMC
   Bug 21867/111852 - 29/03/2012 - AMC
   **************************************************************/
   FUNCTION f_valida_pagoccc(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcnordban IN NUMBER,
      pcodilit OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***************************************************************************
   Funcin bloquear una persona por LOPD
   Traspasar los datos de la persona a las tablas LOPD
   *****************************************************************************/
   FUNCTION f_bloquear_persona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***************************************************************************
   Funcin desbloquear una persona por LOPD
   Volver a deja la persona igual que antes que el traspaso a las tablas LOPD
   *****************************************************************************/
   FUNCTION f_desbloquear_persona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/***************************************************************************
Funcin borra persona de la lopd
*****************************************************************************/
   FUNCTION f_borrar_persona_lopd(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*Retorna l'ultim registre de la lopd per aquesta persona i agent*/
   FUNCTION f_get_perlopd(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pobperlopd OUT ob_iax_perlopd,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***************************************************************************
   Funcin inserta un nuevo movimiento a la LOPD
   *****************************************************************************/
   FUNCTION f_set_persona_lopd(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcesion IN NUMBER,
      ppublicidad IN NUMBER,
      pacceso IN NUMBER,
      prectificacion IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************
   Funci?ra obtener la lista de autorizaciones de contactos y la lista de autorizaciones de direcciones
   param in psperson : codigo de persona
   param in pcagente : codigo del agente
   return lista de autorizaciones
   BUG 18949/103391 - 03/02/2012 - AMC
   **************************************************************/
   FUNCTION f_get_autorizaciones(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_personas_aut;

   /**************************************************************
   Funci?ra obtener la lista de autorizaciones de contactos
   param in psperson : codigo de persona
   param in pcagente : codigo del agente
   return codigo error : 0 - ok ,codigo de error
   BUG 18949/103391 - 02/02/2012 - AMC
   **************************************************************/
   FUNCTION f_get_contacto_aut(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcmodcon IN NUMBER,
      pnorden IN NUMBER,
      obcontacto_aut OUT ob_iax_contactos_aut,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************
   Funci?ra obtener la lista de autorizaciones de direcciones
   param in psperson : codigo de persona
   param in pcagente : codigo del agente
   param in pcdomic : codigo del domicilio
   param in pnorden : numero de orden
   param out obdireccion_aut
   param out mensajes
   return codigo error : 0 - ok ,codigo de error
   BUG 18949/103391 - 02/02/2012 - AMC
   **************************************************************/
   FUNCTION f_get_direccion_aut(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcdomici IN NUMBER,
      pnorden IN NUMBER,
      obdireccion_aut OUT ob_iax_direcciones_aut,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************
   Funci?ra guardar los contactos
   param in psperson : codigo de persona
   param in pcagente : codigo del agente
   param in pcmodcon : codigo del contacto
   param in pnorden : numero de orden
   param in pcestado : Codigo del estado
   param in ptobserva : Observaciones
   param out mensajes
   return codigo error : 0 - ok ,codigo de error
   BUG 18949/103391 - 02/02/2012 - AMC
   **************************************************************/
   FUNCTION f_set_contacto_aut(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcmodcon IN NUMBER,
      ptmodcon IN VARCHAR2,
      pnorden IN NUMBER,
      pcestado IN NUMBER,
      ptobserva IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************
   Funci?ra guardar las direcciones
   param in psperson : codigo de persona
   param in pcagente : codigo del agente
   param in pcdomici: codigo de la direccion
   param in pnorden : numero de orden
   param in pcestado : Codigo del estado
   param in ptobserva : Observaciones
   param out mensajes
   return codigo error : 0 - ok ,codigo de error
   BUG 18949/103391 - 03/02/2012 - AMC
   **************************************************************/
   FUNCTION f_set_direccion_aut(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcdomici IN NUMBER,
      pnorden IN NUMBER,
      pcestado IN NUMBER,
      ptobserva IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --IN iBUG 22642 -- ETM --24/07/2012
   /*************************************************************************
   FUNCION f_get_inquiaval
   Obtiene la select con los inquilinos avalistas
   param in psperson   : Codi sperson
   param in pctipfig    : Codi id de avalista o inqui(1 inquilino , 2 Avalista )
   param out pcur      : Cursor amb les dades
   param out mensajes  : mensajes de error
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_inquiaval(
      psperson IN NUMBER,
      pctipfig IN NUMBER,   -- 1 inquilino , 2 Avalista Desde java le pasamos el tipo
      pcur OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************
   FUNCION f_get_gescobro
   Obtiene la select con los gestores de cobro
   param in psperson   : Codi sperson
   param out pcur   : cursor con los datos de lo gestores
   param out mensajes
   return              : 0.- OK, 1.- KO
   **************************************************************/
   FUNCTION f_get_gescobro(
      psperson IN NUMBER,
      pcur OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --FIN BUG 22642 -- ETM --24/07/2012
   /*************************************************************************
   Funcion que recupera la informacion de la antiguedad de la persona
   return : cursor con el resultado
   *************************************************************************/
   -- Bug 25542 - APD - se crea la funcion
   FUNCTION f_get_antiguedad(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************
   funcion que devuelve los conductores
   **************************************************************/
   FUNCTION f_get_conductores(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   funcion que retorna la informacion de paises, provincias y poblaciones
   con un numero de codigo postal en comun.
   param pcpostal : codigo postal relacionado
   param mensajes : mensajes registrados en el proceso
   return : cursor con el resultado
   Bug 33977 mnustes
   *************************************************************************/
   FUNCTION f_get_provinpoblapais(
      pcpostal IN codpostal.cpostal%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   funcion que retorna la informacion de codigo postal por medio de los
   parametros pais, provincia, poblacion.
   param pcpais : codigo de pais
   param pcprovin : codigo de provincia
   param pcpoblac : codigo de poblacion
   param mensajes : mensajes registrados en el proceso
   return : cursor con el resultado
   Bug 33977 mnustes
   *************************************************************************/
   FUNCTION f_get_codpostal(
      pcpais IN despaises.cpais%TYPE,
      pcprovin IN provincias.cprovin%TYPE,
      pcpoblac IN poblaciones.cpoblac%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************
   funcion que devuelve CODISOTEL en la tabla paises
   **************************************************************/
   FUNCTION f_get_prefijospaises(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_estparpersonas(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcvisible IN NUMBER,
      ptots IN NUMBER,
      pcur OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Inserta el paràmetre per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in pcparam    : Codi parametre
   param in pnvalpar   : Resposta numérica
   param in ptvalpar   : Resposta text
   param in pfvalpar   : Resposta data
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_ins_estparpersonas(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      pnvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_estparpersonas(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --Ini AP CONF-190
   FUNCTION f_get_regimenfiscal(
      pcagente IN NUMBER,
      poregimenfiscal OUT ob_iax_regimenfiscal,
      mensajes OUT t_iax_mensajes,
      ptablas IN VARCHAR2)
      RETURN NUMBER;
--Fi AP CONF-190
FUNCTION f_del_datsarlatf(
      pssarlaft IN NUMBER,
      pfradica IN DATE,
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_datsarlatf(
      pssarlaft IN NUMBER,
      pfradica IN DATE,
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_datsarlatf(
      pssarlaft IN NUMBER,
      pfradica IN DATE,
      psperson IN NUMBER,
      pfdiligencia IN DATE,
      pcauttradat IN NUMBER,
      pcrutfcc IN NUMBER,
      pcestconf IN NUMBER,
      pfconfir IN DATE,
      pcvinculacion IN NUMBER,
      ptvinculacion IN VARCHAR2,
      per_cdeptosol IN NUMBER,
      per_tdeptosol IN VARCHAR2,
      per_cciusol IN NUMBER,
      per_tciusol IN VARCHAR2,
      pcvintomase IN NUMBER,
      ptvintomase IN VARCHAR2,
      pcvintomben IN NUMBER,
      ptvintombem IN VARCHAR2,
      pcvinaseben IN NUMBER,
      ptvinasebem IN VARCHAR2,
      pcactippal IN NUMBER,
      ppersectorppal IN NUMBER,
      pnciiuppal IN NUMBER,
      ptcciiuppal IN VARCHAR2,
      ppertipoactivppal IN VARCHAR2,
      ptocupacion IN VARCHAR2,
      ptcargo IN VARCHAR2,
      ptempresa IN VARCHAR2,
      ptdirempresa IN VARCHAR2,
      ppercdeptoofic IN NUMBER,
      ppertdeptoofic IN VARCHAR2,
      ppercciuofic IN NUMBER,
      ppertciuofic IN VARCHAR2,
      pttelempresa IN VARCHAR2,
      pcactisec IN NUMBER,
      pnciiusec IN NUMBER,
      ptcciiusec IN VARCHAR2,
      ptdirsec IN VARCHAR2,
      pttelsec IN VARCHAR2,
      ptprodservcom IN VARCHAR2,
      piingresos IN NUMBER,
      piactivos IN NUMBER,
      pipatrimonio IN NUMBER,
      piegresos IN NUMBER,
      pipasivos IN NUMBER,
      piotroingreso IN NUMBER,
      ptconcotring IN VARCHAR2,
      pcmanrecpub IN NUMBER,
      pcpodpub IN NUMBER,
      pcrecpub IN NUMBER,
      pcvinperpub IN NUMBER,
      ptvinperpub IN VARCHAR2,
      pcdectribext IN NUMBER,
      ptdectribext IN VARCHAR2,
      ptorigfond IN VARCHAR2,
      pctraxmodext IN NUMBER,
      pttraxmodext IN VARCHAR2,
      pcprodfinext IN NUMBER,
      pcctamodext IN NUMBER,
      ptotrasoper IN VARCHAR2,
      pcreclindseg IN NUMBER,
      ptciudadsuc IN NUMBER,
      ptpaisuc IN NUMBER,
      ptdepatamentosuc IN NUMBER,
      ptciudad IN NUMBER,
      ptdepatamento IN NUMBER,
      ptpais IN NUMBER,
      ptlugarexpedidoc IN NUMBER,
      presociedad IN NUMBER,
      ptnacionali2 IN NUMBER,
      pngradopod IN NUMBER,
      pngozrec IN NUMBER,
      pnparticipa IN NUMBER,
      pnvinculo IN NUMBER,
      pntipdoc IN NUMBER,
      pfexpedicdoc IN DATE,
      pfnacimiento IN DATE,
      pnrazonso IN VARCHAR2,
      ptnit IN VARCHAR2,
      ptdv IN VARCHAR2,
      ptoficinapri IN VARCHAR2,
      pttelefono IN VARCHAR2,
      ptfax IN VARCHAR2,
      ptsucursal IN VARCHAR2,
      pttelefonosuc IN VARCHAR2,
      ptfaxsuc IN VARCHAR2,
      pctipoemp IN VARCHAR2,
      ptcualtemp IN VARCHAR2,
      ptsector IN VARCHAR2,
      pcciiu IN NUMBER,
      ptactiaca IN VARCHAR2,
      ptmailjurid IN VARCHAR2,
      ptrepresentanle IN VARCHAR2,
      ptsegape IN VARCHAR2,
      ptnombres IN VARCHAR2,
      ptnumdoc IN VARCHAR2,
      ptlugnaci IN VARCHAR2,
      ptnacionali1 IN VARCHAR2,
      ptindiquevin IN VARCHAR2,
      pper_papellido IN VARCHAR2,
      pper_sapellido IN VARCHAR2,
      pper_nombres IN VARCHAR2,
      pper_tipdocument IN NUMBER,
      pper_document IN VARCHAR2,
      pper_fexpedicion IN DATE,
      pper_lugexpedicion IN NUMBER,
      pper_fnacimi IN DATE,
      pper_lugnacimi IN NUMBER,
      pper_nacion1 IN NUMBER,
      pper_direreci IN VARCHAR2,
      pper_pais IN NUMBER,
      pper_ciudad IN NUMBER,
      pper_departament IN NUMBER,
      pper_email IN VARCHAR2,
      pper_telefono IN VARCHAR2,
      pper_celular IN VARCHAR2,
      pnrecpub IN NUMBER,
      ptpresetreclamaci IN NUMBER,
      pper_tlugexpedicion IN VARCHAR2,
      pper_tlugnacimi IN VARCHAR2,
      pper_tnacion1 IN VARCHAR2,
      pper_tnacion2 IN VARCHAR2,
      pper_tpais IN VARCHAR2,
      pper_tdepartament IN VARCHAR2,
      pper_tciudad IN VARCHAR2,
      pemptpais IN VARCHAR2,
      pemptdepatamento IN VARCHAR2,
      pemptciudad IN VARCHAR2,
      pemptpaisuc IN VARCHAR2,
      pemptdepatamentosuc IN VARCHAR2,
      pemptciudadsuc IN VARCHAR2,
      pemptlugnaci IN VARCHAR2,
      pemptnacionali1 IN VARCHAR2,
      pemptnacionali2 IN VARCHAR2,
      pcsujetooblifacion IN NUMBER,
      ptindiqueoblig IN VARCHAR2,
      pper_paisexpedicion IN NUMBER,
      pper_tpaisexpedicion IN VARCHAR2,
      pper_depexpedicion IN NUMBER,
      pper_tdepexpedicion IN VARCHAR2,
      pper_paislugnacimi IN NUMBER,
      pper_tpaislugnacimi IN VARCHAR2,
      pper_deplugnacimi IN NUMBER,
      pper_tdeplugnacimi IN VARCHAR2,
      pemp_paisexpedicion IN NUMBER,
      pemp_tpaisexpedicion IN VARCHAR2,
      pemp_depexpedicion IN NUMBER,
      pemp_tdepexpedicion IN VARCHAR2,
      pemp_paislugnacimi IN NUMBER,
      pemp_tpaislugnacimi IN VARCHAR2,
      pemp_deplugnacimi IN NUMBER,
      pemp_tdeplugnacimi IN VARCHAR2,
      pemp_lugnacimi IN NUMBER,
      pemp_tlugnacimi IN VARCHAR2,
      pemp_fexpedicion IN DATE,
      pemp_lugexpedicion IN NUMBER,
      pemp_tlugexpedicion IN VARCHAR2,
      pper_nacion2 IN NUMBER,
      pper_pcciusol IN NUMBER DEFAULT NULL,
      pper_pcsucursal IN NUMBER, --CP0615M_SYS_PERS AP 28/12/2018
      pper_pctipsol IN NUMBER DEFAULT NULL,
      pper_pcsector IN NUMBER DEFAULT NULL,
      pper_pctipact IN VARCHAR2 DEFAULT NULL,
      pper_pcciuofc IN NUMBER DEFAULT NULL,
      pper_pcdepofc IN NUMBER DEFAULT NULL,
      pemp_tmailrepl	IN VARCHAR2  DEFAULT NULL,
      pemp_tdirsrepl IN VARCHAR2 DEFAULT NULL,
      pemp_cciurrepl IN NUMBER DEFAULT NULL,
      pemp_tciurrepl IN VARCHAR2,
      pemp_cdeprrepl IN NUMBER DEFAULT NULL,
      pemp_tdeprrepl IN VARCHAR2,
      pemp_cpairrepl IN NUMBER DEFAULT NULL,
      pemp_tpairrepl IN VARCHAR2,
      pemp_ttelrepl	IN NUMBER DEFAULT NULL,
      pemp_tcelurepl IN NUMBER DEFAULT NULL,
      pcdeptoentrev IN NUMBER DEFAULT NULL,
      ptdeptoentrev IN VARCHAR2,
      pcciuentrev  IN NUMBER DEFAULT NULL,
      ptciuentrev IN VARCHAR2,
      pfentrevista IN DATE DEFAULT NULL,
      pthoraentrev IN VARCHAR2 DEFAULT NULL,
      ptagenentrev IN VARCHAR2 DEFAULT NULL,
      ptasesentrev IN VARCHAR2 DEFAULT NULL,
      ptobseentrev IN VARCHAR2 DEFAULT NULL,
      pcrestentrev IN NUMBER DEFAULT NULL,
      ptobseconfir IN VARCHAR2 DEFAULT NULL,
      pthoraconfir IN VARCHAR2 DEFAULT NULL,
      ptemplconfir IN VARCHAR2 DEFAULT NULL,
	  pcorigenfon  IN VARCHAR2 DEFAULT NULL,
      pcclausula1  IN NUMBER DEFAULT NULL, --TCS-9 AP 12/02/2019
      pcclausula2  IN NUMBER DEFAULT NULL, --TCS-9 AP 12/02/2019
      pcconfir   IN NUMBER DEFAULT NULL, --IAXIS-3287 01/04/2019
      mensajes OUT t_iax_mensajes)     -- CP0727M_SYS_PERS_Val - Inc. 2169 - ACL - 23/11/2018
      RETURN NUMBER;

   FUNCTION f_del_detsarlatf_dec(
      pndeclara IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_detsarlatf_dec(
      pndeclara IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_detsarlatf_dec(
      pndeclara IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      pctipoid IN NUMBER,
      pcnumeroid IN VARCHAR2,
      ptnombre IN VARCHAR2,
      pcmanejarec IN NUMBER,
      pcejercepod IN NUMBER,
      pcgozarec IN NUMBER,
      pcdeclaraci IN NUMBER,
      pcdeclaracicual IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_detsarlatf_act(
      pnactivi IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_detsarlatf_act(
      pnactivi IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_detsarlatf_act(
      pnactivi IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      pctipoprod IN VARCHAR2,
      pcidnumprod IN VARCHAR2,
      ptentidad IN VARCHAR2,
      pcmonto IN VARCHAR2,
      pcciudad IN NUMBER,
      pcpais IN NUMBER,
      pcmoneda IN VARCHAR2,
      pscpais IN VARCHAR2,
      pstdepb IN VARCHAR2,
      ptdepb IN NUMBER,
      pscciudad IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_detsarlaft_rec(
      pnrecla IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_detsarlaft_rec(
      pnrecla IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_detsarlaft_rec(
      pnrecla IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      pcanio IN NUMBER,
      pcramo IN VARCHAR2,
      ptcompania IN VARCHAR2,
      pcvalor IN VARCHAR2,
      ptresultado IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   --INI BUG CONF-186  Fecha (22/08/2016) - HRE - proceso de marcas
   /*************************************************************************
    FUNCTION f_get_permarcas
    Permite obtener las marcas de una persona
    param in pcempres    : codigo de la empresa
    param in psperson    : codigo de la persona
    param out ppermarcas : objeto marcas
    param out mensajes   : mesajes de error
    return               : number
  *************************************************************************/
   FUNCTION f_get_permarcas(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      ppermarcas OUT t_iax_permarcas,
      mensajes IN OUT t_iax_mensajes) RETURN NUMBER;
  /*************************************************************************
    FUNCTION f_get_permarca
    Permite obtener la marca de una persona
    param in pcempres   : codigo de la empresa
    param in psperson   : codigo de la persona
    param in pnmovimi   : numero de movimiento
    param out ppermarca : objeto marcas
    param out mensajes  : mesajes de error
    return              : number
  *************************************************************************/
  FUNCTION f_get_permarca(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      pcmarca  IN VARCHAR2,
      pnmovimi IN NUMBER,
      ppermarca OUT ob_iax_permarcas,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_persona_cifin(
      nnumide IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;


    FUNCTION f_set_cpep_sarlatf(
      PSSARLAFT   IN NUMBER ,
      PIDENTIFICACION IN  NUMBER,
      PCTIPREL    IN NUMBER,
      PTNOMBRE    IN VARCHAR2,
      PCTIPIDEN   IN NUMBER ,
      PNNUMIDE    IN VARCHAR2,
      PCPAIS      IN NUMBER,
      PTPAIS      IN VARCHAR2,
      PTENTIDAD   IN VARCHAR2,
      PTCARGO     IN VARCHAR2,
      PFDESVIN    IN DATE,
      mensajes    OUT t_iax_mensajes
    ) RETURN NUMBER;

    FUNCTION f_get_cpep_sarlatf(
      PSSARLAFT IN  NUMBER ,
      mensajes  OUT t_iax_mensajes
    ) RETURN sys_refcursor;

    FUNCTION f_del_cpep_sarlatf(
      PSSARLAFT       IN  NUMBER,
      PIDENTIFICACION IN NUMBER,
      mensajes        OUT t_iax_mensajes
    ) RETURN NUMBER;


    FUNCTION f_set_caccionista_sarlatf (
      PSSARLAFT   IN NUMBER ,
      PIDENTIFICACION IN  NUMBER,
      PPPARTICI   IN NUMBER,
      PTNOMBRE    IN VARCHAR2,
      PCTIPIDEN   IN NUMBER ,
      PNNUMIDE    IN VARCHAR2 ,
      PCBOLSA     IN NUMBER,
      PCPEP    	  IN NUMBER,
      PCTRIBUEXT  IN NUMBER,
      mensajes    OUT t_iax_mensajes
    )  RETURN NUMBER;

    FUNCTION f_get_caccionista_sarlatf (
      PSSARLAFT IN  NUMBER ,
      mensajes  OUT t_iax_mensajes
    )  RETURN sys_refcursor;

    FUNCTION f_del_caccionista_sarlatf (
      PSSARLAFT       IN  NUMBER,
      PIDENTIFICACION IN NUMBER,
      mensajes        OUT t_iax_mensajes
    )  RETURN NUMBER;


    FUNCTION f_set_accionista_sarlatf (
      PSSARLAFT       IN  NUMBER,
      PIDENTIFICACION IN  NUMBER,
      PPPARTICI       IN  NUMBER,
      PTNOMBRE        IN  VARCHAR2,
      PCTIPIDEN       IN  NUMBER,
      PNNUMIDE        IN  VARCHAR2,
      PTSOCIEDAD      IN  VARCHAR2,
      PNNUMIDESOC     IN  VARCHAR2,
      mensajes        OUT t_iax_mensajes
    ) RETURN NUMBER;

    FUNCTION f_get_accionista_sarlatf (
      PSSARLAFT IN  NUMBER ,
      mensajes  OUT t_iax_mensajes
    ) RETURN sys_refcursor;

    FUNCTION f_del_accionista_sarlatf (
      PSSARLAFT       IN  NUMBER,
      PIDENTIFICACION IN NUMBER,
      mensajes        OUT t_iax_mensajes
    ) RETURN NUMBER;

    FUNCTION f_get_ultimosestados_sarlatf (
      PSPERSON   IN  NUMBER ,
      mensajes   OUT t_iax_mensajes

    )  RETURN sys_refcursor;

    FUNCTION f_get_persona_sarlaf(
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes
	) RETURN sys_refcursor;
--INI--WAJ
    FUNCTION f_get_impuestos(
      psperson IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes,
      poimpuestos OUT ob_iax_impuestos)
      RETURN NUMBER;

  FUNCTION f_del_impuesto(
      psperson IN NUMBER,
      pctipind IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_get_tipo_vinculacion (
      psperson IN  NUMBER ,
      mensajes  OUT t_iax_mensajes
    ) RETURN sys_refcursor;

	--FIN--WAJ

	-- Ini TCS_1569B - ACL - 01/02/2019
	/*************************************************************************
   Obtiene los datos de las EST en un objeto OB_IAX_PERSONA
   param out mensajes  : mensajes de error
   return              : El OB_IAX_PERSONA
   *************************************************************************/
   FUNCTION f_get_persona_publica_imp(
      psperson IN NUMBER,
      pctipage IN NUMBER DEFAULT NULL,
      obpersona OUT ob_iax_personas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
	-- Fin TCS_1569B - ACL - 01/02/2019

	--Inicio Bartolo Herrera 04-03-2019 ---- IAXIS-2826
	/*************************************************************************
    FUNCTION f_get_parpersona_cont
    Permite obtener los valores de un parametro de persona
    param in psperson    : codigo de la persona
    param in pcparam     : codigo del parametro
    param out mensajes   : mesajes de error
    return               : sys_refcursor
   *************************************************************************/
    FUNCTION f_get_parpersona_cont (
      psperson IN  NUMBER ,
      pcparam IN  VARCHAR2,
      mensajes  OUT t_iax_mensajes
    ) RETURN sys_refcursor;

    /*************************************************************************
    FUNCTION f_get_cupo_persona
    Permite obtener el cupo asignado en ficha financiera de la persona
    param in psperson    : codigo de la persona
    param out mensajes   : mesajes de error
    return               : sys_refcursor
   *************************************************************************/
    FUNCTION f_get_cupo_persona (
      psperson IN  NUMBER ,
      mensajes  OUT t_iax_mensajes
    ) RETURN sys_refcursor;
	--Fin Bartolo Herrera 04-03-2019 ---- IAXIS-2826

-- Inicio IAXIS-3287 01/04/2019
    /*************************************************************************
    FUNCTION f_duplicar_sarlaft
    Permite duplicar un formulario SARLAFT ya confirmado
    param in  pssarlaft     : Código Sarlaft
    param out pssarlaftdest : Nuevo Sarlaft
    param out mensajes   : mesajes de error
    return               : number
   *************************************************************************/
    FUNCTION f_duplicar_sarlaft (
      pssarlaft     IN  NUMBER,
      pssarlaftdest OUT NUMBER,
      mensajes      OUT t_iax_mensajes
    ) RETURN NUMBER;
   -- Fin IAXIS-3287 01/04/2019
    --INI IAXIS-3670 16/04/2019 AP
     /*************************************************************************
    FUNCTION F_VALIDA_CONSORCIOS
    Validaciones para Consorcios
    param in psperson    : codigo de la persona
    param out mensajes   : mesajes de error
    return               : sys_refcursor
   *************************************************************************/
    FUNCTION F_VALIDA_CONSORCIOS (
      psperson IN  NUMBER ,
      mensajes  OUT t_iax_mensajes
    ) RETURN NUMBER;
    --FIN IAXIS-3670 16/04/2019 AP
	
	/*************************************************************************
	For IAXIS-4149 by PK-18/07/2019
	FUNCTION F_GET_CODITIPOBANC : Nueva funcion para obtener tipo de CUENTA.
		PCBANCO Código de Banco.
		PCTIPCC Que tipo de cuenta és.
	return              : 0 si ha ido bien, 1 si ha ido mal.
	*************************************************************************/
	FUNCTION F_GET_CODITIPOBANC(PCBANCO IN NUMBER, PCTIPCC IN VARCHAR2, PCTIPBAN OUT NUMBER)
      RETURN NUMBER;
      
END pac_iax_persona;

/
