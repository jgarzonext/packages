  CREATE OR REPLACE PACKAGE BODY "PAC_IAX_PERSONA" IS
   /******************************************************************************
      NOMBRE:       PAC_IAX_PERSONA
      PROPÓSITO: Funciones para gestionar personas

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        04/04/2008   JRH                1. Creación del package.
      2.0        18/05/2009   JTS                2. 10074: Modificaciones en el Mantenimiento de Personas
      3.0        09/06/2009   JTS                3. 10371: APR - tipo de empresaf
      4.0        02/07/2009   XPL                4. 10339 i 9227, APR - Campos extra en la búsqueda de personas
                                                                i APR - Error al crear un agente
      5.0        16/09/2009   AMC                5. 11165: Se sustituÃ±e  T_iax_saldodeutorseg por t_iax_prestamoseg
      6.0        16/11/2009   NMM                6. 11948: CEM - Alta de destinatatios.
      7.0        11/12/2009   DRA                7. 0010569: CRE080 - Suplementos/ Anulaciones para el producto Saldo Deutors
      8.0        09/02/2010   DRA                8. 0011171: APR - campos de búsqueda en el mto. de personas
      9.0        09/07/2010   JTS                9. 0015199: Nova Petició - CV FinanÃ§ament: Canvi en comportament en cartera i suplements
     10.0        22/11/2010   XPL               10. 16753: CRE - Pantalla destinatarios - 22/11/2010 - XPL
     11.0        11/04/2011   APD               11. 0018225: AGM704 - Realizar la modificación de precisión el cagente
     12.0        14/06/2011   APD               12. 0017931: CRE800 - Persones duplicades
     13.0        27/07/2011   ICV               13. 0018941: LCOL_P001 - PER - Personas relacionadas. Representante legal
     14.0        23/09/2011   MDS               14. 0018943  Modulo SARLAFT en el mantenimiento de personas
     15.0        04/10/2011   MDS               15. 0018947: LCOL_P001 - PER - Posición global
     16.0        08/11/2011   JGR               16. 0019985 LCOL_A001-Control de las matriculas (prenotificaciones)
     17.0        23/11/2011   APD               17. 0020126: LCOL_P001 - PER - Documentación en personas
     18.0        10/01/2012   JGR               18. 0020735/0103205 Modificaciones tarjetas y ctas.bancarias
     19.0        11/07/2012   ETM               19. 0022263: LCOL_P001 - PER - Informaci?n relacionado con documentos identificativos.
     20.0        24/07/2012   ETM               20. 0022642: MDP - PER - Posici??lobal. Inquilinos, avalistas y gestor de cobro
     21.0        26/11/2012   DRA               21. 0024653: MDP - PER - Suplementos relacionados con personas.
     22.0        21/01/2013   APD               22. 0025542: LCOL_T031- LCOL - AUT - (id 431) Fecha de antig?edad en personas por agrupaci?n
     23.0        31/01/2013   JDS               23. 0025542: LCOL_T031- LCOL - AUT - (id 431) Fecha de antig?edad en personas por agrupaci?n
     24.0        25/06/2013   RCL               24. 0024697: Canvi mida camp sseguro
     25.0        08/07/2013   RCL               25. 0025599: LCOL - PER - Revision incidencias qtracker y Releases
     26.0        05/08/2013   RCL               26. 0027814: LCOL - PER - Nuevo contacto en el alta rápida de personas Fax.
     27.0        03/04/2014   FAL               27. 0030525: INT030-Prueba de concepto CONFIANZA
     28.0        27/07/2015   IGIL              28. 0036596  MSV - diferenciar opersonas juridicas Hospitales
     29.0        23/06/2016   ERH               29. CONF-52 Modificación de la función f_set_persona_rel se adiciona al final el parametro â€¢   PTLIMIT VARCHAR2
     30.0        22/08/2016   HRE               30. CONF-186: Se incluyen procesos para gestion de marcas.
     31.0        23/11/2018   ACL               31. CP0727M_SYS_PERS_Val Se agrega en la función f_set_datsarlatf el parámetro pcorigenfon.
     32.0        18/12/2018   ACL               32. CP0416M_SYS_PERS Se agrega la función f_get_persona_sarlaf.
     33.0        07/01/2019   SWAPNIL           33. Cambios para solicitudes múltiples
     34.0        29/01/2019   WAJ               34.Se aidicona consulta para traer los indicadores de las personas
     35.0        01/02/2019   ACL               35. TCS_1569B: Se agrega la función f_get_persona_publica_imp.
     36.0        12/02/2019   AP                34. TCS-9: Se adiciona campos en la funcion f_set_datsarlatf para clausulas.
     37.0        20/03/2019   CES               37. IAXIS-3060: Ajuste Codigo identificacion del sistema Consorcios. 
     38.0        01/04/2019   DFRP              38. IAXIS-3287:FCC (Formulario de Conocimiento de Cliente).
     39.0        27/06/2019   KK                39. CAMBIOS De IAXIS-4538
     40.0        18/07/2019   PK                40. Added function for IAXIS-4149 - Modificación Cuentas Bancarias
     41.0        05/09/2019   DFRP              41. IAXIS-4832(4): Refinamiento revision final
     42.0        10/02/2020   CJMR              42. IAXIS-3670: Solución bug IAXIS-11917. Modificación de la función f_valida_consorcios
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
   /*Limpia los objectos*/
   FUNCTION f_limpiar_objetos(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      condicio       VARCHAR2(1000);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vpsseguro      NUMBER;
      vparam         VARCHAR2(2000);
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_limpiar_objectos';
   BEGIN
      pac_iax_persona.parpersonas := NULL;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_limpiar_objetos;

   /* Svj. bug 5912*/
   /*************************************************************************
      Recupera la lista de personas que coinciden con los criterios de consulta.
      param in numide    : número documento
      param in nombre    : texto que incluye nombre + apellidos
      param in nsip      : identificador externo de persona, puede ser nulo
      param out mensajes : mensajes de error
      param in psseguro  : identificador interno de seguro, puede ser nulo
      param in pnom      : nombre de la persona, puede ser nulo
      param in pcognom1  : apellido 1 de la persona, puede ser nulo
      param in pcognom2  : apellido 2 de la persona, puede ser nulo
      param in pctipide  : tipo de documento identificativo, puede ser nulo
      param in phospital : Es hospital ?
      return             : ref cursor
   *************************************************************************/
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
      RETURN sys_refcursor IS
      condicio       VARCHAR2(1000);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vpsseguro      NUMBER;
      vparam         VARCHAR2(2000)
         := 'numide= ' || numide || ', nombre= ' || nombre || ', nsip= ' || nsip
            || ', psseguro= ' || psseguro || ', pnom= ' || pnom || ', pcognom1= ' || pcognom1
            || ', pcognom2= ' || pcognom2 || ', pctipide= ' || pctipide || ', pfnacimi =  '
            || pfnacimi || ', ptdomici =  ' || ptdomici || ',pcpostal =  ' || pcpostal
            || ' phospital = ' || phospital;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_Personas_Agentes';
   BEGIN
      vpsseguro := psseguro;

      IF pac_iax_produccion.issuplem THEN
         vpsseguro := NVL(pac_iax_produccion.vsolicit, psseguro);
      END IF;

      cur := pac_md_persona.f_get_personas_agentes(numide, nombre, nsip, mensajes, vpsseguro,
                                                   pnom, pcognom1, pcognom2, pctipide,
                                                   pfnacimi, ptdomici, pcpostal, phospital,
                                                   pfideico);   -- Bug 36596 IGIL
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_personas_agentes;

   /* JLB - I - 6044*/
   /*************************************************************************
      Recupera la lista de personas contra el HOST que coinciden con los criterios de consulta
      param in numide    : número documento
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
   FUNCTION f_get_personas_host(
      numide IN VARCHAR2,
      nombre IN VARCHAR2,
      nsip IN VARCHAR2 DEFAULT NULL,
      mensajes OUT t_iax_mensajes,
      psseguro IN NUMBER DEFAULT NULL,
      /*JRH 04/2008 Se pasa el seguro*/
      pnom IN VARCHAR2 DEFAULT NULL,
      pcognom1 IN VARCHAR2 DEFAULT NULL,
      pcognom2 IN VARCHAR2 DEFAULT NULL,
      pctipide IN NUMBER DEFAULT NULL,
      pomasdatos OUT NUMBER)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'numide= ' || numide || ', nombre= ' || nombre || ', nsip= ' || nsip
            || ', psseguro= ' || psseguro || ', pnom= ' || pnom || ', pcognom1= ' || pcognom1
            || ', pcognom2= ' || pcognom2 || ', pctipide= ' || pctipide;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_Personas_HOST';
   BEGIN
      cur := pac_md_persona.f_get_personas_host(numide, nombre, nsip, mensajes, psseguro,
                                                pnom, pcognom1, pcognom2, pctipide,
                                                pomasdatos);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_personas_host;

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
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' nsip= ' || nsip;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_CCC_HOST';
   BEGIN
      IF numide IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_persona.f_get_ccc_host(numide, nsip, pac_md_common.f_get_cxtagenteprod,
                                           porigen, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ccc_host;

   /* JLB - F - 6044*/
   /*************************************************************************
      Recupera la lista de personas que coinciden con los criterios de consulta
      param in numide    : número documento
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
   FUNCTION f_get_personas(
      numide IN VARCHAR2,
      nombre IN VARCHAR2,
      nsip IN VARCHAR2 DEFAULT NULL,
      mensajes OUT t_iax_mensajes,
      psseguro IN NUMBER DEFAULT NULL,   /*JRH 04/2008 Se pasa el seguro*/
      pnom IN VARCHAR2 DEFAULT NULL,
      pcognom1 IN VARCHAR2 DEFAULT NULL,
      pcognom2 IN VARCHAR2 DEFAULT NULL,
      pctipide IN NUMBER DEFAULT NULL)
      RETURN sys_refcursor IS
      condicio       VARCHAR2(1000);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'numide= ' || numide || ', nombre= ' || nombre || ', nsip= ' || nsip
            || ', psseguro= ' || psseguro || ', pnom= ' || pnom || ', pcognom1= ' || pcognom1
            || ', pcognom2= ' || pcognom2 || ', pctipide= ' || pctipide;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_Personas';
   BEGIN
      cur := pac_md_persona.f_get_personas(numide, nombre, nsip, mensajes, psseguro, pnom,
                                           pcognom1, pcognom2, pctipide);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_personas;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Traspasa a las EST si es necesario desde las tablas reales
      param out mensajes  : mensajes de error
      return              : 0 o código error
   *************************************************************************/
   FUNCTION f_traspasapersonaest(
      psperson IN NUMBER,
      /* I - JLb -*/
      psnip IN VARCHAR2,
      /* F - JLb -*/
      pcagente IN NUMBER,
      pcoditabla IN VARCHAR2,
      psperson_out OUT NUMBER,
      psseguro IN NUMBER,
      pmensapotup OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' - pcodiTabla: ' || pcoditabla
            || ' eg: ' || psseguro || ' psnip: ' || psnip;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_TraspasaPersonaEst';
      vcagente       NUMBER;
      /* Bug 18225 - APD - 11/04/2011 - la precisión de cdelega debe ser NUMBER*/
      vpsseguro      NUMBER := psseguro;   /*ACC 020209*/
   BEGIN
      IF psperson IS NULL
         AND psnip IS NULL   /* JLB - 6353*/
                          THEN
         RAISE e_param_error;
      END IF;

      vpsseguro := psseguro;

      IF pac_iax_produccion.issuplem THEN
         /* Si sóm a les taules EST s'ha d'agafar el vsolicit.#6.*/
         IF pcoditabla = 'EST' THEN
            vpsseguro := NVL(pac_iax_produccion.vsolicit, psseguro);
         END IF;

         /*BUG9727-28042009-XVM*/
         vnumerr := pac_seguros.f_get_cagente(vpsseguro, 'EST', vcagente);

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;
      ELSE
         vcagente := pac_md_common.f_get_cxtagenteprod;
      END IF;

      vnumerr := pac_md_persona.f_traspasapersona(psperson, psnip,   /* JLB - I - 6353*/
                                                  vcagente, pcoditabla, psperson_out,
                                                  vpsseguro, 'EST'   -- BUG 11948
                                                                  , pmensapotup, mensajes);
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_traspasapersonaest;

   /*************************************************************************
      Valida el nif
      param out mensajes  : mensajes de error
      return              : 0 o código error
   *************************************************************************/
   FUNCTION f_validanif(
      pnnumide IN per_personas.nnumide%TYPE,
      pctipide IN per_personas.ctipide%TYPE,
      csexper IN per_personas.csexper%TYPE,
      /* -- sexo de la pesona.*/
      fnacimi IN per_personas.fnacimi%TYPE,
      /* -- Fecha de nacimiento de la persona*/
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                       := 'parámetros - pnnumide: ' || pnnumide || ' - pctipide: ' || pctipide;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_validaNif';
   BEGIN
      vnumerr := pac_md_persona.f_validanif(pnnumide, pctipide, csexper, fnacimi, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RETURN 1;
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
   END f_validanif;

   FUNCTION f_set_estpersona(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pspersonout OUT NUMBER,
      pspereal IN NUMBER,
      pcagente IN NUMBER,
      ctipper IN NUMBER,   /* Â¿ tipo de persona (física o jurídica)*/
      ctipide IN NUMBER,   /* Â¿ tipo de identificación de persona*/
      nnumide IN VARCHAR2,
      /*  -- Número identificativo de la persona.*/
      csexper IN NUMBER,   /*     -- sexo de la pesona.*/
      fnacimi IN DATE,   /*   -- Fecha de nacimiento de la persona*/
      snip IN VARCHAR2,   /*  -- snip*/
     cestper IN NUMBER,
      fjubila IN DATE,
      cmutualista IN NUMBER,
      fdefunc IN DATE,
      nordide IN NUMBER,
      cidioma IN NUMBER,   /*-      Código idioma*/
      tapelli1 IN VARCHAR2,   /*      Primer apellido*/
      tapelli2 IN VARCHAR2,   /*      Segundo apellido*/
      tnombre IN VARCHAR2,   /*     Nombre de la persona*/
      tsiglas IN VARCHAR2,   /*     Siglas persona jurídica*/
      cprofes IN VARCHAR2,   /*     Código profesión*/
      cestciv IN NUMBER,   /* Código estado civil. VALOR FIJO = 12*/
      cpais IN NUMBER,   /*     Código país de residencia*/
      ptnombre1 IN VARCHAR2,
      ptnombre2 IN VARCHAR2,
      pswrut IN NUMBER,
      pcocupacion IN VARCHAR2,   /* Bug 25456/133727 - 16/01/2013 - AMC*/
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' - Pspereal: ' || pspereal || ' '
            || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Set_EstPersona';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
      pduplicada     NUMBER;   /* Bug 17931 - APD - 13/05/2011*/
      vpsseguro      NUMBER;   /* BUG24653:DRA:20/11/2012*/
   BEGIN
      IF psperson IS NOT NULL THEN
         pspersonout := psperson;
      END IF;

      /* BUG24653:DRA:20/11/2012:Inici*/
      vpsseguro := psseguro;

      /* BUG24653:DRA:20/11/2012:Fi Si estamos en modo suplemento..*/
      IF pac_iax_produccion.issuplem THEN
         vnumerr := pac_seguros.f_get_cagente(psseguro, 'POL', vcagente);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;

         /* BUG24653:DRA:20/11/2012:Inici*/
         vpsseguro := NVL(pac_iax_produccion.vsolicit, psseguro);
      /* BUG24653:DRA:20/11/2012:Fi*/
      ELSE
         /* DRA 13-10-2008: bug mantis 7784*/
         /* svj Bug 0025938  En nueva producci??ogemos el agente de producci?? si no esta inicializado el de la p??a.*/
         vcagente := pac_md_common.f_get_cxtagenteprod();

         IF vcagente IS NULL THEN
            vnumerr := pac_seguros.f_get_cagente(psseguro, 'EST', vcagente);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;
      /* Fin svj Bug 0025938*/
      END IF;

      /* Bug 17931 - APD - 13/05/2011 - si la persona que se está creando es una persona*/
      /* creada desde simulacion (cestper = 99) y se ha informado el nÂº de documento, se debe*/
      /* validar que no exista otra persona con el mismo nÂº de documento, ya que si existiera se*/
      /* deberia seleccionar dicha persona y no crear una persona desde simulacion*/
      IF cestper = 99
         AND nnumide IS NOT NULL THEN
         /* PERSONA DE SIMULACION*/
         IF nnumide IS NOT NULL THEN
            /* Bug 18668 - APD - 07/06/2011 - se valida que el nnumide sea correcto*/
            vnumerr := pac_md_persona.f_validanif(nnumide, ctipide, csexper, fnacimi,
                                                  mensajes);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;

            /* Fin Bug 18668 - APD - 07/06/2011*/
            vnumerr := pac_md_persona.f_persona_duplicada(psperson, nnumide, csexper, fnacimi,
                                                          snip, vcagente, NULL, ctipide,
                                                          pduplicada, mensajes);

            IF pduplicada <> 0 THEN
               vnumerr := 9001806;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;
      END IF;

      /* Fin Bug 17931 - APD - 13/05/2011 -*/
      vnumerr := pac_md_persona.f_set_persona(vpsseguro, pspersonout, pspereal, vcagente,
                                              ctipper, ctipide, nnumide, csexper, fnacimi,
                                              snip, cestper, fjubila, cmutualista, fdefunc,
                                              nordide, cidioma, tapelli1, tapelli2, tnombre,
                                              tsiglas, cprofes, cestciv, cpais, 'EST', 0, NULL,
                                              ptnombre1, ptnombre2, pswrut, pcocupacion,
                                                                                                                                                                               /* Cambios para solicitudes múltiples : Start */
                                              null,null,null,null,null,null,null,null,
                                              /* Cambios para solicitudes múltiples : End */
                                              /* Bug 25456/133727 - 16/01/2013 - AMC*/
                                              mensajes
											  /* CAMBIOS De IAXIS-4538 : Start */
												,null,null,null,null
											  /* CAMBIOS De IAXIS-4538 : End */
											  );
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_estpersona;

   FUNCTION f_set_persona(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pspersonout OUT NUMBER,
      pspereal IN NUMBER,
      pcagente IN NUMBER,
      ctipper IN NUMBER,   /* Â¿ tipo de persona (física o jurídica)*/
      ctipide IN NUMBER,   /* Â¿ tipo de identificación de persona*/
      nnumide IN VARCHAR2,
      /*  -- Número identificativo de la persona.*/
      csexper IN NUMBER,   /*     -- sexo de la pesona.*/
      fnacimi IN DATE,   /*   -- Fecha de nacimiento de la persona*/
      snip IN VARCHAR2,   /*  -- snip*/
      cestper IN NUMBER,
      fjubila IN DATE,
      cmutualista IN NUMBER,
      fdefunc IN DATE,
      nordide IN NUMBER,
      cidioma IN NUMBER,   /*-      Código idioma*/
      tapelli1 IN VARCHAR2,   /*      Primer apellido*/
      tapelli2 IN VARCHAR2,   /*      Segundo apellido*/
      tnombre IN VARCHAR2,   /*     Nombre de la persona*/
      tsiglas IN VARCHAR2,   /*     Siglas persona jurídica*/
      cprofes IN VARCHAR2,   /*     Código profesión*/
      cestciv IN NUMBER,   /* Código estado civil. VALOR FIJO = 12*/
      cpais IN NUMBER,   /*     Código país de residencia*/
      pswpubli IN NUMBER,
      pduplicada IN NUMBER,
      ptnombre1 IN VARCHAR2,
      ptnombre2 IN VARCHAR2,
      pswrut IN NUMBER,
      pcocupacion IN VARCHAR2,   /* Bug 25456/133727 - 16/01/2013 - AMC*/
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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' - Pspereal: ' || pspereal || ' '
            || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_set_persona';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NOT NULL THEN
         pspersonout := psperson;
      END IF;
       IF pcagente IS NOT NULL THEN
         pcagenteout := pcagente;
      END IF;

      vnumerr := pac_md_persona.f_set_persona(psseguro, pspersonout, pspereal, pcagenteout,
                                              ctipper, ctipide, nnumide, csexper, fnacimi,
                                              snip, cestper, fjubila, cmutualista, fdefunc,
                                              nordide, cidioma, tapelli1, tapelli2, tnombre,
                                              tsiglas, cprofes, cestciv, cpais, 'POL',
                                              pswpubli, pduplicada, ptnombre1, ptnombre2,
                                              pswrut, pcocupacion,
                                              /* Bug 25456/133727 - 16/01/2013 - AMC*/
                                                                                                                                                                               /* Cambios para solicitudes múltiples : Start */
                                              pTipoosc,pCIIU,pSFINANCI,pFConsti,pCONTACTOS_PER,pDIRECCIONS_PER,
                                              pNacionalidad,pDigitoide,
                                              /* Cambios para solicitudes múltiples : End */
                                              mensajes
											  /* CAMBIOS De IAXIS-4538 : Start */
											  ,pfefecto,pcregfiscal,pctipiva,pIMPUETOS_PER
											  /* CAMBIOS De IAXIS-4538 : End */
											  );

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_persona;

 /*************************************************************************
      Obtiene los datos de las EST en un objeto OB_IAX_PERSONAS
      param out mensajes  : mensajes de error
      return              : El OB_IAX_PERSONAS
   *************************************************************************/
   FUNCTION f_get_persona(
      psperson IN NUMBER,
     pcagente IN NUMBER,
      obpersona OUT ob_iax_personas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_Persona';
      objpers        ob_iax_personas := ob_iax_personas();
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;
      obpersona := pac_md_persona.f_get_persona(psperson, pcagente, mensajes, 'POL');
      IF obpersona IS NULL THEN
         RAISE NO_DATA_FOUND;   /*JRH Si no lo encuentra*/
      END IF;
      RETURN 0;
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
   END f_get_persona;

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
      fnacimi IN DATE,   /* Fecha de nacimiento de la persona*/
      pmodo IN VARCHAR2,
      psseguro IN NUMBER,
      pcagente IN NUMBER,
      ppduplicada IN NUMBER,
      obpersona OUT ob_iax_personas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pctipper  = ' || pctipper || '- pctipide  = ' || pctipide
            || '- pnnumnif  = ' || pnnumnif || '- pcsexper  = ' || pcsexper
            || '- fnacimi     = ' || fnacimi || '- pmodo       = ' || pmodo
            || '- psseguro  = ' || psseguro || '- pcagente  = ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_PersonaUnica';
      objpers        t_iax_personas;
      ptablas        VARCHAR2(20);
      v_parpersonas  NUMBER;
      pparper        t_iax_par_personas;
   BEGIN
      ptablas := pac_md_common.f_get_ptablas(pmodo, mensajes);
      obpersona := pac_md_persona.f_get_personaunica(pctipper, pctipide, pnnumnif, pcsexper,
                                                     fnacimi, pmodo, psseguro, pcagente, 0,
                                                     ptablas, ppduplicada, mensajes);
      /*Bug 27314/159252 - 19/11/2013 - AMC*/
      v_parpersonas := pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                     'PARPERSONAS');

      IF NVL(v_parpersonas, 0) = 1
         AND pctipper = 2 THEN
         vnumerr := pac_iax_persona.f_get_estparpersona(NULL, NULL, 0, 1, pctipper, pparper,
                                                        mensajes);
         vnumerr := pac_iax_persona.f_ins_estparpersona(NULL, NULL, 'PER_OFICIAL', 2, NULL,
                                                        NULL, mensajes);
      ELSIF NVL(v_parpersonas, 0) = 1
            AND pctipper = 1 THEN
         vnumerr := pac_iax_persona.f_get_estparpersona(NULL, NULL, 0, 1, pctipper, pparper,
                                                        mensajes);
      END IF;

      /*Fi Bug 27314/159252 - 19/11/2013 - AMC*/
      RETURN 0;
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
   END f_get_personaunica;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Obtiene los datos de las EST en un objeto OB_IAX_PERSONAS
      param out mensajes  : mensajes de error
      return              : El OB_IAX_PERSONAS
   *************************************************************************/
   FUNCTION f_get_estpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      obpersona OUT ob_iax_personas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_EstPersona';
      objpers        ob_iax_personas := ob_iax_personas();
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      obpersona := pac_md_persona.f_get_persona(psperson, pcagente, mensajes, 'EST');

      IF obpersona IS NULL THEN
         RAISE NO_DATA_FOUND;   /*JRH Si no lo encuentra*/
      END IF;

      RETURN 0;
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
   END f_get_estpersona;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
     Obtiene de parámetros de salida los datos principales del contacto tipo teléfono fijo.
     return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_contactotlffijo(
      psperson IN NUMBER,
      cagente IN NUMBER,
      smodcon OUT NUMBER,
      tvalcon OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'parámetros - psperson: ' || psperson || ' cagente:' || cagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_ContactoTlfFijo';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_contactotlffijo(psperson,
                                                      pac_md_common.f_get_cxtagenteprod,
                                                      smodcon, tvalcon, mensajes, 'POL');

      IF vnumerr <> 0 THEN
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
   END f_get_contactotlffijo;

   FUNCTION f_get_estcontactotlffijo(
      psperson IN NUMBER,
      cagente IN NUMBER,
      smodcon OUT NUMBER,
      tvalcon OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'parámetros - psperson: ' || psperson || ' cagente:' || cagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_EstContactoTlfFijo';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_contactotlffijo(psperson,
                                                      pac_md_common.f_get_cxtagenteprod,
                                                      smodcon, tvalcon, mensajes, 'EST');

      IF vnumerr <> 0 THEN
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
   END f_get_estcontactotlffijo;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Obtiene de parámetros de salida los datos principales del contacto  tipo teléfono móvil.
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_contactotlfmovil(
      psperson IN NUMBER,
      cagente IN NUMBER,
      smodcon OUT NUMBER,
      tvalcon OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'parámetros - psperson: ' || psperson || ' cagente:' || cagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_ContactoTlfMovil';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_contactotlfmovil(psperson,
                                                       pac_md_common.f_get_cxtagenteprod,
                                                       smodcon, tvalcon, mensajes, 'POL');

      IF vnumerr <> 0 THEN
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
   END f_get_contactotlfmovil;

   FUNCTION f_get_estcontactotlfmovil(
      psperson IN NUMBER,
      cagente IN NUMBER,
      smodcon OUT NUMBER,
      tvalcon OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'parámetros - psperson: ' || psperson || ' cagente:' || cagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_EstContactoTlfMovil';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_contactotlfmovil(psperson,
                                                       pac_md_common.f_get_cxtagenteprod,
                                                       smodcon, tvalcon, mensajes, 'EST');

      IF vnumerr <> 0 THEN
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
   END f_get_estcontactotlfmovil;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Obtiene  de parámetros de salida los datos principales del contacto  tipo mail.
      return              : T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_contactomail(
      psperson IN NUMBER,
      cagente IN NUMBER,
      smodcon OUT NUMBER,
      tvalcon OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'parámetros - psperson: ' || psperson || ' cagente:' || cagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_ContactoMail';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

     vnumerr := pac_md_persona.f_get_contactomail(psperson, pac_md_common.f_get_cxtagenteprod,
                                                   smodcon, tvalcon, mensajes, 'POL');

      IF vnumerr <> 0 THEN
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
   END f_get_contactomail;

   FUNCTION f_get_estcontactomail(
      psperson IN NUMBER,
      cagente IN NUMBER,
      smodcon OUT NUMBER,
      tvalcon OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'parámetros - psperson: ' || psperson || ' cagente:' || cagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_EstContactoMail';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_contactomail(psperson, pac_md_common.f_get_cxtagenteprod,
                                                   smodcon, tvalcon, mensajes, 'EST');

      IF vnumerr <> 0 THEN
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
   END f_get_estcontactomail;

   FUNCTION f_get_contactofax(
      psperson IN NUMBER,
      cagente IN NUMBER,
      smodcon OUT NUMBER,
      tvalcon OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'parámetros - psperson: ' || psperson || ' cagente:' || cagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_ContactoFax';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_contactofax(psperson, pac_md_common.f_get_cxtagenteprod,
                                                  smodcon, tvalcon, mensajes, 'POL');

      IF vnumerr <> 0 THEN
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
   END f_get_contactofax;

   FUNCTION f_get_estcontactofax(
      psperson IN NUMBER,
      cagente IN NUMBER,
      smodcon OUT NUMBER,
      tvalcon OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'parámetros - psperson: ' || psperson || ' cagente:' || cagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_EstContactoFax';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_contactofax(psperson, pac_md_common.f_get_cxtagenteprod,
                                                  smodcon, tvalcon, mensajes, 'EST');

      IF vnumerr <> 0 THEN
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
   END f_get_estcontactofax;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Obtiene el código del pais, nacionalidad por defecto.
      return              : Pais
   *************************************************************************/
   FUNCTION f_get_estnacionalidaddefecto(
      psperson IN NUMBER,
      cagente IN NUMBER,
      cpais OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'parámetros - psperson: ' || psperson || ' cagente:' || cagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_EstNacionalidadDefecto';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_nacionalidaddefecto(psperson,
                                                          pac_md_common.f_get_cxtagenteprod,
                                                          cpais, mensajes, 'EST');

      IF vnumerr <> 0 THEN
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
   END f_get_estnacionalidaddefecto;

   FUNCTION f_get_nacionalidaddefecto(
      psperson IN NUMBER,
      cagente IN NUMBER,
      cpais OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'parámetros - psperson: ' || psperson || ' cagente:' || cagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_NacionalidadDefecto';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_nacionalidaddefecto(psperson,
                                                          pac_md_common.f_get_cxtagenteprod,
                                                          cpais, mensajes, 'POL');

      IF vnumerr <> 0 THEN
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
   END f_get_nacionalidaddefecto;

   /*************************************************************************
      Obtiene las nacionalidades de una persona
      return              : Pais
   *************************************************************************/
   FUNCTION f_get_estnacionalidades(
      psperson IN NUMBER,
      cagente IN NUMBER,
      pnacionalidades OUT t_iax_nacionalidades,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'parámetros - psperson: ' || psperson || ' cagente:' || cagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_estNacionalidades';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_nacionalidades(psperson,
                                                     pac_md_common.f_get_cxtagenteprod,
                                                     pnacionalidades, mensajes, 'EST');

      IF vnumerr <> 0 THEN
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
   END f_get_estnacionalidades;

   FUNCTION f_get_nacionalidades(
      psperson IN NUMBER,
      cagente IN NUMBER,
      pnacionalidades OUT t_iax_nacionalidades,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'parámetros - psperson: ' || psperson || ' cagente:' || cagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_Nacionalidades';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_nacionalidades(psperson,
                                                     pac_md_common.f_get_cxtagenteprod,
                                                     pnacionalidades, mensajes, 'POL');

      IF vnumerr <> 0 THEN
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
   END f_get_nacionalidades;

   FUNCTION f_get_estnacionalidad(
      psperson IN NUMBER,
      pcpais IN NUMBER,
      pcagente IN NUMBER,
      nacionalidad OUT ob_iax_nacionalidades,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                              := 'parámetros - psperson: ' || psperson || ' pcpais:' || pcpais;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_ESTNacionalidad';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_nacionalidad(psperson, pcpais, pcagente, nacionalidad,
                                                   mensajes, 'EST');

      IF vnumerr <> 0 THEN
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
   END f_get_estnacionalidad;

   FUNCTION f_get_nacionalidad(
      psperson IN NUMBER,
      pcpais IN NUMBER,
      pcagente IN NUMBER,
      nacionalidad OUT ob_iax_nacionalidades,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                              := 'parámetros - psperson: ' || psperson || ' pcpais:' || pcpais;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_Nacionalidad';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_nacionalidad(psperson, pcpais, pcagente, nacionalidad,
                                                   mensajes, 'POL');

      IF vnumerr <> 0 THEN
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
   END f_get_nacionalidad;

   FUNCTION f_set_nacionalidad(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcpais IN NUMBER,
      pcdefecto IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || 'Cagente:' || pcagente || 'pcpais:'
            || pcpais || 'pcdefecto:' || pcdefecto;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_Set_nacionalidad';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcpais IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 40202);
         RAISE e_object_error;
      END IF;

      /*DRA 13-10-2008: bug mantis 7784*/
      /* xpl 19/06/2009 : bug mantis 0010339*/
      vcagente := NVL(pcagente,
                      pac_iax_persona.f_get_cagente(psperson, pcagente, 'POL', mensajes));
      vnumerr := pac_md_persona.f_set_nacionalidad(psperson, pcagente, pcpais, pcdefecto,
                                                   mensajes, 'POL');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_nacionalidad;

   FUNCTION f_set_estnacionalidad(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcpais IN NUMBER,
      pcdefecto IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || 'Cagente:' || pcagente || 'pcpais:'
            || pcpais || 'pcdefecto:' || pcdefecto;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_Set_estnacionalidad';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcpais IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 40202);
         RAISE e_object_error;
     END IF;

      IF pac_iax_produccion.issuplem THEN
         vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vsseguro, 'POL', vcagente);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      ELSE
         /* svj Bug 0025938  En nueva producci??ogemos el agente de producci?? si no esta inicializado el de la p??a.*/
         vcagente := pac_md_common.f_get_cxtagenteprod();

         IF vcagente IS NULL THEN
            vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vssegpol, 'POL', vcagente);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;
      /* Fin svj Bug 0025938*/
      END IF;

      vnumerr :=
         pac_md_persona.f_set_nacionalidad(psperson, vcagente,             /*pcagente,*/
                                                                 /*pac_md_common.f_get_cxtagenteprod,*/
                                           pcpais, pcdefecto, mensajes, 'EST');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_estnacionalidad;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      cpais          NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' Cagente' || cagente || ' psseguro'
            || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_cuentaPoliza';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_cuentapoliza(psperson, pac_md_common.f_get_cxtagenteprod,
                                                   psseguro, pctipban, cbancar, mensajes,
                                                   'POL');

      IF vnumerr <> 0 THEN
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
   END f_get_cuentapoliza;

   FUNCTION f_get_estcuentapoliza(
      psperson IN NUMBER,
      cagente IN NUMBER,
      psseguro IN NUMBER,
      pctipban OUT NUMBER,
      cbancar OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      cpais          NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' Cagente' || cagente || ' psseguro'
            || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_EstcuentaPoliza';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_cuentapoliza(psperson, pac_md_common.f_get_cxtagenteprod,
                                                   psseguro, pctipban, cbancar, mensajes,
                                                   'EST');

      IF vnumerr <> 0 THEN
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
   END f_get_estcuentapoliza;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      cpais          NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                             := 'parámetros - cbancar: ' || cbancar || ' pctipban' || pctipban;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_getFormatoCCC';
   BEGIN
      IF pctipban IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF cbancar IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_getformatoccc(pctipban, cbancar, pcbancar, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_getformatoccc;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
      Nueva función que valida la cuenta bancaria dependiendo del tipo.
      pcbancar es cbancar pero formateado.
      return              : 0 si ha ido bien , 1 si ha ido mal
   *************************************************************************/
   FUNCTION f_validaccc(pctipban IN NUMBER, cbancar IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      cpais          NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                             := 'parámetros - cbancar: ' || cbancar || ' pctipban' || pctipban;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_validaCCC';
   BEGIN
      IF pctipban IS NULL
         OR cbancar IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 40202);
         RAISE e_object_error;
      END IF;

      vnumerr := pac_md_persona.f_validaccc(pctipban, cbancar, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_validaccc;

   FUNCTION f_set_contactotlffijo(
      psperson IN NUMBER,
      cagente IN NUMBER,
      tvalcon IN VARCHAR2,
      smodcon IN NUMBER,
      smodconout OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || 'Cagente:' || cagente || 'Tvalcon:'
            || tvalcon;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_Set_ContactoTlfFijo';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF smodcon IS NOT NULL THEN
         smodconout := smodcon;
      END IF;

      /* DRA 13-10-2008: bug mantis 7784*/
      /* xpl 19/06/2009 : bug mantis 0010339*/
      vcagente := NVL(cagente,
                      pac_iax_persona.f_get_cagente(psperson, cagente, 'POL', mensajes));
      vnumerr := pac_md_persona.f_set_contactotlffijo(psperson, vcagente, tvalcon, smodconout,
                                                      NULL, mensajes, 'POL');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_contactotlffijo;

   FUNCTION f_set_estcontactotlffijo(
      psperson IN NUMBER,
      cagente IN NUMBER,
      tvalcon IN VARCHAR2,
      smodcon IN NUMBER,
      smodconout OUT NUMBER,
      pcprefix IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || 'Cagente:' || cagente || 'Tvalcon:'
            || tvalcon;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_Set_EstContactoTlfFijo';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF smodcon IS NOT NULL THEN
         smodconout := smodcon;
      END IF;

      IF pac_iax_produccion.issuplem THEN
         vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vsseguro, 'POL', vcagente);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      ELSE
         /* svj Bug 0025938  En nueva producci??ogemos el agente de producci?? si no esta inicializado el de la p??a.*/
         vcagente := pac_md_common.f_get_cxtagenteprod();

         IF vcagente IS NULL THEN
            vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vssegpol, 'POL', vcagente);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;
      /* Fin svj Bug 0025938*/
      END IF;

      vnumerr := pac_md_persona.f_set_contactotlffijo(psperson, vcagente, tvalcon, smodconout,
                                                      pcprefix, mensajes, 'EST');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_estcontactotlffijo;

   FUNCTION f_set_contactotlfmovil(
      psperson IN NUMBER,
      cagente IN NUMBER,
      tvalcon IN VARCHAR2,
      smodcon IN NUMBER,
      smodconout OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || 'Cagente:' || cagente || 'Tvalcon:'
            || tvalcon;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_Set_ContactoTlfMovil';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF smodcon IS NOT NULL THEN
         smodconout := smodcon;
      END IF;

      /* DRA 13-10-2008: bug mantis 7784*/
      /* xpl 19/06/2009 : bug mantis 0010339*/
      vcagente := NVL(cagente,
                      pac_iax_persona.f_get_cagente(psperson, cagente, 'POL', mensajes));
      vnumerr := pac_md_persona.f_set_contactotlfmovil(psperson, vcagente, tvalcon, smodconout,
                                                       NULL, mensajes, 'POL');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_contactotlfmovil;

   FUNCTION f_set_estcontactotlfmovil(
      psperson IN NUMBER,
      cagente IN NUMBER,
      tvalcon IN VARCHAR2,
      smodcon IN NUMBER,
      smodconout OUT NUMBER,
      pcprefix IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || 'Cagente:' || cagente || 'Tvalcon:'
            || tvalcon;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_Set_EstContactoTlfMovil';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF smodcon IS NOT NULL THEN
         smodconout := smodcon;
      END IF;

      IF pac_iax_produccion.issuplem THEN
         vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vsseguro, 'POL', vcagente);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      ELSE
         /* svj Bug 0025938  En nueva producci??ogemos el agente de producci?? si no esta inicializado el de la p??a.*/
         vcagente := pac_md_common.f_get_cxtagenteprod();

         IF vcagente IS NULL THEN
            vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vssegpol, 'POL', vcagente);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;
      /* Fin svj Bug 0025938*/
      END IF;

      vnumerr := pac_md_persona.f_set_contactotlfmovil(psperson, vcagente, tvalcon, smodconout,
                                                       pcprefix, mensajes, 'EST');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_estcontactotlfmovil;

   FUNCTION f_set_contactomail(
      psperson IN NUMBER,
      cagente IN NUMBER,
      tvalcon IN VARCHAR2,
      smodcon IN NUMBER,
      smodconout OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || 'Cagente:' || cagente || 'Tvalcon:'
            || tvalcon;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_Set_ContactoMail';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF smodcon IS NOT NULL THEN
         smodconout := smodcon;
      END IF;

      /* DRA 13-10-2008: bug mantis 7784*/
      /* xpl 19/06/2009 : bug mantis 0010339*/
      vcagente := NVL(cagente,
                      pac_iax_persona.f_get_cagente(psperson, cagente, 'POL', mensajes));
      vnumerr := pac_md_persona.f_set_contactomail(psperson, vcagente, tvalcon, smodconout,
                                                   mensajes, 'POL');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_contactomail;

   FUNCTION f_set_estcontactomail(
      psperson IN NUMBER,
      cagente IN NUMBER,
      tvalcon IN VARCHAR2,
      smodcon IN NUMBER,
      smodconout OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || 'Cagente:' || cagente || 'Tvalcon:'
            || tvalcon;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_Set_EstContactoMail';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF smodcon IS NOT NULL THEN
         smodconout := smodcon;
      END IF;

      IF pac_iax_produccion.issuplem THEN
         vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vsseguro, 'POL', vcagente);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      ELSE
         /* svj Bug 0025938  En nueva producci??ogemos el agente de producci?? si no esta inicializado el de la p??a.*/
         vcagente := pac_md_common.f_get_cxtagenteprod();

         IF vcagente IS NULL THEN
            vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vssegpol, 'POL', vcagente);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;
      /* Fin svj Bug 0025938*/
      END IF;

      vnumerr := pac_md_persona.f_set_contactomail(psperson, vcagente, tvalcon, smodconout,
                                                   mensajes, 'EST');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_estcontactomail;

   FUNCTION f_set_nacionalidaddefecto(
      psperson IN NUMBER,
      cagente IN NUMBER,
      cpais IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || 'Cagente:' || cagente || 'Cpais:'
            || cpais;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_Set_NacionalidadDefecto';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      /* DRA 13-10-2008: bug mantis 7784*/
      /* xpl 19/06/2009 : bug mantis 0010339*/
      vcagente := NVL(cagente,
                      pac_iax_persona.f_get_cagente(psperson, cagente, 'POL', mensajes));
      vnumerr := pac_md_persona.f_set_nacionalidaddefecto(psperson, vcagente, cpais, mensajes,
                                                          'POL');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_nacionalidaddefecto;

   FUNCTION f_set_estnacionalidaddefecto(
      psperson IN NUMBER,
      cagente IN NUMBER,
      cpais IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || 'Cagente:' || cagente || 'Cpais:'
            || cpais;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_Set_estNacionalidadDefecto';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pac_iax_produccion.issuplem THEN
         vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vsseguro, 'POL', vcagente);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      ELSE
         /* svj Bug 0025938  En nueva producci??ogemos el agente de producci?? si no esta inicializado el de la p??a.*/
         vcagente := pac_md_common.f_get_cxtagenteprod();

         IF vcagente IS NULL THEN
            vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vssegpol, 'POL', vcagente);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;
      /* Fin svj Bug 0025938*/
      END IF;

      vnumerr := pac_md_persona.f_set_nacionalidaddefecto(psperson, vcagente, cpais, mensajes,
                                                          'EST');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_estnacionalidaddefecto;

   FUNCTION f_set_ccc(
      psperson IN NUMBER,
      cagente IN NUMBER,
      cnordban IN NUMBER,
      cnordbanout OUT NUMBER,
      pctipban IN NUMBER,
      cbancar IN VARCHAR2,
      pcdefecto IN NUMBER,
      mensajes OUT t_iax_mensajes,
      pcpagsin IN NUMBER DEFAULT NULL,
      /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
      pfvencim IN DATE DEFAULT NULL,
      /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
      ptseguri IN VARCHAR2 DEFAULT NULL,
      /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
      pctipcc IN VARCHAR2 DEFAULT NULL /* 20735/102170 Introduccion de cuenta bancaria*/)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' Cagente:' || cagente || ' CNordBan:'
            || cnordban || ' pctipban:' || pctipban || ' cbancar:' || cbancar || ' pcpagsin:'
            || pcpagsin || ' pfvencim:' || pfvencim || ' ptseguri:' || ptseguri || ' pctipcc:'
            || pctipcc;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_set_CCC';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF (pctipban IS NULL
          AND pctipcc IS NULL)
         OR cbancar IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 40202);
         RAISE e_object_error;
      END IF;

      IF cnordban IS NOT NULL THEN
         cnordbanout := cnordban;
      END IF;

      /* DRA 13-10-2008: bug mantis 7784*/
      /* xpl 19/06/2009 : bug mantis 0010339*/
      /*vcagente := NVL(cagente,
      pac_iax_persona.f_get_cagente(psperson, cagente, 'POL', mensajes));*/
      vcagente := pac_iax_persona.f_get_cagente(psperson, cagente, 'POL', mensajes);
      vnumerr := pac_md_persona.f_set_ccc(psperson, vcagente, cnordbanout, pctipban, cbancar,
                                          pcdefecto, mensajes, 'POL', pcpagsin,
                                          /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
                                          pfvencim,
                                          /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
                                          ptseguri,
                                          /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
                                          pctipcc
                                                 /* 20735/102170 Introduccion de cuenta bancaria*/
                );

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_ccc;

   FUNCTION f_set_estccc(
      psperson IN NUMBER,
      cagente IN NUMBER,
      cnordban IN NUMBER,
      cnordbanout OUT NUMBER,
      pctipban IN NUMBER,
      cbancar IN VARCHAR2,
      pcdefecto IN NUMBER,
      mensajes OUT t_iax_mensajes,
      pcpagsin IN NUMBER DEFAULT NULL,
      /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
      pfvencim IN DATE DEFAULT NULL,
      /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
      ptseguri IN VARCHAR2 DEFAULT NULL,
      /* 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
      pctipcc IN VARCHAR2 DEFAULT NULL /* 20735/102170 Introduccion de cuenta bancaria*/)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || 'Cagente:' || cagente || 'CNordBan:'
            || cnordban || 'pctipban:' || pctipban || 'cbancar:' || cbancar;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_set_estCCC';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      /*if pctipban is null OR cbancar is null  then
        raise e_param_error;
      end if;*/
      IF cnordban IS NOT NULL THEN
         cnordbanout := cnordban;
      END IF;

      IF pac_iax_produccion.issuplem THEN
         vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vsseguro, 'POL', vcagente);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      ELSE
         /* svj Bug 0025938  En nueva producci??ogemos el agente de producci?? si no esta inicializado el de la p??a.*/
         vcagente := pac_md_common.f_get_cxtagenteprod();

         IF vcagente IS NULL THEN
            vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vssegpol, 'POL', vcagente);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;
      /* Fin svj Bug 0025938*/
      END IF;

      vnumerr := pac_md_persona.f_set_ccc(psperson, vcagente, cnordbanout, pctipban, cbancar,
                                          pcdefecto, mensajes, 'EST', pcpagsin, pfvencim,
                                          ptseguri, pctipcc
                                                           /* 20735/102170 Introduccion de cuenta bancaria*/
                );

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_estccc;

   /*************************************************************************
         Obtiene los contactos de una persona
         return              : t_iax_contactos
   *************************************************************************/
   FUNCTION f_get_estcontactos(
      psperson IN NUMBER,
      cagente IN NUMBER,
      tcontactos OUT t_iax_contactos,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_estcontactos';
      objpers        t_iax_personas;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_contactos(psperson, pac_md_common.f_get_cxtagenteprod,
                                                tcontactos, mensajes, 'EST');

      IF vnumerr <> 0 THEN
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
   END f_get_estcontactos;

   FUNCTION f_get_contactos(
      psperson IN NUMBER,
      cagente IN NUMBER,
      tcontactos OUT t_iax_contactos,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_contactos';
      objpers        t_iax_personas;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_contactos(psperson, pac_md_common.f_get_cxtagenteprod,
                                                tcontactos, mensajes, 'POL');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_get_contactos;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                         := 'parámetros - psperson: ' || psperson || ' pcmodcon: ' || pcmodcon;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_estcontactos';
      objpers        t_iax_personas;
   BEGIN
      IF psperson IS NULL
         OR pcmodcon IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_contacto(psperson, pac_md_common.f_get_cxtagenteprod,
                                               pcmodcon, obcontacto, mensajes, 'EST');

      IF vnumerr <> 0 THEN
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
   END f_get_estcontacto;

   FUNCTION f_get_contacto(
      psperson IN NUMBER,
      cagente IN NUMBER,
      pcmodcon IN NUMBER,
      obcontacto OUT ob_iax_contactos,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                         := 'parámetros - psperson: ' || psperson || ' pcmodcon: ' || pcmodcon;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_contactos';
      objpers        t_iax_personas;
   BEGIN
      IF psperson IS NULL
         OR pcmodcon IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_contacto(psperson, cagente, pcmodcon, obcontacto,
                                               mensajes, 'POL');

      IF vnumerr <> 0 THEN
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
   END f_get_contacto;

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
      pcdomici IN NUMBER,   /*BUG 24806*/
      psmodconout OUT NUMBER,
      pcprefix IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || 'Cagente:' || cagente || 'pctipcon:'
            || pctipcon || 'ptcomcon:' || ptcomcon || 'tvalcon:' || tvalcon || 'pcdomici:'
            || pcdomici;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_Set_estcontacto';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF psmodcon IS NOT NULL THEN
         psmodconout := psmodcon;
      END IF;

      IF pac_iax_produccion.issuplem THEN
         vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vsseguro, 'POL', vcagente);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      ELSE
         /* svj Bug 0025938  En nueva producci??ogemos el agente de producci?? si no esta inicializado el de la p??a.*/
         vcagente := pac_md_common.f_get_cxtagenteprod();

         IF vcagente IS NULL THEN
            vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vssegpol, 'POL', vcagente);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;
      /* Fin svj Bug 0025938*/
      END IF;

      vnumerr := pac_md_persona.f_set_contacto(psperson, vcagente, pctipcon, ptcomcon, tvalcon,
                                               pcdomici,   /*bug 24806*/
                                               psmodconout, pcprefix, mensajes, 'EST');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_estcontacto;

   FUNCTION f_set_contacto(
      psperson IN NUMBER,
      cagente IN NUMBER,
      pctipcon IN NUMBER,
      ptcomcon IN VARCHAR2,
      tvalcon IN VARCHAR2,
      psmodcon IN NUMBER,
      pcdomici IN NUMBER,   /*bug 24806*/
      psmodconout OUT NUMBER,
      pcprefix IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || 'Cagente:' || cagente || 'pctipcon:'
            || pctipcon || 'ptcomcon:' || ptcomcon || 'tvalcon:' || tvalcon || 'pcdomici:'
            || pcdomici || 'pcprefix:' || pcprefix;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_Set_contacto';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL   /*OR  tvalcon IS NULL  OR pctipcon IS NULL*/
                         THEN
         RAISE e_param_error;
      END IF;

      IF tvalcon IS NULL
         OR pctipcon IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 40202);
         RAISE e_object_error;
      END IF;

      IF psmodcon IS NOT NULL THEN
         psmodconout := psmodcon;
      END IF;

      IF psmodcon IS NOT NULL THEN
         psmodconout := psmodcon;
      END IF;

      /* DRA 13-10-2008: bug mantis 7784*/
      /* xpl 19/06/2009 : bug mantis 0010339*/
      vcagente := NVL(cagente,
                      pac_iax_persona.f_get_cagente(psperson, cagente, 'POL', mensajes));
      vnumerr := pac_md_persona.f_set_contacto(psperson, vcagente,   /*Bug 27814*/
                                               pctipcon, ptcomcon, tvalcon, pcdomici,   /*bug 24806*/
                                               psmodconout, pcprefix, mensajes, 'POL');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_contacto;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_EstDirecciones';
      objpers        t_iax_personas;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_direcciones(psperson, pac_md_common.f_get_cxtagenteprod,
                                                  pdirecciones, mensajes, 'EST');

      IF vnumerr <> 0 THEN
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
   END f_get_estdirecciones;

   FUNCTION f_get_direcciones(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pdirecciones OUT t_iax_direcciones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_Direcciones';
      objpers        t_iax_personas;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_direcciones(psperson, pac_md_common.f_get_cxtagenteprod,
                                                  pdirecciones, mensajes, 'POL');

      IF vnumerr <> 0 THEN
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
   END f_get_direcciones;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson || ' ' || cdomici;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Del_EstDirecciones';
      objpers        t_iax_personas;
   BEGIN
      IF psperson IS NULL
         OR cdomici IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_del_direcciones(psperson, cdomici, mensajes, 'EST', pcagente);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_estdirecciones;

   FUNCTION f_del_estcontacto(
      psperson IN NUMBER,
      psmodcon IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson || ' ' || psmodcon;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Del_estcontacto';
      objpers        t_iax_personas;
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL
         OR psmodcon IS NULL THEN
         RAISE e_param_error;
      END IF;

      /* DRA 13-10-2008: bug mantis 7784*/
      /*vcagente := pac_iax_persona.f_get_cagente (psperson, pcagente, 'EST', mensajes);*/
      vcagente := pac_md_persona.f_get_cagentepol(psperson, 'EST', mensajes);
      vnumerr := pac_md_persona.f_del_contacto(psperson, psmodcon, vcagente, mensajes, 'EST');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_estcontacto;

   FUNCTION f_del_contacto(
      psperson IN NUMBER,
      psmodcon IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson || ' ' || psmodcon;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Del_contacto';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL
         OR psmodcon IS NULL THEN
         RAISE e_param_error;
      END IF;

      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente := pac_iax_persona.f_get_cagente(psperson, pcagente, 'POL', mensajes);
      vnumerr := pac_md_persona.f_del_contacto(psperson, psmodcon, vcagente, mensajes, 'POL');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

     COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_contacto;

   FUNCTION f_del_direcciones(
      psperson IN NUMBER,
      cdomici IN NUMBER,
      ptablas IN VARCHAR2,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson || ' ' || cdomici;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Del_Direcciones';
      objpers        t_iax_personas;
   BEGIN
      IF psperson IS NULL
         OR cdomici IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_del_direcciones(psperson, cdomici, mensajes, 'POL', pcagente);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_direcciones;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson || ' ' || cdomici;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_EstDireccion';
      objpers        t_iax_personas;
   BEGIN
      IF psperson IS NULL
         OR cdomici IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_direccion(psperson, cdomici, pdirecciones, mensajes,
                                                'EST');

      IF vnumerr <> 0 THEN
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
   END f_get_estdireccion;

   FUNCTION f_get_direccion(
      psperson IN NUMBER,
      cdomici IN NUMBER,
      pdirecciones OUT ob_iax_direcciones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
     vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson || ' ' || cdomici;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_Direccion';
      objpers        t_iax_personas;
   BEGIN
      IF psperson IS NULL
         OR cdomici IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_direccion(psperson, cdomici, pdirecciones, mensajes,
                                                'POL');

      IF vnumerr <> 0 THEN
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
   END f_get_direccion;

   /*************************************************************************
   Nueva función que se encarga de realizar las validaciones en la introducción o modificación de una dirección
   param out mensajes  : pDirecciones que es t_iax_direcciones
   return              : El T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_valida_direccion(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pctipdir IN NUMBER,   /* Código del tipo de dirección*/
      pcsiglas IN NUMBER,   /* Código del tipo de vía*/
      ptnomvia IN VARCHAR2,   /* Nombre de la vía.*/
      nnumvia IN NUMBER,
      ptcomple IN VARCHAR2,   /* Otros.*/
      pcpostal IN VARCHAR2,   /*Código postal*/
      pcpobla IN NUMBER,   /*Código población*/
      pcprovin IN NUMBER,   /* Código de la provincia.*/
      pcpais IN NUMBER /*Código del país*/,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - pCtipdiR: ' || pctipdir;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_valida_Direccion';
   BEGIN
      vnumerr := pac_md_persona.f_valida_direccion(psperson, pcagente, pctipdir,   /* Código del tipo de dirección*/
                                                   pcsiglas,   /* Código del tipo de vía*/
                                                   ptnomvia,   /* Nombre de la vía.*/
                                                   nnumvia, ptcomple,   /* Otros.*/
                                                   pcpostal,   /*Código postal*/
                                                   pcpobla,   /*Código población*/
                                                   pcprovin,   /* Código de la provincia.*/
                                                   pcpais,   /*Código del país*/
                                                   mensajes);

      IF vnumerr <> 0 THEN
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
   END f_valida_direccion;

   FUNCTION f_set_estdireccion(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcdomici IN NUMBER,
      pcdomiciout OUT NUMBER,
      pctipdir IN NUMBER,   /* Código del tipo de dirección*/
      pcsiglas IN NUMBER,   /* Código del tipo de vía*/
      ptnomvia IN VARCHAR2,   /* Nombre de la vía.*/
      pnnumvia IN NUMBER,
      ptcomple IN VARCHAR2,   /* Otros.*/
      pcpostal IN VARCHAR2,   /*Código postal*/
      pcpoblac IN NUMBER,   /*Código población*/
      pcprovin IN NUMBER,   /* Código de la provincia.*/
      pcpais IN NUMBER,                          /*Código del país*/
                          /* Bug 18940/92686 - 27/09/2011 - AMC*/
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
      /* Fi Bug 18940/92686 - 27/09/2011 - AMC*/
      plocalidad IN estper_direcciones.localidad%TYPE,
      /* Bug 24780/130907 - 05/12/2012 - AMC*/
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'parámetros - psperson: ' || psperson || 'Cagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Set_EstDireccion';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcdomici IS NOT NULL THEN
         pcdomiciout := pcdomici;
      END IF;

      IF pac_iax_produccion.issuplem THEN
         vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vsseguro, 'POL', vcagente);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      ELSE
         /* svj Bug 0025938  En nueva producci??ogemos el agente de producci?? si no esta inicializado el de la p??a.*/
         vcagente := pac_md_common.f_get_cxtagenteprod();

         IF vcagente IS NULL THEN
            vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vssegpol, 'POL', vcagente);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;
      /* Fin svj Bug 0025938*/
      END IF;

      IF pctipdir <> 99 THEN
         /* CTIPDIR 99 es direcci??esimulaciones que no necesita validaci??*/
         vnumerr := pac_md_persona.f_valida_direccion(psperson, vcagente, pctipdir,
                                                      /* Código del tipo de dirección*/
                                                      pcsiglas,   /* Código del tipo de vía*/
                                                      ptnomvia,   /* Nombre de la vía.*/
                                                      pnnumvia, ptcomple,   /* Otros.*/
                                                      pcpostal,   /*Código postal*/
                                                      pcpoblac,   /*Código población*/
                                                      pcprovin,   /* Código de la provincia.*/
                                                      pcpais,   /*Código del país*/
                                                      mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      /* DRA 13-10-2008: bug mantis 7784*/
      /*vcagente := pac_iax_persona.f_get_cagente (psperson, pcagente, 'EST', mensajes);*/
      vnumerr := pac_md_persona.f_set_direccion(psperson,
                                                /*pac_md_common.f_get_cxtagenteprod,*/
                                                vcagente, pcdomiciout, pctipdir, pcsiglas,
                                                ptnomvia, pnnumvia, ptcomple, pcpostal,
                                                pcpoblac, pcprovin, pcpais, mensajes, 'EST',
                                                pcviavp, pclitvp, pcbisvp, pcorvp, pnviaadco,
                                                pclitco, pcorco, pnplacaco, pcor2co, pcdet1ia,
                                                ptnum1ia, pcdet2ia, ptnum2ia, pcdet3ia,
                                                ptnum3ia, plocalidad, NULL -- BUG CONF-441 - 14/12/2016 - JAEG
                                                                    /* Bug 24780/130907 - 05/12/2012 - AMC*/
                );

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_estdireccion;

   FUNCTION f_set_direccion(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcdomici IN NUMBER,
      pcdomiciout OUT NUMBER,
      pctipdir IN NUMBER,   /* Código del tipo de dirección*/
      pcsiglas IN NUMBER,   /* Código del tipo de vía*/
      ptnomvia IN VARCHAR2,   /* Nombre de la vía.*/
      pnnumvia IN NUMBER,
      ptcomple IN VARCHAR2,   /* Otros.*/
      pcpostal IN VARCHAR2,   /*Código postal*/
      pcpoblac IN NUMBER,   /*Código población*/
      pcprovin IN NUMBER,   /* Código de la provincia.*/
      pcpais IN NUMBER,                          /*Código del país*/
                          /* Bug 18940/92686 - 27/09/2011 - AMC*/
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
      /* Fi Bug 18940/92686 - 27/09/2011 - AMC*/
      plocalidad IN estper_direcciones.localidad%TYPE,
      ptalias IN estper_direcciones.talias%TYPE,      -- BUG CONF-441 - 14/12/2016 - JAEG
      /* Bug 24780/130907 - 05/12/2012 - AMC*/
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'parámetros - psperson: ' || psperson || 'Cagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Set_Direccion';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       NUMBER;
   /*svj bug 0010339 -  en capa iax no podemos definir como en la capa ncg -- agentes.cagente%TYPE;*/
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcdomici IS NOT NULL THEN
         pcdomiciout := pcdomici;
      END IF;

      /* DRA 13-10-2008: bug mantis 7784*/
      /* xpl 19/06/2009 : bug mantis 0010339*/
      vcagente := NVL(pcagente,
                      pac_iax_persona.f_get_cagente(psperson, pcagente, 'POL', mensajes));
      vnumerr := pac_md_persona.f_valida_direccion(psperson, vcagente, pctipdir,
                                                   /*svj bug 0010339 - cambiar pcagente por vcagente*/
                                                   /* Código del tipo de dirección*/
                                                   pcsiglas,
                                                   /* Código del tipo de vía*/
                                                   ptnomvia,   /* Nombre de la vía.*/
                                                   pnnumvia, ptcomple,   /* Otros.*/
                                                   pcpostal,   /*Código postal*/
                                                   pcpoblac,   /*Código población*/
                                                   pcprovin,
                                                   /* Código de la provincia.*/
                                                   pcpais /*Código del país*/, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      /* DRA 13-10-2008: bug mantis 7784*/
      /*  vcagente := pac_iax_persona.f_get_cagente (psperson, pcagente, 'POL', mensajes);*/
      vnumerr := pac_md_persona.f_set_direccion(psperson, vcagente, pcdomiciout, pctipdir,   /*svj bug 0010339 -*/
                                                pcsiglas, ptnomvia, pnnumvia, ptcomple,
                                                pcpostal, pcpoblac, pcprovin, pcpais, mensajes,
                                                'POL', pcviavp, pclitvp, pcbisvp, pcorvp,
                                                pnviaadco, pclitco, pcorco, pnplacaco, pcor2co,
                                                pcdet1ia, ptnum1ia, pcdet2ia, ptnum2ia,
                                                pcdet3ia, ptnum3ia, plocalidad,
                                                                                              ptalias -- BUG CONF-441 - 14/12/2016 - JAEG
                                                                              /* Bug 24780/130907 - 05/12/2012 - AMC*/
                );

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_direccion;

   /*************************************************************************
   Nueva función que se encarga de recuperar las  cuentas bancarias de una persona.
   return              : El T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_estcuentasbancarias(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pccc OUT t_iax_ccc,
      mensajes OUT t_iax_mensajes,
      pctipcc IN NUMBER DEFAULT NULL
                                    /* 08/11/2011 JGR 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
   )
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'parámetros - psperson: ' || psperson || 'Cagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_EstCuentasBancarias';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      --INICIO BUG 0038252 - DCT - 18/05/2016 -- pasar pcagente y si nulo pasar el pac_md_common.f_get_cxtagenteprod, si este también fuera nulo pac_md_common.f_get_cxtagente
      vnumerr :=
         pac_md_persona.f_get_cuentasbancarias(psperson,
                                               NVL(pcagente,
                                                   NVL(pac_md_common.f_get_cxtagenteprod,
                                                       pac_md_common.f_get_cxtagente)),
                                               NULL,   /*pfvigente*/
                                               pccc, mensajes, 'EST', pctipcc
                                                                             /* 08/11/2011 JGR 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
         );

      --FIN BUG 0038252 - DCT - 18/05/2016 -- pasar pcagente y si nulo pasar el pac_md_common.f_get_cxtagenteprod, si este también fuera nulo pac_md_common.f_get_cxtagente
      IF vnumerr <> 0 THEN
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
   END f_get_estcuentasbancarias;

   FUNCTION f_get_cuentasbancarias(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pccc OUT t_iax_ccc,
      mensajes OUT t_iax_mensajes,
      pctipcc IN NUMBER DEFAULT NULL
                                    /* 08/11/2011 JGR 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
   )
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'parámetros - psperson: ' || psperson || 'Cagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_CuentasBancarias';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      --INICIO BUG 0038252 - DCT - 18/05/2016 -- pasar pcagente y si nulo pasar el pac_md_common.f_get_cxtagenteprod, si este también fuera nulo pac_md_common.f_get_cxtagente
      vnumerr :=
         pac_md_persona.f_get_cuentasbancarias(psperson,
                                               NVL(pcagente,
                                                   NVL(pac_md_common.f_get_cxtagenteprod,
                                                       pac_md_common.f_get_cxtagente)),
                                               NULL,   /*pfvigente*/
                                               pccc, mensajes, 'POL', pctipcc
                                                                             /* 08/11/2011 JGR 19985 LCOL_A001-Control de las matriculas (prenotificaciones)*/
         );

      --FIN  BUG 0038252 - DCT - 18/05/2016 -- pasar pcagente y si nulo pasar el pac_md_common.f_get_cxtagenteprod, si este también fuera nulo pac_md_common.f_get_cxtagente
      IF vnumerr <> 0 THEN
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
   END f_get_cuentasbancarias;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
   /*************************************************************************
   Nueva función que se encarga de borrar una cuenta bancaria.
   return              : El T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_del_estccc(psperson IN NUMBER, cnordban IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson || ' ' || cnordban;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Del_EstCCC';
      objpers        t_iax_personas;
   BEGIN
      IF psperson IS NULL
         OR cnordban IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_del_ccc(psperson, cnordban, mensajes, 'EST');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_estccc;

   FUNCTION f_del_ccc(psperson IN NUMBER, cnordban IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson || ' ' || cnordban;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Del_CCC';
      objpers        t_iax_personas;
   BEGIN
      IF psperson IS NULL
         OR cnordban IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_del_ccc(psperson, cnordban, mensajes, 'POL');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_ccc;

   FUNCTION f_del_nacionalidad(
      psperson IN NUMBER,
      pcpais IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                               := 'parámetros - psperson: ' || psperson || ' pcpais' || pcpais;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Del_nacionalidad';
      objpers        t_iax_personas;
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL
         OR pcpais IS NULL THEN
         RAISE e_param_error;
      END IF;

      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente := pac_iax_persona.f_get_cagente(psperson, pcagente, 'POL', mensajes);
      vnumerr := pac_md_persona.f_del_nacionalidad(psperson, pcpais, vcagente, mensajes, 'POL');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_nacionalidad;

   FUNCTION f_del_estnacionalidad(
      psperson IN NUMBER,
      pcpais IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                               := 'parámetros - psperson: ' || psperson || ' pcpais' || pcpais;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Del_estnacionalidad';
      objpers        t_iax_personas;
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL
         OR pcpais IS NULL THEN
         RAISE e_param_error;
      END IF;

      /* DRA 13-10-2008: bug mantis 7784*/
      /*vcagente := pac_iax_persona.f_get_cagente (psperson, pcagente, 'EST', mensajes);*/
      vcagente := pac_md_persona.f_get_cagentepol(psperson, 'EST', mensajes);
      vnumerr := pac_md_persona.f_del_nacionalidad(psperson, pcpais, vcagente, mensajes, 'EST');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_estnacionalidad;

   FUNCTION f_get_estccc(
      psperson IN NUMBER,
      cnordban IN NUMBER,
      ccc OUT ob_iax_ccc,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_EstCCC';
      objpers        t_iax_personas;
   BEGIN
      IF psperson IS NULL   /*OR cnordban is null*/
                         THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_ccc(psperson, cnordban, ccc, mensajes, 'EST');

      IF vnumerr <> 0 THEN
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
   END f_get_estccc;

   FUNCTION f_get_ccc(
      psperson IN NUMBER,
      cnordban IN NUMBER,
      ccc OUT ob_iax_ccc,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_CCC';
      objpers        t_iax_personas;
   BEGIN
      IF psperson IS NULL   /*OR cnordban is null*/
                         THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_ccc(psperson, cnordban, ccc, mensajes, 'POL');

      IF vnumerr <> 0 THEN
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
   END f_get_ccc;

   /*JRH 04/2008 Tarea ESTPERSONAS*/
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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - pCodpostal: ' || pcpostal;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_ProvinPobla';
   BEGIN
      IF pcpostal IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_provinpobla(pcpostal, cpais, tpais, cprovin, tprovin,
                                                  cpoblac, tpoblac, pautocalle, mensajes);
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
   END f_get_provinpobla;

   FUNCTION f_set_identificador(
      psperson IN NUMBER,
      cagente IN NUMBER,
      ctipide IN NUMBER,
      nnumide IN VARCHAR2,
      cdefecto IN NUMBER,
      mensajes OUT t_iax_mensajes,
      /* Bug 22263 - 11/07/2012 - ETM*/
      paisexp IN NUMBER DEFAULT NULL,
      cdepartexp IN NUMBER DEFAULT NULL,
      cciudadexp IN NUMBER DEFAULT NULL,
      fechaexp IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' cagente:' || cagente || ' Ctipide:'
            || ctipide || ' NNUMIDE:' || nnumide || ' CPAISEXP:' || paisexp || ' CDEPARTEXP:'
            || cdepartexp || ' CCIUDADEXP:' || cciudadexp || ' FECHAEXP:' || fechaexp;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_Set_Identificador';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF ctipide IS NULL
         OR nnumide IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 40202);
         RAISE e_object_error;
      END IF;

      /* DRA 13-10-2008: bug mantis 7784*/
      /* xpl 19/06/2009 : bug mantis 0010339*/
      vcagente := NVL(cagente,
                      pac_iax_persona.f_get_cagente(psperson, cagente, 'POL', mensajes));
      vnumerr := pac_md_persona.f_set_identificador(psperson, cagente, ctipide, nnumide,
                                                    cdefecto, mensajes, 'POL', paisexp,
                                                    cdepartexp, cciudadexp, fechaexp);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_identificador;

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
      /* Bug 22263 - 11/07/2012 - ETM*/
      paisexp IN NUMBER DEFAULT NULL,
      cdepartexp IN NUMBER DEFAULT NULL,
      cciudadexp IN NUMBER DEFAULT NULL,
      fechaexp IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' cagente:' || cagente || ' Ctipide:'
            || ctipide || ' NNUMIDE:' || nnumide || ' CPAISEXP:' || paisexp || ' CDEPARTEXP:'
            || cdepartexp || ' CCIUDADEXP:' || cciudadexp || ' FECHAEXP:' || fechaexp;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_Set_Identificador';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF ctipide IS NULL
         OR nnumide IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 40202);
         RAISE e_object_error;
      END IF;

      /* DRA 13-10-2008: bug mantis 7784*/
      /* xpl 19/06/2009 : bug mantis 0010339*/
      vcagente := NVL(cagente,
                      pac_iax_persona.f_get_cagente(psperson, cagente, 'POL', mensajes));
      vnumerr := pac_md_persona.f_mod_identificador(psperson, cagente, ctipide, nnumide,
                                                    cdefecto, mensajes, 'POL', paisexp,
                                                    cdepartexp, cciudadexp, fechaexp);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_mod_identificador;

   FUNCTION f_set_estidentificador(
      psperson IN NUMBER,
      cagente IN NUMBER,
      ctipide IN NUMBER,
      nnumide IN VARCHAR2,
      cdefecto IN NUMBER,
      mensajes OUT t_iax_mensajes,
      /* Bug 22263 - 11/07/2012 - ETM*/
      paisexp IN NUMBER DEFAULT NULL,
      cdepartexp IN NUMBER DEFAULT NULL,
      cciudadexp IN NUMBER DEFAULT NULL,
      fechaexp IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' cagente:' || cagente || ' Ctipide:'
            || ctipide || ' NNUMIDE:' || nnumide || ' CPAISEXP:' || paisexp || ' CDEPARTEXP:'
            || cdepartexp || ' CCIUDADEXP:' || cciudadexp || ' FECHAEXP:' || fechaexp;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_Set_EstIdentificador';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF ctipide IS NULL
         OR nnumide IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 40202);
         RAISE e_object_error;
      END IF;

      IF pac_iax_produccion.issuplem THEN
         vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vsseguro, 'POL', vcagente);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      ELSE
         /* svj Bug 0025938  En nueva producci??ogemos el agente de producci?? si no esta inicializado el de la p??a.*/
         vcagente := pac_md_common.f_get_cxtagenteprod();

         IF vcagente IS NULL THEN
            vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vssegpol, 'POL', vcagente);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;
      /* Fin svj Bug 0025938*/
      END IF;

      vnumerr := pac_md_persona.f_set_identificador(psperson, vcagente, ctipide, nnumide,
                                                    cdefecto, mensajes, 'EST', paisexp,
                                                    cdepartexp, cciudadexp, fechaexp);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_estidentificador;

   FUNCTION f_del_estidentificador(
      psperson IN NUMBER,
      cagente IN NUMBER,
      ctipide IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' cagente:' || cagente || ' Ctipide:'
            || ctipide;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_del_EstIdentificador';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL
         OR ctipide IS NULL THEN
         RAISE e_param_error;
      END IF;

      /* DRA 13-10-2008: bug mantis 7784*/
      /*vcagente := pac_iax_persona.f_get_cagente (psperson, cagente, 'EST', mensajes);*/
      vcagente := pac_md_persona.f_get_cagentepol(psperson, 'EST', mensajes);
      vnumerr := pac_md_persona.f_del_identificador(psperson, vcagente, ctipide, mensajes,
                                                    'EST');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_estidentificador;

   FUNCTION f_del_identificador(
      psperson IN NUMBER,
      cagente IN NUMBER,
      ctipide IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' cagente:' || cagente || ' Ctipide:'
            || ctipide;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_del_Identificador';
      /* DRA 13-10-2008: bug mantis 7784*/
      vcagente       agentes.cagente%TYPE;
   BEGIN
      IF psperson IS NULL
         OR ctipide IS NULL THEN
         RAISE e_param_error;
      END IF;

      /* DRA 13-10-2008: bug mantis 7784*/
      /*      vcagente :=*/
      /*            pac_iax_persona.f_get_cagente (psperson, cagente, 'POL', mensajes);*/
      vnumerr := pac_md_persona.f_del_identificador(psperson, cagente, ctipide, mensajes,
                                                    'POL');

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000429);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_identificador;

   /*************************************************************************
   Obtiene los datos de los identificadores en un T_IAX_IDENTIFICADORES
   param out mensajes  : pDirecciones que es t_iax_direcciones
   return              : El T_IAX_MENSAJES
   *************************************************************************/
   FUNCTION f_get_identificadores(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pidentificadores OUT t_iax_identificadores,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_Identificadores';
      objpers        t_iax_personas;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_identificadores(psperson, pcagente, pidentificadores,
                                                      mensajes, 'POL');

      IF vnumerr <> 0 THEN
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
   END f_get_identificadores;

   FUNCTION f_get_estidentificadores(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pidentificadores OUT t_iax_identificadores,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_EstIdentificadores';
      objpers        t_iax_personas;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_identificadores(psperson, pcagente, pidentificadores,
                                                      mensajes, 'EST');

      IF vnumerr <> 0 THEN
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
   END f_get_estidentificadores;

   FUNCTION f_get_estidentificador(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      ctipide IN NUMBER,
      pidentificadores OUT ob_iax_identificadores,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson || ' ' || ctipide;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_ESTIdentificador';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_identificador(psperson, pcagente, ctipide,
                                                    pidentificadores, mensajes, 'EST');

      IF vnumerr <> 0 THEN
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
   END f_get_estidentificador;

   FUNCTION f_get_identificador(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      ctipide IN NUMBER,
      pidentificadores OUT ob_iax_identificadores,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson || ' ' || ctipide;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_Identificador';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_identificador(psperson, pcagente, ctipide,
                                                    pidentificadores, mensajes, 'POL');

      IF vnumerr <> 0 THEN
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
   END f_get_identificador;

   /*************************************************************************
   Funció que recupera els comptes bancaris vigents d'una persona. (pfvigente=f_sysdate)
   return : 0 si ha ido todo bien , 1 en caso contrario.
   *************************************************************************/
  FUNCTION f_get_estcuentasvigentes(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfvigente IN DATE,
      pcc OUT t_iax_ccc,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'parámetros - psperson: ' || psperson || 'Cagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_EstCuentasVigentes';
   BEGIN
      IF psperson IS NULL
         OR pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_md_persona.f_get_cuentasbancarias(psperson,
                                                       pac_md_common.f_get_cxtagenteprod,
                                                       NVL(pfvigente, f_sysdate), pcc,
                                                       mensajes, 'EST');
      vpasexec := 3;

      IF vnumerr <> 0 THEN
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
   END f_get_estcuentasvigentes;

   FUNCTION f_get_cuentasvigentes(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfvigente IN DATE,
      pcc OUT t_iax_ccc,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'parámetros - psperson: ' || psperson || 'Cagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_CuentasVigentes';
   BEGIN
      IF psperson IS NULL
         OR pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_md_persona.f_get_cuentasbancarias(psperson,
                                                       pac_md_common.f_get_cxtagenteprod,
                                                       NVL(pfvigente, f_sysdate), pcc,
                                                       mensajes, 'POL');
      vpasexec := 3;

      IF vnumerr <> 0 THEN
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
   END f_get_cuentasvigentes;

   FUNCTION f_get_tipcontactos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_TipContactos';
   BEGIN
      cur := pac_md_persona.f_get_tipcontactos(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipcontactos;

   /*************************************************************************
   Funció que recupera les pòlisses en el que la persona és prenedor
   return : cursor con el resultado
   *************************************************************************/
   FUNCTION f_get_poltom(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_PolTom';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      cur := pac_md_persona.f_get_poltom(psperson, mensajes);
      vpasexec := 3;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN cur;
   END f_get_poltom;

   /*************************************************************************
   Funció que recupera les pòlisses en el que la persona és assegurat
   return : cursor con el resultado
   *************************************************************************/
   FUNCTION f_get_polase(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_PolAse';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
     END IF;

      vpasexec := 2;
      cur := pac_md_persona.f_get_polase(psperson, mensajes);
      vpasexec := 3;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN cur;
   END f_get_polase;

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
      RETURN NUMBER IS
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || 'pficticia_sperson:' || pficticia_sperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.traspaso_ccc';
      vnumerr        NUMBER(10) := 0;
      vpasexec       VARCHAR2(5) := 1;
   BEGIN
      vnumerr := pac_md_persona.traspaso_ccc(psseguro, psperson, pficticia_sperson, mensajes);
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
   END traspaso_ccc;

   /* DRA 13-10-2008: bug mantis 7784*/
   FUNCTION f_get_cagente(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' - pcagente: ' || pcagente
            || ' - ptablas: ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_cagente';
      vnumerr        NUMBER(10) := 0;
      vpasexec       VARCHAR2(5) := 1;
      vcagente       agentes.cagente%TYPE;
   BEGIN
      vpasexec := 2;
      vcagente := pac_md_persona.f_buscaagente(psperson,
                                               NVL(pcagente,
                                                   pac_md_common.f_get_cxtagenteprod),
                                               ptablas, mensajes);
      vpasexec := 5;
      RETURN vcagente;
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
   END f_get_cagente;

   FUNCTION f_persona_origen_int(
      psperson IN estper_personas.sperson%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_persona_origen_int';
      vnumerr        NUMBER(10) := 0;
      vpasexec       VARCHAR2(5) := 1;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_md_persona.f_persona_origen_int(psperson, mensajes);
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
   END f_persona_origen_int;

   FUNCTION f_get_persona_trecibido(
      psperson IN estper_personas.sperson%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vparam         VARCHAR2(200) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_persona_trecibido';
      vnumerr        NUMBER(10) := 0;
      vpasexec       VARCHAR2(5) := 1;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL,
                                           pac_md_persona.f_get_persona_trecibido(psperson,
                                                                                  mensajes));
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_persona_trecibido;

   FUNCTION f_direccion_origen_int(
      psperson IN estper_direcciones.sperson%TYPE,
      pcdomici IN estper_direcciones.cdomici%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vparam         VARCHAR2(200) := 'parámetros - psperson: ' || psperson || '-' || pcdomici;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_direccion_origen_int';
      vnumerr        NUMBER(10) := 0;
      vpasexec       VARCHAR2(5) := 1;
   BEGIN
      IF psperson IS NULL
         OR pcdomici IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_md_persona.f_direccion_origen_int(psperson, pcdomici, mensajes);
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
   END f_direccion_origen_int;

   FUNCTION f_get_direccion_trecibido(
      psperson IN estper_direcciones.sperson%TYPE,
      pcdomici IN estper_direcciones.cdomici%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vparam         VARCHAR2(200) := 'parámetros - psperson: ' || psperson || '-' || pcdomici;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_direccion_trecibido';
      vnumerr        NUMBER(10) := 0;
      vpasexec       VARCHAR2(5) := 1;
   BEGIN
      IF psperson IS NULL
         OR pcdomici IS NULL THEN
         RAISE e_param_error;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL,
                                           pac_md_persona.f_get_direccion_trecibido(psperson,
                                                                                    pcdomici,
                                                                                    mensajes));
      RETURN 0;
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
   END f_get_direccion_trecibido;

   /*************************************************************************
      F_BUSQUEDA_MASDATOS
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_busqueda_masdatos(mensajes OUT t_iax_mensajes, pomasdatos OUT NUMBER)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000);
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_busqueda_masdatos';
   BEGIN
      cur := pac_md_persona.f_busqueda_masdatos(mensajes, pomasdatos);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_busqueda_masdatos;

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
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'sperson= ' || sperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_GET_PERSONA_AGENTE';
      num_err        NUMBER;
   BEGIN
      num_err := pac_md_persona.f_get_persona_agente(sperson, pcagente, pmode, obpersona,
                                                     mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_persona_agente;

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
      pfnacimi IN DATE,   /* BUG11171:DRA:24/11/2009*/
      ptdomici IN VARCHAR2,   /* BUG11171:DRA:24/11/2009*/
      pcpostal IN VARCHAR2,
      pswpubli IN NUMBER,
      pestseguro IN NUMBER)
      RETURN sys_refcursor IS
      condicio       VARCHAR2(1000);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'numide= ' || numide || ', nombre= ' || nombre || ', nsip= ' || nsip
            || ',  pnom= ' || pnom || ', pcognom1= ' || pcognom1 || ', pcognom2= ' || pcognom2
            || ', pctipide= ' || pctipide || ', pfnacimi= ' || pfnacimi || ', ptdomici= '
            || ptdomici || ', pcpostal= ' || pcpostal;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_GET_DET_PERSONA';
   BEGIN
      cur := pac_md_persona.f_get_det_persona(numide, nombre, nsip, mensajes, pnom, pcognom1,
                                              pcognom2, pctipide, pfnacimi, ptdomici,
                                              pcpostal, pswpubli, pestseguro);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_det_persona;

   /*************************************************************************
     función que a partir de un sperson te devuelve los detalles
     de la persona, según el nivel de visión del usuario
     que esta consultando.
   *************************************************************************/
   FUNCTION f_get_agentes_vision(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      condicio       VARCHAR2(1000);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psperson= ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_GET_AGENTES_VISION';
   BEGIN
      cur := pac_md_persona.f_get_agentes_vision(psperson, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_agentes_vision;

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
      RETURN NUMBER IS
      condicio       VARCHAR2(1000);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psperson= ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_SET_BASICOS_PERSONA';
      vnum_err       NUMBER;
   BEGIN
      vnum_err := pac_md_persona.f_set_basicos_persona(psperson, pctipper, pctipide, pnnumide,
                                                       pcsexper, pfnacimi, pswpubli, 'POL',
                                                       pswrut, pcpreaviso, mensajes);

      IF vnum_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnum_err);
         /* error interno.*/
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnum_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_basicos_persona;

   /*************************************************************************
    función que devuelve la colección de tipo t_iax_irpf
   *************************************************************************/
   FUNCTION f_get_irpfs(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pirpfs OUT t_iax_irpf,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      condicio       VARCHAR2(1000);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psperson= ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_irpfs';
      vnum_err       NUMBER;
   BEGIN
      vnum_err := pac_md_persona.f_get_irpfs(psperson, pcagente, 'POL', pirpfs, mensajes);

      IF vnum_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnum_err;
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
   END f_get_irpfs;

   /*************************************************************************
    función que devuelve el objeto ob_iax_irpf a partir de BBDD
   *************************************************************************/
   FUNCTION f_get_irpf(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      pirpf OUT ob_iax_irpf,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      condicio       VARCHAR2(1000);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psperson= ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_irpf';
      vnum_err       NUMBER;
   BEGIN
      vnum_err := pac_md_persona.f_get_irpf(psperson, pcagente, pnano, 'POL', pirpf, mensajes);

      IF vnum_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnum_err;
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
   END f_get_irpf;

   /*************************************************************************
    función que traspasa los datos del IRPF al objeto persistente
   *************************************************************************/
   FUNCTION f_inicializa_obirpf(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      condicio       VARCHAR2(1000);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psperson= ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_inicializa_obirpf';
      vnum_err       NUMBER;
      pirpf          ob_iax_irpf := ob_iax_irpf();
   BEGIN
      vnum_err := pac_iax_persona.f_get_irpf(psperson, pcagente, pnano, pirpf, mensajes);
      pac_iax_persona.v_obirpf := pirpf;

      IF vnum_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnum_err;
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
   END f_inicializa_obirpf;

   /*************************************************************************
    función que recupera el objeto persistente ob_iax_irpf
   *************************************************************************/
   FUNCTION f_get_objetoirpf(pirpf OUT ob_iax_irpf, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      condicio       VARCHAR2(1000);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_objetoirpf';
      vnum_err       NUMBER;
   BEGIN
      pirpf := pac_iax_persona.v_obirpf;
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
   END f_get_objetoirpf;

   /*************************************************************************
    función que recupera el objeto persistente ob_iax_irpf.mayores y ob_iax_irpf.descendientes
   *************************************************************************/
   FUNCTION f_get_objetos_asc_desc(
      pirpfmayores OUT t_iax_irpfmayores,
      pirpfdescen OUT t_iax_irpfdescen,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      condicio       VARCHAR2(1000);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_objetosascendientesdescendientes';
      vnum_err       NUMBER;
   BEGIN
      pirpfmayores := pac_iax_persona.v_obirpf.mayores;
      pirpfdescen := pac_iax_persona.v_obirpf.descendientes;
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
   END f_get_objetos_asc_desc;

   /*************************************************************************
    función graba en una variable global de la capa IAX los valores del objeto
    irpfdescen
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
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psperson=' || psperson || ' pcagente=' || pcagente || 'pnano=' || pnano
            || ' pnorden=' || pnorden || 'pfnacimi=' || pfnacimi || ' pcgrado=' || pcgrado;
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.F_Set_objetoirpfdescen';
      v_index        NUMBER(2);
      v_trobat       BOOLEAN := FALSE;
      v_irpfmayores  t_iax_irpfmayores;
      vnorden        NUMBER;
   BEGIN
      /*Comprovació de paràmetres*/
      IF psperson IS NULL
         OR pcagente IS NULL
         OR pnano IS NULL
         OR pfnacimi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF pnorden IS NULL THEN
         vnorden := v_obirpf.mayores.COUNT + 1;
      END IF;

      IF pnorden IS NOT NULL THEN
         IF v_obirpf.mayores IS NOT NULL THEN
            FOR i IN v_obirpf.mayores.FIRST .. v_obirpf.mayores.LAST LOOP
               IF v_obirpf.mayores(i).sperson = psperson
                  AND v_obirpf.mayores(i).cagente = pcagente
                  AND v_obirpf.mayores(i).nano = pnano
                  AND v_obirpf.mayores(i).norden = pnorden THEN
                  /* Si el trobem, el modifiquem*/
                  v_obirpf.mayores(i).cagente := pcagente;
                  v_obirpf.mayores(i).nano := pnano;
                  v_obirpf.mayores(i).norden := pnorden;
                  v_obirpf.mayores(i).fnacimi := pfnacimi;
                  v_obirpf.mayores(i).cgrado := pcgrado;
                  v_obirpf.mayores(i).tgrado :=
                                  ff_desvalorfijo(688, pac_md_common.f_get_cxtidioma, pcgrado);
                  v_obirpf.mayores(i).nviven := pnviven;
                  v_obirpf.mayores(i).crenta := pcrenta;
                  v_trobat := TRUE;
               END IF;
            END LOOP;
         END IF;
      ELSE
         IF v_obirpf.mayores IS NULL THEN
            v_obirpf.mayores := t_iax_irpfmayores();
         END IF;

         vpasexec := 7;
         v_obirpf.mayores.EXTEND;
         v_index := v_obirpf.mayores.LAST;
         v_obirpf.mayores(v_index) := ob_iax_irpfmayores();
         v_obirpf.mayores(v_index).sperson := psperson;
         v_obirpf.mayores(v_index).cagente := pcagente;
         v_obirpf.mayores(v_index).nano := pnano;
         v_obirpf.mayores(v_index).norden := vnorden;
         v_obirpf.mayores(v_index).fnacimi := pfnacimi;
         v_obirpf.mayores(v_index).cgrado := pcgrado;
         v_obirpf.mayores(v_index).tgrado := ff_desvalorfijo(688,
                                                             pac_md_common.f_get_cxtidioma,
                                                             pcgrado);
         v_obirpf.mayores(v_index).nviven := pnviven;
         v_obirpf.mayores(v_index).crenta := pcrenta;
      END IF;

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
   END f_set_objetoirpfmayores;

   /*************************************************************************
    función graba en una variable global de la capa IAX los valores del objeto
    irpfmayores

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
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psperson=' || psperson || ' pcagente=' || pcagente || 'pnano=' || pnano
            || ' pnorden=' || pnorden || 'pfnacimi=' || pfnacimi || ' pcgrado=' || pcgrado
            || ' pfadopcion=' || pfadopcion;
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.F_Set_objetoirpfdescen';
      v_index        NUMBER(2);
      v_trobat       BOOLEAN := FALSE;
      vnorden        NUMBER(2);
   /*      v_irpfdescen   t_iax_irpfdescen;*/
   BEGIN
      /*Comprovació de paràmetres*/
      IF psperson IS NULL
         OR pcagente IS NULL
         OR pnano IS NULL
         OR pfnacimi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vnorden := pnorden;

      IF pnorden IS NULL THEN
         vnorden := v_obirpf.descendientes.COUNT + 1;
      END IF;

      IF pnorden IS NOT NULL THEN
         IF v_obirpf.descendientes IS NOT NULL THEN
            FOR i IN v_obirpf.descendientes.FIRST .. v_obirpf.descendientes.LAST LOOP
               IF v_obirpf.descendientes(i).sperson = psperson
                  AND v_obirpf.descendientes(i).cagente = pcagente
                  AND v_obirpf.descendientes(i).nano = pnano
                  AND v_obirpf.descendientes(i).norden = pnorden THEN
                  /* Si el trobem, el modifiquem*/
                  v_obirpf.descendientes(i).cagente := pcagente;
                  v_obirpf.descendientes(i).nano := pnano;
                  v_obirpf.descendientes(i).norden := pnorden;
                  v_obirpf.descendientes(i).fnacimi := pfnacimi;
                  /* bug 12716 - 25/03/2010 - AMC*/
                  v_obirpf.descendientes(i).fadopcion := pfadopcion;
                  /* fi bug 12716 - 25/03/2010 - AMC*/
                  v_obirpf.descendientes(i).cgrado := pcgrado;
                  v_obirpf.descendientes(i).tgrado :=
                                  ff_desvalorfijo(688, pac_md_common.f_get_cxtidioma, pcgrado);
                  v_obirpf.descendientes(i).center := pcenter;
                  v_trobat := TRUE;
               END IF;
            END LOOP;
         END IF;
      ELSE
         IF v_obirpf.descendientes IS NULL THEN
            v_obirpf.descendientes := t_iax_irpfdescen();
         END IF;

         vpasexec := 7;
         v_obirpf.descendientes.EXTEND;
         v_index := v_obirpf.descendientes.LAST;
         v_obirpf.descendientes(v_index) := ob_iax_irpfdescen();
         v_obirpf.descendientes(v_index).sperson := psperson;
         v_obirpf.descendientes(v_index).cagente := pcagente;
         v_obirpf.descendientes(v_index).nano := pnano;
         v_obirpf.descendientes(v_index).norden := vnorden;
         v_obirpf.descendientes(v_index).fnacimi := pfnacimi;
         /* bug 12716 - 25/03/2010 - AMC*/
         v_obirpf.descendientes(v_index).fadopcion := pfadopcion;
         /* fi bug 12716 - 25/03/2010 - AMC*/
         v_obirpf.descendientes(v_index).cgrado := pcgrado;
         v_obirpf.descendientes(v_index).tgrado :=
                                   ff_desvalorfijo(688, pac_md_common.f_get_cxtidioma, pcgrado);
         v_obirpf.descendientes(v_index).center := pcenter;
      END IF;

      vpasexec := 5;
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
   END f_set_objetoirpfdescen;

   /*************************************************************************
    función borra de l'objecte persistent un irpfdescen
   *************************************************************************/
   FUNCTION f_del_objetoirpfdescen(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      pnorden IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psperson=' || psperson || ' pcagente=' || pcagente || 'pnano=' || pnano
            || ' pnorden=' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.F_del_objetoirpfdescen';
   BEGIN
      /*Comprovació de paràmetres*/
      IF psperson IS NULL
         OR pcagente IS NULL
         OR pnano IS NULL
         OR pnorden IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF v_obirpf.descendientes IS NOT NULL THEN
         FOR i IN v_obirpf.descendientes.FIRST .. v_obirpf.descendientes.LAST LOOP
            IF v_obirpf.descendientes(i).sperson = psperson
               AND v_obirpf.descendientes(i).cagente = pcagente
               AND v_obirpf.descendientes(i).nano = pnano
               AND v_obirpf.descendientes(i).norden = pnorden THEN
               /* Si el trobem, el modifiquem*/
               v_obirpf.descendientes.DELETE(i);
            END IF;
         END LOOP;
      END IF;

      vpasexec := 5;
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
   END f_del_objetoirpfdescen;

   /*************************************************************************
    función borra de l'objecte persistent un objetoirpfmayor
   *************************************************************************/
   FUNCTION f_del_objetoirpfmayor(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      pnorden IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psperson=' || psperson || ' pcagente=' || pcagente || 'pnano=' || pnano
            || ' pnorden=' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.F_del_objetoirpfmayor';
   BEGIN
      /*Comprovació de paràmetres*/
      IF psperson IS NULL
         OR pcagente IS NULL
         OR pnano IS NULL
         OR pnorden IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF v_obirpf.mayores IS NOT NULL THEN
         FOR i IN v_obirpf.mayores.FIRST .. v_obirpf.mayores.LAST LOOP
            IF v_obirpf.mayores(i).sperson = psperson
               AND v_obirpf.mayores(i).cagente = pcagente
               AND v_obirpf.mayores(i).nano = pnano
               AND v_obirpf.mayores(i).norden = pnorden THEN
               /* Si el trobem, el modifiquem*/
               v_obirpf.mayores.DELETE(i);
            END IF;
         END LOOP;
      END IF;

      vpasexec := 5;
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
   END f_del_objetoirpfmayor;

   /*************************************************************************
    función borra todo el objeto irpf de bbdd
   *************************************************************************/
   FUNCTION f_del_irpf(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psperson= ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_del_irpf';
      vnum_err       NUMBER;
   BEGIN
      vnum_err := pac_md_persona.f_del_irpf(psperson, pcagente, pnano, 'POL', mensajes);

      IF vnum_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnum_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_irpf;

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
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psperson= ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_set_irpf';
      vnum_err       NUMBER;
   BEGIN
      /*Comprovació de paràmetres*/
      IF psperson IS NULL
         OR pcagente IS NULL
         OR pnano IS NULL
         OR pcsitfam IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF v_obirpf IS NOT NULL THEN
         v_obirpf.sperson := psperson;
         v_obirpf.cagente := pcagente;
         v_obirpf.nano := pnano;
         v_obirpf.csitfam := pcsitfam;
         v_obirpf.cnifcon := pcnifcon;
         v_obirpf.cgrado := pcgrado;
         v_obirpf.cayuda := pcayuda;
         v_obirpf.ipension := pipension;
         v_obirpf.ianuhijos := pianuhijos;
         v_obirpf.prolon := pprolon;
         v_obirpf.rmovgeo := prmovgeo;
         /*bug 12716 - 29/03/2010 - AMC*/
         v_obirpf.fmovgeo := pfmovgeo;
         v_obirpf.cpago := pcpago;
      /* fi bug 12716 - 29/03/2010 - AMC*/
      END IF;

      vnum_err := pac_md_persona.f_set_irpf(v_obirpf, 'POL', mensajes);

      IF vnum_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnum_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_irpf;

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
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psperson= ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_anysIrpf';
      vnum_err       NUMBER;
   BEGIN
      vnum_err := pac_md_persona.f_get_anysirpf(psperson, pcagente, pnanos, mensajes);

      IF vnum_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnum_err;
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
   END f_get_anysirpf;

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
      RETURN sys_refcursor IS
      condicio       VARCHAR2(1000);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'numide= ' || numide || ', nombre= ' || nombre || ', nsip= ' || nsip
            || ',  pnom= ' || pnom || ', pcognom1= ' || pcognom1 || ', pcognom2= ' || pcognom2
            || ', pctipide= ' || pctipide;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_personas_generica';
   BEGIN
      cur := pac_md_persona.f_get_personas_generica(numide, nombre, nsip, mensajes, pnom,
                                                    pcognom1, pcognom2, pctipide, pcagente,
                                                    pmodo_swpubli);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_personas_generica;

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
      fnacimi IN DATE,   /* Fecha de nacimiento de la persona*/
      pmodo IN VARCHAR2,
      psseguro IN NUMBER,
      pcagente IN NUMBER,
      pswpubli IN NUMBER,
      obpersona OUT ob_iax_personas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros  - pctipper = ' || pctipper || ' - pctipide = ' || pctipide
            || ' - pnnumnif = ' || pnnumnif || ' - pcsexper = ' || pcsexper
            || ' - fnacimi  = ' || fnacimi || ' - pmodo       = ' || pmodo || ' - psseguro = '
            || psseguro || ' - pcagente = ' || pcagente || ' - pswpubli = ' || pswpubli;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_PersonaUnica_GENERICA';
      objpers        t_iax_personas;
      ptablas        VARCHAR2(20);
      vcagentvisio   NUMBER;
   BEGIN
      vnumerr := pac_md_persona.f_agente_cpervisio(pcagente, vcagentvisio, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      ptablas := pac_md_common.f_get_ptablas(pmodo, mensajes);
      obpersona := pac_md_persona.f_get_personaunica(pctipper, pctipide, pnnumnif, pcsexper,
                                                     fnacimi, pmodo, psseguro, vcagentvisio,
                                                     pswpubli, ptablas, NULL, mensajes);
      RETURN 0;
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
   END f_get_personaunica_generica;

   /* ini t.8063*/
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
      RETURN sys_refcursor IS
      condicio       VARCHAR2(1000);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'numide= ' || numide || ', nombre= ' || nombre || ', nsip= ' || nsip
            || ',  pnom= ' || pnom || ', pcognom1= ' || pcognom1 || ', pcognom2= ' || pcognom2
            || ', pctipide= ' || pctipide;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_GET_PERSONAS_PUBLICAS';
   BEGIN
      cur := pac_md_persona.f_get_personas_publicas(numide, nombre, nsip, mensajes, pnom,
                                                    pcognom1, pcognom2, pctipide);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_personas_publicas;

   /*************************************************************************
   Obtiene los datos de las EST en un objeto OB_IAX_PERSONA
   param out mensajes  : mensajes de error
   return              : El OB_IAX_PERSONA
   *************************************************************************/
   FUNCTION f_get_persona_publica(
      psperson IN NUMBER,
      obpersona OUT ob_iax_personas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_persona_publica';
      objpers        ob_iax_personas := ob_iax_personas();
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      obpersona := pac_md_persona.f_get_persona_publica(psperson, mensajes);

      IF obpersona IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN 0;
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
   END f_get_persona_publica;

   /*BUG 10074 - JTS - 18/05/2009*/
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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_profesionales';
      squery         VARCHAR2(3000);
   BEGIN
      vnumerr := pac_md_persona.f_get_profesionales(psperson, pcur, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_profesionales;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_companias';
      squery         VARCHAR2(3000);
   BEGIN
      vnumerr := pac_md_persona.f_get_companias(psperson, pcur, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_companias;

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
      RETURN NUMBER IS
     vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_agentes';
      squery         VARCHAR2(3000);
   BEGIN
      vnumerr := pac_md_persona.f_get_agentes(psperson, pcur, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_agentes;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_siniestros';
      squery         VARCHAR2(3000);
   BEGIN
      vnumerr := pac_md_persona.f_get_siniestros(psperson, pcur, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_siniestros;

   /*Fi BUG 10074 - JTS - 18/05/2009*/
   /*BUG 10371 - JTS - 09/06/2009*/
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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' - pcagente: ' || pcagente
            || ' - ptots: ' || ptots;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_Parpersona';
      squery         VARCHAR2(5000);
   BEGIN
      IF psperson IS NULL
         OR pcagente IS NULL
         OR ptots IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_parpersona(psperson, pcagente, pcvisible, ptots, 'POL',
                                                 NULL, pcur, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_parpersona;

   /*************************************************************************
   Obté la select amb els paràmetres per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in ptots      : 0.- Només retorna els paràmetres contestats
                         1.- Retorna tots els paràmetres
   param in pctipper   : Codi ctipper
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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      pcur           sys_refcursor;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' - pcagente: ' || pcagente
            || ' - ptots: ' || ptots || ' - pctipper: ' || pctipper;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_ESTParpersona';
      squery         VARCHAR2(5000);
      obparpersona   ob_iax_par_personas := ob_iax_par_personas();
      pparper2       t_iax_par_personas;
      vorden         NUMBER;
      vorden1        NUMBER;
      v              NUMBER;
   BEGIN
      IF ptots IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF (parpersonas IS NULL
          OR parpersonas.COUNT = 0)
         OR ptots = 1 THEN
         vnumerr := pac_md_persona.f_get_parpersona(psperson, pcagente, pcvisible, ptots,
                                                    'EST', pctipper, pcur, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;

         vpasexec := 3;
         pparper2 := parpersonas;
         parpersonas := t_iax_par_personas();
         obparpersona := ob_iax_par_personas();
         vpasexec := 4;

         LOOP
            FETCH pcur
             INTO v, obparpersona.cgrppar, obparpersona.tgrppar,
                                                                /* Bug 24764/138736 - 22/02/2013 - AMC*/
                                                                obparpersona.cutili,
                  obparpersona.cparam, obparpersona.ctipo, obparpersona.tparam,
                  obparpersona.cvisible, obparpersona.ctipper, obparpersona.tvalpar,
                  obparpersona.nvalpar, obparpersona.fvalpar, obparpersona.resp, vorden,
                  vorden1;

            /* Bug 24764/138736 - 22/02/2013 - AMC*/
            EXIT WHEN pcur%NOTFOUND;
            vpasexec := 5;
            parpersonas.EXTEND;
            parpersonas(parpersonas.LAST) := obparpersona;
            obparpersona := ob_iax_par_personas();
         END LOOP;

         vpasexec := 6;

         IF pparper2 IS NOT NULL
            AND pparper2.COUNT > 0
            AND parpersonas IS NOT NULL
            AND parpersonas.COUNT > 0 THEN
            vpasexec := 7;

            FOR j IN parpersonas.FIRST .. parpersonas.LAST LOOP
               FOR i IN pparper2.FIRST .. pparper2.LAST LOOP
                  IF parpersonas(j).cparam = pparper2(i).cparam THEN
                     parpersonas(j).tvalpar := pparper2(i).tvalpar;
                     parpersonas(j).nvalpar := pparper2(i).nvalpar;
                     parpersonas(j).fvalpar := pparper2(i).fvalpar;
                     vpasexec := 8;

                     IF pparper2(i).nvalpar IS NOT NULL
                        AND pparper2(i).ctipo IN(4, 5) THEN
                        /* SOLO PARA TIPO LISTA O TIPO B?QUEDA*/
                        BEGIN
                           SELECT det.tvalpar
                             INTO parpersonas(j).resp
                             FROM detparam det
                            WHERE det.cparam = parpersonas(j).cparam
                              AND det.cidioma = pac_md_common.f_get_cxtidioma
                              AND det.cvalpar = pparper2(i).nvalpar;
                        EXCEPTION
                           WHEN OTHERS THEN
                              vparam := vparam || ' cparam = ' || parpersonas(j).cparam
                                        || '  nvalpar = ' || pparper2(i).nvalpar;
                              pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                                                vpasexec, vparam,
                                                                psqcode => SQLCODE,
                                                                psqerrm => SQLERRM);
                        END;
                     END IF;
                  END IF;
               END LOOP;
            END LOOP;
         END IF;
      END IF;

      vpasexec := 9;

      /*pparper := parpersonas;*/
      IF ptots = 0 THEN
         IF parpersonas IS NOT NULL
            AND parpersonas.COUNT > 0 THEN
            pparper := t_iax_par_personas();
            vpasexec := 10;

            FOR i IN parpersonas.FIRST .. parpersonas.LAST LOOP
               IF parpersonas(i).nvalpar IS NOT NULL
                  OR parpersonas(i).tvalpar IS NOT NULL
                  OR parpersonas(i).fvalpar IS NOT NULL THEN
                  pparper.EXTEND;
                  pparper(pparper.LAST) := parpersonas(i);
               END IF;
            END LOOP;
         END IF;
      ELSE
         pparper := parpersonas;
      END IF;

      vpasexec := 11;
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
   END f_get_estparpersona;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      pcur           sys_refcursor;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' - pcagente: ' || pcagente
            || '  - pcvisible ' || pcvisible || ' - ptots: ' || ptots || ' - ptablas: '
            || ptablas;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_parpersona_ob';
      squery         VARCHAR2(5000);
      obparpersona   ob_iax_par_personas := ob_iax_par_personas();
      pparper2       t_iax_par_personas;
      vorden         NUMBER;
      vorden1        NUMBER;
      v              NUMBER;
   BEGIN
      IF ptots IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF (parpersonas IS NULL
          OR parpersonas.COUNT = 0)
         OR ptots = 1 THEN
         IF psperson IS NOT NULL THEN
            vnumerr := pac_md_persona.f_get_parpersona(psperson, pcagente, pcvisible, ptots,
                                                       ptablas, NULL, pcur, mensajes);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;

            pparper2 := parpersonas;
            parpersonas := t_iax_par_personas();
            obparpersona := ob_iax_par_personas();

            LOOP
               FETCH pcur
                INTO v, obparpersona.cutili, obparpersona.cparam, obparpersona.ctipo,
                     obparpersona.tparam, obparpersona.cvisible, obparpersona.ctipper,
                     obparpersona.tvalpar, obparpersona.nvalpar, obparpersona.fvalpar,
                     obparpersona.resp, vorden, vorden1;

               EXIT WHEN pcur%NOTFOUND;
               parpersonas.EXTEND;
               parpersonas(parpersonas.LAST) := obparpersona;
               obparpersona := ob_iax_par_personas();
            END LOOP;

            IF pparper2 IS NOT NULL
               AND pparper2.COUNT > 0
               AND parpersonas IS NOT NULL
               AND parpersonas.COUNT > 0 THEN
               FOR j IN parpersonas.FIRST .. parpersonas.LAST LOOP
                  FOR i IN pparper2.FIRST .. pparper2.LAST LOOP
                     IF parpersonas(j).cparam = pparper2(i).cparam THEN
                        parpersonas(j).tvalpar := pparper2(i).tvalpar;
                        parpersonas(j).nvalpar := pparper2(i).nvalpar;
                        parpersonas(j).fvalpar := pparper2(i).fvalpar;

                        IF pparper2(i).nvalpar IS NOT NULL
                           AND pparper2(i).ctipo IN(4, 5) THEN
                           BEGIN
                              SELECT det.tvalpar
                                INTO parpersonas(j).resp
                                FROM detparam det
                               WHERE det.cparam = parpersonas(j).cparam
                                 AND det.cidioma = pac_md_common.f_get_cxtidioma
                                 AND det.cvalpar = pparper2(i).nvalpar;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 vparam := vparam || ' - CPARAM: ' || parpersonas(j).cparam
                                           || ' - NVALPAR : ' || pparper2(i).nvalpar;
                                 pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001,
                                                                   vpasexec, vparam,
                                                                   psqcode => SQLCODE,
                                                                   psqerrm => SQLERRM);
                           END;
                        END IF;
                     END IF;
                  END LOOP;
               END LOOP;
            END IF;
         END IF;
      END IF;

      /*pparper := parpersonas;*/
      IF ptots = 0 THEN
         IF parpersonas IS NOT NULL
            AND parpersonas.COUNT > 0 THEN
            pparper := t_iax_par_personas();

            FOR i IN parpersonas.FIRST .. parpersonas.LAST LOOP
               IF parpersonas(i).nvalpar IS NOT NULL
                  OR parpersonas(i).tvalpar IS NOT NULL
                  OR parpersonas(i).fvalpar IS NOT NULL THEN
                  pparper.EXTEND;
                  pparper(pparper.LAST) := parpersonas(i);
               END IF;
            END LOOP;
         END IF;
      ELSE
         pparper := parpersonas;
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
   END f_get_parpersona_ob;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'parámetros - psperson: ' || psperson || ' - pcagente: ' || pcagente
            || ' - pcparam: ' || pcparam || ' - pnvalpar: ' || pnvalpar || ' - ptvalpar: '
            || ptvalpar || ' - pfvalpar: ' || pfvalpar;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Ins_Parpersona';
      trobat         BOOLEAN := FALSE;
   BEGIN
      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF parpersonas IS NOT NULL
         AND parpersonas.COUNT > 0 THEN
         FOR i IN parpersonas.FIRST .. parpersonas.LAST LOOP
            IF parpersonas(i).cparam = pcparam THEN
               parpersonas(i).tvalpar := ptvalpar;
               parpersonas(i).nvalpar := pnvalpar;
               parpersonas(i).fvalpar := pfvalpar;

               IF pnvalpar IS NOT NULL THEN
                  BEGIN
                     SELECT det.tvalpar
                       INTO parpersonas(i).resp
                       FROM detparam det
                      WHERE det.cparam = pcparam
                        AND det.cidioma = pac_md_common.f_get_cxtidioma
                        AND det.cvalpar = pnvalpar;
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;
               END IF;

               trobat := TRUE;
            END IF;
         END LOOP;
      END IF;

      IF NOT trobat THEN
         IF parpersonas IS NULL THEN
            parpersonas := t_iax_par_personas();
         END IF;

         parpersonas.EXTEND;
         parpersonas(parpersonas.LAST) := ob_iax_par_personas();
         vnumerr := pac_md_persona.f_get_obparpersona(pcparam, parpersonas(parpersonas.LAST),
                                                      mensajes);
         parpersonas(parpersonas.LAST).tvalpar := ptvalpar;
         parpersonas(parpersonas.LAST).nvalpar := pnvalpar;
         parpersonas(parpersonas.LAST).fvalpar := pfvalpar;

         IF pnvalpar IS NOT NULL THEN
            BEGIN
               SELECT det.tvalpar
                 INTO parpersonas(parpersonas.LAST).resp
                 FROM detparam det
                WHERE det.cparam = pcparam
                  AND det.cidioma = pac_md_common.f_get_cxtidioma
                  AND det.cvalpar = pnvalpar;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END IF;

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
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
   END f_ins_estparpersona;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' - pcagente: ' || pcagente
            || ' - pcparam: ' || pcparam || ' - pnvalpar: ' || pnvalpar || ' - ptvalpar: '
            || ptvalpar || ' - pfvalpar: ' || pfvalpar;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Ins_Parpersona';
   BEGIN
      IF psperson IS NULL
         OR pcagente IS NULL
         OR pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_ins_parpersona(psperson, pcagente, pcparam, pnvalpar,
                                                 ptvalpar, pfvalpar, 'POL', mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_ins_parpersona;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                       := 'parámetros - psperson: ' || psperson || ' - pcagente: ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_grabar_parpersona';
      vcagente       NUMBER;
   BEGIN
      IF ptablas = 'CAN' THEN
         parpersonas := NULL;
         RETURN 0;
      END IF;

      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF parpersonas IS NOT NULL
         AND parpersonas.COUNT > 0 THEN
         IF pac_iax_produccion.issuplem THEN
            vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vsseguro, 'POL', vcagente);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         ELSE
            /* DRA 13-10-2008: bug mantis 7784*/
            /*vcagente := pac_iax_persona.f_get_cagente (psperson, cagente, 'EST', mensajes);*/
            /* JLTS 14/02/2012: bug 22693/138033 QT-4918*/
            /*vcagente := pac_md_persona.f_get_cagentepol(psperson, EST, mensajes);*/
            vcagente := NVL(pcagente,
                            pac_iax_persona.f_get_cagente(psperson, pcagente, ptablas,
                                                          mensajes));
         END IF;

         IF ptablas = 'EST' THEN
            vnumerr := pac_md_persona.f_del_parpersona(psperson,
                                                       NVL(vcagente,
                                                           pac_md_common.f_get_cxtagente),
                                                       NULL, ptablas, mensajes);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;

         FOR i IN parpersonas.FIRST .. parpersonas.LAST LOOP
            IF parpersonas(i).nvalpar IS NOT NULL
               OR parpersonas(i).tvalpar IS NOT NULL
               OR parpersonas(i).fvalpar IS NOT NULL THEN
               vnumerr := pac_md_persona.f_ins_parpersona(psperson, vcagente,
                                                          parpersonas(i).cparam,
                                                          parpersonas(i).nvalpar,
                                                          parpersonas(i).tvalpar,
                                                          parpersonas(i).fvalpar, ptablas,
                                                          mensajes);

               IF vnumerr <> 0 THEN
                  RAISE e_object_error;
               END IF;
            END IF;
         END LOOP;
      END IF;

      parpersonas := NULL;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_grabar_parpersona;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' - pcagente: ' || pcagente
            || ' - pcparam: ' || pcparam;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Del_estParpersona';
      borrada        BOOLEAN := FALSE;
   BEGIN
      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF parpersonas IS NOT NULL
         AND parpersonas.COUNT > 0 THEN
         FOR i IN parpersonas.FIRST .. parpersonas.LAST LOOP
            IF parpersonas(i).cparam = pcparam THEN
               /*   parpersonas.DELETE(i);*/
               parpersonas(i).tvalpar := NULL;
               parpersonas(i).nvalpar := NULL;
               parpersonas(i).fvalpar := NULL;
               parpersonas(i).resp := NULL;
            END IF;
         END LOOP;
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
   END f_del_estparpersona;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' - pcagente: ' || pcagente
            || ' - pcparam: ' || pcparam;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Del_Parpersona';
   BEGIN
      IF psperson IS NULL
         OR pcagente IS NULL
         OR pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_del_parpersona(psperson, pcagente, pcparam, 'POL', mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_parpersona;

   /*Fi BUG 10371 - JTS - 09/06/2009*/
   /*************************************************************************
   param out pcur      : Cursor
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   /* Bug 11165 - 16/09/2009 - AMC - Se sustituÃ±e  T_iax_saldodeutorseg por t_iax_prestamoseg*/
   FUNCTION f_get_ctr_prestamoseg_host(
     pnriesgo IN NUMBER,
      pmodo IN VARCHAR2,
      pt_prestamoseg OUT t_iax_prestamoseg,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - : ';
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_ctr_saldodeutoseg_host';
      vsquery        VARCHAR2(5000);
      pcurprestamoseg sys_refcursor;
   BEGIN
      IF (pac_mdpar_productos.f_get_parproducto('WS_PRESTAMOS', pac_iax_produccion.vproducto) =
                                                                                              0) THEN
         RETURN 0;
      END IF;

      IF pnriesgo IS NULL THEN
         RAISE e_param_error;
      END IF;

      pt_prestamoseg := pac_iax_produccion.f_leedatosprestamoseg(pnriesgo, mensajes);

      IF pt_prestamoseg IS NULL
         AND NOT pac_iax_produccion.issimul THEN
         vnumerr := pac_iax_persona.f_get_contratos_host(pmodo, pt_prestamoseg, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
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
   END f_get_ctr_prestamoseg_host;

   /*************************************************************************
      Recupera Sperson del últim prenedor
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_spersoncontratos(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - : ';
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_spersoncontratos';
      vsquery        VARCHAR2(5000);
      poliza         ob_iax_detpoliza;
      tomador        ob_iax_tomadores;
   BEGIN
      poliza := pac_iobj_prod.f_getpoliza(mensajes);
      tomador := pac_iax_produccion.f_leeulttomadores(mensajes);
      RETURN tomador.sperson;
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
   END f_get_spersoncontratos;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - pmodo: ' || pmodo;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_contratos_host';
      vsquery        VARCHAR2(5000);
      cur            sys_refcursor;
      ptablas        VARCHAR2(40);
      vprestamo      ob_iax_prestamoseg := ob_iax_prestamoseg();
     vsperson       NUMBER;
      vicuota        NUMBER;
      vperiodo       VARCHAR2(3);
      vfechaini      DATE;
      vfechafin      DATE;
      tipointeres    NUMBER;
      modalidadinteres NUMBER;
      vdesc          VARCHAR2(2000);
      vcapitalactual NUMBER;
      poliza         ob_iax_detpoliza;   /* BUG10569:DRA:11/12/2009*/
      riesgos        t_iax_riesgos;
      v_trobat       BOOLEAN;
   BEGIN
      ptablas := pac_md_common.f_get_ptablas(pmodo, mensajes);
      ptablas := 'EST';
      vsperson := pac_iax_persona.f_get_spersoncontratos(mensajes);
      cur := pac_md_persona.f_get_contratos_host(vsperson, ptablas, mensajes);
      /* BUG10569:DRA:11/12/2009:Inici*/
      poliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      riesgos := pac_iobj_prod.f_partpolriesgos(poliza, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      pt_prestamo := pac_iobj_prod.f_partriessaldodeutor(riesgos(riesgos.FIRST), mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      /*BUG15199 - JTS - 09/07/2010*/
      IF pt_prestamo IS NOT NULL THEN
         IF pt_prestamo.COUNT > 0 THEN
            FOR i IN pt_prestamo.FIRST .. pt_prestamo.LAST LOOP
               pt_prestamo(i).isaldo := 0;
               pt_prestamo(i).ilimite := 0;
               pt_prestamo(i).isaldo := 0;
            END LOOP;
         END IF;
      END IF;

      /*Fi BUG15199 - JTS - 09/07/2010*/
      /* BUG10569:DRA:11/12/2009:Fi*/
      LOOP
         FETCH cur
          INTO vprestamo.ctipcuenta, vprestamo.idcuenta, vprestamo.descripcion,
               vcapitalactual, vprestamo.isaldo, vprestamo.ilimite, vprestamo.cmoneda,
               vicuota, vperiodo, vprestamo.finiprest, vprestamo.ffinprest, tipointeres,
               modalidadinteres;

         EXIT WHEN cur%NOTFOUND;

         IF vprestamo.ctipcuenta IS NOT NULL THEN
            vprestamo.ttipcuenta := ff_desvalorfijo(401, pac_md_common.f_get_cxtidioma(),
                                                    vprestamo.ctipcuenta);
         END IF;

         vprestamo.ttipban := ff_desvalorfijo(274, pac_md_common.f_get_cxtidioma(),
                                              vprestamo.ctipban);
         vprestamo.ctipimp := 1;   /*Saldo detvalores 402*/
         vprestamo.selsaldo := 0;

         IF vprestamo.ilimite IS NOT NULL THEN
            vprestamo.ctipimp := 3;   /*Limite detvalores 402*/
         END IF;

         IF vprestamo.porcen IS NOT NULL
            AND vprestamo.porcen > 0 THEN
            vprestamo.ctipimp := 2;   /*Percentatge sobre saldo detvalores 402*/
         END IF;

         IF vprestamo.ctipimp IS NOT NULL THEN
            vprestamo.ttipimp := ff_desvalorfijo(402, pac_md_common.f_get_cxtidioma(),
                                                 vprestamo.ctipimp);
         END IF;

         /* BUG10569:DRA:11/12/2009:Inici: Analizamos si teniamos contratada la cuenta y actualizamos*/
         v_trobat := FALSE;

         IF pt_prestamo IS NOT NULL THEN
            IF pt_prestamo.COUNT > 0 THEN
               FOR i IN pt_prestamo.FIRST .. pt_prestamo.LAST LOOP
                  IF pt_prestamo(i).idcuenta = vprestamo.idcuenta THEN
                     v_trobat := TRUE;
                     pt_prestamo(i).isaldo := vprestamo.isaldo;
                     pt_prestamo(i).ilimite := vprestamo.ilimite;

                     IF pac_iax_produccion.vproducto IN(569, 571, 572) THEN
                        pt_prestamo(i).isaldo := vcapitalactual;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;

         IF NOT v_trobat THEN
            pt_prestamo.EXTEND;
            pt_prestamo(pt_prestamo.LAST) := vprestamo;

            IF pac_iax_produccion.vproducto IN(569, 571, 572) THEN
               pt_prestamo(pt_prestamo.LAST).isaldo := vcapitalactual;
            END IF;
         END IF;

         /* BUG10569:DRA:11/12/2009:Fi*/
         vprestamo := ob_iax_prestamoseg();
      END LOOP;

      CLOSE cur;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         ROLLBACK;
         RETURN 1;
   END f_get_contratos_host;

   /* bug 11948.16/11/2009.NMM.i.*/
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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' - pcodiTabla: ' || pcoditabla
            || ' eg: ' || psseguro || ' psnip: ' || psnip;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA. f_traspasapersonapol';
      vcagente       NUMBER;
      /* Bug 18225 - APD - 11/04/2011 - la precisión de cdelega debe ser NUMBER*/
      vpsseguro      NUMBER := psseguro;   /*ACC 020209*/
      vexiste        NUMBER;
      vcagente_visio NUMBER;
      vcagente_per   NUMBER;
   BEGIN
      IF psperson IS NULL
         AND psnip IS NULL THEN
         RAISE e_param_error;
      END IF;

      vcagente := pcagente_in;

      IF psseguro IS NOT NULL THEN
         vpsseguro := psseguro;
         vnumerr := pac_seguros.f_get_cagente(vpsseguro, 'POL', vcagente);
         pac_persona.p_busca_agentes(psperson, vcagente, vcagente_visio, vcagente_per, 'POL');
         vcagente := vcagente_per;
      END IF;

     vnumerr := pac_md_persona.f_traspasapersona(psperson, psnip, vcagente, pcoditabla,
                                                  psperson_out, vpsseguro, 'POL', pmensapotup,
                                                  mensajes);
      pcagente := vcagente;
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_traspasapersonapol;

   /* bug 11948.16/11/2009.NMM.f.*/
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
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' nsip= ' || psnip;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_ccc_host_axis';
      vcagente       NUMBER;
      vnumerr        NUMBER;
   BEGIN
      vcagente := pcagente;

      /*vnumerr := pac_seguros.f_get_cagente(psseguro, 'POL', vcagente);*/
      IF vcagente IS NULL THEN
         vcagente := pac_md_common.f_get_cxtagente;
      END IF;

      cur := pac_md_persona.f_get_ccc_host_axis(psperson, psnip, vcagente, porigen, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ccc_host_axis;

   FUNCTION f_existe_ccc(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcbancar IN VARCHAR2,
      pctipban IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' - pcbancar: ' || pcbancar
            || ' vcagente: ' || pcagente || ' pctipban: ' || pctipban;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_existe_ccc';
      vcagente       NUMBER;
   /* Bug 18225 - APD - 11/04/2011 - la precisión de cdelega debe ser NUMBER*/
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vcagente := pcagente;

      IF pcagente IS NULL THEN
         vcagente := pac_md_common.f_get_cxtagenteprod;
      END IF;

      vnumerr := pac_md_persona.f_existe_ccc(psperson, vcagente, pcbancar, pctipban, mensajes);
      /*si retorn != null es que la compte existeix*/
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_existe_ccc;

   FUNCTION f_existe_persona(
      ppnnumide IN VARCHAR2,
      ppcsexper IN NUMBER,
      ppfnacimi IN DATE,
      psperson_new OUT NUMBER,
      ppsnip IN VARCHAR2,
      ppspereal IN NUMBER,
      ppcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - ppsperreal: ' || ppspereal || ' - ppnnumide: ' || ppnnumide
            || ' ppcagente: ' || ppcagente || ' ppsnip: ' || ppsnip;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_existe_ccc';
      vsperson       NUMBER(8);
   BEGIN
      /*  vnumerr := pac_persona.f_existe_persona(pac_iax_common.f_get_cxtempresa, ppnnumide,
      ppcsexper, ppfnacimi, PSPERSON_NEW, ppsnip,
     ppspereal);*/
      BEGIN
         /*miramos si existe alguna persona con el mismo nnumide*/
         SELECT MAX(sperson)
           INTO psperson_new
           FROM per_personas
          WHERE nnumide = ppnnumide
            AND swpubli = 0;   /* t.9318*/
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            psperson_new := NULL;
      END;

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_existe_persona;

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
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_SINIESTROS.f_inserta_Detalle_per';
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' pcagente: ' || pcagente
            || ' pcagente_prod: ' || pcagente_prod;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF psperson IS NULL
         OR pcagente_prod IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_inserta_detalle_per(psperson, pcagente, pcagente_prod,
                                                      mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_inserta_detalle_per;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - ppsperreal: ' || psperson || ' - ppnnumide: ' || pnnumide
            || ' ppcagente: ' || pcagente || ' ppsnip: ' || psnip;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_persona_duplicada';
      vsperson       NUMBER(8);
   BEGIN
      IF pnnumide IS NULL THEN
         RETURN 0;
      END IF;

      vnumerr := pac_md_persona.f_persona_duplicada(psperson, pnnumide, pcsexper, pfnacimi,
                                                    psnip, pcagente, pswpubli, pctipide,
                                                    pduplicada, mensajes,
                                                    pac_iax_produccion.vsolicit);

      IF vnumerr <> 0 THEN
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
   END f_persona_duplicada;

   /*************************************************************************
     FUNCTION que devuelve el nif, en el caso que sea un identificador interno
     param in psperson    : código interno
     param in pctipide    : tipo documento
     param in pnnumide    : Nnumide que vamos a comprobar
     param in psnip    : SNIP
     param out  pnnumide_out : nif de salida
     return           : código de error
     ---- Bug 17563 : AGA800 - data naixement - 08/03/2011 - XPL
                3.0  IAXIS-3060  CES    Ajuste Codigo identificacion del sistema Consorcios.                                                                                                                                                                                                                                                                                                     
   *************************************************************************/
   FUNCTION f_get_nif(
      psperson IN NUMBER,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      psnip IN VARCHAR2,
      pnnumide_out OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - ppsperreal: ' || psperson || ' - ppnnumide: ' || pnnumide
            || ' pctipide: ' || pctipide || ' ppsnip: ' || psnip;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_nif';
      vsperson       NUMBER(8);
   BEGIN
      pnnumide_out := pnnumide;

      IF pctipide = 0 THEN
--INI-IAXIS-3060-CES 
         vnumerr := f_snnumnif('9', pnnumide_out);
--END-IAXIS-3060-CES                                                                                                                   
      ELSIF pctipide = 96 THEN
         vnumerr := f_snnumnif('4', pnnumide_out);
      --   
      -- Inicio IAXIS-4832(4) 05/09/2019
      --
      -- Se agrega el tipo de identificación "Sin definir"
      ELSIF pctipide = 98 THEN
         vnumerr := f_snnumnif('8', pnnumide_out);
      --   
      -- Fin IAXIS-4832(4) 05/09/2019
      --
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
   END f_get_nif;

   /*************************************************************************
    Nueva función que se encarga de borrar una persona relacionada
    return              : 0 Ok. 1 Error
    Bug.: 18941
   *************************************************************************/
   FUNCTION f_del_persona_rel(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      psperson_rel IN NUMBER,
      pcagrupa IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
            := 'parámetros - psperson: ' || psperson || ' ' || pcagente || ' ' || psperson_rel;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Del_Persona_Rel';
   BEGIN
      IF psperson IS NULL
         OR pcagente IS NULL
         OR psperson_rel IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_del_persona_rel(psperson, pcagente, psperson_rel, pcagrupa, mensajes,
                                                  'POL');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_persona_rel;

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
      pislider IN NUMBER,   /* BUG 0030525 - FAL - 01/04/2014*/
                  ptlimit IN VARCHAR2 DEFAULT '',
                  pcagrupa IN NUMBER,
      pfagrupa IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' ' || pcagente || ' ' || psperson_rel
            || ' ' || pctipper_rel || ' ' || ppparticipacion;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_set_Persona_Rel';
   BEGIN
      IF psperson_rel IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902301);
         RETURN 1;
      END IF;

      IF psperson IS NULL
         OR pcagente IS NULL
         OR psperson_rel IS NULL
         OR pctipper_rel IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_set_persona_rel(psperson, pcagente, psperson_rel,
                                                  pctipper_rel, ppparticipacion, pislider,
                                                  mensajes, 'POL', ptlimit,pcagrupa,pfagrupa);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_persona_rel;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                := 'parámetros - psperson: ' || psperson || ' ' || pcagente || ' ' || pfefecto;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_del_regimenfiscal';
   BEGIN
      IF psperson IS NULL
         OR pcagente IS NULL
         OR pfefecto IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_del_regimenfiscal(psperson, pcagente, pfefecto, mensajes,
                                                    'POL');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_regimenfiscal;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'par?!metros - psperson: ' || psperson || ' ' || pcagente || ' ' || pfefecto || ' '
            || pcregfiscal || ' ' || pctipiva;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_set_regimenfiscal';
      vcagente       NUMBER;
   BEGIN
      IF psperson IS NULL
         OR pfefecto IS NULL
         OR pcregfiscal IS NULL THEN
         RAISE e_param_error;
      END IF;

      vcagente := NVL(pcagente,
                      pac_iax_persona.f_get_cagente(psperson, pcagente, 'POL', mensajes));
      vnumerr := pac_md_persona.f_set_regimenfiscal(psperson, vcagente, pfefecto, pcregfiscal,
                                                    pcregfisexeiva,pctipiva, mensajes, 'POL');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_regimenfiscal;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'par?!metros - psperson: ' || psperson || ' ' || pcagente || ' ' || pfefecto || ' '
            || pcregfiscal|| ' '|| pctipiva;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_set_estregimenfiscal';
      vcagente       NUMBER := pcagente;
   BEGIN
      IF psperson IS NULL
         OR pfefecto IS NULL
         OR pcregfiscal IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pac_iax_produccion.issuplem THEN
         vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vsseguro, 'POL', vcagente);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      ELSE
         /* svj Bug 0025938  En nueva producci??ogemos el agente de producci?? si no esta inicializado el de la p??a.*/
         vcagente := pac_md_common.f_get_cxtagenteprod();

         IF vcagente IS NULL THEN
            vnumerr := pac_seguros.f_get_cagente(pac_iax_produccion.vssegpol, 'POL', vcagente);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;
      /* Fin svj Bug 0025938*/
      END IF;

      vnumerr := pac_md_persona.f_set_regimenfiscal(psperson, vcagente, pfefecto, pcregfiscal, pctipiva,
                                                    NULL, mensajes, 'EST');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_estregimenfiscal;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' pcagente: ' || pcagente
            || ' pfefecto: ' || pfefecto;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_del_sarlaft';
   BEGIN
      IF psperson IS NULL
         OR pcagente IS NULL
         OR pfefecto IS NULL THEN
         RAISE e_param_error;
      END IF;

      /* de momento solo se utiliza para las tablas reales (POL por defecto), no se hace la parte de las EST*/
      vnumerr := pac_md_persona.f_del_sarlaft(psperson, pcagente, pfefecto, mensajes, 'POL');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
     END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_sarlaft;

   /*************************************************************************
    Nueva funcion que se encarga de crear un registro de SARLAFT
    return              : 0 Ok. 1 Error
    Bug.: 18943
   *************************************************************************/
   FUNCTION f_set_sarlaft(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfefecto IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' pcagente: ' || pcagente
            || ' pfefecto: ' || pfefecto;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_set_sarlaft';
   BEGIN
      IF psperson IS NULL
         OR pcagente IS NULL
         OR pfefecto IS NULL THEN
         RAISE e_param_error;
      END IF;

      /* de momento solo se utiliza para las tablas reales (POL por defecto), no se hace la parte de las EST*/
      vnumerr := pac_md_persona.f_set_sarlaft(psperson, pcagente, pfefecto, mensajes, 'POL');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_sarlaft;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_gestores_empleados';
      squery         VARCHAR2(3000);
   BEGIN
      vnumerr := pac_md_persona.f_get_gestores_empleados(psperson, pcur, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_gestores_empleados;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_represent_promotores';
      squery         VARCHAR2(3000);
   BEGIN
      vnumerr := pac_md_persona.f_get_represent_promotores(psperson, pcur, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_represent_promotores;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_coordinadores';
      squery         VARCHAR2(3000);
   BEGIN
      vnumerr := pac_md_persona.f_get_coordinadores(psperson, pcur, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_coordinadores;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_listas_oficiales';
      squery         VARCHAR2(3000);
   BEGIN
      vnumerr := pac_md_persona.f_get_listas_oficiales(psperson, pcclalis, pcur, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_listas_oficiales;

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
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONAS.F_Get_TipCCC';
   BEGIN
      cur := pac_md_listvalores.f_get_tipccc(mensajes, pctipocc);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipccc;

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
      RETURN sys_refcursor IS
      condicio       VARCHAR2(1000);
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'numide= ' || numide || ', nombre= ' || nombre || ', nsip= ' || nsip
            || ',  pnom= ' || pnom || ', pcognom1= ' || pcognom1 || ', pcognom2= ' || pcognom2
            || ', pctipide= ' || pctipide;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_personas_generica_cond';
      cond           VARCHAR2(2000);
      verror         BOOLEAN := FALSE;
   BEGIN
      cond := pac_md_listvalores.f_get_lstcondiciones(pac_md_common.f_get_cxtempresa, f_user,
                                                      pccondicion, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            verror := TRUE;
         END IF;
      END IF;

      IF verror
         OR pccondicion IS NULL THEN
         cur := pac_md_persona.f_get_personas_generica(numide, nombre, nsip, mensajes, pnom,
                                                       pcognom1, pcognom2, pctipide, pcagente,
                                                       pmodo_swpubli);
      ELSE
         cur := pac_md_persona.f_get_personas_generica_cond(numide, nombre, nsip, mensajes,
                                                            pnom, pcognom1, pcognom2,
                                                            pctipide, pcagente, pmodo_swpubli,
                                                            cond);
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_personas_generica_cond;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' - pcagente: ' || pcagente
            || ' - pfcaduca: ' || TO_CHAR(pfcaduca, 'DD/MM/YYYY') || ' - ptobserva: '
            || ptobserva || ' - ptfilename: ' || ptfilename || ' - piddocgedox: '
            || piddocgedox || ' - ptdesc: ' || ptdesc || ' - pidcat: ' || pidcat
            || ' - ptdocumento: ' || ptdocumento || ' - pedocumento: ' || pedocumento
            || ' - pfedo: ' || pfedo;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_set_docpersona';
      viddocgedox    NUMBER;
   BEGIN
      IF psperson IS NULL
         OR pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      viddocgedox := piddocgedox;

      IF viddocgedox IS NOT NULL THEN
         vnumerr := pac_md_persona.f_set_docpersona(psperson, pcagente, pfcaduca, ptobserva,
                                                    viddocgedox, ptdocumento, pedocumento,
                                                    pfedo, mensajes);
      ELSE
         vnumerr := pac_md_gedox.f_set_documpersgedox(psperson, pcagente,
                                                      pac_md_common.f_get_cxtusuario(),
                                                      pfcaduca, ptobserva, ptfilename,
                                                      viddocgedox, ptdesc, pidcat,
                                                      ptdocumento, pedocumento, pfedo,
                                                      mensajes);
      END IF;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_docpersona;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      cpais          NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' pcagente = ' || pcagente
            || ' piddocgedox = ' || piddocgedox || ' ptablas = ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_docpersona';
      dummy          NUMBER;
   BEGIN
      IF psperson IS NULL
         OR pcagente IS NULL
         OR piddocgedox IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_docpersona(psperson, pcagente, piddocgedox, ptablas,
                                                 pobdocpersona, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_docpersona;

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
      RETURN VARCHAR2 IS
      vnumerr        NUMBER(8) := 0;
      cpais          NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                         := 'parmetros - pnnumide: ' || pnnumide || ' pctipide = ' || pctipide;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_digito_nif_col';
      digito         VARCHAR2(5);
   BEGIN
      IF pctipide IS NULL
         OR pnnumide IS NULL THEN
         RAISE e_param_error;
      END IF;

      digito := pac_md_persona.f_digito_nif_col(pctipide, pnnumide, mensajes);
      RETURN digito;
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
   END f_digito_nif_col;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vcodilit       NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_valida_pagoccc';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_valida_pagoccc(psperson, pcagente, pcnordban, vcodilit,
                                                 mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      IF vcodilit <> 0 THEN
         pcodilit := f_axis_literales(vcodilit);
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
   END f_valida_pagoccc;

   /***************************************************************************
   Funcin bloquear una persona por LOPD
   Traspasar los datos de la persona a las tablas LOPD
   *****************************************************************************/
   FUNCTION f_bloquear_persona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                         := 'parmetros - psperson: ' || psperson || ' pcagente = ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_bloquear_persona';
      vcagente       NUMBER := pcagente;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcagente IS NULL THEN
         vcagente := pac_md_common.f_get_cxtagente;
      END IF;

      vnumerr := pac_md_persona.f_bloquear_persona(psperson, pcagente, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN vnumerr;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN vnumerr;
   END f_bloquear_persona;

   /***************************************************************************
   Funcin desbloquear una persona por LOPD
   Volver a deja la persona igual que antes que el traspaso a las tablas LOPD
   *****************************************************************************/
   FUNCTION f_desbloquear_persona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                         := 'parmetros - psperson: ' || psperson || ' pcagente = ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_desbloquear_persona';
     vcagente       NUMBER := pcagente;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcagente IS NULL THEN
         vcagente := pac_md_common.f_get_cxtagente;
      END IF;

      vnumerr := pac_md_persona.f_desbloquear_persona(psperson, pcagente, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN vnumerr;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
        RETURN vnumerr;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN vnumerr;
   END f_desbloquear_persona;

/***************************************************************************
Funcin borra persona de la lopd
*****************************************************************************/
   FUNCTION f_borrar_persona_lopd(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                         := 'parmetros - psperson: ' || psperson || ' pcagente = ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_borrar_persona_lopd';
      vcagente       NUMBER := pcagente;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcagente IS NULL THEN
         vcagente := pac_md_common.f_get_cxtagente;
      END IF;

      vnumerr := pac_md_persona.f_borrar_persona_lopd(psperson, pcagente, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN vnumerr;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN vnumerr;
   END f_borrar_persona_lopd;

   /*Retorna l'ultim registre de la lopd per aquesta persona i agent*/
   FUNCTION f_get_perlopd(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pobperlopd OUT ob_iax_perlopd,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
     vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                         := 'parmetros - psperson: ' || psperson || ' pcagente = ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_perlopd';
      vcagente       NUMBER := pcagente;
      vtperlopd      t_iax_perlopd;
      vcestado       NUMBER;
      vtestado       VARCHAR2(300);
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcagente IS NULL THEN
         vcagente := pac_md_common.f_get_cxtagente;
      END IF;

      vnumerr := pac_md_persona.f_get_perlopd(psperson, pcagente, vtperlopd, vcestado,
                                              vtestado, mensajes, 'POL');

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      IF vtperlopd IS NOT NULL
         AND vtperlopd.COUNT > 0 THEN
         pobperlopd := vtperlopd(vtperlopd.FIRST);
      /*Ultimo movimiento, como hay un order by desc*/
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
   END f_get_perlopd;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parmetros - psperson: ' || psperson || ' pcagente = ' || pcagente
            || ' pcesion = ' || pcesion || ' ppublicidad = ' || ppublicidad || ' pacceso = '
            || pacceso || ' prectificacion = ' || prectificacion;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_set_persona_lopd';
      vcagente       NUMBER := pcagente;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcagente IS NULL THEN
         vcagente := pac_md_common.f_get_cxtagente;
      END IF;

      vnumerr := pac_md_persona.f_set_persona_lopd(psperson, pcagente, pcesion, ppublicidad,
                                                   pacceso, prectificacion, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN vnumerr;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN vnumerr;
   END f_set_persona_lopd;

   /**************************************************************
     Funci??ra obtener la lista de autorizaciones de contactos y la lista de autorizaciones de direcciones
     param in psperson : codigo de persona
     param in pcagente : codigo del agente
     return lista de autorizaciones
     BUG 18949/103391 - 03/02/2012 - AMC
   **************************************************************/
   FUNCTION f_get_autorizaciones(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_personas_aut IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                          := 'parametros - psperson: ' || psperson || ' pcagente:' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_GET_AUTORIZACIONES';
      vpersona_aut   ob_iax_personas_aut;
   BEGIN
      vpersona_aut := pac_md_persona.f_get_autorizaciones(psperson, pcagente, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN vpersona_aut;
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
   END f_get_autorizaciones;

   /**************************************************************
   Funci??ra obtener la lista de autorizaciones de contactos
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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parametros - psperson: ' || psperson || ' pcagente:' || pcagente || ' pcmodcon:'
            || pcmodcon || ' pnorden:' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_GET_CONTACTO_AUT';
   BEGIN
      IF psperson IS NULL
         OR pcagente IS NULL
         OR pcmodcon IS NULL
         OR pnorden IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_get_contacto_aut(psperson, pcagente, pcmodcon, pnorden,
                                                   obcontacto_aut, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_contacto_aut;

   /**************************************************************
   Funci??ra obtener la lista de autorizaciones de direcciones
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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parametros - psperson: ' || psperson || ' pcagente:' || pcagente || ' pcdomici:'
            || pcdomici;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_GET_DIRECCION_AUT';
   BEGIN
      vnumerr := pac_md_persona.f_get_direccion_aut(psperson, pcagente, pcdomici, pnorden,
                                                    obdireccion_aut, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_direccion_aut;

   /**************************************************************
   Funci??ra guardar los contactos
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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parametros - psperson: ' || psperson || ' pcagente:' || pcagente || ' pcmodcon:'
            || pcmodcon || ' pnorden:' || pnorden || ' pcestado:' || pcestado || ' ptobserva:'
            || ptobserva;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_SET_CONTACTO_AUT';
   BEGIN
      IF psperson IS NULL
         OR pcagente IS NULL
         OR pcmodcon IS NULL
         OR pnorden IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_set_contacto_aut(psperson, pcagente, pcmodcon, ptmodcon,
                                                   pnorden, pcestado, ptobserva, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_set_contacto_aut;

   /**************************************************************
   Funci??ra guardar las direcciones
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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parametros - psperson: ' || psperson || ' pcagente:' || pcagente || ' pcdomici:'
            || pcdomici || ' pnorden:' || pnorden || ' pcestado:' || pcestado || ' ptobserva:'
            || ptobserva;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_SET_DIRECCION_AUT';
   BEGIN
      IF psperson IS NULL
         OR pcagente IS NULL
         OR pcdomici IS NULL
         OR pnorden IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_set_direccion_aut(psperson, pcagente, pcdomici, pnorden,
                                                    pcestado, ptobserva, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_set_direccion_aut;

   /*INI BUG 22642--ETM --24/07/2012*/
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
      pctipfig IN NUMBER,
      pcur OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                          := 'parámetros - psperson: ' || psperson || ' pctipfig=' || pctipfig;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_inquiaval';
      squery         VARCHAR2(3000);
   BEGIN
      vnumerr := pac_md_persona.f_get_inquiaval(psperson, pctipfig, pcur, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_inquiaval;

   FUNCTION f_get_gescobro(
      psperson IN NUMBER,
      pcur OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_gescobro';
      squery         VARCHAR2(3000);
   BEGIN
      vnumerr := pac_md_persona.f_get_gescobro(psperson, pcur, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_gescobro;

   /*FIN BUG 22642 -- ETM --24/07/2012*/
   /*************************************************************************
   Funcion que recupera la informacion de la antiguedad de la persona
   return : cursor con el resultado
   *************************************************************************/
   /* Bug 25542 - APD - se crea la funcion*/
   FUNCTION f_get_antiguedad(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_antiguedad';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      cur := pac_md_persona.f_get_antiguedad(psperson, mensajes);
      vpasexec := 3;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN cur;
   END f_get_antiguedad;

   /*************************************************************
   funcion que devuelve los conductores
   **************************************************************/
   FUNCTION f_get_conductores(psperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'parametros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_conductores';
      cur            sys_refcursor;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      cur := pac_md_persona.f_get_conductores(psperson, mensajes);
      vpasexec := 3;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN cur;
   END f_get_conductores;

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
      RETURN sys_refcursor IS
      /**/
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_provinpoblapais';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'parametros - pcpostal: ' || pcpostal;
      srccur         sys_refcursor;
   /**/
   BEGIN
      /**/
      IF pcpostal IS NULL THEN
         RAISE e_param_error;
      END IF;

      /**/
      vpasexec := 2;
      /**/
      srccur := pac_md_persona.f_get_provinpoblapais(pcpostal, mensajes);
      /**/
      RETURN srccur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN srccur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN srccur;
   END f_get_provinpoblapais;

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
      RETURN sys_refcursor IS
      /**/
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_codpostal';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'parametros - pcpais: ' || pcpais || ' pcprovin: ' || pcprovin || ' pcpoblac: '
            || pcpoblac;
      srccur         sys_refcursor;
   /**/
   BEGIN
      /**/
      vpasexec := 2;
      /**/
      srccur := pac_md_persona.f_get_codpostal(pcpais, pcprovin, pcpoblac, mensajes);
      /**/
      RETURN srccur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN srccur;
   END f_get_codpostal;

   /*************************************************************
    funcion que devuelve CODISOTEL en la tabla paises
   **************************************************************/
   FUNCTION f_get_prefijospaises(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      /**/
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(1000) := 'parametros';
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_prefijospaises';
      v_cur          sys_refcursor;
   /**/
   BEGIN
      /**/
      v_cur := pac_md_persona.f_get_prefijospaises(mensajes);
      /**/
      vpasexec := 2;
      /**/
      RETURN v_cur;
   EXCEPTION
      /**/
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_prefijospaises;

   FUNCTION f_get_estparpersonas(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcvisible IN NUMBER,
      ptots IN NUMBER,
      pcur OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' - pcagente: ' || pcagente
            || ' - ptots: ' || ptots;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_Parpersona';
      squery         VARCHAR2(5000);
   BEGIN
      IF psperson IS NULL
         OR ptots IS NULL THEN
         RAISE e_param_error;
      END IF;

      /*vnumerr := pac_md_persona.f_get_parpersona(psperson, pcagente, pcvisible, ptots,
                                                    'EST', pctipper, pcur, mensajes);
      */
      vnumerr := pac_md_persona.f_get_parpersona(psperson, pcagente, pcvisible, ptots, 'EST',
                                                 NULL, pcur, mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_estparpersonas;

   FUNCTION f_ins_estparpersonas(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      pnvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' - pcagente: ' || pcagente
            || ' - pcparam: ' || pcparam || ' - pnvalpar: ' || pnvalpar || ' - ptvalpar: '
            || ptvalpar || ' - pfvalpar: ' || pfvalpar;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Ins_Parpersona';
   BEGIN
      IF psperson IS NULL
         OR pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_ins_parpersona(psperson,
                                                 NVL(pcagente, pac_md_common.f_get_cxtagente),
                                                 pcparam, pnvalpar, ptvalpar, pfvalpar, 'EST',
                                                 mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_ins_estparpersonas;

   /*************************************************************************
   Esborra el paràmetre per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in pcparam    : Codi parametre
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_del_estparpersonas(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psperson: ' || psperson || ' - pcagente: ' || pcagente
            || ' - pcparam: ' || pcparam;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Del_Parpersona';
   BEGIN
      IF psperson IS NULL
         OR pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_del_parpersona(psperson,
                                                 NVL(pcagente, pac_md_common.f_get_cxtagente),
                                                 pcparam, 'EST', mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
     END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_estparpersonas;

   --Ini AP - CONF-190
     FUNCTION f_get_regimenfiscal(
      pcagente IN NUMBER,
      poregimenfiscal OUT ob_iax_regimenfiscal,
      mensajes OUT t_iax_mensajes,
      ptablas IN VARCHAR2)
      RETURN NUMBER IS
      psperson       NUMBER;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500)
         := 'parametros - psperson: ' || psperson || ' pcagente = ' || pcagente
            || ' ptablas = ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_regimenfiscal';
      vpasexec       NUMBER(8) := 1;
      v_fefecto      DATE;
      v_cagente      NUMBER;

      CURSOR c_agentes IS
          SELECT sperson
            FROM agentes
           WHERE cagente = pcagente;

      CURSOR c_regimenfiscal IS
          SELECT fefecto, cagente
            FROM per_regimenfiscal
           WHERE sperson = psperson
             AND fefecto = (SELECT MAX(fefecto)
                              FROM per_regimenfiscal
                             WHERE sperson = psperson);

   BEGIN

      OPEN  c_agentes;
        FETCH c_agentes INTO psperson;
      CLOSE   c_agentes;

      OPEN  c_regimenfiscal;
        FETCH c_regimenfiscal INTO v_fefecto, v_cagente;
      CLOSE   c_regimenfiscal;

      vnumerr := pac_md_persona.f_get_regimenfiscal(psperson, v_cagente, v_fefecto,
                                                    poregimenfiscal, mensajes, ptablas);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_get_regimenfiscal;
--Fi AP - CONF-190
FUNCTION f_del_datsarlatf(
      pssarlaft IN NUMBER,
      pfradica IN DATE,
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      i              NUMBER := 1;
      verr           ob_error;
      vpasexec       NUMBER;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_del_datsarlatf';
   BEGIN
      RETURN pac_md_persona.f_del_datsarlatf(pssarlaft, pfradica, psperson, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_datsarlatf;

   FUNCTION f_get_datsarlatf(
      pssarlaft IN NUMBER,
      pfradica IN DATE,
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_get_datsarlatf';
      vparam         VARCHAR2(500) := '';
   BEGIN
      v_cursor := pac_md_persona.f_get_datsarlatf(pssarlaft, pfradica, psperson, mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_datsarlatf;

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
      pemp_tmailrepl        IN VARCHAR2  DEFAULT NULL,
      pemp_tdirsrepl IN VARCHAR2 DEFAULT NULL,
      pemp_cciurrepl IN NUMBER DEFAULT NULL,
      pemp_tciurrepl IN VARCHAR2,
      pemp_cdeprrepl IN NUMBER DEFAULT NULL,
      pemp_tdeprrepl IN VARCHAR2,
      pemp_cpairrepl IN NUMBER DEFAULT NULL,
      pemp_tpairrepl IN VARCHAR2,
      pemp_ttelrepl           IN NUMBER DEFAULT NULL,
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
      mensajes OUT t_iax_mensajes)   -- CP0727M_SYS_PERS_Val - Inc. 2169 - ACL - 23/11/2018
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_set_001';
      cont           NUMBER;
   BEGIN
      RETURN pac_md_persona.f_set_datsarlatf(pssarlaft, pfradica, psperson, pfdiligencia,
                                             pcauttradat, pcrutfcc, pcestconf, pfconfir,
                                             pcvinculacion, ptvinculacion, per_cdeptosol, per_tdeptosol, per_cciusol, per_tciusol,
                                             pcvintomase, ptvintomase,
                                             pcvintomben, ptvintombem, pcvinaseben,
                                             ptvinasebem, pcactippal, ppersectorppal, pnciiuppal, ptcciiuppal, ppertipoactivppal, ptocupacion,
                                             ptcargo, ptempresa, ptdirempresa, ppercdeptoofic, ppertdeptoofic, ppercciuofic, ppertciuofic, pttelempresa,
                                             pcactisec, pnciiusec, ptcciiusec, ptdirsec, pttelsec,
                                             ptprodservcom, piingresos, piactivos,
                                             pipatrimonio, piegresos, pipasivos,
                                             piotroingreso, ptconcotring, pcmanrecpub,
                                             pcpodpub, pcrecpub, pcvinperpub, ptvinperpub,
                                             pcdectribext, ptdectribext, ptorigfond,
                                             pctraxmodext, pttraxmodext, pcprodfinext,
                                             pcctamodext, ptotrasoper, pcreclindseg,
                                             ptciudadsuc, ptpaisuc, ptdepatamentosuc, ptciudad, ptdepatamento, ptpais,
                                             ptlugarexpedidoc, presociedad, ptnacionali2,
                                             pngradopod, pngozrec, pnparticipa, pnvinculo,
                                             pntipdoc, pfexpedicdoc, pfnacimiento, pnrazonso,
                                             ptnit, ptdv, ptoficinapri, pttelefono, ptfax,
                                             ptsucursal, pttelefonosuc, ptfaxsuc, pctipoemp,
                                             ptcualtemp, ptsector, pcciiu, ptactiaca, ptmailjurid,
                                             ptrepresentanle, ptsegape, ptnombres, ptnumdoc,
                                             ptlugnaci, ptnacionali1, ptindiquevin,
                                             pper_papellido, pper_sapellido, pper_nombres,
                                             pper_tipdocument, pper_document,
                                             pper_fexpedicion, pper_lugexpedicion,
                                             pper_fnacimi, pper_lugnacimi, pper_nacion1,
                                             pper_direreci, pper_pais, pper_ciudad,
                                             pper_departament, pper_email, pper_telefono,
                                             pper_celular, pnrecpub, ptpresetreclamaci,
                                             pper_tlugexpedicion, pper_tlugnacimi,
                                             pper_tnacion1, pper_tnacion2, pper_tpais,
                                             pper_tdepartament, pper_tciudad, pemptpais,
                                             pemptdepatamento, pemptciudad, pemptpaisuc,
                                             pemptdepatamentosuc, pemptciudadsuc,
                                             pemptlugnaci, pemptnacionali1, pemptnacionali2,
                                             pcsujetooblifacion, ptindiqueoblig, pper_paisexpedicion,
                                             pper_tpaisexpedicion, pper_depexpedicion,
                                             pper_tdepexpedicion, pper_paislugnacimi,
                                             pper_tpaislugnacimi, pper_deplugnacimi,
                                             pper_tdeplugnacimi, pemp_paisexpedicion,
                                             pemp_tpaisexpedicion, pemp_depexpedicion,
                                             pemp_tdepexpedicion, pemp_paislugnacimi,
                                             pemp_tpaislugnacimi, pemp_deplugnacimi,
                                             pemp_tdeplugnacimi, pemp_lugnacimi,
                                             pemp_tlugnacimi, pemp_fexpedicion,
                                             pemp_lugexpedicion, pemp_tlugexpedicion,
                                             pper_nacion2, pper_pcciusol, pper_pcsucursal,
                                             pper_pctipsol , pper_pcsector , pper_pctipact , pper_pcciuofc ,
                                             pper_pcdepofc , pemp_tmailrepl, pemp_tdirsrepl,
                                             pemp_cciurrepl, pemp_tciurrepl, pemp_cdeprrepl, pemp_tdeprrepl, pemp_cpairrepl, pemp_tpairrepl,
                                             pemp_ttelrepl               , pemp_tcelurepl, pcdeptoentrev, ptdeptoentrev, pcciuentrev, ptciuentrev,
                                             pfentrevista ,pthoraentrev ,ptagenentrev ,ptasesentrev ,
                                             ptobseentrev ,pcrestentrev ,ptobseconfir ,pthoraconfir ,ptemplconfir ,pcorigenfon,pcclausula1,pcclausula2,pcconfir, mensajes );    -- CP0727M_SYS_PERS_Val - Inc. 2169 - ACL - 23/11/2018 -IAXIS-3287 01/04/2019
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_datsarlatf;

   FUNCTION f_del_detsarlatf_dec(
      pndeclara IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      i              NUMBER := 1;
      verr           ob_error;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_set_001';
   BEGIN
      RETURN pac_md_persona.f_del_detsarlatf_dec(pndeclara, psperson, pssarlaft, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_detsarlatf_dec;

   FUNCTION f_get_detsarlatf_dec(
      pndeclara IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_get_detsarlatf_dec';
      vparam         VARCHAR2(500) := '';
   BEGIN
      v_cursor := pac_md_persona.f_get_detsarlatf_dec(pndeclara, psperson, pssarlaft,
                                                      mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_detsarlatf_dec;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_set_001';
      cont           NUMBER;
   BEGIN
      RETURN pac_md_persona.f_set_detsarlatf_dec(pndeclara, psperson, pssarlaft, pctipoid,
                                                 pcnumeroid, ptnombre, pcmanejarec,
                                                 pcejercepod, pcgozarec, pcdeclaraci,
                                                 pcdeclaracicual, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_detsarlatf_dec;

   FUNCTION f_del_detsarlatf_act(
      pnactivi IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      i              NUMBER := 1;
      verr           ob_error;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_del_detsarlatf_act';
   BEGIN
      RETURN pac_md_persona.f_del_detsarlatf_act(pnactivi, psperson, pssarlaft, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_detsarlatf_act;

   FUNCTION f_get_detsarlatf_act(
      pnactivi IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_get_detsarlatf_act';
      vparam         VARCHAR2(500) := '';
   BEGIN
      v_cursor := pac_md_persona.f_get_detsarlatf_act(pnactivi, psperson, pssarlaft, mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_detsarlatf_act;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_set_001';
      cont           NUMBER;
   BEGIN
      RETURN pac_md_persona.f_set_detsarlatf_act(pnactivi, psperson, pssarlaft, pctipoprod,
                                                 pcidnumprod, ptentidad, pcmonto, pcciudad,
                                                 pcpais, pcmoneda, pscpais, pstdepb, ptdepb,
                                                 pscciudad, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_detsarlatf_act;

   FUNCTION f_del_detsarlaft_rec(
      pnrecla IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      i              NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      verr           ob_error;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_set_001';
   BEGIN
      RETURN pac_md_persona.f_del_detsarlaft_rec(pnrecla, psperson, pssarlaft, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_detsarlaft_rec;

   FUNCTION f_get_detsarlaft_rec(
      pnrecla IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_get_detsarlaft_rec';
      vparam         VARCHAR2(500) := '';
   BEGIN
      v_cursor := pac_md_persona.f_get_detsarlaft_rec(pnrecla, psperson, pssarlaft, mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_detsarlaft_rec;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_set_001';
      cont           NUMBER;
   BEGIN
      RETURN pac_md_persona.f_set_detsarlaft_rec(pnrecla, psperson, pssarlaft, pcanio, pcramo,
                                                 ptcompania, pcvalor, ptresultado, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_detsarlaft_rec;
   /************************************************************************
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
      RETURN NUMBER
                IS
                  vnumerr  NUMBER (8):=0;
                  vpasexec NUMBER (8):=1;
                  vparam   VARCHAR2 (500):='parámetros - pcempres: '|| pcempres||' psperson:'||psperson
                             ||' pcmarca:'||pcmarca||' pnmovimi:'||pnmovimi;
                  vobject  VARCHAR2 (200):='PAC_IAX_PERSONA.f_get_permarca';
                  objpers  T_IAX_PERSONAS;
                BEGIN
                    IF pcempres IS NULL OR psperson IS NULL  OR
                       pcmarca IS NULL THEN
                      RAISE e_param_error;
                    END IF;

                    vnumerr:=pac_md_persona.f_get_permarca(pcempres, psperson, pcmarca, pnmovimi, ppermarca, mensajes, 'POL');

                    IF vnumerr<>0 THEN
                      RAISE e_object_error;
                    END IF;

                    RETURN vnumerr;
                EXCEPTION
                  WHEN e_param_error THEN
                             pac_iobj_mensajes.p_tratarmensaje (mensajes, vobject, 1000006, vpasexec, vparam);

                             RETURN 1; WHEN e_object_error THEN
                             pac_iobj_mensajes.p_tratarmensaje (mensajes, vobject, 1000005, vpasexec, vparam);

                             RETURN 1; WHEN OTHERS THEN
                             pac_iobj_mensajes.p_tratarmensaje (mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

                             RETURN 1;
                END f_get_permarca;

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
      mensajes IN OUT t_iax_mensajes) RETURN NUMBER
                IS
                  vnumerr  NUMBER (8):=0;
                  vpasexec NUMBER (8):=1;
                  vparam   VARCHAR2 (500):='parámetros - pcempres: '|| pcempres||' psperson:'||psperson;
                  vobject  VARCHAR2 (200):='PAC_IAX_PERSONA.f_get_permarcas';
                  objpers  T_IAX_PERSONAS;
                BEGIN
                    IF pcempres IS NULL OR psperson IS NULL THEN
                      RAISE e_param_error;
                    END IF;

                    vnumerr:=pac_md_persona.f_get_permarcas (pcempres, psperson, ppermarcas, mensajes, 'POL');

                    IF vnumerr<>0 THEN
                      RAISE e_object_error;
                    END IF;

                    RETURN vnumerr;
                EXCEPTION
                  WHEN e_param_error THEN
                             pac_iobj_mensajes.p_tratarmensaje (mensajes, vobject, 1000006, vpasexec, vparam);

                             RETURN 1; WHEN e_object_error THEN
                             pac_iobj_mensajes.p_tratarmensaje (mensajes, vobject, 1000005, vpasexec, vparam);

                             RETURN 1; WHEN OTHERS THEN
                             pac_iobj_mensajes.p_tratarmensaje (mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

                             RETURN 1;
                END f_get_permarcas;

  FUNCTION f_set_persona_cifin(
      nnumide IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - nnumide: ' || nnumide;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_set_persona_cifin';
   BEGIN
      vnumerr := pac_md_persona.f_set_persona_cifin(nnumide,mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_persona_cifin;


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
      mensajes  OUT t_iax_mensajes
    ) RETURN NUMBER IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSSARLAFT: ' || PSSARLAFT;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_set_cpep_sarlatf';
    BEGIN
       vnumerr := pac_md_persona.f_set_cpep_sarlatf(PSSARLAFT, PIDENTIFICACION, PCTIPREL, PTNOMBRE, PCTIPIDEN, PNNUMIDE, PCPAIS, PTPAIS, PTENTIDAD, PTCARGO, PFDESVIN, mensajes);

       IF vnumerr <> 0 THEN
          RAISE e_object_error;
       END IF;

       COMMIT;
       RETURN vnumerr;
    EXCEPTION
       WHEN e_param_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN e_object_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          ROLLBACK;
          RETURN 1;
    END f_set_cpep_sarlatf;

    FUNCTION f_get_cpep_sarlatf(
      PSSARLAFT   IN  NUMBER ,
      mensajes  OUT t_iax_mensajes
    ) RETURN sys_refcursor   IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSSARLAFT: ' || PSSARLAFT;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_cpep_sarlatf';
      v_cursor       sys_refcursor;
    BEGIN
       v_cursor := pac_md_persona.f_get_cpep_sarlatf(PSSARLAFT,mensajes);


       COMMIT;
       RETURN v_cursor;
    EXCEPTION
       WHEN e_param_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          ROLLBACK;
          RETURN NULL;
       WHEN e_object_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          ROLLBACK;
          RETURN NULL;
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          ROLLBACK;
          RETURN NULL;
    END f_get_cpep_sarlatf;

    FUNCTION f_del_cpep_sarlatf(
      PSSARLAFT       IN  NUMBER,
      PIDENTIFICACION IN NUMBER,
      mensajes  OUT t_iax_mensajes
     ) RETURN NUMBER  IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSSARLAFT: ' || PSSARLAFT;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_del_cpep_sarlatf';
    BEGIN
       vnumerr := pac_md_persona.f_del_cpep_sarlatf(PSSARLAFT, PIDENTIFICACION, mensajes);

       IF vnumerr <> 0 THEN
          RAISE e_object_error;
       END IF;

       COMMIT;
       RETURN vnumerr;
    EXCEPTION
       WHEN e_param_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN e_object_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          ROLLBACK;
          RETURN 1;
    END f_del_cpep_sarlatf;



    FUNCTION f_set_caccionista_sarlatf (
      PSSARLAFT   IN NUMBER ,
      PIDENTIFICACION IN  NUMBER,
      PPPARTICI   IN NUMBER,
      PTNOMBRE    IN VARCHAR2,
      PCTIPIDEN   IN NUMBER ,
      PNNUMIDE    IN VARCHAR2 ,
      PCBOLSA     IN NUMBER,
      PCPEP              IN NUMBER,
      PCTRIBUEXT  IN NUMBER,
      mensajes    OUT t_iax_mensajes
    )  RETURN NUMBER IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSSARLAFT: ' || PSSARLAFT;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_set_caccionista_sarlatf';
    BEGIN
       vnumerr := pac_md_persona.f_set_caccionista_sarlatf(PSSARLAFT, PIDENTIFICACION, PPPARTICI, PTNOMBRE, PCTIPIDEN, PNNUMIDE, PCBOLSA, PCPEP, PCTRIBUEXT,mensajes);

       IF vnumerr <> 0 THEN
          RAISE e_object_error;
       END IF;

       COMMIT;
       RETURN vnumerr;
    EXCEPTION
       WHEN e_param_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN e_object_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          ROLLBACK;
          RETURN 1;
    END f_set_caccionista_sarlatf;

    FUNCTION f_get_caccionista_sarlatf (
      PSSARLAFT   IN  NUMBER ,
      mensajes  OUT t_iax_mensajes
    )  RETURN sys_refcursor   IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSSARLAFT: ' || PSSARLAFT;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_caccionista_sarlatf';
      v_cursor       sys_refcursor;
    BEGIN
       v_cursor := pac_md_persona.f_get_caccionista_sarlatf(PSSARLAFT,mensajes);


       COMMIT;
       RETURN v_cursor;
    EXCEPTION
       WHEN e_param_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          ROLLBACK;
          RETURN NULL;
       WHEN e_object_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          ROLLBACK;
          RETURN NULL;
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          ROLLBACK;
          RETURN NULL;
    END f_get_caccionista_sarlatf;

    FUNCTION f_del_caccionista_sarlatf (
      PSSARLAFT       IN  NUMBER,
      PIDENTIFICACION IN NUMBER,
      mensajes  OUT t_iax_mensajes
    )  RETURN NUMBER  IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSSARLAFT: ' || PSSARLAFT;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_del_caccionista_sarlatf';
    BEGIN
       vnumerr := pac_md_persona.f_del_caccionista_sarlatf(PSSARLAFT, PIDENTIFICACION,mensajes);

       IF vnumerr <> 0 THEN
          RAISE e_object_error;
       END IF;

       COMMIT;
       RETURN vnumerr;
    EXCEPTION
       WHEN e_param_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN e_object_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          ROLLBACK;
          RETURN 1;
    END f_del_caccionista_sarlatf;


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
    ) RETURN NUMBER  IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSSARLAFT: ' || PSSARLAFT;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_set_accionista_sarlatf';
    BEGIN
       vnumerr := pac_md_persona.f_set_accionista_sarlatf(PSSARLAFT, PIDENTIFICACION,PPPARTICI, PTNOMBRE, PCTIPIDEN, PNNUMIDE, PTSOCIEDAD, PNNUMIDESOC ,mensajes);

       IF vnumerr <> 0 THEN
          RAISE e_object_error;
       END IF;

       COMMIT;
       RETURN vnumerr;
    EXCEPTION
       WHEN e_param_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN e_object_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          ROLLBACK;
          RETURN 1;
    END f_set_accionista_sarlatf;

    FUNCTION f_get_accionista_sarlatf (
      PSSARLAFT   IN  NUMBER ,
      mensajes  OUT t_iax_mensajes
    ) RETURN sys_refcursor  IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSSARLAFT: ' || PSSARLAFT;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_accionista_sarlatf';
      v_cursor       sys_refcursor;
    BEGIN
       v_cursor := pac_md_persona.f_get_accionista_sarlatf(PSSARLAFT,mensajes);


       COMMIT;
       RETURN v_cursor;
    EXCEPTION
       WHEN e_param_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          ROLLBACK;
          RETURN NULL;
       WHEN e_object_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          ROLLBACK;
          RETURN NULL;
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          ROLLBACK;
          RETURN NULL;
    END f_get_accionista_sarlatf;

    FUNCTION f_del_accionista_sarlatf (
      PSSARLAFT       IN  NUMBER,
      PIDENTIFICACION IN NUMBER,
      mensajes        OUT t_iax_mensajes
    ) RETURN NUMBER  IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSSARLAFT: ' || PSSARLAFT;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_del_accionista_sarlatf';
    BEGIN
       vnumerr := pac_md_persona.f_del_accionista_sarlatf(PSSARLAFT,PIDENTIFICACION,mensajes);

       IF vnumerr <> 0 THEN
          RAISE e_object_error;
       END IF;

       COMMIT;
       RETURN vnumerr;
    EXCEPTION
       WHEN e_param_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN e_object_error THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
          ROLLBACK;
          RETURN 1;
       WHEN OTHERS THEN
          pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                            psqcode => SQLCODE, psqerrm => SQLERRM);
          ROLLBACK;
          RETURN 1;
    END f_del_accionista_sarlatf;


    FUNCTION f_get_ultimosestados_sarlatf   (
      PSPERSON   IN  NUMBER ,
      mensajes   OUT t_iax_mensajes
      )  RETURN sys_refcursor   IS

      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - PSPERSON: ' || PSPERSON;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_get_ultimosestados_sarlatf';
      v_cursor       sys_refcursor;
   BEGIN
      v_cursor := pac_md_persona.f_get_ultimosestados_sarlatf(PSPERSON,mensajes);


      COMMIT;
      RETURN v_cursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN NULL;
   END f_get_ultimosestados_sarlatf;

   FUNCTION f_get_persona_sarlaf(
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_get_datsarlatf';
      vparam         VARCHAR2(500) := '';
   BEGIN
      v_cursor := pac_md_persona.f_get_persona_sarlaf(psperson, mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_persona_sarlaf;
--INI--WAJ
/*****************************************************************/
   FUNCTION f_get_impuestos(
      psperson IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes,
      poimpuestos OUT ob_iax_impuestos)
      RETURN NUMBER IS

      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(500)
         := 'parametros - psperson: ' || psperson
            || ' ptablas = ' || ptablas;
      vobject        VARCHAR2(200) := 'PAC_MD_PERSONA.f_get_impuestos';
      vpasexec       NUMBER(8) := 1;
begin
      vnumerr := pac_md_persona.f_get_impuesto(psperson, 0,ptablas, mensajes,
                                                    poimpuestos);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_get_impuestos;
   /*****************************************************************/
   FUNCTION f_del_impuesto(
      psperson IN NUMBER,
      pctipind IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.f_del_impuesto';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_persona.f_del_impuesto(psperson, pctipind, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_impuesto;

    FUNCTION f_get_tipo_vinculacion(
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_get_tipo_vinculacion';
      vparam         VARCHAR2(500) := '';
   BEGIN
      v_cursor := pac_md_persona.f_get_tipo_vinculacion(psperson, mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_tipo_vinculacion;

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
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_PERSONA.F_Get_persona_publica_imp';
      objpers        ob_iax_personas := ob_iax_personas();
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      obpersona := pac_md_persona.f_get_persona_publica_imp(psperson, pctipage, mensajes);

      IF obpersona IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN 0;
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
   END f_get_persona_publica_imp;
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
   FUNCTION f_get_parpersona_cont(
      psperson IN NUMBER,
      pcparam IN  VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_get_parpersona_cont';
      vparam         VARCHAR2(500) := 'psperson = ' || psperson || ' - pcparam = ' || pcparam;
   BEGIN
      v_cursor := pac_md_persona.f_get_parpersona_cont(psperson, pcparam, mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_parpersona_cont;

   /*************************************************************************
    FUNCTION f_get_cupo_persona
    Permite obtener el cupo asignado en ficha financiera de la persona
    param in psperson    : codigo de la persona
    param out mensajes   : mesajes de error
    return               : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_cupo_persona(
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_get_cupo_persona';
      vparam         VARCHAR2(500) := 'psperson = ' || psperson;
      vnumerr   NUMBER := 0;
   BEGIN
    v_cursor := pac_md_persona.f_get_cupo_persona(psperson, mensajes);
    RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cupo_persona;
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
     mensajes      OUT t_iax_mensajes) 
      RETURN NUMBER IS
      -- 
      vnumerr  NUMBER := 0;
      vobject  VARCHAR2(200) := 'PAC_IAX_PERSONA.f_duplicar_sarlaft';
      vparam   VARCHAR2(500) := 'pssarlaft = ' || pssarlaft;
      vpasexec NUMBER := 0;
      vmensa   VARCHAR2(2000);
      --
    BEGIN
      IF pssarlaft IS NULL
      THEN
         RAISE e_param_error;
      END IF;
      vpasexec := 1;
      vnumerr  := pac_md_persona.f_duplicar_sarlaft(pssarlaft, pssarlaftdest, mensajes );
      vpasexec := 2;
      
      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;
      
      vpasexec := 3;
      -- Aprobamos los cambios si todo ha salido bien.
      IF vnumerr = 0
      THEN
         /* retorna como mensaje el nuevo documento Sarlaft creada*/
         vmensa := pac_iobj_mensajes.f_get_descmensaje(89906257,
                                                       pac_md_common.f_get_cxtidioma);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0,
                                              vmensa || pssarlaftdest);
      END IF;
      
      COMMIT;
      RETURN vnumerr;  
    EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
    END;
    -- Fin IAXIS-3287 01/04/2019
                --INI IAXIS-3670 16/04/2019 AP
    /*************************************************************************
    FUNCTION f_valida_consorcios
    Permite obtener el cupo asignado en ficha financiera de la persona
    param in psperson    : codigo de la persona
    param out mensajes   : mesajes de error
    return               : sys_refcursor
   *************************************************************************/
   FUNCTION f_valida_consorcios(
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_IAX_persona.f_valida_consorcios';
      vparam         VARCHAR2(500) := 'psperson = ' || psperson;
      vnumerr   NUMBER := 0;
      v_pparticipacion NUMBER := 0;
   BEGIN
    vnumerr := pac_md_persona.f_valida_consorcios(psperson, mensajes);
    
    --  INI IAXIS-3670  10/02/2020  CJMR
    --IF vnumerr <> 0 THEN
    --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
    --END IF;
    --  FIN IAXIS-3670  10/02/2020  CJMR
    
    RETURN vnumerr;
  EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_valida_consorcios;
   --FIN IAXIS-3670 16/04/2019 AP

	/*************************************************************************
	For IAXIS-4149 by PK-18/07/2019
	FUNCTION F_GET_CODITIPOBANC : Nueva funcion para obtener tipo de CUENTA.
		PCBANCO Código de Banco.
		PCTIPCC Que tipo de cuenta és.
	return              : 0 si ha ido bien, 1 si ha ido mal.
	*************************************************************************/
	FUNCTION F_GET_CODITIPOBANC(PCBANCO IN NUMBER,
							PCTIPCC  IN VARCHAR2,
							PCTIPBAN OUT NUMBER) RETURN NUMBER IS
		vnumerr   NUMBER(8) := 0;
		VTRAZA    NUMBER := 0;
		vparam    VARCHAR2(500) := 'parametros - PCBANCO: ' || PCBANCO || ' PCTIPCC' || PCTIPCC;
		vobject   VARCHAR2(200) := 'PAC_IAX_PERSONA.F_GET_CODITIPOBANC';
		--
	BEGIN
		IF PCBANCO IS NULL OR PCTIPCC IS NULL THEN
			RAISE e_object_error;
		END IF;
		--
		vnumerr := PAC_MD_PERSONA.F_GET_CODITIPOBANC(PCBANCO, PCTIPCC, PCTIPBAN);
		--
		IF vnumerr <> 0 THEN
			RAISE e_object_error;
		END IF;
		--
		RETURN vnumerr;
		--
	EXCEPTION
		WHEN e_object_error THEN
			P_TAB_ERROR(F_SYSDATE, F_USER, vobject, VTRAZA, 'Error en PAC_IAX_PERSONA.F_GET_CODITIPOBANC', 'Error : ' || SQLERRM);
			RETURN 1;
		WHEN OTHERS THEN
			P_TAB_ERROR(F_SYSDATE, F_USER, vobject, VTRAZA, 'Error en PAC_IAX_PERSONA.F_GET_CODITIPOBANC', 'Error : ' || SQLERRM);
			RETURN 1;
	END F_GET_CODITIPOBANC;

END pac_iax_persona;

/