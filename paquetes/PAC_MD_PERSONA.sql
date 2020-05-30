
  CREATE OR REPLACE PACKAGE "PAC_MD_PERSONA" IS
   /******************************************************************************
      NOMBRE:       PAC_MD_PERSONA
      PROPÃƒâ€œSITO: Funciones para gestionar personas

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        04/04/2008   JRH                1. Creación del package.
      2.0        18/05/2009   JTS                2. 10074: Modificaciones en el Mantenimiento de Personas
      3.0        09/06/2009   JTS                3. 10371: APR - tipo de empresa
      4.0        02/07/2009   XPL                4. 10339 i 9227, APR - Campos extra en la bÃƒÂºsqueda de personas
                                                                        i APR - Error al crear un agente
      5.0        16/11/2009   NMM                5. 11948: CEM - Alta de destinatatios.
      6.0        09/02/2010   DRA                6. 0011171: APR - campos de bÃƒÂºsqueda en el mto. de personas
      7.0        09/09/2010   DRA                7. 0015810: AGA003 - L'alta de persona no comprova bÃƒÂ© si la persona existeix o no
      8.0        22/11/2010   XPL                8. 16753: CRE - Pantalla destinatarios - 22/11/2010 - XPL
      9.0        19/07/2011   ICV                9. 0018941: LCOL_P001 - PER - Personas relacionadas. Representante legal
     10.0        23/09/2011   MDS               10. 0018943  Modulo SARLAFT en el mantenimiento de personas
     11.0        04/10/2011   MDS               11. 0018947: LCOL_P001 - PER - Posición global
     12.0        04/11/2011   APD               12. 0018946: LCOL_P001 - PER - Visibilidad en personas
     13.0        08/11/2011   JGR               13. 0019985 LCOL_A001-Control de las matriculas (prenotificaciones)
     14.0        23/11/2011   APD               14. 0020126: LCOL_P001 - PER - Documentación en personas
     15.0        10/01/2012   JGR               15. 0020735/0103205 Modificaciones tarjetas y ctas.bancarias
     16.0        09/07/2012   ETM               16.0022263: LCOL_P001 - PER - Informaci?n relacionado con documentos identificativos.
     17.0        24/07/2012   ETM               17. 0022642: MDP - PER - PosiciÃ³n global. Inquilinos, avalistas y gestor de cobro
     18.0        21/01/2013   APD               18. 0025542: LCOL_T031- LCOL - AUT - (id 431) Fecha de antig?edad en personas por agrupaci?n
     19.0        05/02/2013   JDS               19. 0025849: LCOL - PER - Posición global de personas : conductores
     20.0        08/07/2013   RCL               20. 0025599: LCOL - PER - Revision incidencias qtracker y Releases
     21.0        05/08/2013   RCL               21. 0027814: LCOL - PER - Nuevo contacto en el alta rápida de personas Fax.
     22.0        03/04/2014   FAL               22. 0030525: INT030-Prueba de concepto CONFIANZA
     23.0        27/07/2015   IGIL              23. 0036596: MSV- Diferenciacion persona juridica Hospital
     24.0        07/03/2016   JAEG              24. 40927/228750: Desarrollo Diseño técnico CONF_TEC-03_CONTRAGARANTIAS
     25.0        23/06/2016   ERH               24. CONF-52 Modificació® ¤e la funció® ¦_set_persona_rel se adiciona al final el parametro Õ‰PTLIMIT VARCHAR2
     26.0        22/08/2016   HRE               26  CONF-186: Se incluyen procesos para gestion de marcas.
     27.0        25/08/2016   JGONZALEZ         27  CONF-11049: Llamado al web service de persona para dar de alta
     28.0        21/11/2018   JLTS              28. CP0025M_SYS_PERS - JLTS - 21/11/2018 - se intercambia el orden de los parámetros pctipiva y pcregfisexeiva
	 29.0        23/11/2018   ACL               29. CP0727M_SYS_PERS_Val Se agrega en la función f_set_datsarlatf el parámetro pcorigenfon.
     30.0        18/12/2018   ACL               30. CP0416M_SYS_PERS Se agrega la función f_get_persona_sarlaf.
	 31.0		 07/01/2019	  SWAPNIL 			31. Cambios para solicitudes múltiples
	 32.0	     17/01/2019   AP		        32. TCS 468A 17/01/2019 AP Se modifica funcion f_get_persona_rel Consorcios y Uniones Temporales
     33.0        29/01/2019   WAJ               33. Se adiciona funcion para traer los indicadores de las personas.
	 34.0        01/02/2019   ACL               34. TCS_1569B: Se agrega la funcion f_get_persona_publica_imp
	 35.0		 12/02/2019	  AP				34. TCS-9: Se adiciona campos en la funcion f_set_datsarlatf para clausulas.
	 36.0        01/04/2019   DFRP              36. IAXIS-3287:FCC (Formulario de Conocimiento de Cliente).
	 37.0	     27/04/2019	  KK				37.	CAMBIOS De IAXIS-4538
	 38.0 	  03/07/2019  Shakti			  38.IAXIS 4696 El campo de IVA debe ser visible en este seccion en personas
	 39.0		 18/07/2019	  PK			39. Added function for IAXIS-4149 - Modificación Cuentas Bancarias
******************************************************************************/

   /*************************************************************************
      Recupera la lista de personas que coinciden con los criterios de consulta
      param in numide    : nÃƒÂºmero documento
      param in nombre    : texto que incluye nombre + apellidos
      param in nsip      : identificador externo de persona, puede ser nulo
      param out mensajes : mensajes de error
      param in psseguro  : identificador interno de seguro, puede ser nulo
      param in pnom      : nombre de la persona, puede ser nulo
      param in pcognom1  : apellido 1 de la persona, puede ser nulo
      param in pcognom2  : apellido 2 de la persona, puede ser nulo
      param in pctipide  : tipo de documento identificativo, puede ser nulo
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_personas(numide   IN VARCHAR2,
                           nombre   IN VARCHAR2,
                           nsip     IN VARCHAR2 DEFAULT NULL,
                           mensajes IN OUT t_iax_mensajes,
                           psseguro IN NUMBER DEFAULT NULL,
                           --JRH 04/2008 Se pasa el seguro
                           pnom     IN VARCHAR2 DEFAULT NULL,
                           pcognom1 IN VARCHAR2 DEFAULT NULL,
                           pcognom2 IN VARCHAR2 DEFAULT NULL,
                           pctipide IN NUMBER DEFAULT NULL)
      RETURN SYS_REFCURSOR;

   ----------------------------------------------------------------------------
   -- xpl 19/06/2009 : bug mantis 0010339 --afegir tdomici, cpostal i fnacimi
   FUNCTION f_get_personas_agentes(numide   IN VARCHAR2,
                                   nombre   IN VARCHAR2,
                                   nsip     IN VARCHAR2,
                                   mensajes IN OUT t_iax_mensajes,
                                   psseguro IN NUMBER,
                                   --JRH 04/2008 Se pasa el seguro
                                   pnom      IN VARCHAR2,
                                   pcognom1  IN VARCHAR2,
                                   pcognom2  IN VARCHAR2,
                                   pctipide  IN NUMBER,
                                   pfnacimi  IN DATE,
                                   ptdomici  IN VARCHAR2,
                                   pcpostal  IN VARCHAR2,
                                   phospital IN VARCHAR2 DEFAULT NULL, -- Bug 36596 IGIL
                                   pfideico  IN VARCHAR2 DEFAULT NULL) --BUG 40927/228750 - 07/03/2016 - JAEG
    RETURN SYS_REFCURSOR;

   --Pasa de t_ob_errores a T_IAX_MENSAJES
   FUNCTION f_traspasar_errores_mensajes(errores IN t_ob_error)
      RETURN t_iax_mensajes;

   /*************************************************************************
      Define con que tablas se trabajarÃƒÂ¡
      param in pmode     : mode en que se debe trabajar
      param out mensajes : mensajes de error
   *************************************************************************/
   -- PROCEDURE Define_Mode(pmode IN VARCHAR2,mensajes OUT T_IAX_MENSAJES);

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
      Traspasa a las EST si es necesario desde las tablas reales
      param out mensajes  : mensajes de error
      return              : 0 o código error
   *************************************************************************/
   FUNCTION f_traspasapersona(psperson     IN NUMBER,
                              pnsip        IN VARCHAR2, --    JLB - I 6353
                              pcagente     IN OUT NUMBER,
                              pcoditabla   IN VARCHAR2,
                              psperson_out OUT NUMBER,
                              psseguro     IN NUMBER,
                              p_modo       IN VARCHAR2, -- Bug 11948.
                              pmensapotup  OUT VARCHAR2,
                              mensajes     OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_ccc_host(psperson IN VARCHAR2,
                           pnsip    IN VARCHAR2,
                           pcagente IN NUMBER,
                           porigen  IN VARCHAR2 DEFAULT 'EST',
                           mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

   /*************************************************************************
      Valida el nif
      param out mensajes  : mensajes de error
      return              : 0 o código error
   *************************************************************************/
   FUNCTION f_validanif(pnnumide IN per_personas.nnumide%TYPE,
                        pctipide IN per_personas.ctipide%TYPE,
                        csexper  IN per_personas.csexper%TYPE, --     -- sexo de la pesona.
                        fnacimi  IN per_personas.fnacimi%TYPE, --   -- Fecha de nacimiento de la persona
                        mensajes OUT t_iax_mensajes) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
      Graba los datos de  persona en las EST
      param out mensajes  : mensajes de error
      return              : 0 o código error
   *************************************************************************/
   FUNCTION f_set_persona(psseguro IN NUMBER,
                          psperson IN OUT NUMBER,
                          pspereal IN NUMBER,
                          pcagente IN OUT NUMBER,
                          ctipper  IN NUMBER, -- Ã‚Â¿ tipo de persona (fÃƒÂ­sica o jurÃƒÂ­dica)
                          ctipide  IN NUMBER, -- Ã‚Â¿ tipo de identificación de persona
                          nnumide  IN VARCHAR2,
                          --  -- NÃƒÂºmero identificativo de la persona.
                          csexper     IN NUMBER, --     -- sexo de la pesona.
                          fnacimi     IN DATE, --   -- Fecha de nacimiento de la persona
                          snip        IN VARCHAR2, --  -- snip
                          cestper     IN NUMBER,
                          fjubila     IN DATE,
                          cmutualista IN NUMBER,
                          fdefunc     IN DATE,
                          nordide     IN NUMBER,
                          cidioma     IN NUMBER, ---      código idioma
                          tapelli1    IN VARCHAR2, --      Primer apellido
                          tapelli2    IN VARCHAR2, --      Segundo apellido
                          tnombre     IN VARCHAR2, --     Nombre de la persona
                          tsiglas     IN VARCHAR2, --     Siglas persona jurÃƒÂ­dica
                          cprofes     IN VARCHAR2, --     código profesión
                          cestciv     IN NUMBER, -- código estado civil. VALOR FIJO = 12
                          cpais       IN NUMBER, --     código paÃƒÂ­s de residencia
                          ptablas     IN VARCHAR2,
                          pswpubli    IN NUMBER,
                          ppduplicada IN NUMBER,
                          ptnombre1   IN VARCHAR2,
                          ptnombre2   IN VARCHAR2,
                          pswrut      IN NUMBER,
                          pcocupacion IN VARCHAR2, -- Bug 25456/133727 - 16/01/2013 - AMC
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
                          mensajes    IN OUT t_iax_mensajes
						  /* CAMBIOS De IAXIS-4538 : Start */
                          ,pfefecto IN DATE, 
                          pcregfiscal IN NUMBER, 
                          pctipiva    IN NUMBER,  
                          pIMPUETOS_PER IN T_IAX_PROF_IMPUESTOS  
                          /* CAMBIOS De IAXIS-4538 : End */
						) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
     Obtiene los datos de las EST en un objeto OB_IAX_PERSONA
     param out mensajes  : mensajes de error
     return              : El OB_IAX_PERSONA o un null
   *************************************************************************/
   FUNCTION f_get_persona(psperson IN NUMBER,
                          pcagente IN NUMBER,
                          mensajes OUT t_iax_mensajes,
                          ptablas  IN VARCHAR2) RETURN ob_iax_personas;

   -- BUG15810:DRA:09/09/2010:Inici
   /*************************************************************************
         Obtiene los datos de las EST en un objeto OB_IAX_PERSONA
         param out mensajes  : mensajes de error
         return              : El OB_IAX_PERSONA o un null
   *************************************************************************/
   FUNCTION f_get_persona_est(psperson IN NUMBER,
                              pcagente IN NUMBER,
                              mensajes OUT t_iax_mensajes,
                              ptablas  IN VARCHAR2) RETURN ob_iax_personas;

   -- BUG15810:DRA:09/09/2010:Fi

   /*************************************************************************
       Obtiene los datos de una persona pasandole el nif, sexo y fecha nacimiento
       param out mensajes  : mensajes de error
       return              : El OB_IAX_PERSONA
   *************************************************************************/
   FUNCTION f_get_personaunica(pctipper    IN NUMBER,
                               pctipide    IN NUMBER,
                               pnnumnif    IN VARCHAR2,
                               pcsexper    IN NUMBER,
                               pfnacimi    IN DATE,
                               pmodo       IN VARCHAR2,
                               psseguro    IN NUMBER,
                               pcagente    IN NUMBER,
                               pswpubli    IN NUMBER,
                               ptablas     IN VARCHAR2,
                               ppduplicada IN NUMBER,
                               mensajes    OUT t_iax_mensajes)
      RETURN ob_iax_personas;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
     Obtiene  de parÃƒÂ¡metros de salida los datos principales del contacto tipo  telÃƒÂ©fono fijo.
      param out mensajes  : mensajes de error
      return              : El OB_IAX_PERSONA o un null
   *************************************************************************/
   FUNCTION f_get_contactotlffijo(psperson IN NUMBER,
                                  pcagente IN NUMBER,
                                  psmodcon OUT NUMBER,
                                  ptvalcon OUT VARCHAR2,
                                  mensajes IN OUT t_iax_mensajes,
                                  ptablas  IN VARCHAR2) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
     Obtiene  de parÃƒÂ¡metros de salida los datos principales del contacto tipo  telÃƒÂ©fono movil.
      param out mensajes  : mensajes de error
      return              : El OB_IAX_PERSONA o un null
   *************************************************************************/
   FUNCTION f_get_contactotlfmovil(psperson IN NUMBER,
                                   pcagente IN NUMBER,
                                   psmodcon OUT NUMBER,
                                   ptvalcon OUT VARCHAR2,
                                   mensajes IN OUT t_iax_mensajes,
                                   ptablas  IN VARCHAR2) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
      Obtiene  de parÃƒÂ¡metros de salida los datos principales del contacto tipo  mail.
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_contactomail(psperson IN NUMBER,
                               pcagente IN NUMBER,
                               psmodcon OUT NUMBER,
                               ptvalcon OUT VARCHAR2,
                               mensajes IN OUT t_iax_mensajes,
                               ptablas  IN VARCHAR2) RETURN NUMBER;

   /*************************************************************************
       Obtiene  de parÃƒÂ¡metros de salida los datos principales del contacto tipo  fax.
           return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_contactofax(psperson IN NUMBER,
                              pcagente IN NUMBER,
                              psmodcon OUT NUMBER,
                              ptvalcon OUT VARCHAR2,
                              mensajes IN OUT t_iax_mensajes,
                              ptablas  IN VARCHAR2) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
      Obtiene el código del pais, nacionalidad por defecto.
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_nacionalidaddefecto(psperson IN NUMBER,
                                      pcagente IN NUMBER,
                                      pcpais   OUT NUMBER,
                                      mensajes OUT t_iax_mensajes,
                                      ptablas  IN VARCHAR2) RETURN NUMBER;

   FUNCTION f_get_nacionalidades(psperson        IN NUMBER,
                                 pcagente        IN NUMBER,
                                 pnacionalidades OUT t_iax_nacionalidades,
                                 mensajes        OUT t_iax_mensajes,
                                 ptablas         IN VARCHAR2) RETURN NUMBER;

   FUNCTION f_get_nacionalidad(psperson     IN NUMBER,
                               pcpais       IN NUMBER,
                               pcagente     IN NUMBER,
                               nacionalidad OUT ob_iax_nacionalidades,
                               mensajes     IN OUT t_iax_mensajes,
                               ptablas      IN VARCHAR2) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
      Nueva función que recupera la cuenta bancaria que tiene primero se mirarÃƒÂ¡ a nivel de póliza,
      si no hay definida se mira a nivel de persona
      return              : 0 si ha ido bien , 1 si ha ido mal
   *************************************************************************/
   FUNCTION f_get_cuentapoliza(psperson IN NUMBER,
                               pcagente IN NUMBER,
                               psseguro IN NUMBER,
                               pctipban OUT NUMBER,
                               pcbancar OUT VARCHAR2,
                               mensajes OUT t_iax_mensajes,
                               ptablas  IN VARCHAR2) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
      Nueva función que da formato a la cuenta bancaria dependiendo del tipo.
      pcbancar es cbancar pero formateado.
      return              : 0 si ha ido bien , 1 si ha ido mal
   *************************************************************************/
   FUNCTION f_getformatoccc(pctipban IN NUMBER,
                            cbancar  IN VARCHAR2,
                            pcbancar OUT VARCHAR2,
                            mensajes OUT t_iax_mensajes) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
      Nueva función que valida la cuenta bancaria dependiendo del tipo.
      pcbancar es cbancar pero formateado.
      return              : 0 si ha ido bien , 1 si ha ido mal
   *************************************************************************/
   FUNCTION f_validaccc(pctipban IN NUMBER,
                        cbancar  IN VARCHAR2,
                        mensajes OUT t_iax_mensajes) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
     Esta nueva función se encarga de grabar  el contacto telÃƒÂ©fono fijo  en estper_contactos.
     return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_set_contactotlffijo(psperson IN NUMBER,
                                  pcagente IN NUMBER,
                                  ptvalcon IN VARCHAR2,
                                  psmodcon IN OUT NUMBER,
                                  pcprefix IN NUMBER,
                                  mensajes IN OUT t_iax_mensajes,
                                  ptablas  IN VARCHAR2) RETURN NUMBER;

   FUNCTION f_set_nacionalidad(psperson  IN NUMBER,
                               pcagente  IN NUMBER,
                               pcpais    IN NUMBER,
                               pcdefecto IN NUMBER,
                               mensajes  IN OUT t_iax_mensajes,
                               ptablas   IN VARCHAR2) RETURN NUMBER;

   FUNCTION f_del_nacionalidad(psperson IN NUMBER,
                               pcpais   IN NUMBER,
                               pcagente IN NUMBER,
                               mensajes IN OUT t_iax_mensajes,
                               ptablas  IN VARCHAR2) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
     Esta nueva función se encarga de grabar  el contacto telÃƒÂ©fono móvil  en estper_contactos.
     return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_set_contactotlfmovil(psperson IN NUMBER,
                                   pcagente IN NUMBER,
                                   ptvalcon IN VARCHAR2,
                                   psmodcon IN OUT NUMBER,
                                   pcprefix IN NUMBER,
                                   mensajes IN OUT t_iax_mensajes,
                                   ptablas  IN VARCHAR2) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
     Esta nueva función se encarga de grabar  el contacto mail  en estper_contactos.
     return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_set_contactomail(psperson IN NUMBER,
                               pcagente IN NUMBER,
                               ptvalcon IN VARCHAR2,
                               psmodcon IN OUT NUMBER,
                               mensajes IN OUT t_iax_mensajes,
                               ptablas  IN VARCHAR2) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
     Esta nueva función se encarga de grabar  la nacionalidad por defecto de una persona.
     return              : 0 si ha ido todo bien , 1 en caso contrario.
   *************************************************************************/
   FUNCTION f_set_nacionalidaddefecto(psperson IN NUMBER,
                                      pcagente IN NUMBER,
                                      pcpais   IN NUMBER,
                                      mensajes OUT t_iax_mensajes,
                                      ptablas  IN VARCHAR2) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
     Esta nueva función se encarga de grabar  la cuenta bancaria  de una persona, serÃƒÂ¡ la de por defecto
     si no existe hasta el momento si ya tiene una cuenta bancaria por defecto este campo no se modificarÃƒÂ¡.
     return              : 0 si ha ido todo bien , 1 en caso contrario.
   *************************************************************************/
   FUNCTION f_set_ccc(psperson  IN NUMBER,
                      pcagente  IN NUMBER,
                      pcnordban IN OUT NUMBER,
                      pctipban  IN NUMBER,
                      pcbancar  IN VARCHAR2,
                      pcdefecto IN NUMBER,
                      mensajes  IN OUT t_iax_mensajes,
                      ptablas   IN VARCHAR2,
                      pcpagsin  IN NUMBER DEFAULT NULL, -- 19985 LCOL_A001-Control de las matriculas (prenotificaciones)
                      pfvencim  IN DATE DEFAULT NULL, -- 19985 LCOL_A001-Control de las matriculas (prenotificaciones)
                      ptseguri  IN VARCHAR2 DEFAULT NULL, -- 19985 LCOL_A001-Control de las matriculas (prenotificaciones)
                      pctipcc   IN VARCHAR2 DEFAULT NULL -- 20735/102170 Introduccion de cuenta bancaria
                      ) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
      Obtiene las direcciones del sperson
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_direcciones(psperson    IN NUMBER,
                              pcagente    IN NUMBER,
                              direcciones OUT t_iax_direcciones,
                              mensajes    IN OUT t_iax_mensajes,
                              ptablas     IN VARCHAR2) RETURN NUMBER;

   /*************************************************************************
      Obtiene los contactos del sperson
      return              : T_IAX_CONTACTOS   T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_contactos(psperson   IN NUMBER,
                            pcagente   IN NUMBER,
                            tcontactos OUT t_iax_contactos,
                            mensajes   OUT t_iax_mensajes,
                            ptablas    IN VARCHAR2) RETURN NUMBER;

   /*************************************************************************
      Obtiene el contacto del sperson
      return              : ob_IAX_CONTACTOS   T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_contacto(psperson    IN NUMBER,
                           pcagente    IN NUMBER,
                           pcmodcon    IN NUMBER,
                           obcontactos OUT ob_iax_contactos,
                           mensajes    OUT t_iax_mensajes,
                           ptablas     IN VARCHAR2) RETURN NUMBER;

   /*************************************************************************
         Esta nueva función se encarga de grabar  un contacto
         return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_set_contacto(psperson IN NUMBER,
                           cagente  IN NUMBER,
                           pctipcon IN NUMBER,
                           ptcomcon IN VARCHAR2,
                           ptvalcon IN VARCHAR2,
                           pcdomici IN NUMBER, --bug 24806
                           psmodcon IN OUT NUMBER,
                           pcprefix IN NUMBER,
                           mensajes IN OUT t_iax_mensajes,
                           ptablas  IN VARCHAR2) RETURN NUMBER;

   FUNCTION f_del_contacto(psperson IN NUMBER,
                           psmodcon IN NUMBER,
                           pcagente IN NUMBER,
                           mensajes IN OUT t_iax_mensajes,
                           ptablas  IN VARCHAR2) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
      Borra una dirección.
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_del_direcciones(psperson IN NUMBER,
                              pcdomici IN NUMBER,
                              mensajes IN OUT t_iax_mensajes,
                              ptablas  IN VARCHAR2,
                              pcagente IN NUMBER) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
      Nueva función que se encarga de recuperar una dirección de una persona.
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_direccion(psperson  IN NUMBER,
                            pcdomici  IN NUMBER,
                            direccion OUT ob_iax_direcciones,
                            mensajes  IN OUT t_iax_mensajes,
                            ptablas   IN VARCHAR2) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
      Nueva función que se encarga de realizar las validaciones en la introducción o modificación de una dirección.
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_valida_direccion(psperson IN NUMBER,
                               pcagente IN NUMBER,
                               pctipdir IN NUMBER,
                               pcsiglas IN NUMBER,
                               ptnomvia IN VARCHAR2,
                               pnnumvia IN NUMBER,
                               ptcomple IN VARCHAR2,
                               pcpostal IN VARCHAR2,
                               pcpoblac IN NUMBER, --código población
                               pcprovin IN NUMBER,
                               pcpais   IN NUMBER,
                               mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
    Nueva función que inserta o modifica la dirección de una persona en estper_direcciones.
    return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_set_direccion(psperson IN NUMBER,
                            pcagente IN NUMBER,
                            pcdomici IN OUT NUMBER,
                            pctipdir IN NUMBER,
                            pcsiglas IN NUMBER,
                            ptnomvia IN VARCHAR2,
                            pnnumvia IN NUMBER,
                            potros   IN VARCHAR2,
                            pcpostal IN VARCHAR2,
                            pcpoblac IN NUMBER,
                            pcprovin IN NUMBER,
                            pcpais   IN NUMBER,
                            mensajes IN OUT t_iax_mensajes,
                            ptablas  IN VARCHAR2,
                            -- Bug 18940/92686 - 27/09/2011 - AMC
                            pcviavp   IN estper_direcciones.cviavp%TYPE,
                            pclitvp   IN estper_direcciones.clitvp%TYPE,
                            pcbisvp   IN estper_direcciones.cbisvp%TYPE,
                            pcorvp    IN estper_direcciones.corvp%TYPE,
                            pnviaadco IN estper_direcciones.nviaadco%TYPE,
                            pclitco   IN estper_direcciones.clitco%TYPE,
                            pcorco    IN estper_direcciones.corco%TYPE,
                            pnplacaco IN estper_direcciones.nplacaco%TYPE,
                            pcor2co   IN estper_direcciones.cor2co%TYPE,
                            pcdet1ia  IN estper_direcciones.cdet1ia%TYPE,
                            ptnum1ia  IN estper_direcciones.tnum1ia%TYPE,
                            pcdet2ia  IN estper_direcciones.cdet2ia%TYPE,
                            ptnum2ia  IN estper_direcciones.tnum2ia%TYPE,
                            pcdet3ia  IN estper_direcciones.cdet3ia%TYPE,
                            ptnum3ia  IN estper_direcciones.tnum3ia%TYPE,
                            -- Fi Bug 18940/92686 - 27/09/2011 - AMC
                            plocalidad IN estper_direcciones.localidad%TYPE, -- Bug 24780/130907 - 05/12/2012 - AMC
			    ptalias    IN estper_direcciones.talias%TYPE      -- BUG CONF-441 - 14/12/2016 - JAEG
                            ) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
      Obtiene las direcciones del sperson
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_cuentasbancarias(psperson  IN NUMBER,
                                   pcagente  IN NUMBER,
                                   pfvigente IN DATE, --xvila:bug 6466
                                   ccc       OUT t_iax_ccc,
                                   mensajes  IN OUT t_iax_mensajes,
                                   ptablas   IN VARCHAR2,
                                   pctipcc   IN NUMBER DEFAULT NULL -- 08/11/2011 JGR 19985 LCOL_A001-Control de las matriculas (prenotificaciones)
                                   ) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
      Borra una cuenta.
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_del_ccc(psperson  IN NUMBER,
                      pcnordban IN NUMBER,
                      mensajes  IN OUT t_iax_mensajes,
                      ptablas   IN VARCHAR2) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
      Nueva función que se encarga de recuperar una cuenta bancaria de una persona.
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_ccc(psperson  IN NUMBER,
                      pcnordban IN NUMBER,
                      ccc       OUT ob_iax_ccc,
                      mensajes  IN OUT t_iax_mensajes,
                      ptablas   IN VARCHAR2,
                      pfvigente IN DATE DEFAULT NULL) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
       Nueva función que se encarga de recuperar la povicincia y población a partir de un codigo postal
       A partir de un código postal obtenemos los codigos de pais, provincia, población y sus respectivas  descripciones.
       return              : 0 si ha ido todo bien 1 si ha ido mal
       return : 0 si no ha encontrado coincidencias.
                1 si existe algun error.
                2 si existe mas de una provincia, pais o poblacion con el
                  codigo postal relacionado.
   *************************************************************************/
   FUNCTION f_get_provinpobla(pcodpostal IN VARCHAR2,
                              pcpais     OUT NUMBER,
                              ptpais     OUT VARCHAR2,
                              pcprovin   OUT NUMBER,
                              ptprovin   OUT VARCHAR2,
                              pcpoblac   OUT NUMBER,
                              ptpoblac   OUT VARCHAR2,
                              pautocalle OUT NUMBER,
                              mensajes   IN OUT t_iax_mensajes) RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
     Esta nueva función se encarga de grabar  un identificador de la persona
     return              : 0 si ha ido todo bien , 1 en caso contrario.
   *************************************************************************/
   FUNCTION f_set_identificador(psperson  IN NUMBER,
                                pcagente  IN NUMBER,
                                pctipide  IN NUMBER,
                                pnnumide  IN VARCHAR2,
                                pcdefecto IN NUMBER,
                                mensajes  IN OUT t_iax_mensajes,
                                ptablas   IN VARCHAR2,
                                -- Bug 22263 - 11/07/2012 - ETM
                                ppaisexp    IN NUMBER DEFAULT NULL,
                                pcdepartexp IN NUMBER DEFAULT NULL,
                                pcciudadexp IN NUMBER DEFAULT NULL,
                                pfechaexp   IN DATE DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
     Esta nueva funciÃƒÆ’Ã‚Â³n se encarga de modificar un identificador
     return              : 0 si ha ido todo bien , 1 en caso contrario.

     Bug 20441/101686 - 10/01/2012 - AMC
   *************************************************************************/
   FUNCTION f_mod_identificador(psperson  IN NUMBER,
                                pcagente  IN NUMBER,
                                pctipide  IN NUMBER,
                                pnnumide  IN VARCHAR2,
                                pcdefecto IN NUMBER,
                                mensajes  IN OUT t_iax_mensajes,
                                ptablas   IN VARCHAR2,
                                -- Bug 22263 - 11/07/2012 - ETM
                                ppaisexp    IN NUMBER DEFAULT NULL,
                                pcdepartexp IN NUMBER DEFAULT NULL,
                                pcciudadexp IN NUMBER DEFAULT NULL,
                                pfechaexp   IN DATE DEFAULT NULL)
      RETURN NUMBER;

   --JRH 04/2008 Tarea ESTPERSONAS
   /*************************************************************************
     Esta nueva función se encarga de borrar  un identificador de la persona
     return              : 0 si ha ido todo bien , 1 en caso contrario.
   *************************************************************************/
   FUNCTION f_del_identificador(psperson IN NUMBER,
                                pcagente IN NUMBER,
                                pctipide IN NUMBER,
                                mensajes IN OUT t_iax_mensajes,
                                ptablas  IN VARCHAR2) RETURN NUMBER;

   /*************************************************************************
   Obtiene los datos de los identificadores en un T_IAX_IDENTIFICADORES
   param out mensajes  : pDirecciones que es t_iax_direcciones
   return              : El T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_identificadores(psperson         IN NUMBER,
                                  pcagente         IN NUMBER,
                                  pidentificadores OUT t_iax_identificadores,
                                  mensajes         IN OUT t_iax_mensajes,
                                  ptablas          IN VARCHAR2) RETURN NUMBER;

   /*************************************************************************
   Obtiene los datos de un tipo de identificador en un ob_iax_IDENTIFICADORES
   param out mensajes  : pIdentificadores que es ob_iax_IDENTIFICADORES
   return              : 0 si ha ido todo bien , 1 en caso contrario.
   Obtiene los datos de las EST de una dirección en un objeto OB_IAX_DIRECCIONES
   param out mensajes  : pDirecciones que es t_iax_direcciones
   return              : El T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_identificador(psperson         IN NUMBER,
                                pcagente         IN NUMBER,
                                pctipide         IN NUMBER,
                                pidentificadores OUT ob_iax_identificadores,
                                mensajes         IN OUT t_iax_mensajes,
                                ptablas          IN VARCHAR2) RETURN NUMBER;

   /*************************************************************************
      Recupera la lista de valores del desplegable TIPOS CONTACTOS
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipcontactos(mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /*************************************************************************
   Funció que recupera les pÃƒÂ²lisses en el que la persona ÃƒÂ©s prenedor
   return : cursor con el resultado
   *************************************************************************/
   FUNCTION f_get_poltom(psperson IN NUMBER,
                         mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

   /*************************************************************************
   Funció que recupera les pÃƒÂ²lisses en el que la persona ÃƒÂ©s assegurat
   return : cursor con el resultado
   *************************************************************************/
   FUNCTION f_get_polase(psperson IN NUMBER,
                         mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

   -- JLB - I -
   /*************************************************************************
      Recupera la lista de personas contra el HOST que coinciden con los criterios de consulta
      param in numide    : nÃƒÂºmero documento
      param in nombre    : texto que incluye nombre + apellidos
      param in nsip      : identificador externo de persona, puede ser nulo
      param out mensajes : mensajes de error
      param in psseguro  : identificador interno de seguro, puede ser nulo
      param in pnom      : nombre de la persona, puede ser nulo
      param in pcognom1  : apellido 1 de la persona, puede ser nulo
      param in pcognom2  : apellido 2 de la persona, puede ser nulo
      param in pctipide  : tipo de documento identificativo, puede ser nulo
      param out pomasdatos : variable que informa si se necesitan mas datos
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_personas_host(numide   IN VARCHAR2,
                                nombre   IN VARCHAR2,
                                nsip     IN VARCHAR2 DEFAULT NULL,
                                mensajes IN OUT t_iax_mensajes,
                                psseguro IN NUMBER DEFAULT NULL,
                                --JRH 04/2008 Se pasa el seguro
                                pnom       IN VARCHAR2 DEFAULT NULL,
                                pcognom1   IN VARCHAR2 DEFAULT NULL,
                                pcognom2   IN VARCHAR2 DEFAULT NULL,
                                pctipide   IN NUMBER DEFAULT NULL,
                                pomasdatos OUT NUMBER) RETURN SYS_REFCURSOR;

   /*************************************************************************
     Traspasa a las EST las cuentas banacarias de una persona
     param in: psperson real ,
               pficticia_sperson, persona de la tabla est
     param out: mensajes de error
   *************************************************************************/
   FUNCTION traspaso_ccc(psseguro          IN NUMBER,
                         psperson          IN per_personas.sperson%TYPE,
                         pficticia_sperson IN estper_personas.sperson%TYPE,
                         mensajes          OUT t_iax_mensajes) RETURN NUMBER;

   -- DRA 13-10-2008: bug mantis 7784
   FUNCTION f_buscaagente(psperson IN per_personas.sperson%TYPE,
                          pcagente IN agentes.cagente%TYPE,
                          ptablas  IN VARCHAR2,
                          mensajes OUT t_iax_mensajes)
      RETURN agentes.cagente%TYPE;

   FUNCTION f_persona_origen_int(psperson IN estper_personas.sperson%TYPE,
                                 mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_get_persona_trecibido(psperson IN estper_personas.sperson%TYPE,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   FUNCTION f_direccion_origen_int(psperson IN estper_direcciones.sperson%TYPE,
                                   pcdomici IN estper_direcciones.cdomici%TYPE,
                                   mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_direccion_trecibido(psperson IN estper_direcciones.sperson%TYPE,
                                      pcdomici IN estper_direcciones.cdomici%TYPE,
                                      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   -- bug 7873
   FUNCTION f_get_cagentepol(psperson IN per_personas.sperson%TYPE,
                             ptablas  IN VARCHAR2,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER;

   FUNCTION f_busqueda_masdatos(mensajes   IN OUT t_iax_mensajes,
                                pomasdatos OUT NUMBER) RETURN SYS_REFCURSOR;

   /***********************************************************************
      Dado un identificativo de persona llena el objeto personas
      param in sperson       : código de persona
      param in cagente       : código del agente
      param in out obpersona : objeto persona
      param in out mensajes  : mensajes de error
      retorno : 0 - ok
                1 - error
   ***********************************************************************/
   FUNCTION f_get_persona_agente(psperson  IN NUMBER,
                                 pcagente  IN NUMBER,
                                 pmode     IN VARCHAR2,
                                 obpersona IN OUT ob_iax_personas,
                                 mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*********************************************************************************************
   *  Dado una identificador de persona, valida que los datos minimos necesarios para dar de alta un persona esten informados
   *  param sperson : código de persona
   *  param in out mensajes  : mensajes de error
   *   retorno : 0 - ok
   *             1 - error
   **********************************************************************************************/
   FUNCTION f_validapersona(psperson IN estper_personas.sperson%TYPE,
                            mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
      Valida la persona
      param out mensajes  : mensajes de error
      return              : 0 o código error
   *************************************************************************/
   FUNCTION f_validapersona(psperson    IN NUMBER,
                            pidioma_usu IN NUMBER,
                            ctipper     IN NUMBER, -- tipo de persona (fÃƒÂ­sica o jurÃƒÂ­dica)
                            ctipide     IN NUMBER, -- tipo de identificación de persona
                            nnumide     IN VARCHAR2,
                            -- NÃƒÂºmero identificativo de la persona.
                            csexper       IN NUMBER, -- sexo de la pesona.
                            fnacimi       IN DATE, -- Fecha de nacimiento de la persona
                            snip          IN VARCHAR2, -- snip
                            cestper       IN NUMBER,
                            fjubila       IN DATE,
                            cmutualista   IN NUMBER,
                            fdefunc       IN DATE,
                            nordide       IN NUMBER,
                            cidioma       IN NUMBER, --  código idioma
                            tapelli1      IN VARCHAR2, --      Primer apellido
                            tapelli2      IN VARCHAR2, -- Segundo apellido
                            tnombre       IN VARCHAR2, --    Nombre de la persona
                            tsiglas       IN VARCHAR2, --      Siglas persona jurÃƒÂ­dica
                            cprofes       IN VARCHAR2, --código profesión
                            cestciv       IN NUMBER, --código estado civil. VALOR FIJO = 12
                            cpais         IN NUMBER, -- código paÃƒÂ­s de residencia
                            cnacionalidad IN NUMBER,
                            ptablas       IN VARCHAR2,
                            ptnombre1     IN VARCHAR2,
                            ptnombre2     IN VARCHAR2,
                            pcocupacion   IN VARCHAR2, -- Bug 25456/133727 - 16/01/2013 - AMC
                            mensajes      OUT t_iax_mensajes) RETURN NUMBER;

   /*********************************************************************************************
   *  Dado una identificador de persona y un domicilio, valida que los datos minimos necesarios para dar de alta un dirreción
   *  esten informados
   *  param sperson : código de persona
   *  param cdomici:  identificador de direccion seleccionado del tomador
   *  param in out mensajes  : mensajes de error
   *  retorno : 0 - ok
   *            1 - error
   **********************************************************************************************/
   FUNCTION f_valida_direccion(psperson IN estper_personas.sperson%TYPE,
                               pcdomici IN estper_direcciones.cdomici%TYPE,
                               mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
     función que recuperarÃƒÂ¡ todas la personas
     con sus detalles segÃƒÂºn el nivel de visión
     del usuario que este consultando.
   *************************************************************************/
   FUNCTION f_get_det_persona(numide     IN VARCHAR2,
                              nombre     IN VARCHAR2,
                              nsip       IN VARCHAR2 DEFAULT NULL,
                              mensajes   IN OUT t_iax_mensajes,
                              pnom       IN VARCHAR2 DEFAULT NULL,
                              pcognom1   IN VARCHAR2 DEFAULT NULL,
                              pcognom2   IN VARCHAR2 DEFAULT NULL,
                              pctipide   IN NUMBER DEFAULT NULL,
                              pfnacimi   IN DATE, -- BUG11171:DRA:24/11/2009
                              ptdomici   IN VARCHAR2, -- BUG11171:DRA:24/11/2009
                              pcpostal   IN VARCHAR2, -- BUG11171:DRA:24/11/2009
                              pswpubli   IN NUMBER,
                              pestseguro IN NUMBER) RETURN SYS_REFCURSOR;

   /*************************************************************************
          Nueva función que servirÃƒÂ¡ para modificar los datos bÃƒÂ¡sicos de una persona
   *************************************************************************/
   FUNCTION f_set_basicos_persona(psperson   IN NUMBER,
                                  pctipper   IN NUMBER,
                                  pctipide   IN NUMBER,
                                  pnnumide   IN VARCHAR2,
                                  pcsexper   IN NUMBER,
                                  pfnacimi   IN DATE,
                                  pswpubli   IN NUMBER,
                                  ptablas    IN VARCHAR2,
                                  pswrut     IN NUMBER,
                                  pcpreaviso IN NUMBER,
                                  mensajes   IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     función que a partir de un sperson te devuelve los detalles
     de la persona, segÃƒÂºn el nivel de visión del usuario
     que esta consultando.
   *************************************************************************/
   FUNCTION f_get_agentes_vision(psperson IN NUMBER,
                                 mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /*************************************************************
   Nueva función que llena la colección del t_iax_irpfmayores.
   **************************************************************/
   FUNCTION f_get_irpfmayores(psperson    IN NUMBER,
                              pcagente    IN NUMBER,
                              pnano       IN NUMBER,
                              ptablas     IN VARCHAR2,
                              irpfmayores OUT t_iax_irpfmayores,
                              mensajes    IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************
    función que llena el objeto ob_iax_irpfmayores.
   **************************************************************/
   FUNCTION f_get_irpfmayor(psperson    IN NUMBER,
                            pcagente    IN NUMBER,
                            pnano       IN NUMBER,
                            pnorden     IN NUMBER,
                            ptablas     IN VARCHAR2,
                            irpfmayores OUT ob_iax_irpfmayores,
                            mensajes    IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************
    función que llena la coleccion del t_iax_irpfdescen.
   **************************************************************/
   FUNCTION f_get_irpfdescens(psperson    IN NUMBER,
                              pcagente    IN NUMBER,
                              pnano       IN NUMBER,
                              ptablas     IN VARCHAR2,
                              irpfdescens OUT t_iax_irpfdescen,
                              mensajes    IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************
    función que llena el objeto ob_iax_irpfdescen.
   **************************************************************/
   FUNCTION f_get_irpfdescen(psperson   IN NUMBER,
                             pcagente   IN NUMBER,
                             pnano      IN NUMBER,
                             pnorden    IN NUMBER,
                             ptablas    IN VARCHAR2,
                             irpfdescen OUT ob_iax_irpfdescen,
                             mensajes   IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************
    función que llena la coleccion del t_iax_irpf.
   **************************************************************/
   FUNCTION f_get_irpfs(psperson IN NUMBER,
                        pcagente IN NUMBER,
                        ptablas  IN VARCHAR2,
                        pirpfs   OUT t_iax_irpf,
                        mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************
    función que llena el objeto ob_iax_irpfdescen.
   **************************************************************/
   FUNCTION f_get_irpf(psperson IN NUMBER,
                       pcagente IN NUMBER,
                       pnano    IN NUMBER,
                       ptablas  IN VARCHAR2,
                       pirpf    OUT ob_iax_irpf,
                       mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************
    función que eliminar los registros de las tablas relacionadas a IRPF
   **************************************************************/
   FUNCTION f_del_irpf(psperson IN NUMBER,
                       pcagente IN NUMBER,
                       pnano    IN NUMBER,
                       ptablas  IN VARCHAR2,
                       mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************
    función que grabar los registros de las tablas relacionadas a IRPF
   **************************************************************/
   FUNCTION f_set_irpf(pobirpf  IN ob_iax_irpf,
                       ptablas  IN VARCHAR2,
                       mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
    función que devuelve nÃƒÂºmero de aÃƒÂ±os para declarar el irpf de una persona,
    si la persona existe se le devolverÃƒÂ¡ el mÃƒÂ¡ximo mÃƒÂ¡s uno sino existiera se
    le devolverÃƒÂ­a el actual aÃƒÂ±o
   *************************************************************************/
   FUNCTION f_get_anysirpf(psperson IN NUMBER,
                           pcagente IN NUMBER,
                           pnanos   OUT SYS_REFCURSOR,
                           mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
    función que torna l'agent de visio passant-li un agent
   *************************************************************************/
   FUNCTION f_agente_cpervisio(pcagente      IN NUMBER,
                               pcagentevisio OUT NUMBER,
                               mensajes      IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
     función que recuperarÃƒÂ¡ todas la personas dependiendo del modo.
     publico o no. servirÃƒÂ¡ para todas las pantallas donde quieran utilizar el
     buscador de personas.
   *************************************************************************/
   FUNCTION f_get_personas_generica(pnumide       IN VARCHAR2,
                                    pnombre       IN VARCHAR2,
                                    pnsip         IN VARCHAR2 DEFAULT NULL,
                                    mensajes      IN OUT t_iax_mensajes,
                                    pnom          IN VARCHAR2 DEFAULT NULL,
                                    pcognom1      IN VARCHAR2 DEFAULT NULL,
                                    pcognom2      IN VARCHAR2 DEFAULT NULL,
                                    pctipide      IN NUMBER DEFAULT NULL,
                                    pcagente      IN NUMBER DEFAULT NULL,
                                    pmodo_swpubli IN VARCHAR2)
      RETURN SYS_REFCURSOR;

   -- ini t.8063
   /*************************************************************************
     función que recuperarÃƒÂ¡ todas la personas publicas
     con sus detalles segÃƒÂºn el nivel de visión
     del usuario que este consultando.
   *************************************************************************/
   FUNCTION f_get_personas_publicas(numide   IN VARCHAR2,
                                    nombre   IN VARCHAR2,
                                    nsip     IN VARCHAR2 DEFAULT NULL,
                                    mensajes IN OUT t_iax_mensajes,
                                    pnom     IN VARCHAR2 DEFAULT NULL,
                                    pcognom1 IN VARCHAR2 DEFAULT NULL,
                                    pcognom2 IN VARCHAR2 DEFAULT NULL,
                                    pctipide IN NUMBER DEFAULT NULL)
      RETURN SYS_REFCURSOR;

   /*************************************************************************
   Obtiene los datos en un objeto OB_IAX_PERSONA
   param out mensajes  : mensajes de error
   return              : El OB_IAX_PERSONA o un null
   *************************************************************************/
   FUNCTION f_get_persona_publica(psperson IN NUMBER,
                                  mensajes OUT t_iax_mensajes)
      RETURN ob_iax_personas;

   -- fin jtg 8063

   --BUG 10074 - JTS - 18/05/2009
   /*************************************************************************
   ObtÃƒÂ© els profesionals associats a una persona
   param in psperson   : Codi sperson
   param out pcur      : Cursor amb les dades
   param out mensajes  : mensajes de error
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_profesionales(psperson IN NUMBER,
                                pcur     OUT SYS_REFCURSOR,
                                mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   ObtÃƒÂ© les companyies associades a una persona
   param in psperson   : Codi sperson
   param out pcur      : Cursor amb les dades
   param out mensajes  : mensajes de error
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_companias(psperson IN NUMBER,
                            pcur     OUT SYS_REFCURSOR,
                            mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   ObtÃƒÂ© els agents associats a una persona
   param in psperson   : Codi sperson
   param out pcur      : Cursor amb les dades
   param out mensajes  : mensajes de error
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_agentes(psperson IN NUMBER,
                          pcur     OUT SYS_REFCURSOR,
                          mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   ObtÃƒÂ© els sinistres associats a una persona
   param in psperson   : Codi sperson
   param out pcur      : Cursor amb les dades
   param out mensajes  : mensajes de error
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_siniestros(psperson IN NUMBER,
                             pcur     OUT SYS_REFCURSOR,
                             mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   --Fi BUG 10074 - JTS - 18/05/2009
   --BUG 10371 - JTS - 09/06/2009
   /*************************************************************************
   ObtÃƒÂ© la select amb els parÃƒÂ metres per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in ptots      : 0.- NomÃƒÂ©s retorna els parÃƒÂ metres contestats
                         1.- Retorna tots els parÃƒÂ metres
   param in ctipper    : Codi tipus persona
   param out pcur      : Cursor
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_parpersona(psperson  IN NUMBER,
                             pcagente  IN NUMBER,
                             pcvisible IN NUMBER,
                             ptots     IN NUMBER,
                             ptablas   IN VARCHAR2,
                             pctipper  IN NUMBER,
                             pcur      OUT SYS_REFCURSOR,
                             mensajes  IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   ObtÃƒÆ’Ã‚Â© la select amb els parÃƒÆ’Ã‚Â metres per persona
        pcparam IN NUMBER,
   param out pcur      : Cursor
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_obparpersona(pcparam       IN VARCHAR2,
                               pobparpersona OUT ob_iax_par_personas,
                               mensajes      IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Inserta el parÃƒÂ metre per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in pcparam    : Codi parametre
   param in pnvalpar   : Resposta numÃƒÂ©rica
   param in ptvalpar   : Resposta text
   param in pfvalpar   : Resposta data
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_ins_parpersona(psperson IN NUMBER,
                             pcagente IN NUMBER,
                             pcparam  IN VARCHAR2,
                             pnvalpar IN NUMBER,
                             ptvalpar IN VARCHAR2,
                             pfvalpar IN DATE,
                             ptablas  IN VARCHAR2,
                             mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Esborra el parÃƒÂ metre per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in pcparam    : Codi parametre
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_del_parpersona(psperson IN NUMBER,
                             pcagente IN NUMBER,
                             pcparam  IN VARCHAR2,
                             ptablas  IN VARCHAR2,
                             mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   --Fi BUG 10371 - JTS - 09/06/2009

   /*************************************************************************
   Esborra el parÃƒÂ metre per persona
   param in psperson   : Codi sperson
   param in porigen    : Origen de los datos 'EST', 'REA'
   param in mensajes   : Codi parametre
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_contratos_host(psperson IN NUMBER,
                                 porigen  IN VARCHAR2 DEFAULT 'EST',
                                 mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /*************************************************************************
      Recupera las ccc en HOST con las cuentas de axis si esa persona ya esta traspasada.
      Solo personas que pertenecen a una póliza, es decir las personas no pÃƒÂºblicas no las devuelve
      param in nsip      : identificador externo de persona
      param in psperson      : identificador interno de persona
      param in porigen      : De que tablas extraer la información
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_ccc_host_axis(psperson IN VARCHAR2,
                                psnip    IN VARCHAR2,
                                pcagente IN NUMBER,
                                porigen  IN VARCHAR2 DEFAULT 'EST',
                                mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   FUNCTION f_existe_ccc(psperson IN NUMBER,
                         pcagente IN NUMBER,
                         pcbancar IN VARCHAR2,
                         pctipban IN NUMBER,
                         mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
      FUNCTION función que crea un detalle sinó existe la persona con el detalle del agente
      que le estamos pasando
      param in psperson    : Persona de la qual el detalle vamos a duplicar
      param in pcagente    : Agente del qual hemos obtenido el detalle
      param in pcagente_prod : Agente del siniestros que estamos trabajando
      return           : código de error

       ---- Bug 16753: CRE - Pantalla destinatarios - 22/11/2010 - XPL
   *************************************************************************/
   FUNCTION f_inserta_detalle_per(psperson      IN NUMBER,
                                  pcagente      IN NUMBER,
                                  pcagente_prod IN NUMBER,
                                  mensajes      IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION función que nos comprueba si la persona tiene el mismo nnumide
      param in pnnumide    : Nnumide que vamos a comprobar
      param out pduplicada : Miramos si esta duplicada
      return           : código de error

       ---- Bug 17563 : AGA800 - data naixement - 08/03/2011 - XPL
   *************************************************************************/
   FUNCTION f_persona_duplicada(psperson   IN NUMBER,
                                pnnumide   IN VARCHAR2,
                                pcsexper   IN NUMBER,
                                pfnacimi   IN DATE,
                                psnip      IN VARCHAR2,
                                pcagente   IN NUMBER,
                                pswpubli   IN NUMBER,
                                pctipide   IN NUMBER,
                                pduplicada OUT NUMBER,
                                mensajes   OUT t_iax_mensajes,
                                psolicit   IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION función que recupera la información de las personas relacionadas
      param in psperson    : Persona
      param in pcagente    : Agente
      param in psperson_rel    : Persona rel
      pt_perrel out t_iax_personas_rel : Objeto de personas relacionadas
      return           : código de error
       ---- Bug 18941 - 26/07/2011 - ICV
   *************************************************************************/
   FUNCTION f_get_persona_rel(psperson       IN NUMBER,
                              pcagente       IN NUMBER,
                              psperson_rel   IN NUMBER,
                              pobpersona_rel OUT ob_iax_personas_rel,
                              pcagrupa       IN NUMBER, --TCS 468A 17/01/2019 AP
                              mensajes       IN OUT t_iax_mensajes,
                              ptablas        IN VARCHAR2) RETURN NUMBER;

   /*************************************************************************
      FUNCTION función que recupera la información de las personas relacionada y devuelve una colección
      param in psperson    : Persona
      param in pcagente    : Agente
      pt_perrel out t_iax_personas_rel : Colección de personas relacionadas
      return           : código de error
       ---- Bug 18941 - 19/07/2011 - ICV
   *************************************************************************/
   FUNCTION f_get_personas_rel(psperson       IN NUMBER,
                               pcagente       IN NUMBER,
                               ptablas        IN VARCHAR2,
                               ptpersonas_rel OUT t_iax_personas_rel,
                               mensajes       IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva función que se encarga de borrar una persona relacionada
    return              : 0 Ok. 1 Error
    Bug.: 18941
   *************************************************************************/
   FUNCTION f_del_persona_rel(psperson     IN NUMBER,
                              pcagente     IN NUMBER,
                              psperson_rel IN NUMBER,
                              pcagrupa IN NUMBER, --IAXIS-3670 16/04/2019 AP
                              mensajes     IN OUT t_iax_mensajes,
                              ptablas      IN VARCHAR2) RETURN NUMBER;

   /*************************************************************************
    Nueva función que se encarga de insertar una persona relacionada
    return              : 0 Ok. 1 Error
    Bug.: 18941
   *************************************************************************/
   FUNCTION f_set_persona_rel(psperson        IN NUMBER,
                              pcagente        IN NUMBER,
                              psperson_rel    IN NUMBER,
                              pctipper_rel    IN NUMBER,
                              ppparticipacion IN NUMBER,
                              pislider        IN NUMBER, -- BUG 0030525 - FAL - 01/04/2014
                              mensajes        IN OUT t_iax_mensajes,
                              ptablas         IN VARCHAR2,
							  ptlimit         IN VARCHAR2 DEFAULT '',
                              pcagrupa        IN NUMBER,
                              pfagrupa        IN DATE) RETURN NUMBER;

   /*************************************************************************
      FUNCTION función que recupera la información del regimen fiscal
      param in psperson    : Persona
      param in pcagente    : Agente
      param in pfefecto    : Fecha efectop
      poregimenfiscal out ob_iax_regimenfiscal : Objeto de régimen fiscal
      return           : código de error
       ---- Bug 18942 - 29/07/2011 - ICV
   *************************************************************************/
   FUNCTION f_get_regimenfiscal(psperson        IN NUMBER,
                                pcagente        IN NUMBER,
                                pfefecto        IN DATE,
                                poregimenfiscal OUT ob_iax_regimenfiscal,
                                mensajes        IN OUT t_iax_mensajes,
                                ptablas         IN VARCHAR2) RETURN NUMBER;

   /*************************************************************************
      FUNCTION función que recupera la información de las personas relacionada y devuelve una colección
      param in psperson    : Persona
      param in pcagente    : Agente
      ptregimenfiscal out t_iax_regimenfiscal : Colección de régimen fiscal
      return           : código de error
       ---- Bug 18942 - 29/07/2011 - ICV
   *************************************************************************/
   FUNCTION f_get_regimenfiscales(psperson        IN NUMBER,
                                  pcagente        IN NUMBER,
                                  ptablas         IN VARCHAR2,
                                  ptregimenfiscal OUT t_iax_regimenfiscal,
                                  mensajes        IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Nueva función que se encarga de borrar un régimen fiscal
   return              : 0 Ok. 1 Error
   Bug.: 18942
   *************************************************************************/
   FUNCTION f_del_regimenfiscal(psperson IN NUMBER,
                                pcagente IN NUMBER,
                                pfefecto IN DATE,
                                mensajes IN OUT t_iax_mensajes,
                                ptablas  IN VARCHAR2) RETURN NUMBER;

   /*************************************************************************
    Nueva función que se encarga de insertar el régimen fiscal
    return              : 0 Ok. 1 Error
    Bug.: 18942
   *************************************************************************/
   FUNCTION f_set_regimenfiscal(psperson       IN NUMBER,
                                pcagente       IN NUMBER,
                                pfefecto       IN DATE,
                                pcregfiscal    IN NUMBER,
                                -- CP0025M_SYS_PERS - JLTS - 21/11/2018 - se intercambia el orden de los parámetros pctipiva y pcregfisexeiva
                               /* pctipiva       IN NUMBER,
                                pcregfisexeiva IN NUMBER DEFAULT 0, --AP CONF-190 */
				/* IAXIS-4696 changes by SA */

                                pcregfisexeiva IN NUMBER DEFAULT 0,
				pctipiva       IN NUMBER,
				/* END IAXIS-4696 */

                                mensajes       IN OUT t_iax_mensajes,
                                ptablas        IN VARCHAR2) RETURN NUMBER;

   /*************************************************************************
    Nueva funcion que se encarga de recuperar registros de SARLAFT
    return              : 0 Ok. 1 Error
    Bug.: 18943
   ************************************************************************/
   FUNCTION f_get_sarlafts(psperson  IN NUMBER,
                           pcagente  IN NUMBER,
                           ptablas   IN VARCHAR2,
                           ptsarlaft OUT t_iax_sarlaft,
                           mensajes  IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
    Nueva funcion que se encarga de borrar un registro de SARLAFT
    return              : 0 Ok. 1 Error
    Bug.: 18943
   *************************************************************************/
   FUNCTION f_del_sarlaft(psperson IN NUMBER,
                          pcagente IN NUMBER,
                          pfefecto IN DATE,
                          mensajes IN OUT t_iax_mensajes,
                          ptablas  IN VARCHAR2) RETURN NUMBER;

   /*************************************************************************
    Nueva funcion que se encarga de insertar un registro de SARLAFT
    return              : 0 Ok. 1 Error
    Bug.: 18943
   *************************************************************************/
   FUNCTION f_set_sarlaft(psperson IN NUMBER,
                          pcagente IN NUMBER,
                          pfefecto IN DATE,
                          mensajes IN OUT t_iax_mensajes,
                          ptablas  IN VARCHAR2) RETURN NUMBER;

   /*************************************************************************
    Nueva funcion que obtiene información de los gestores/empleados de la persona
    param in psperson   : Codigo sperson
    param out pcur      : Cursor con la informacion
    param out mensajes  : mensajes de error
    return              : 0.- OK, 1.- KO
    Bug 18947
   *************************************************************************/
   FUNCTION f_get_gestores_empleados(psperson IN NUMBER,
                                     pcur     OUT SYS_REFCURSOR,
                                     mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva funcion que obtiene información de los representantes/promotores de la persona
    param in psperson   : Codigo sperson
    param out pcur      : Cursor con la informacion
    param out mensajes  : mensajes de error
    return              : 0.- OK, 1.- KO
    Bug 18947
   *************************************************************************/
   FUNCTION f_get_represent_promotores(psperson IN NUMBER,
                                       pcur     OUT SYS_REFCURSOR,
                                       mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Nueva funcion que obtiene información de los representantes/promotores asociados a un coordinador
    param in psperson   : Codigo sperson
    param out pcur      : Cursor con la informacion
    param out mensajes  : mensajes de error
    return              : 0.- OK, 1.- KO
    Bug 18947
   *************************************************************************/
   FUNCTION f_get_coordinadores(psperson IN NUMBER,
                                pcur     OUT SYS_REFCURSOR,
                                mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
    Nueva funcion que obtiene información de las listas oficiales del estado de la persona
    param in psperson   : Codigo sperson
    param in pcclalis   : Identificador de clase de lista
    param out pcur      : Cursor con la informacion
    param out mensajes  : mensajes de error
    return              : 0.- OK, 1.- KO
    Bug 18947
   *************************************************************************/
   FUNCTION f_get_listas_oficiales(psperson IN NUMBER,
                                   pcclalis IN NUMBER,
                                   pcur     OUT SYS_REFCURSOR,
                                   mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 18946 - APD - 28/10/2011 - se crea la funcion
   FUNCTION ff_agente_cpolvisio(pcagente IN agentes.cagente%TYPE,
                                pfecha   IN DATE DEFAULT f_sysdate,
                                pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa)
      RETURN NUMBER;

   /*************************************************************************
    función que torna l'agent de visio de polizas passant-li un agent
   *************************************************************************/
   -- Bug 18946 - APD - 28/10/2011 - se crea la funcion
   FUNCTION f_agente_cpolvisio(pcagente   IN agentes.cagente%TYPE,
                               pfecha     IN DATE DEFAULT f_sysdate,
                               pcempres   IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa(),
                               pcpolvisio IN OUT NUMBER,
                               mensajes   IN OUT t_iax_mensajes) RETURN NUMBER;

   -- Bug 18946 - APD - 28/10/2011 - se crea la funcion
   FUNCTION ff_agente_cpolnivel(pcagente IN agentes.cagente%TYPE,
                                pfecha   IN DATE DEFAULT f_sysdate,
                                pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa)
      RETURN NUMBER;

   /*************************************************************************
    función que torna l'agent de nivel de polizas passant-li un agent
   *************************************************************************/
   -- Bug 18946 - APD - 28/10/2011 - se crea la funcion
   FUNCTION f_agente_cpolnivel(pcagente   IN agentes.cagente%TYPE,
                               pfecha     IN DATE DEFAULT f_sysdate,
                               pcempres   IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa(),
                               pcpolnivel IN OUT NUMBER,
                               mensajes   IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
     función que recuperarÃƒÂ¡ todas la personas dependiendo del modo.
     publico o no. servirÃƒÂ¡ para todas las pantallas donde quieran utilizar el
     buscador de personas.

     Bug 20044/97773 - 12/11/2011 - AMC
   *************************************************************************/
   FUNCTION f_get_personas_generica_cond(pnumide       IN VARCHAR2,
                                         pnombre       IN VARCHAR2,
                                         pnsip         IN VARCHAR2 DEFAULT NULL,
                                         mensajes      IN OUT t_iax_mensajes,
                                         pnom          IN VARCHAR2 DEFAULT NULL,
                                         pcognom1      IN VARCHAR2 DEFAULT NULL,
                                         pcognom2      IN VARCHAR2 DEFAULT NULL,
                                         pctipide      IN NUMBER DEFAULT NULL,
                                         pcagente      IN NUMBER DEFAULT NULL,
                                         pmodo_swpubli IN VARCHAR2,
                                         pcond         IN VARCHAR2)
      RETURN SYS_REFCURSOR;

   /*************************************************************************
     función que inserta o actualiza los datos de un documento asociado a la persona

     Bug 20126 - APD - 23/11/2011 - se crea la funcion
   *************************************************************************/
   FUNCTION f_set_docpersona(psperson    IN NUMBER,
                             pcagente    IN NUMBER,
                             pfcaduca    IN DATE,
                             ptobserva   IN VARCHAR2,
                             piddocgedox IN OUT NUMBER,
                             ptdocumento IN NUMBER DEFAULT NULL,
                             pedocumento IN NUMBER DEFAULT NULL,
                             pfedo       IN DATE DEFAULT NULL,
                             mensajes    IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
      FUNCTION función que recupera la información de los datos de un documento
      asociado a la persona.
      param in psperson    : Persona
      param in pcagente    : Agente
      param in piddocgedox  : documento gedox
      pobdocpersona out ob_iax_docpersona : Objeto de documentos de personas
      return           : código de error
       ---- Bug 20126 - 23/11/2011 - APD
   *************************************************************************/
   FUNCTION f_get_docpersona(psperson      IN NUMBER,
                             pcagente      IN NUMBER,
                             piddocgedox   IN NUMBER,
                             ptablas       IN VARCHAR2,
                             pobdocpersona OUT ob_iax_docpersona,
                             mensajes      IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION función que recupera la información de los datos de un documento
      asociado a la persona.
      param in psperson    : Persona
      param in pcagente    : Agente
      ptdocpersona out t_iax_docpersona : Colección de objetos de documentos de personas
      return           : código de error
       ---- Bug 20126 - 23/11/2011 - APD
   *************************************************************************/
   FUNCTION f_get_documentacion(psperson     IN NUMBER,
                                pcagente     IN NUMBER,
                                ptablas      IN VARCHAR2,
                                ptdocpersona OUT t_iax_docpersona,
                                mensajes     IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***************************************************************************
   Funcin para obtener el dgito de control del documento de identidad de Colombia
   Tipos de documento a los que puede aplicar calcular el dgito de control
   Tipo de Documento ------------------- Tipo -------- Regla de validacin - Tamao -----
   36 - Cdula ciudadana                Numrico      Nmeros               Entre 3 y 10
   *****************************************************************************/
   FUNCTION f_digito_nif_col(pctipide IN NUMBER,
                             pnnumide IN VARCHAR2,
                             mensajes IN OUT t_iax_mensajes) RETURN VARCHAR2;

   /**************************************************************
   Funci que valida que si hay una ccc con pagos de siniestros
      param in psperson : codigo de persona
      param in pcagente : codigo del agente
      param out pcodilit : codigo del literal a mostrar
      return codigo error : 0 - ok ,codigo de error
      BUG 20958/104928 - 24/01/2012 - AMC

      Bug 21867/111852 - 29/03/2012 - AMC
    **************************************************************/
   FUNCTION f_valida_pagoccc(psperson  IN NUMBER,
                             pcagente  IN NUMBER,
                             pcnordban IN NUMBER,
                             pcodilit  IN OUT NUMBER,
                             mensajes  IN OUT t_iax_mensajes) RETURN NUMBER;

   /***************************************************************************
   Funcin bloquear una persona por LOPD
   Traspasar los datos de la persona a las tablas LOPD
   *****************************************************************************/
   FUNCTION f_bloquear_persona(psperson IN NUMBER,
                               pcagente IN NUMBER,
                               mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /***************************************************************************
   Funcin desbloquear una persona por LOPD
   Volver a deja la persona igual que antes que el traspaso a las tablas LOPD
   *****************************************************************************/
   FUNCTION f_desbloquear_persona(psperson IN NUMBER,
                                  pcagente IN NUMBER,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***************************************************************************
   Funcin borra persona de la lopd
   *****************************************************************************/
   FUNCTION f_borrar_persona_lopd(psperson IN NUMBER,
                                  pcagente IN NUMBER,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       FUNCTION funcin que recupera la informacin de la lopd
       param in psperson    : Persona
       param in pcagente    : Agente
       return           : cdigo de error
   *************************************************************************/
   FUNCTION f_get_perlopd(psperson IN NUMBER,
                          pcagente IN NUMBER,
                          pperlopd OUT t_iax_perlopd,
                          pcestado OUT NUMBER,
                          ptestado OUT VARCHAR2,
                          mensajes IN OUT t_iax_mensajes,
                          ptablas  IN VARCHAR2) RETURN NUMBER;

   /***************************************************************************
   Funcin inserta un nuevo movimiento en LOPD
   *****************************************************************************/
   FUNCTION f_set_persona_lopd(psperson       IN NUMBER,
                               pcagente       IN NUMBER,
                               pcesion        IN NUMBER,
                               ppublicidad    IN NUMBER,
                               pacceso        IN NUMBER,
                               prectificacion IN NUMBER,
                               mensajes       IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       FUNCTION que recupera los carnets de una persona
       param in psperson    : Persona
       param in pcagente    : Agente
       return           : cdigo de error
   *************************************************************************/
   FUNCTION f_get_perautcarnets(psperson       IN NUMBER,
                                pcagente       IN NUMBER,
                                pperautcarnets OUT t_iax_perautcarnets,
                                mensajes       IN OUT t_iax_mensajes,
                                ptablas        IN VARCHAR2) RETURN NUMBER;

   /**************************************************************
     FunciÃ³ para obtener la lista de autorizaciones de contactos y la lista de autorizaciones de direcciones
     param in psperson : codigo de persona
     param in pcagente : codigo del agente
     return lista de autorizaciones
     BUG 18949/103391 - 02/02/2012 - AMC
   **************************************************************/
   FUNCTION f_get_autorizaciones(psperson IN NUMBER,
                                 pcagente IN NUMBER,
                                 mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_personas_aut;

   /**************************************************************
     FunciÃ³ para obtener la lista de autorizaciones de contactos
     param in psperson : codigo de persona
     param in pcagente : codigo del agente
     return lista de autorizaciones
     BUG 18949/103391 - 02/02/2012 - AMC
   **************************************************************/
   FUNCTION f_get_contacto_aut(psperson       IN NUMBER,
                               pcagente       IN NUMBER,
                               pcmodcon       IN NUMBER,
                               pnorden        IN NUMBER,
                               obcontacto_aut OUT ob_iax_contactos_aut,
                               mensajes       IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************
     FunciÃ³ para obtener la lista de autorizaciones de direcciones
     param in psperson : codigo de persona
     param in pcagente : codigo del agente
     param in pcdomic : codigo del domicilio
     param in pnorden : numero de orden
     param out obdireccion_aut
     param out mensajes
     return codigo error : 0 - ok ,codigo de error
     BUG 18949/103391 - 02/02/2012 - AMC
   **************************************************************/
   FUNCTION f_get_direccion_aut(psperson        IN NUMBER,
                                pcagente        IN NUMBER,
                                pcdomici        IN NUMBER,
                                pnorden         IN NUMBER,
                                obdireccion_aut OUT ob_iax_direcciones_aut,
                                mensajes        IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************
     FunciÃ³ para guardar los contactos
     param in psperson : codigo de persona
     param in pcagente : codigo del agente
     param in pcmodcon : codigo del contacto
     param in pnorden : numero de orden
     param out obdireccion_aut
     param out mensajes
     return codigo error : 0 - ok ,codigo de error
     BUG 18949/103391 - 02/02/2012 - AMC
   **************************************************************/
   FUNCTION f_set_contacto_aut(psperson  IN NUMBER,
                               pcagente  IN NUMBER,
                               pcmodcon  IN NUMBER,
                               ptcomcon  IN VARCHAR2,
                               pnorden   IN NUMBER,
                               pcestado  IN NUMBER,
                               ptobserva IN VARCHAR2,
                               mensajes  IN OUT t_iax_mensajes) RETURN NUMBER;

   /**************************************************************
     FunciÃ³ para guardar las direcciones
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
   FUNCTION f_set_direccion_aut(psperson  IN NUMBER,
                                pcagente  IN NUMBER,
                                pcdomici  IN NUMBER,
                                pnorden   IN NUMBER,
                                pcestado  IN NUMBER,
                                ptobserva IN VARCHAR2,
                                mensajes  IN OUT t_iax_mensajes) RETURN NUMBER;

   --INI BUG 22642--ETM --24/07/2012

   /**************************************************************
     FUNCION f_get_inquiaval
     Obtiene la select con los inquilinos avalistas
       param in psperson   : Codi sperson
        param in pctipfig    : Codi id de avalista o inqui(1 inquilino , 2 Avalista )
       param out pcur   : cursor con los datos
       param out mensajes
       return              : 0.- OK, 1.- KO
   **************************************************************/
   FUNCTION f_get_inquiaval(psperson IN NUMBER,
                            pctipfig IN NUMBER, -- 1 inquilino , 2 Avalista Desde java le pasamos el tipo
                            pcur     OUT SYS_REFCURSOR,
                            mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /**************************************************************
      FUNCION f_get_gescobro
      Obtiene la select con los gestores de cobro
        param in psperson   : Codi sperson
        param out pcur   : cursor con los datos de lo gestores
         param out mensajes
        return              : 0.- OK, 1.- KO
   **************************************************************/
   FUNCTION f_get_gescobro(psperson IN NUMBER,
                           pcur     OUT SYS_REFCURSOR,
                           mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
   Funcion que recupera la informacion de la antiguedad de la persona
   return : cursor con el resultado
   *************************************************************************/
   -- Bug 25542 - APD - se crea la funcion
   FUNCTION f_get_antiguedad(psperson IN NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR;

   /*************************************************************
    funcion que devuelve los conductores
   **************************************************************/
   FUNCTION f_get_conductores(psperson IN NUMBER,
                              mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /*************************************************************************
     funcion que retorna la informacion de paises, provincias y poblaciones
     con un numero de codigo postal en comun.
     param pcpostal : codigo postal relacionado
     param mensajes : mensajes registrados en el proceso
     return : cursor con el resultado
     Bug 33977 mnustes
   *************************************************************************/
   FUNCTION f_get_provinpoblapais(pcpostal IN codpostal.cpostal%TYPE,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

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
   FUNCTION f_get_codpostal(pcpais   IN despaises.cpais%TYPE,
                            pcprovin IN provincias.cprovin%TYPE,
                            pcpoblac IN poblaciones.cpoblac%TYPE,
                            mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /*************************************************************
   funcion que devuelve CODISOTEL en la tabla paises
   **************************************************************/
   FUNCTION f_get_prefijospaises(mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   FUNCTION f_get_hispersona_rel(psperson       IN NUMBER,
                                 pcagente       IN NUMBER,
                                 psperson_rel   IN NUMBER,
                                 pobpersona_rel OUT ob_iax_personas_rel,
                                 mensajes       IN OUT t_iax_mensajes,
                                 ptablas        IN VARCHAR2) RETURN NUMBER;

   /*************************************************************************
      FUNCTION funciÃ³n que recupera la informaciÃ³n de las personas relacionada y devuelve una colecciÃ³n
      param in psperson    : Persona
      param in pcagente    : Agente
      pt_perrel out t_iax_personas_rel : ColecciÃ³n de personas relacionadas
      return           : cÃ³digo de error
       ---- Bug 18941 - 19/07/2011 - ICV
   *************************************************************************/
   FUNCTION f_get_hispersonas_rel(psperson       IN NUMBER,
                                  pcagente       IN NUMBER,
                                  ptablas        IN VARCHAR2,
                                  ptpersonas_rel OUT t_iax_personas_rel,
                                  mensajes       IN OUT t_iax_mensajes)
      RETURN NUMBER;

FUNCTION f_del_datsarlatf(
      pssarlaft IN NUMBER,
      pfradica IN DATE,
      psperson IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_datsarlatf(
      pssarlaft IN NUMBER,
      pfradica IN DATE,
      psperson IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
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
      pcactisec IN VARCHAR2,
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
      pcconfir     IN NUMBER DEFAULT NULL, --IAXIS-3287 01/04/2019
	  mensajes OUT t_iax_mensajes)    -- CP0727M_SYS_PERS_Val - Inc. 2169 - ACL - 23/11/2018
      RETURN NUMBER;

   FUNCTION f_del_detsarlatf_dec(
      pndeclara IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_detsarlatf_dec(
      pndeclara IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_detsarlatf_act(
      pnactivi IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_detsarlaft_rec(
      pnrecla IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
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
    ptablas in           : tablas defiitivas o est.
    param out mensajes   : mesajes de error
    return               : number
   *************************************************************************/
   FUNCTION f_get_permarcas(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      permarcas OUT t_iax_permarcas,
      mensajes IN OUT t_iax_mensajes,
      ptablas IN VARCHAR2) RETURN NUMBER;
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
      permarca OUT ob_iax_permarcas,
      mensajes IN OUT t_iax_mensajes,
      ptablas IN VARCHAR2)
      RETURN NUMBER;
   --FIN BUG CONF-186  - Fecha (22/08/2016) - HRE

       FUNCTION f_get_riesgo_financiero(psperson  IN NUMBER,
                           ptablas   IN VARCHAR2,
                           ptriesgo_financiero OUT t_iax_riesgo_financiero,
                           mensajes  IN OUT t_iax_mensajes)
    RETURN NUMBER;



      FUNCTION f_get_riesgo(psperson  IN NUMBER,pnmovimi  IN NUMBER,
                          ptriesgo_financiero OUT ob_iax_riesgo_financiero,
                          mensajes  IN OUT t_iax_mensajes,
                          ptablas   IN VARCHAR2)
  RETURN NUMBER;

  FUNCTION f_set_persona_cifin(
      vnnumide IN VARCHAR2,
      mensajes in OUT t_iax_mensajes)
      RETURN NUMBER;

  PROCEDURE parsear (p_clob IN CLOB, p_parser IN OUT xmlparser.parser);

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
      mensajes    IN OUT t_iax_mensajes
    ) RETURN NUMBER;

    FUNCTION f_get_cpep_sarlatf(
      PSSARLAFT IN  NUMBER ,
      mensajes  IN OUT t_iax_mensajes
    ) RETURN sys_refcursor;

    FUNCTION f_del_cpep_sarlatf(
      PSSARLAFT       IN  NUMBER,
      PIDENTIFICACION IN NUMBER,
      mensajes        IN OUT t_iax_mensajes
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
      mensajes    IN OUT t_iax_mensajes
    )  RETURN NUMBER;

    FUNCTION f_get_caccionista_sarlatf (
      PSSARLAFT IN  NUMBER ,
      mensajes  IN OUT t_iax_mensajes
    )  RETURN sys_refcursor;

    FUNCTION f_del_caccionista_sarlatf (
      PSSARLAFT       IN  NUMBER,
      PIDENTIFICACION IN NUMBER,
      mensajes        IN OUT t_iax_mensajes
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
      mensajes        IN OUT t_iax_mensajes
    ) RETURN NUMBER;

    FUNCTION f_get_accionista_sarlatf (
      PSSARLAFT IN  NUMBER ,
      mensajes  IN OUT t_iax_mensajes
    ) RETURN sys_refcursor;

    FUNCTION f_del_accionista_sarlatf (
      PSSARLAFT       IN  NUMBER,
      PIDENTIFICACION IN NUMBER,
      mensajes        IN OUT t_iax_mensajes
    ) RETURN NUMBER;


    FUNCTION f_get_ultimosestados_sarlatf (
      PSPERSON   IN  NUMBER,
      mensajes   IN OUT t_iax_mensajes
    ) RETURN sys_refcursor;

    FUNCTION f_get_persona_sarlaf(
      psperson IN NUMBER,
      mensajes IN OUT t_iax_mensajes
    ) RETURN sys_refcursor;

--INI--WAJ
   FUNCTION f_get_impuestos(psperson        IN NUMBER,
                                  ptablas         IN VARCHAR2,
                                  mensajes        IN OUT t_iax_mensajes,
                                  ptimpuestos OUT t_iax_impuestos)
      RETURN NUMBER;
 -------------------------------------------------------------------------------
FUNCTION f_get_impuesto(psperson        IN NUMBER,
                               ptablas         IN VARCHAR2,
                               psctipind    IN NUMBER,
                               mensajes        IN OUT t_iax_mensajes,
                               poimpuestos OUT  ob_iax_impuestos
                              )
                               RETURN NUMBER;

 FUNCTION f_del_impuesto(psperson IN NUMBER,
                                pctipind IN NUMBER,
                                mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

	FUNCTION f_get_tipo_vinculacion (
      psperson IN  NUMBER ,
      mensajes  OUT t_iax_mensajes
    ) RETURN sys_refcursor;

--FIN--WAJ

	-- Ini TCS_1569B - ACL - 01/02/2019
 /*************************************************************************
   Obtiene los datos en un objeto OB_IAX_PERSONA
   param out mensajes  : mensajes de error
   return              : El OB_IAX_PERSONA o un null
   *************************************************************************/
   FUNCTION f_get_persona_publica_imp(psperson IN NUMBER,
                                  pctipage IN NUMBER DEFAULT NULL,
                                  mensajes OUT t_iax_mensajes)
      RETURN ob_iax_personas;
	--  Fin TCS_1569B - ACL - 01/02/2019

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
    --IAXIS-3670 16/04/2019 AP
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
    --IAXIS-3670 16/04/2019 AP

	/*************************************************************************
	For IAXIS-4149 by PK-18/07/2019
	FUNCTION F_GET_CODITIPOBANC : Nueva funcion para obtener tipo de CUENTA.
		PCBANCO Código de Banco.
		PCTIPCC Que tipo de cuenta és.
	return              : 0 si ha ido bien, 1 si ha ido mal.
	*************************************************************************/
	FUNCTION F_GET_CODITIPOBANC(PCBANCO IN NUMBER, PCTIPCC IN VARCHAR2, PCTIPBAN OUT NUMBER)
      RETURN NUMBER;
      
END pac_md_persona;

/